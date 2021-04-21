Shader "Unlit/GeometryShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _ExtrusionFactor("Extrusion Factor", float) = 0
        _ExtrusionFactor2("Extrusion Factor 2", float) = 0
        _ExtrusionFactor3("Extrusion Factor 3", float) = 0
        _Color("Color",color) = (1,1,1,1)

        _BarycenterValue("Barycenter Value", float) = 3
        _NormalValue("Normal Value", float) = 3
    }
    SubShader
    {
            Tags { "RenderType" = "Opaque" }
            Cull Off
            LOD 100
            
            Pass
            {
                HLSLPROGRAM
                #pragma vertex vert
                #pragma geometry geom
                #pragma fragment frag
            
                #include "UnityCG.cginc"
            
                struct UnityDataStream
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                    float3 normal : NORMAL;
                };
            
                struct VertexToGeometry
                {
                    float4 vertex : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float3 normal : NORMAL;
                };
            
                struct GeometryToPixel
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    float4 color : COLOR;
                };
            
                sampler2D _MainTex;
                float4 _MainTex_ST;
                float _ExtrusionFactor;
                float _ExtrusionFactor2;
                float _ExtrusionFactor3;
                float4 _Color;
                float _BarycenterValue;
                float _NormalValue;
            
                VertexToGeometry vert(UnityDataStream v)
                {
                    VertexToGeometry o;
                    o.vertex = v.vertex;
                    o.uv = v.uv;
                    o.normal = v.normal;
                    return o;
                }
            
                float random(float2 uv)
                {
                    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123);
                }

                [maxvertexcount(12)]
                void geom(triangle VertexToGeometry IN[3], inout TriangleStream<GeometryToPixel> triStream)
                {
                    GeometryToPixel o;
            
                    float4 barycenter = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / _BarycenterValue;
                    float3 normal = (IN[0].normal + IN[1].normal + IN[2].normal) / _NormalValue;
            
                    for (int i = 0; i < 3; i++) {

                        float k = random(IN[i].uv);
                        
                        int next = (i + 1) % 3;
                        o.vertex = UnityObjectToClipPos(IN[i].vertex * _ExtrusionFactor2);
                        o.uv = TRANSFORM_TEX(IN[i].uv, _MainTex);
                        o.color = _Color;
                        triStream.Append(o);
            
                        o.vertex = UnityObjectToClipPos(barycenter + float4(normal, 0.0) * _ExtrusionFactor * k);
                        o.uv = TRANSFORM_TEX(IN[i].uv, _MainTex);
                        o.color = _Color;
                        triStream.Append(o);
            
                        o.vertex = UnityObjectToClipPos(IN[next].vertex * _ExtrusionFactor3);
                        o.uv = TRANSFORM_TEX(IN[next].uv, _MainTex);
                        o.color = _Color;
                        triStream.Append(o);
            
                        triStream.RestartStrip();
                    }
                }

                fixed4 frag(GeometryToPixel i) : SV_Target
                {
                    fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                    return col;
                }
            ENDHLSL
        }
    }
}