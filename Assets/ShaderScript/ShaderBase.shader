Shader "Unlit/ShaderBase"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
    
            #include "UnityCG.cginc"
    
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
    
            struct VertexData
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };
    
            struct Interpolators
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
    
            Interpolators vert(VertexData VD)
            {
                Interpolators Intpol;
                Intpol.position = mul(UNITY_MATRIX_MVP, VD.position);       //Aggiungo alla shader la matrice di roto-traslazione per attaccare la texture agli oggetti
                Intpol.uv = VD.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                
                //Intpol.uv = TRANSFORM_TEX(VD.uv, _MainTex);
                //Intpol.pos = UnityObjectToClipPos(VD.position);
                
                return Intpol;
            }
    
            float4 frag(Interpolators Intpol) : SV_Target
            {
                return tex2D(_MainTex, Intpol.uv) * _Color;
            }
            ENDHLSL
        }
    }
}
