#if !defined(PASSLIGHTING_INCLUDED)
#define PASSLIGHTING_INCLUDED

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"

sampler2D _MainTex;					//1
float4 _MainTex_ST;

sampler2D _Texture1;				//2
SamplerState sampler_Texture1;
float4 _Texture1_ST;
sampler2D _DetailTexture1;			//3
float4 _DetailTexture1_ST;

sampler2D _Texture2;				//4
float4 _Texture2_ST;
sampler2D _DetailTexture2;			//5
float4 _DetailTexture2_ST;

sampler2D _Texture3;				//6
float4 _Texture3_ST;
sampler2D _DetailTexture3;			//7
float4 _DetailTexture3_ST;

sampler2D _Texture4;				//8
float4 _Texture4_ST;
sampler2D _DetailTexture4;			//9
float4 _DetailTexture4_ST;

//sampler2D _Texture5;				//10
//float4 _Texture5_ST;
//sampler2D _DetailTexture5;		//11
//float4 _DetailTexture5_ST;
//
//sampler2D _Texture6;				//12
//float4 _Texture6_ST;
//sampler2D _DetailTexture6;		//13
//float4 _DetailTexture6_ST;
//
//sampler2D _Texture7;				//14
//float4 _Texture7_ST;
//sampler2D _DetailTexture7;		//15
//float4 _DetailTexture7_ST;
//
//sampler2D _Texture8;				//16
//float4 _Texture8_ST;
//sampler2D _DetailTexture8;		//17
//float4 _DetailTexture8_ST;

float4 _Offset;
float _FirstAngle;
float _SecondAngle;
float _ThirdAngle;

float _Smoothness;
float _Metallic;
sampler2D _MainTexAlbedo;			//togliere
float4 _MainTexAlbedo_ST;
float4 _Tint;
sampler2D _NormalMap, _DetailNormalMap;		//togliere
float _BumpScale, _DetailBumpScale;


sampler2D _NormalMap1, _DetailNormalMap1;		//18		//19
sampler2D _NormalMap2, _DetailNormalMap2;		//20		//21
//sampler2D _NormalMap3, _DetailNormalMap3;		//22		//23
//sampler2D _NormalMap4, _DetailNormalMap4;		//24		//25
//sampler2D _NormalMap5, _DetailNormalMap5;		//26		//27
//sampler2D _NormalMap6, _DetailNormalMap6;		//28		//29
//sampler2D _NormalMap7, _DetailNormalMap7;		//30		//31
//sampler2D _NormalMap8, _DetailNormalMap8;		//32		//33

float _BumpScale1, _DetailBumpScale1;
//float _BumpScale2, _DetailBumpScale2;
//float _BumpScale3, _DetailBumpScale3;
//float _BumpScale4, _DetailBumpScale4;

struct VertexData {
	float4 position : POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float4 uv : TEXCOORD0;
};

struct Interpolators {
	float4 position : SV_POSITION;
	float4 uv : TEXCOORD0;
	float2 uvSplat : TEXCOORD1;
	//float4 uvDetail : TEXCOORD2;
	float3 normal : TEXCOORD2;
#if defined(BINORMAL_PER_FRAGMENT)
	float4 tangent : TEXCOORD3;
#else
	float3 tangent : TEXCOORD4;
	float3 binormal : TEXCOORD5;
#endif
	float3 worldPos : TEXCOORD6;


	#if defined(VERTEXLIGHT_ON)
	float3 vertexLightColor : TEXCOORD7;
	#endif
};

struct g2f
{
	float4 worldPos : SV_POSITION;
	float4 uv : TEXCOORD0;
	//float4 color : COLOR;
	float2 uvSplat : TEXCOORD1;
	//float2 uvDetail : TEXCOORD2;
	float3 normal : TEXCOORD2;
#if defined(BINORMAL_PER_FRAGMENT)
	float4 tangent : TEXCOORD3;
#else
	float3 tangent : TEXCOORD4;
	float3 binormal : TEXCOORD5;
#endif
	float3 worldPosLight : TEXCOORD6;

	#if defined(VERTEXLIGHT_ON)
	float3 vertexLightColor : TEXCOORD7;
	#endif
};

float4 RotateAroundYInDegrees(float4 vertex, float degrees)
{
	float alpha = degrees * UNITY_PI / 180.0;
	float sina, cosa;
	sincos(alpha, sina, cosa);
	float2x2 m = float2x2(cosa, -sina, sina, cosa);
	return float4(mul(m, vertex.xz), vertex.yw).xzyw;
}

void ComputeVertexLightColor(inout Interpolators i) {
#if defined(VERTEXLIGHT_ON)
	i.vertexLightColor = Shade4PointLights(
		unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
		unity_LightColor[0].rgb, unity_LightColor[1].rgb,
		unity_LightColor[2].rgb, unity_LightColor[3].rgb,
		unity_4LightAtten0, i.worldPos, i.normal
	);
#endif
}

float3 CreateBinormal(float3 normal, float3 tangent, float binormalSign) {
	return cross(normal, tangent.xyz) *
		(binormalSign * unity_WorldTransformParams.w);
}

Interpolators MyVertexProgram(VertexData v) {
	Interpolators i;
	i.position = v.position;
	i.worldPos = mul(unity_ObjectToWorld, v.position);
	i.normal = UnityObjectToWorldNormal(v.normal);

	#if defined(BINORMAL_PER_FRAGMENT)
		i.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
	#else
		i.tangent = UnityObjectToWorldDir(v.tangent.xyz);
		i.binormal = CreateBinormal(i.normal, i.tangent, v.tangent.w);
	#endif
	
	i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
	i.uv.zw = TRANSFORM_TEX(v.uv, _DetailTexture1);
	i.uvSplat = v.uv;
	ComputeVertexLightColor(i);
	return i;
}

UnityLight CreateLight(Interpolators i) {
	UnityLight light;

#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
	light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
#else
	light.dir = _WorldSpaceLightPos0.xyz;
#endif

	UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
	light.color = _LightColor0.rgb * attenuation;
	light.ndotl = DotClamped(i.normal, light.dir);
	return light;
}

UnityIndirect CreateIndirectLight(Interpolators i) {
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

#if defined(VERTEXLIGHT_ON)
	indirectLight.diffuse = i.vertexLightColor;
#endif

#if defined(FORWARD_BASE_PASS)
	indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
#endif

	return indirectLight;
}

[maxvertexcount(12)]
void geom(triangle Interpolators input[3], inout TriangleStream<g2f> tristream) {
	g2f o;

	input[0].position = RotateAroundYInDegrees(input[0].position, _FirstAngle);
	o.worldPos = UnityObjectToClipPos(input[0].position);
	o.uv.xy = input[0].uv.xy;
	o.uvSplat = input[0].uvSplat;
	o.uv.zw = input[0].uv.zw;
	o.normal = input[0].normal;
	o.tangent = input[0].tangent;
	o.binormal = input[0].binormal;
	o.worldPosLight = input[0].worldPos;
	ComputeVertexLightColor(input[0]);
	//o.color = fixed4(0, 0, 0, 1);
	tristream.Append(o);

	input[1].position = RotateAroundYInDegrees(input[1].position, _FirstAngle);
	o.worldPos = UnityObjectToClipPos(input[1].position);
	o.uv.xy = input[1].uv.xy;
	//o.color = fixed4(0, 0, 0, 1);
	o.uvSplat = input[1].uvSplat;
	o.uv.zw = input[1].uv.zw;
	o.normal = input[1].normal;
	o.tangent = input[1].tangent;
	o.binormal = input[1].binormal;
	o.worldPosLight = input[1].worldPos;
	ComputeVertexLightColor(input[1]);
	tristream.Append(o);

	input[2].position = RotateAroundYInDegrees(input[2].position, _FirstAngle);
	o.worldPos = UnityObjectToClipPos(input[2].position);
	o.uv.xy = input[2].uv.xy;
	//o.color = fixed4(0, 0, 0, 1);
	o.uvSplat = input[2].uvSplat;
	o.uv.zw = input[2].uv.zw;
	o.normal = input[2].normal;
	o.tangent = input[2].tangent;
	o.binormal = input[2].binormal;
	o.worldPosLight = input[2].worldPos;
	ComputeVertexLightColor(input[2]);
	tristream.Append(o);
	/*#ifdef Duplication
	tristream.RestartStrip();

	input[0].position = RotateAroundYInDegrees(input[0].position, _SecondAngle);
	o.worldPos = UnityObjectToClipPos(input[0].position + _Offset);
	o.uv = input[0].uv;
	//o.color = fixed4(0, 0, 0, 1);
	o.uvSplat = input[1].uvSplat;
	o.uvDetail = input[1].uvDetail;
	tristream.Append(o);

	input[1].position = RotateAroundYInDegrees(input[1].position, _SecondAngle);
	o.worldPos = UnityObjectToClipPos(input[1].position + _Offset);
	o.uv = input[1].uv;
	//o.color = fixed4(0, 0, 0, 1);
	o.uvSplat = input[0].uvSplat;
	o.uvDetail = input[0].uvDetail;
	tristream.Append(o);

	input[2].position = RotateAroundYInDegrees(input[2].position, _SecondAngle);
	o.worldPos = UnityObjectToClipPos(input[2].position + _Offset);
	o.uv = input[2].uv;
	//o.color = fixed4(0, 0, 0, 1);
	o.uvSplat = input[2].uvSplat;
	o.uvDetail = input[2].uvDetail;
	tristream.Append(o);

	tristream.RestartStrip();

	input[0].position = RotateAroundYInDegrees(input[0].position, _ThirdAngle);
	o.worldPos = UnityObjectToClipPos(input[0].position - _Offset);
	o.uv = input[0].uv;
	//o.color = fixed4(0, 0, 0, 1);
	o.uvSplat = input[0].uvSplat;
	o.uvDetail = input[0].uvDetail;
	tristream.Append(o);

	input[1].position = RotateAroundYInDegrees(input[1].position, _ThirdAngle);
	o.worldPos = UnityObjectToClipPos(input[1].position - _Offset);
	o.uv = input[1].uv;
	//o.color = fixed4(0, 0, 0, 1);
	o.uvSplat = input[1].uvSplat;
	o.uvDetail = input[1].uvDetail;
	tristream.Append(o);

	input[2].position = RotateAroundYInDegrees(input[2].position, _ThirdAngle);
	o.worldPos = UnityObjectToClipPos(input[2].position - _Offset);
	o.uv = input[2].uv;
	//o.color = fixed4(0, 0, 0, 1);
	o.uvSplat = input[2].uvSplat;
	o.uvDetail = input[2].uvDetail;
	tristream.Append(o);
	#endif*/
}

void InitializeFragmentNormal(inout Interpolators i) {
	float3 mainNormal = UnpackScaleNormal(tex2D(_NormalMap, i.uv.xy), _BumpScale);
	float3 detailNormal = UnpackScaleNormal(tex2D(_DetailNormalMap, i.uv.zw), _DetailBumpScale);
	float3 tangentSpaceNormal = BlendNormals(mainNormal, detailNormal);

	#if defined(BINORMAL_PER_FRAGMENT)
		float3 binormal = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal = i.binormal;
	#endif

	i.normal = normalize(tangentSpaceNormal.x * i.tangent + tangentSpaceNormal.y * binormal + tangentSpaceNormal.z * i.normal);
	//float3 mainNormal1 = UnpackScaleNormal(tex2D(_NormalMap1, i.uv.xy), _BumpScale1);
	//float3 detailNormal1 = UnpackScaleNormal(tex2D(_DetailNormalMap1, i.uv.zw), _DetailBumpScale1);
	//float3 blendNormal1 = BlendNormals(mainNormal1, detailNormal1);

	//float3 mainNormal2 = UnpackScaleNormal(tex2D(_NormalMap2, i.uv.xy), _BumpScale2);
	//float3 detailNormal2 = UnpackScaleNormal(tex2D(_DetailNormalMap2, i.uv.zw), _DetailBumpScale2);
	//float3 blendNormal2 = BlendNormals(mainNormal2, detailNormal2);
	//
	//float3 mainNormal3 = UnpackScaleNormal(tex2D(_NormalMap3, i.uv.xy), _BumpScale3);
	//float3 detailNormal3 = UnpackScaleNormal(tex2D(_DetailNormalMap3, i.uv.zw), _DetailBumpScale3);
	//float3 blendNormal3 = BlendNormals(mainNormal3, detailNormal3);
	//
	//float3 mainNormal4 = UnpackScaleNormal(tex2D(_NormalMap4, i.uv.xy), _BumpScale4);
	//float3 detailNormal4 = UnpackScaleNormal(tex2D(_DetailNormalMap4, i.uv.zw), _DetailBumpScale4);
	//float3 blendNormal4 = BlendNormals(mainNormal4, detailNormal4);

	//i.normal = blendNormal.xzy + blendNormal1.xzy/* + blendNormal2.xzy + blendNormal3.xzy + blendNormal4.xzy*/;
}

SamplerState sampler_Texture;

float4 MyFragmentProgram(Interpolators i) : SV_TARGET{

	InitializeFragmentNormal(i);

	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

	float4 splat = tex2D(_MainTex, i.uvSplat);
	//float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
	float3 albedo = /*_Texture1.Sample(sampler_Texture1, i.uv.xy)*/ tex2D(_Texture1, i.uv.xy) * tex2D(_DetailTexture1, i.uv.zw) * splat.r * unity_ColorSpaceDouble +
					tex2D(_Texture2, i.uv.xy) * tex2D(_DetailTexture2, i.uv.zw) * splat.g * unity_ColorSpaceDouble +
					tex2D(_Texture3, i.uv.xy) * tex2D(_DetailTexture3, i.uv.zw) * splat.b * unity_ColorSpaceDouble +
					tex2D(_Texture4, i.uv.xy) * tex2D(_DetailTexture4, i.uv.zw) * (1 - splat.r - splat.g - splat.b) * unity_ColorSpaceDouble;

	float3 specularTint;
	float oneMinusReflectivity;
	albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);

	return UNITY_BRDF_PBS(albedo, specularTint, oneMinusReflectivity, _Smoothness, i.normal, viewDir, CreateLight(i), CreateIndirectLight(i));

	//float4 splat = tex2D(_MainTex, i.uvSplat);
	//return
	//	tex2D(_Texture1, i.uv) * tex2D(_DetailTexture1, i.uvDetail) * splat.r +
	//	tex2D(_Texture2, i.uv) * tex2D(_DetailTexture2, i.uvDetail) * splat.g +
	//	tex2D(_Texture3, i.uv) * tex2D(_DetailTexture3, i.uvDetail) * splat.b +
	//	tex2D(_Texture4, i.uv) * tex2D(_DetailTexture4, i.uvDetail) * (1 - splat.r - splat.g - splat.b);
}
#endif