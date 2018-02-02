Shader "Custom/UI/RGB Effect"
{
	Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _Brightness ("Brightness", Range(-1.0, 1.0)) = 0.0
        _Contrast ("Contrast", Range(-1.0, 1.0)) = 0.0
        _CyanRed ("Cyan - Red", Range(-1.0, 1.0)) = 0.0
        _YellowBlue ("Yellow - Blue", Range(-1.0, 1.0)) = 0.0
        _MagentaGreen ("Magenta - Green", Range(-1.0, 1.0)) = 0.0
        _Hue ("Hue", Range(-1.0, 1.0)) = 0.0
        _Saturation ("Saturation", Range(-1.0, 1.0)) = 0.0
        _Lightness ("Lightness", Range(-1.0, 1.0)) = 0.0

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = v.texcoord;

                OUT.color = v.color * _Color;
                return OUT;
            }

            sampler2D _MainTex;
            float _Brightness;
            float _Contrast;
            float _CyanRed;
            float _YellowBlue;
            float _MagentaGreen;
            float _Hue;
            float _Saturation;
            float _Lightness;

            float3 RGBtoHSL(in float R, in float G, in float B){

            float max = 0.0;
            float min = 0.0;
            float diff = 0.0;
            float r_dist = 0.0;
            float g_dist = 0.0;
            float b_dist = 0.0;
            float H = 0.0;
            float S = 0.0;
            float L = 0.0;

            max = R;
            if(max < G){ max = G; }
            if(max < B){ max = B; }

            min = R;
            if(min > G){ min = G; }
            if(min > B){ min = B; }

            diff = max - min;
            L = (max + min) / 2;

            if(abs(diff) < 0.00001){
            S = 0;
            H = 0;
            }
            else{

            if(L <= 0.5){
            S = diff / (max + min);
            }
            else{
            S = diff / (2 - max - min);
            }

            r_dist = (max - R) / diff;
            g_dist = (max - G) / diff;
            b_dist = (max - B) / diff;

            if(R == max){
            H = b_dist - g_dist;
            }
            else if(G == max){
            H = 2 + r_dist - b_dist;
            }
            else{
            H = 4 + g_dist - r_dist;
            }

            H = H * 60;
            if (H < 0) { H = H + 360; }
            }

            return float3(H, S, L);
            }

float QqhToRgb(in float q1, in float q2, in float hue)
{
    if(hue > 360.0){
    hue = hue - 360.0;
    }
    else if(hue < 0.0){
    hue = hue + 360.0;
    }

    if(hue < 60.0){
    return q1 + (q2 - q1) * hue / 60.0;
    }
    else if(hue < 180.0){
    return q2;
    }
    else if(hue < 240.0){
    return q1 + (q2 - q1) * (240.0 - hue) / 60.0;
    }
    else{
    return q1;
    }
}

float3 HSLtoRGB(in float H, in float S, in float L){

float p1 = 0.0;
float p2 = 0.0;
float R = 0.0;
float G = 0.0;
float B = 0.0;

if(L <= 0.5){
p2 = L * (1 + S);
}
else{
p2 = L + S - L * S;
}

p1 = 2 * L - p2;

if(S == 0){
R = L;
G = L;
B = L;
}
else{
R = QqhToRgb(p1, p2, H + 120);
G = QqhToRgb(p1, p2, H);
B = QqhToRgb(p1, p2, H - 120);
}

return float3(R, G, B);

}

            // Output final color
            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

                // Calculate brightness
                float bright = clamp(_Brightness, -1.0, 1.0);
                color.r = clamp(color.r + bright, 0.0, 1.0);
                color.g = clamp(color.g + bright, 0.0, 1.0);
                color.b = clamp(color.b + bright, 0.0, 1.0);

                // Calculate contrast
                float contrast = 1.0 + _Contrast;
                contrast = contrast * contrast;
                color.r = clamp((color.r - 0.5) * contrast + 0.5, 0.0, 1.0);
                color.g = clamp((color.g - 0.5) * contrast + 0.5, 0.0, 1.0);
                color.b = clamp((color.b - 0.5) * contrast + 0.5, 0.0, 1.0);

                // Calculate cyan, magenta, yellow
                float cr = clamp(_CyanRed, -1.0, 1.0);
                float mg = clamp(_MagentaGreen, -1.0, 1.0);
                float yb = clamp(_YellowBlue, -1.0, 1.0);

                color.r = color.r + cr;
                color.g = color.g - (cr / 2.0);
                color.b = color.b - (cr / 2.0);

                color.g = color.g + mg;
                color.r = color.r - (mg / 2.0);
                color.b = color.b - (mg / 2.0);

                color.b = color.b + yb;
                color.r = color.r - (yb / 2.0);
                color.g = color.g - (yb / 2.0);

                // Calculate HSL (Hue, Saturation, Lightness)
                float3 hsl = RGBtoHSL(color.r, color.g, color.b);

                float h = clamp (hsl.r + _Hue * 360.0, 0.0, 360.0);
                float s = clamp (hsl.g + _Saturation, 0.0, 1.0);
                float l = clamp (hsl.b + _Lightness, 0.0, 1.0);

                float3 rgb = HSLtoRGB(h, s, l);

                color.r = rgb.r;
                color.g = rgb.g;
                color.b = rgb.b;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                return color;
            }
        ENDCG
        }
    }
}
