Shader "Custom/XRay"
{
    Properties
    {
        [HDR] _XRayColor ("X-Ray Color", Color) = (0, 1, 0.8, 1)
        _EdgeWidth ("Edge Width", Range(0, 2)) = 1
        _EdgeIntensity ("Edge Intensity", Range(0, 5)) = 1
        _ScanLineSpeed ("Scan Speed", Range(0, 10)) = 1
        _ScanLineCount ("Scan Line Count", Range(0, 100)) = 30
        _ScanLineIntensity ("Scan Line Intensity", Range(0, 1)) = 0.5
        _NoiseScale ("Noise Scale", Range(0, 100)) = 50
        _NoiseIntensity ("Noise Intensity", Range(0, 1)) = 0.2
        _FresnelPower ("Fresnel Power", Range(0, 5)) = 2
        _IntersectPower ("Intersection Power", Range(1, 10)) = 2
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline" }
        
        Pass
        {
            ZTest Greater
            ZWrite Off
            Blend One One

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float3 viewDirWS : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _XRayColor;
                float _EdgeWidth;
                float _EdgeIntensity;
                float _ScanLineSpeed;
                float _ScanLineCount;
                float _ScanLineIntensity;
                float _NoiseScale;
                float _NoiseIntensity;
                float _FresnelPower;
                float _IntersectPower;
            CBUFFER_END

            float random(float2 st)
            {
                return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.viewDirWS = GetWorldSpaceViewDir(TransformObjectToWorld(IN.positionOS.xyz));
                OUT.screenPos = ComputeScreenPos(OUT.positionHCS);
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float3 normalWS = normalize(IN.normalWS);
                float3 viewDirWS = normalize(IN.viewDirWS);
                float fresnel = pow(1.0 - saturate(dot(normalWS, viewDirWS)), _FresnelPower);
                
                float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
                float scanLine = sin(screenUV.y * _ScanLineCount + _Time.y * _ScanLineSpeed);
                scanLine = saturate(scanLine * _ScanLineIntensity + (1 - _ScanLineIntensity));
                
                float2 noiseUV = screenUV * _NoiseScale;
                float noise = random(noiseUV + _Time.y);
                noise = lerp(1, noise, _NoiseIntensity);
                
                float sceneDepth = LinearEyeDepth(SampleSceneDepth(screenUV), _ZBufferParams);
                float surfaceDepth = LinearEyeDepth(IN.positionHCS.z, _ZBufferParams);
                float intersect = pow(1 - saturate((sceneDepth - surfaceDepth) * _IntersectPower), 2);
                
                float edge = saturate(fresnel * _EdgeWidth) * _EdgeIntensity;
                float4 finalColor = _XRayColor;
                finalColor.rgb *= (edge + intersect) * scanLine * noise;
                
                return finalColor;
            }
            ENDHLSL
        }
    }
}