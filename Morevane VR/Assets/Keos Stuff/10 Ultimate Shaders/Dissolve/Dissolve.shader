Shader "Custom/Dissolve"
{
    Properties
    {
        [MainTexture] _MainTex ("Texture", 2D) = "white" {}
        [MainColor] _Color ("Color", Color) = (1,1,1,1)
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _EdgeColor1 ("Edge Color 1", Color) = (1,0,0,1)
        _EdgeColor2 ("Edge Color 2", Color) = (1,1,0,1)
        _Level ("Dissolution Level", Range(0, 1)) = 0
        _EdgeWidth ("Edge Width", Range(0, 1)) = 0.1
        _Smoothness ("Smoothness", Range(0, 1)) = 0.1
        [HDR] _EmissionColor ("Emission Color", Color) = (0,0,0,1)
        _EmissionStr ("Emission Strength", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
                float2 noiseUV : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);
            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_NoiseTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _NoiseTex_ST;
                float4 _Color;
                float4 _EdgeColor1;
                float4 _EdgeColor2;
                float4 _EmissionColor;
                float _Level;
                float _EdgeWidth;
                float _Smoothness;
                float _EmissionStr;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.noiseUV = TRANSFORM_TEX(IN.uv, _NoiseTex);
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Color;
                float noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, IN.noiseUV).r;
                
                float dissolveValue = noise - _Level;
                float edgeLower = _Level - _EdgeWidth;
                float edgeUpper = _Level;
                
                float edgeLerp = saturate((dissolveValue - edgeLower) / (edgeUpper - edgeLower));
                float4 edgeColor = lerp(_EdgeColor2, _EdgeColor1, edgeLerp);
                
                clip(dissolveValue);
                
                float emissionMask = 1 - smoothstep(0, _Smoothness, dissolveValue);
                float4 finalColor = lerp(edgeColor, baseColor, edgeLerp);
                finalColor.rgb += _EmissionColor.rgb * emissionMask * _EmissionStr;
                
                return finalColor;
            }
            ENDHLSL
        }
    }
}