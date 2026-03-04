Shader "Custom/ForceField"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (0.2, 0.5, 1, 0.2)
        _IntersectColor ("Intersection Color", Color) = (1, 1, 1, 1)
        [HDR] _RimColor ("Rim Color", Color) = (1, 2, 4, 1)
        _RimPower ("Rim Power", Range(0, 10)) = 2
        _HexScale ("Hex Pattern Scale", Range(1, 100)) = 15
        _ScrollSpeed ("Pattern Scroll Speed", Range(-10, 10)) = 1
        _PulseSpeed ("Pulse Speed", Range(0, 10)) = 1
        _PulseAmplitude ("Pulse Amplitude", Range(0, 1)) = 0.2
        _IntersectPower ("Intersection Power", Range(0, 10)) = 2
        _Transparency ("Transparency", Range(0, 1)) = 0.5
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

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewDirWS : TEXCOORD1;
                float3 normalWS : NORMAL;
                float4 screenPos : TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _MainColor;
                float4 _IntersectColor;
                float4 _RimColor;
                float _RimPower;
                float _HexScale;
                float _ScrollSpeed;
                float _PulseSpeed;
                float _PulseAmplitude;
                float _IntersectPower;
                float _Transparency;
            CBUFFER_END

            float2 hexagonUV(float2 uv) 
            {
                float2 hexUV = uv * float2(2.0, 1.7320508);
                float2 gridID = floor(hexUV);
                float2 gridUV = frac(hexUV);
                
                float2 temp = gridUV - float2(0.5, 0.5);
                float2 pointA = float2(0.5, 0.866);
                float2 pointB = float2(1.0, 0.0);
                
                if (dot(temp, temp) > 0.5) {
                    float2 offset = float2(
                        step(0.0, temp.x) * 2.0 - 1.0,
                        step(0.0, temp.y) * 2.0 - 1.0
                    );
                    gridID += offset;
                    gridUV -= offset;
                }
                
                return gridID;
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformWorldToHClip(positionWS);
                OUT.uv = IN.uv;
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.viewDirWS = GetWorldSpaceViewDir(positionWS);
                OUT.screenPos = ComputeScreenPos(OUT.positionHCS);
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
                float sceneDepth = LinearEyeDepth(SampleSceneDepth(screenUV), _ZBufferParams);
                float surfaceDepth = LinearEyeDepth(IN.positionHCS.z, _ZBufferParams);
                float intersect = 1 - saturate((sceneDepth - surfaceDepth) * _IntersectPower);

                float2 hexUV = IN.uv * _HexScale;
                hexUV.y += _Time.y * _ScrollSpeed;
                float2 hex = hexagonUV(hexUV);
                float hexPattern = frac(hex.x * 0.5 + hex.y * 0.5);
                
                float rim = pow(1.0 - saturate(dot(normalize(IN.normalWS), normalize(IN.viewDirWS))), _RimPower);
                float pulse = sin(_Time.y * _PulseSpeed) * _PulseAmplitude + (1 - _PulseAmplitude);

                float4 col = _MainColor;
                col.rgb += _RimColor.rgb * rim;
                col.rgb += _IntersectColor.rgb * intersect;
                col.rgb *= lerp(0.8, 1.2, hexPattern) * pulse;
                col.a = _Transparency;
                col.a = saturate(col.a + rim + intersect);

                return col;
            }
            ENDHLSL
        }
    }
}