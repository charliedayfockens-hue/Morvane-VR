Shader "Custom/Water"
{
    Properties
    {
        _Color ("Color", Color) = (0.2, 0.5, 0.8, 0.8)
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _NormalStrength ("Normal Strength", Range(0, 2)) = 1
        _WaveSpeed ("Wave Speed", Range(0, 2)) = 0.5
        _WaveScale ("Wave Scale", Range(0, 10)) = 1
        _WaveHeight ("Wave Height", Range(0, 1)) = 0.1
        _FoamTexture ("Foam Texture", 2D) = "white" {}
        _FoamAmount ("Foam Amount", Range(0, 2)) = 1
        _FoamSpeed ("Foam Speed", Range(0, 2)) = 0.5
        _Glossiness ("Smoothness", Range(0, 1)) = 0.9
        _FresnelPower ("Fresnel Power", Range(1, 10)) = 5
        [HDR] _EmissionColor ("Emission Color", Color) = (0,0.2,0.3,1)
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
                float3 normalWS : NORMAL;
                float3 tangentWS : TEXCOORD1;
                float3 bitangentWS : TEXCOORD2;
                float3 viewDirWS : TEXCOORD3;
                float4 screenPos : TEXCOORD4;
            };

            TEXTURE2D(_NormalMap);
            TEXTURE2D(_FoamTexture);
            SAMPLER(sampler_NormalMap);
            SAMPLER(sampler_FoamTexture);

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _NormalMap_ST;
                float4 _FoamTexture_ST;
                float _NormalStrength;
                float _WaveSpeed;
                float _WaveScale;
                float _WaveHeight;
                float _FoamAmount;
                float _FoamSpeed;
                float _Glossiness;
                float _FresnelPower;
                float4 _EmissionColor;
            CBUFFER_END

            float3 GerstnerWave(float4 wave, float3 p, inout float3 tangent, inout float3 binormal)
            {
                float steepness = wave.z;
                float wavelength = wave.w;
                float k = 2 * PI / wavelength;
                float c = sqrt(9.8 / k);
                float2 d = normalize(wave.xy);
                float f = k * (dot(d, p.xz) - c * _Time.y);
                float a = steepness / k;
                
                tangent += float3(
                    -d.x * d.x * steepness * sin(f),
                    d.x * steepness * cos(f),
                    -d.x * d.y * steepness * sin(f)
                );
                binormal += float3(
                    -d.x * d.y * steepness * sin(f),
                    d.y * steepness * cos(f),
                    -d.y * d.y * steepness * sin(f)
                );
                return float3(
                    d.x * (a * cos(f)),
                    a * sin(f),
                    d.y * (a * cos(f))
                );
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 gridPoint = IN.positionOS.xyz;
                float3 tangent = float3(1, 0, 0);
                float3 binormal = float3(0, 0, 1);
                float3 p = gridPoint;
                
                p += GerstnerWave(float4(1, 1, 0.5, 10), gridPoint, tangent, binormal) * _WaveHeight;
                p += GerstnerWave(float4(1, 0.6, 0.3, 8), gridPoint, tangent, binormal) * _WaveHeight;
                
                float3 normal = normalize(cross(binormal, tangent));
                
                OUT.positionHCS = TransformObjectToHClip(p);
                OUT.uv = TRANSFORM_TEX(IN.uv, _NormalMap);
                OUT.normalWS = TransformObjectToWorldNormal(normal);
                OUT.tangentWS = TransformObjectToWorldDir(tangent);
                OUT.bitangentWS = TransformObjectToWorldDir(binormal);
                OUT.viewDirWS = GetWorldSpaceViewDir(TransformObjectToWorld(p));
                OUT.screenPos = ComputeScreenPos(OUT.positionHCS);
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
                float3 viewDir = normalize(IN.viewDirWS);
                
                float2 uvOffset = _Time.y * float2(_WaveSpeed, _WaveSpeed);
                float3 normal1 = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, IN.uv * _WaveScale + uvOffset));
                float3 normal2 = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, IN.uv * _WaveScale * 2 - uvOffset * 0.5));
                float3 normalTS = normalize(normal1 + normal2);
                normalTS.xy *= _NormalStrength;
                normalTS = normalize(normalTS);
                
                float3x3 tangentToWorld = float3x3(
                    normalize(IN.tangentWS),
                    normalize(IN.bitangentWS),
                    normalize(IN.normalWS)
                );
                
                float3 normalWS = mul(normalTS, tangentToWorld);
                float fresnel = pow(1.0 - saturate(dot(normalWS, viewDir)), _FresnelPower);
                
                float2 foamUV = IN.uv * _WaveScale + _Time.y * float2(_FoamSpeed, _FoamSpeed);
                float foam = SAMPLE_TEXTURE2D(_FoamTexture, sampler_FoamTexture, foamUV).r;
                foam = saturate(foam * _FoamAmount);
                
                float4 refraction = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, 
                    screenUV + normalTS.xy * 0.1);
                
                float4 col = _Color;
                col.rgb += _EmissionColor.rgb;
                col.rgb = lerp(col.rgb, float3(1,1,1), foam);
                col.rgb = lerp(refraction.rgb, col.rgb, col.a);
                col.rgb += fresnel * _Color.rgb;
                col.a = saturate(col.a + fresnel + foam);
                
                return col;
            }
            ENDHLSL
        }
    }
}