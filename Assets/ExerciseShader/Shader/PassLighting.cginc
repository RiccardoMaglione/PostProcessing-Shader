#if !defined(PASSLIGHTING_INCLUDED)
#define PASSLIGHTING_INCLUDED

#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"

sampler2D _MainTex, _DetailMainTex;
float4 _MainTex_ST, _DetailMainTex_ST;

sampler2D  _SplatTex;
float4 _SplatTex_ST;

SamplerState sampler_Texture1;
Texture2D _Texture1, _Texture2, _Texture3, _Texture4, _Texture5, _Texture6, _Texture7, _Texture8;

sampler2D _NormalMap, _DetailNormalMap;
float _BumpScale, _DetailBumpScale;

float4 _Tint;

float4 _Offset;
float _FirstAngle, _SecondAngle, _ThirdAngle;

float _Smoothness;
float _Metallic;

struct VertexData
{
	float4 position : POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float4 uv : TEXCOORD0;
};

struct Interpolators
{
	float4 position : SV_POSITION;
	float4 uv : TEXCOORD0;
	float2 uvSplat : TEXCOORD1;
	float3 normal : TEXCOORD2;

	#if defined(BINORMAL_PER_FRAGMENT)
		float4 tangent : TEXCOORD3;
	#else
		float3 tangent : TEXCOORD3;
		float3 binormal : TEXCOORD4;
	#endif
		float3 worldPos : TEXCOORD5;						//Worldpos//////////////////////////////////////
	
	#if defined(VERTEXLIGHT_ON)
		float3 vertexLightColor : TEXCOORD6;
	#endif
};

struct g2f
{
	float4 worldPos : SV_POSITION;
	float4 uv : TEXCOORD0;
	float2 uvSplat : TEXCOORD1;
	float3 normal : TEXCOORD2;

	#if defined(BINORMAL_PER_FRAGMENT)
		float4 tangent : TEXCOORD3;
	#else
		float3 tangent : TEXCOORD3;
		float3 binormal : TEXCOORD4;
	#endif
	
		float3 worldPosLight : TEXCOORD5;						//Worldposlight//////////////////////////////////////
	
	#if defined(VERTEXLIGHT_ON)
		float3 vertexLightColor : TEXCOORD6;
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

void ComputeVertexLightColor(inout Interpolators i)
{
	#if defined(VERTEXLIGHT_ON)
		i.vertexLightColor = Shade4PointLights(
			unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			unity_LightColor[0].rgb, unity_LightColor[1].rgb,
			unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			unity_4LightAtten0, i.worldPos, i.normal						//Worldpos//////////////////////////////////////
		);
	#endif
}

float3 CreateBinormal(float3 normal, float3 tangent, float binormalSign)
{
	return cross(normal, tangent.xyz) * (binormalSign * unity_WorldTransformParams.w);
}

Interpolators MyVertexProgram(VertexData v)
{
	Interpolators i;
	i.position = v.position;
	i.worldPos = mul(unity_ObjectToWorld, v.position);						//Worldpos//////////////////////////////////////
	i.normal = UnityObjectToWorldNormal(v.normal);

	#if defined(BINORMAL_PER_FRAGMENT)
		i.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
	#else
		i.tangent = UnityObjectToWorldDir(v.tangent.xyz);
		i.binormal = CreateBinormal(i.normal, i.tangent, v.tangent.w);
	#endif

	i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);			//MainTex//////////////////////////////////_______________________________________________________
	i.uv.zw = TRANSFORM_TEX(v.uv, _DetailMainTex);		//DetailMainTex//////////////////////////////////_______________________________________________________
	i.uvSplat = v.uv;
	ComputeVertexLightColor(i);
	return i;
}

UnityLight CreateLight(Interpolators i) {
	UnityLight light;

	#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
		light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);						//WorldSpaceLightPos//////////////////////////////////////
	#else
		light.dir = _WorldSpaceLightPos0.xyz;						//WorldSpaceLightPos//////////////////////////////////////
	#endif

	UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);						//WorldPos//////////////////////////////////////
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
void geom(triangle Interpolators input[3], inout TriangleStream<g2f> tristream) {						//for//////////////////////////////////////////////////////////////////////////////
	g2f o;

	for (int i = 0; i < 3; i++)
	{
		if (i == 0)
		{
			input[0].position = RotateAroundYInDegrees(input[0].position, _FirstAngle);
			o.worldPos = UnityObjectToClipPos(input[0].position);
		}
		#ifdef Duplication
			if (i == 1)
			{
				input[0].position = RotateAroundYInDegrees(input[0].position, _SecondAngle);
				o.worldPos = UnityObjectToClipPos(input[0].position + _Offset);
			}
			if (i == 2)
			{
				input[0].position = RotateAroundYInDegrees(input[0].position, _ThirdAngle);
				o.worldPos = UnityObjectToClipPos(input[0].position - _Offset);
			}
		#endif
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

		if (i == 0)
		{
			input[1].position = RotateAroundYInDegrees(input[1].position, _FirstAngle);
			o.worldPos = UnityObjectToClipPos(input[1].position);
		}
		#ifdef Duplication
			if (i == 1)
			{
				input[1].position = RotateAroundYInDegrees(input[1].position, _SecondAngle);
				o.worldPos = UnityObjectToClipPos(input[1].position + _Offset);
			}
			if (i == 2)
			{
				input[1].position = RotateAroundYInDegrees(input[1].position, _ThirdAngle);
				o.worldPos = UnityObjectToClipPos(input[1].position - _Offset);
			}
		#endif
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

		if (i == 0)
		{
			input[2].position = RotateAroundYInDegrees(input[2].position, _FirstAngle);
			o.worldPos = UnityObjectToClipPos(input[2].position);
		}
		#ifdef Duplication
			if (i == 1)
			{
				input[2].position = RotateAroundYInDegrees(input[2].position, _SecondAngle);
				o.worldPos = UnityObjectToClipPos(input[2].position + _Offset);
			}
			if (i == 2)
			{
				input[2].position = RotateAroundYInDegrees(input[2].position, _ThirdAngle);
				o.worldPos = UnityObjectToClipPos(input[2].position - _Offset);
			}
		#endif
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

		tristream.RestartStrip();
	}
}

void InitializeFragmentNormal(inout Interpolators i)
{
	float3 mainNormal = UnpackScaleNormal(tex2D(_NormalMap, i.uv.xy), _BumpScale);					///Normal----------------------------------------------------
	float3 detailNormal = UnpackScaleNormal(tex2D(_DetailNormalMap, i.uv.zw), _DetailBumpScale);	///DetailNormal----------------------------------------------------
	float3 tangentSpaceNormal = BlendNormals(mainNormal, detailNormal);

	#if defined(BINORMAL_PER_FRAGMENT)
		float3 binormal = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal = i.binormal;
	#endif

	i.normal = normalize(tangentSpaceNormal.x * i.tangent + tangentSpaceNormal.y * binormal + tangentSpaceNormal.z * i.normal);
}


float4 MyFragmentProgram(Interpolators i) : SV_TARGET{

	InitializeFragmentNormal(i);

	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

	float4 splat = tex2D(_SplatTex, i.uvSplat);

	float3 albedo = tex2D(_MainTex, i.uv.xy) * tex2D(_DetailMainTex, i.uv.zw) * _Tint * unity_ColorSpaceDouble +
					_Texture1.Sample(sampler_Texture1, i.uv.xy).rgb * splat.r +
					_Texture2.Sample(sampler_Texture1, i.uv.xy).rgb * splat.g +
					_Texture3.Sample(sampler_Texture1, i.uv.xy).rgb * splat.b +
					_Texture4.Sample(sampler_Texture1, i.uv.xy).rgb * (1 - splat.r - splat.g - splat.b) +
					_Texture5.Sample(sampler_Texture1, i.uv.xy).rgb * splat.r +
					_Texture6.Sample(sampler_Texture1, i.uv.xy).rgb * splat.g +
					_Texture7.Sample(sampler_Texture1, i.uv.xy).rgb * splat.b +
					_Texture8.Sample(sampler_Texture1, i.uv.xy).rgb * (1 - splat.r - splat.g - splat.b);

	float3 specularTint;
	float oneMinusReflectivity;
	albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);

	return UNITY_BRDF_PBS(albedo, specularTint, oneMinusReflectivity, _Smoothness, i.normal, viewDir, CreateLight(i), CreateIndirectLight(i));
}
#endif