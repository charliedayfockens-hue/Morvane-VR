Shader "Custom/Hologram"
{
    Properties
    {
        [MainTexture] _MainTex("Texture", 2D) = "white" {}
        [HDR] _HoloColor("Hologram Color", Color) = (0, 1, 0.95, 1)
        _RimPower("Rim Power", Range(0, 10)) = 3
        _FlickerSpeed("Flicker Speed", Range(0, 50)) = 30
        _FlickerIntensity("Flicker Intensity", Range(0, 1)) = 0.1
        _ScanlineSpeed("Scanline Speed", Range(0, 50)) = 10
        _ScanlineCount("Scanline Count", Range(1, 100)) = 30
        _ScanlineIntensity("Scanline Intensity", Range(0, 1)) = 0.1
        _Transparency("Transparency", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "RenderPipeline" = "UniversalPipeline" }
        
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Back

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _HoloColor;
                float _RimPower;
                float _FlickerSpeed;
                float _FlickerIntensity;
                float _ScanlineSpeed;
                float _ScanlineCount;
                float _ScanlineIntensity;
                float _Transparency;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.viewDirWS = GetWorldSpaceViewDir(TransformObjectToWorld(IN.positionOS.xyz));
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                
                float rim = 1.0 - saturate(dot(normalize(IN.normalWS), normalize(IN.viewDirWS)));
                float rimIntensity = pow(rim, _RimPower);
                
                float flicker = sin(_Time.y * _FlickerSpeed) * 0.5 + 0.5;
                flicker = 1 - (_FlickerIntensity * flicker);
                
                float scanline = sin(IN.uv.y * _ScanlineCount + _Time.y * _ScanlineSpeed) * 0.5 + 0.5;
                scanline = 1 - (_ScanlineIntensity * scanline);
                
                float4 col = _HoloColor;
                col.rgb *= texColor.rgb;
                col.rgb *= flicker;
                col.rgb *= scanline;
                col.rgb += _HoloColor.rgb * rimIntensity * 2;
                
                col.a = texColor.a * _Transparency;
                col.a *= (rimIntensity * 0.5 + 0.5);
                col.a *= flicker;
                
                return col;
            }
            ENDHLSL
        }
    }
}