Shader "Custom/Portal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _PortalColor ("Portal Color", Color) = (0.5, 2, 3, 1)
        _NoiseTexture ("Noise Texture", 2D) = "white" {}
        _DistortionSpeed ("Distortion Speed", Range(0, 10)) = 2
        _DistortionAmount ("Distortion Amount", Range(0, 1)) = 0.3
        _SwirlStrength ("Swirl Strength", Range(0, 50)) = 10
        _SwirlSpeed ("Swirl Speed", Range(0, 10)) = 2
        _RimPower ("Rim Power", Range(0, 10)) = 2
        _AlphaClip ("Alpha Clip", Range(0, 1)) = 0.5
        [Toggle] _UseDepth ("Use Depth", Float) = 1
        _DepthDistance ("Depth Distance", Range(0, 2)) = 0.5
        [HDR] _EdgeGlowColor ("Edge Glow Color", Color) = (2, 0.5, 4, 1)
        _EdgeGlowWidth ("Edge Glow Width", Range(0, 1)) = 0.2
        _EdgeGlowSharpness ("Edge Glow Sharpness", Range(0, 10)) = 5
        _EdgeGlowPulse ("Edge Pulse Speed", Range(0, 10)) = 2
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline" }
        
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                float3 normalWS : NORMAL;
                float3 viewDirWS : TEXCOORD2;
            };

            TEXTURE2D(_MainTex);
            TEXTURE2D(_NoiseTexture);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_NoiseTexture);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _NoiseTexture_ST;
                float4 _PortalColor;
                float _DistortionSpeed;
                float _DistortionAmount;
                float _SwirlStrength;
                float _SwirlSpeed;
                float _RimPower;
                float _AlphaClip;
                float _UseDepth;
                float _DepthDistance;
                float4 _EdgeGlowColor;
                float _EdgeGlowWidth;
                float _EdgeGlowSharpness;
                float _EdgeGlowPulse;
            CBUFFER_END

            float2 RotateUV(float2 uv, float rotation)
            {
                float2 pivot = float2(0.5, 0.5);
                float cosAngle = cos(rotation);
                float sinAngle = sin(rotation);
                float2 rotated = float2(
                    cosAngle * (uv.x - pivot.x) - sinAngle * (uv.y - pivot.y),
                    sinAngle * (uv.x - pivot.x) + cosAngle * (uv.y - pivot.y)
                );
                return rotated + pivot;
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.screenPos = ComputeScreenPos(OUT.positionHCS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.viewDirWS = GetWorldSpaceViewDir(TransformObjectToWorld(IN.positionOS.xyz));
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float2 centerUV = IN.uv - 0.5;
                float distanceFromCenter = length(centerUV);
                float swirl = _Time.y * _SwirlSpeed;
                
                float2 swirlUV = RotateUV(IN.uv, distanceFromCenter * _SwirlStrength + swirl);
                
                float2 noiseUV = swirlUV * 2 + _Time.y * _DistortionSpeed;
                float noise = SAMPLE_TEXTURE2D(_NoiseTexture, sampler_NoiseTexture, noiseUV).r;
                
                float2 distortedUV = IN.uv + centerUV * noise * _DistortionAmount;
                float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, distortedUV);
                
                float rim = 1.0 - saturate(dot(normalize(IN.normalWS), normalize(IN.viewDirWS)));
                rim = pow(rim, _RimPower);
                
                float mask = smoothstep(0.5, 0.2, distanceFromCenter);
                
                float edgePulse = (sin(_Time.y * _EdgeGlowPulse) * 0.5 + 0.5) * 0.5 + 0.5;
                float edgeMask = smoothstep(0.5 + _EdgeGlowWidth, 0.5, distanceFromCenter);
                float fadeEdge = pow(1 - mask, _EdgeGlowSharpness) * edgePulse;
                
                if (_UseDepth > 0.5)
                {
                    float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
                    float sceneDepth = LinearEyeDepth(SampleSceneDepth(screenUV), _ZBufferParams);
                    float surfaceDepth = LinearEyeDepth(IN.positionHCS.z, _ZBufferParams);
                    float depthDiff = saturate((sceneDepth - surfaceDepth) / _DepthDistance);
                    mask *= depthDiff;
                    fadeEdge *= depthDiff;
                }
                
                float4 col = _PortalColor;
                col.rgb *= mainTex.rgb * (1 + noise * 0.5);
                col.rgb += rim * _PortalColor.rgb;
                
                col.rgb += _EdgeGlowColor.rgb * fadeEdge;
                col.a = mask;
                
                clip(col.a - _AlphaClip);
                
                return col;
            }
            ENDHLSL
        }
    }
}