Shader "Custom/Pixelation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PixelSize ("Pixel Size", Range(1, 128)) = 32
        _ColorLevels ("Color Levels", Range(2, 256)) = 32
        _DarkestColor ("Darkest Color", Color) = (0, 0, 0, 1)
        _BrightestColor ("Brightest Color", Color) = (1, 1, 1, 1)
        _Contrast ("Contrast", Range(0, 2)) = 1
        _Brightness ("Brightness", Range(0, 2)) = 1
        [Toggle] _Dithering ("Enable Dithering", Float) = 0
        _DitheringStrength ("Dithering Strength", Range(0, 1)) = 0.1
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
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float _PixelSize;
                float _ColorLevels;
                float4 _DarkestColor;
                float4 _BrightestColor;
                float _Contrast;
                float _Brightness;
                float _Dithering;
                float _DitheringStrength;
            CBUFFER_END

            float Posterize(float value, float levels)
            {
                return floor(value * levels) / levels;
            }

            float GetDither(float2 screenPos)
            {
                float2 uv = screenPos.xy * _ScreenParams.xy;
                float DITHER_THRESHOLDS[16] =
                {
                    0.0588, 0.5294, 0.1176, 0.5882,
                    0.7647, 0.2941, 0.8235, 0.3529,
                    0.1765, 0.6471, 0.0588, 0.5294,
                    0.8824, 0.4118, 0.9412, 0.4706
                };
                int index = (int(uv.x) % 4) * 4 + int(uv.y) % 4;
                return DITHER_THRESHOLDS[index];
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.screenPos = ComputeScreenPos(OUT.positionHCS);
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float2 pixelatedUV = floor(IN.uv * _PixelSize) / _PixelSize;
                float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, pixelatedUV);
                
                color.rgb = lerp(_DarkestColor.rgb, _BrightestColor.rgb, color.rgb);
                color.rgb = (color.rgb - 0.5) * _Contrast + 0.5;
                color.rgb *= _Brightness;

                if (_Dithering > 0.5)
                {
                    float dither = GetDither(IN.screenPos.xy / IN.screenPos.w);
                    color.rgb += (dither - 0.5) * _DitheringStrength;
                }
                
                color.r = Posterize(color.r, _ColorLevels);
                color.g = Posterize(color.g, _ColorLevels);
                color.b = Posterize(color.b, _ColorLevels);
                
                return color;
            }
            ENDHLSL
        }
    }
}