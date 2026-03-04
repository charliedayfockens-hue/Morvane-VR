Shader "Custom/Glass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,0.2)
        _Smoothness ("Smoothness", Range(0,1)) = 0.95
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _IOR ("Index of Refraction", Range(1.0, 3.0)) = 1.45
        _ChromaticAberration ("Chromatic Aberration", Range(0, 1)) = 0.1
        _FresnelPower ("Fresnel Power", Range(0, 10)) = 5
        _DistortionAmount ("Distortion Amount", Range(0, 1)) = 0.1
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpStrength ("Normal Strength", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline" }
        
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Back

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
                float4 screenPos : TEXCOORD3;
                float3 tangentWS : TEXCOORD4;
                float3 bitangentWS : TEXCOORD5;
            };

            TEXTURE2D(_MainTex);
            TEXTURE2D(_BumpMap);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_BumpMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _BumpMap_ST;
                float4 _Color;
                float _Smoothness;
                float _Metallic;
                float _IOR;
                float _ChromaticAberration;
                float _FresnelPower;
                float _DistortionAmount;
                float _BumpStrength;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.viewDirWS = GetWorldSpaceViewDir(TransformObjectToWorld(IN.positionOS.xyz));
                OUT.screenPos = ComputeScreenPos(OUT.positionHCS);
                
                OUT.tangentWS = TransformObjectToWorldDir(IN.tangentOS.xyz);
                OUT.bitangentWS = cross(OUT.normalWS, OUT.tangentWS) * IN.tangentOS.w;
                
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, IN.uv));
                normalTS.xy *= _BumpStrength;
                
                float3x3 TBN = float3x3(IN.tangentWS, IN.bitangentWS, IN.normalWS);
                float3 normalWS = normalize(mul(normalTS, TBN));
                
                float fresnel = pow(1.0 - saturate(dot(normalize(IN.viewDirWS), normalWS)), _FresnelPower);
                
                float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
                float2 offset = normalWS.xy * _DistortionAmount;
                
                float4 refractionR = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, 
                    screenUV + offset * (1.0 + _ChromaticAberration));
                float4 refractionG = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, 
                    screenUV + offset);
                float4 refractionB = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, 
                    screenUV + offset * (1.0 - _ChromaticAberration));
                
                float4 refraction = float4(refractionR.r, refractionG.g, refractionB.b, 1);
                float4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Color;
                
                float4 finalColor = lerp(refraction, baseColor, baseColor.a);
                finalColor.a = lerp(_Color.a, 1, fresnel);
                
                return finalColor;
            }
            ENDHLSL
        }
    }
}