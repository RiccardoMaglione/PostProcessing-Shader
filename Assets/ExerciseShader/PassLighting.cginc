#if !defined(PASSLIGHTING_INCLUDED)
#define PASSLIGHTING_INCLUDED

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"

sampler2D _MainTex;					//1
float4 _MainTex_ST;

SamplerState sampler_Texture1, sampler_DetailTexture1, sampler_NormalMap1, sampler_DetailNormalMap1;

Texture2D _Texture1, _Texture2, _Texture3, _Texture4, _Texture5, _Texture6, _Texture7, _Texture8;
float4 _Texture1_ST, _Texture2_ST, _Texture3_ST, _Texture4_ST, _Texture5_ST, _Texture6_ST, _Texture7_ST, _Texture8_ST;

Texture2D _DetailTexture1, _DetailTexture2, _DetailTexture3, _DetailTexture4, _DetailTexture5, _DetailTexture6, _DetailTexture7, _DetailTexture8;
float4 _DetailTexture1_ST, _DetailTexture2_ST, _DetailTexture3_ST, _DetailTexture4_ST, _DetailTexture5_ST, _DetailTexture6_ST, _DetailTexture7_ST, _DetailTexture8_ST;


float4 _Offset;
float _FirstAngle, _SecondAngle, _ThirdAngle;

float _Smoothness;
float _Metallic;

//sampler2D _MainTexAlbedo;			//togliere
//float4 _MainTexAlbedo_ST;

//float4 _Tint;

//sampler2D _NormalMap, _DetailNormalMap;		//togliere
//float _BumpScale, _DetailBumpScale;

Texture2D _NormalMap1, _NormalMap2, _NormalMap3, _NormalMap4, _NormalMap5, _NormalMap6, _NormalMap7, _NormalMap8;
Texture2D _DetailNormalMap1, _DetailNormalMap2, _DetailNormalMap3, _DetailNormalMap4, _DetailNormalMap5, _DetailNormalMap6, _DetailNormalMap7, _DetailNormalMap8;

float _BumpScale1, _BumpScale2, _BumpScale3, _BumpScale4, _BumpScale5, _BumpScale6, _BumpScale7, _BumpScale8;
float _DetailBumpScale1, _DetailBumpScale2, _DetailBumpScale3, _DetailBumpScale4, _DetailBumpScale5, _DetailBumpScale6, _DetailBumpScale7, _DetailBumpScale8;


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
	return cross(normal, tangent.xyz) * (binormalSign * unity_WorldTransformParams.w);
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
	//float3 mainNormal = UnpackScaleNormal(tex2D(_NormalMap, i.uv.xy), _BumpScale);
	//float3 detailNormal = UnpackScaleNormal(tex2D(_DetailNormalMap, i.uv.zw), _DetailBumpScale);
	//float3 tangentSpaceNormal = BlendNormals(mainNormal, detailNormal);
	//
	//#if defined(BINORMAL_PER_FRAGMENT)
	//	float3 binormal = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	//#else
	//	float3 binormal = i.binormal;
	//#endif
	
	//i.normal = normalize(tangentSpaceNormal.x * i.tangent + tangentSpaceNormal.y * binormal + tangentSpaceNormal.z * i.normal);

	float3 mainNormal1 = UnpackScaleNormal(_NormalMap1.Sample(sampler_NormalMap1, i.uv.xy), _BumpScale1);
	float3 detailNormal1 = UnpackScaleNormal(_DetailNormalMap1.Sample(sampler_DetailNormalMap1, i.uv.zw), _DetailBumpScale1);
	float3 tangentSpaceNormal1 = BlendNormals(mainNormal1, detailNormal1);

	#if defined(BINORMAL_PER_FRAGMENT)
		float3 binormal1 = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal1 = i.binormal;
	#endif

	float3 mainNormal2 = UnpackScaleNormal(_NormalMap2.Sample(sampler_NormalMap1, i.uv.xy), _BumpScale2);
	float3 detailNormal2 = UnpackScaleNormal(_DetailNormalMap2.Sample(sampler_DetailNormalMap1, i.uv.zw), _DetailBumpScale2);
	float3 tangentSpaceNormal2 = BlendNormals(mainNormal2, detailNormal2);

	#if defined(BINORMAL_PER_FRAGMENT)
		float3 binormal2 = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal2 = i.binormal;
	#endif

	float3 mainNormal3 = UnpackScaleNormal(_NormalMap3.Sample(sampler_NormalMap1, i.uv.xy), _BumpScale3);
	float3 detailNormal3 = UnpackScaleNormal(_DetailNormalMap3.Sample(sampler_DetailNormalMap1, i.uv.zw), _DetailBumpScale3);
	float3 tangentSpaceNormal3 = BlendNormals(mainNormal3, detailNormal3);

	#if defined(BINORMAL_PER_FRAGMENT)
		float3 binormal3 = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal3 = i.binormal;
	#endif

	float3 mainNormal4 = UnpackScaleNormal(_NormalMap4.Sample(sampler_NormalMap1, i.uv.xy), _BumpScale4);
	float3 detailNormal4 = UnpackScaleNormal(_DetailNormalMap4.Sample(sampler_DetailNormalMap1, i.uv.zw), _DetailBumpScale4);
	float3 tangentSpaceNormal4 = BlendNormals(mainNormal4, detailNormal4);

	#if defined(BINORMAL_PER_FRAGMENT)
		float3 binormal4 = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal4 = i.binormal;
	#endif

	float3 mainNormal5 = UnpackScaleNormal(_NormalMap5.Sample(sampler_NormalMap1, i.uv.xy), _BumpScale5);
	float3 detailNormal5 = UnpackScaleNormal(_DetailNormalMap5.Sample(sampler_DetailNormalMap1, i.uv.zw), _DetailBumpScale5);
	float3 tangentSpaceNormal5 = BlendNormals(mainNormal5, detailNormal5);

	#if defined(BINORMAL_PER_FRAGMENT)
		float3 binormal5 = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal5 = i.binormal;
	#endif

	float3 mainNormal6 = UnpackScaleNormal(_NormalMap6.Sample(sampler_NormalMap1, i.uv.xy), _BumpScale6);
	float3 detailNormal6 = UnpackScaleNormal(_DetailNormalMap6.Sample(sampler_DetailNormalMap1, i.uv.zw), _DetailBumpScale6);
	float3 tangentSpaceNormal6 = BlendNormals(mainNormal6, detailNormal6);

	#if defined(BINORMAL_PER_FRAGMENT)
		float3 binormal6 = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal6 = i.binormal;
	#endif

	float3 mainNormal7 = UnpackScaleNormal(_NormalMap7.Sample(sampler_NormalMap1, i.uv.xy), _BumpScale7);
	float3 detailNormal7 = UnpackScaleNormal(_DetailNormalMap7.Sample(sampler_DetailNormalMap1, i.uv.zw), _DetailBumpScale7);
	float3 tangentSpaceNormal7 = BlendNormals(mainNormal7, detailNormal7);

	#if defined(BINORMAL_PER_FRAGMENT)
		float3 binormal7 = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal7 = i.binormal;
	#endif

	float3 mainNormal8 = UnpackScaleNormal(_NormalMap8.Sample(sampler_NormalMap1, i.uv.xy), _BumpScale8);
	float3 detailNormal8 = UnpackScaleNormal(_DetailNormalMap8.Sample(sampler_DetailNormalMap1, i.uv.zw), _DetailBumpScale8);
	float3 tangentSpaceNormal8 = BlendNormals(mainNormal8, detailNormal8);

	#if defined(BINORMAL_PER_FRAGMENT)
		float3 binormal8 = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal8 = i.binormal;
	#endif

	i.normal = /*normalize(tangentSpaceNormal.x * i.tangent + tangentSpaceNormal.y * binormal + tangentSpaceNormal.z * i.normal) +*/
			   normalize(tangentSpaceNormal1.x * i.tangent + tangentSpaceNormal1.y * binormal1 + tangentSpaceNormal1.z * i.normal) +
			   normalize(tangentSpaceNormal2.x * i.tangent + tangentSpaceNormal2.y * binormal2 + tangentSpaceNormal2.z * i.normal) +
			   normalize(tangentSpaceNormal3.x * i.tangent + tangentSpaceNormal3.y * binormal3 + tangentSpaceNormal3.z * i.normal) + 
			   normalize(tangentSpaceNormal4.x * i.tangent + tangentSpaceNormal4.y * binormal4 + tangentSpaceNormal4.z * i.normal) + 
			   normalize(tangentSpaceNormal5.x * i.tangent + tangentSpaceNormal5.y * binormal5 + tangentSpaceNormal5.z * i.normal) + 
			   normalize(tangentSpaceNormal6.x * i.tangent + tangentSpaceNormal6.y * binormal6 + tangentSpaceNormal6.z * i.normal) + 
			   normalize(tangentSpaceNormal7.x * i.tangent + tangentSpaceNormal7.y * binormal7 + tangentSpaceNormal7.z * i.normal) + 
			   normalize(tangentSpaceNormal8.x * i.tangent + tangentSpaceNormal8.y * binormal8 + tangentSpaceNormal8.z * i.normal);
}


float4 MyFragmentProgram(Interpolators i) : SV_TARGET{

	InitializeFragmentNormal(i);

	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

	float4 splat = tex2D(_MainTex, i.uvSplat);
	//float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
	//float3 albedo = tex2D(_Texture1, i.uv.xy) * tex2D(_DetailTexture1, i.uv.zw) * splat.r * unity_ColorSpaceDouble +
	//				  tex2D(_Texture2, i.uv.xy) * tex2D(_DetailTexture2, i.uv.zw) * splat.g * unity_ColorSpaceDouble +
	//				  tex2D(_Texture3, i.uv.xy) * tex2D(_DetailTexture3, i.uv.zw) * splat.b * unity_ColorSpaceDouble +
	//				  tex2D(_Texture4, i.uv.xy) * tex2D(_DetailTexture4, i.uv.zw) * (1 - splat.r - splat.g - splat.b) * unity_ColorSpaceDouble;
	float3 albedo = _Texture1.Sample(sampler_Texture1, i.uv.xy) * _DetailTexture1.Sample(sampler_DetailTexture1, i.uv.zw) * splat.r * unity_ColorSpaceDouble +
					_Texture2.Sample(sampler_Texture1, i.uv.xy) * _DetailTexture2.Sample(sampler_DetailTexture1, i.uv.zw) * splat.g * unity_ColorSpaceDouble +
					_Texture3.Sample(sampler_Texture1, i.uv.xy) * _DetailTexture3.Sample(sampler_DetailTexture1, i.uv.zw) * splat.b * unity_ColorSpaceDouble +
					_Texture4.Sample(sampler_Texture1, i.uv.xy) * _DetailTexture4.Sample(sampler_DetailTexture1, i.uv.zw) * (1 - splat.r - splat.g - splat.b) * unity_ColorSpaceDouble +
					_Texture5.Sample(sampler_Texture1, i.uv.xy) * _DetailTexture5.Sample(sampler_DetailTexture1, i.uv.zw) * splat.r * unity_ColorSpaceDouble +
					_Texture6.Sample(sampler_Texture1, i.uv.xy) * _DetailTexture6.Sample(sampler_DetailTexture1, i.uv.zw) * splat.g * unity_ColorSpaceDouble +
					_Texture7.Sample(sampler_Texture1, i.uv.xy) * _DetailTexture7.Sample(sampler_DetailTexture1, i.uv.zw) * splat.b * unity_ColorSpaceDouble +
					_Texture8.Sample(sampler_Texture1, i.uv.xy) * _DetailTexture8.Sample(sampler_DetailTexture1, i.uv.zw) * (1 - splat.r - splat.g - splat.b) * unity_ColorSpaceDouble;

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