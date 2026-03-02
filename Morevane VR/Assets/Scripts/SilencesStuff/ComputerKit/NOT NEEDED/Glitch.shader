Shader "Custom/Glitch"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _GlitchIntensity("Glitch Intensity", Range(0, 10)) = 2
        _ScanLineJitter("Scan Line Jitter", Range(0, 10)) = 1
        _VerticalJump("Vertical Jump", Range(0, 10)) = 2
        _HorizontalShake("Horizontal Shake", Range(0, 10)) = 1
        _ColorDrift("Color Drift", Range(0, 10)) = 2
        _BlockSize("Block Size", Range(1, 100)) = 15
        _GlitchInterval("Glitch Interval", Range(1, 50)) = 5
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
                float3 normalWS : TEXCOORD1;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                float _GlitchIntensity;
                float _ScanLineJitter;
                float _VerticalJump;
                float _HorizontalShake;
                float _ColorDrift;
                float _BlockSize;
                float _GlitchInterval;
            CBUFFER_END

            float random(float2 st)
            {
                return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 position = IN.positionOS.xyz;
                
                float glitchValue = step(0.99, random(floor(_Time.y * (_GlitchInterval * 0.1))));
                position.x += glitchValue * (random(IN.positionOS.xz) * 2 - 1) * (_GlitchIntensity * 0.01);
                
                OUT.positionHCS = TransformObjectToHClip(position);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 uv = IN.uv;
                float time = _Time.y;
                
                float jitter = random(float2(time * 1.3, uv.y * 2.0)) * 2.0 - 1.0;
                uv.x += jitter * (_ScanLineJitter * 0.01);

                float jump = lerp(uv.y, frac(uv.y + time), (_VerticalJump * 0.01));
                uv.y = jump;

                uv.x += (random(float2(time * 0.7, 1.0)) * 2.0 - 1.0) * (_HorizontalShake * 0.01);

                float2 uvR = uv + float2((_ColorDrift * 0.01) * random(float2(time * 0.4, 2.0)), 0);
                float2 uvB = uv - float2((_ColorDrift * 0.01) * random(float2(time * 0.4, 3.0)), 0);
                
                half4 colorR = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvR);
                half4 colorG = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                half4 colorB = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvB);

                half4 finalColor = half4(colorR.r, colorG.g, colorB.b, 1);
                
                float blockNoise = random(floor(uv * (_BlockSize * 0.1)) + floor(time * 3));
                float glitchMask = step(0.97, random(float2(time, 2.0)));
                finalColor = lerp(finalColor, half4(blockNoise, blockNoise, blockNoise, 1), (_GlitchIntensity * 0.01) * glitchMask);

                return finalColor * _BaseColor;
            }
            ENDHLSL
        }
    }
}