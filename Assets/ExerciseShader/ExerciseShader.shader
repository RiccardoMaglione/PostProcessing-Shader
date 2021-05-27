Shader "MyShader/ExerciseShader"
{
	Properties{
		_MainTex("Splat Map", 2D) = "white" {}

		_Texture1("Channel Texture 1", 2D) = "white" {}
		/*[NoScaleOffset]*/ _DetailTexture1("Channel Detail 1", 2D) = "gray" {}

		_Texture2("Channel Texture 2", 2D) = "white" {}
		/*[NoScaleOffset]*/ _DetailTexture2("Channel Detail 2", 2D) = "gray" {}

		_Texture3("Channel Texture 3", 2D) = "white" {}
		/*[NoScaleOffset]*/ _DetailTexture3("Channel Detail 3", 2D) = "gray" {}

		_Texture4("Channel Texture 4", 2D) = "white" {}
		/*[NoScaleOffset]*/ _DetailTexture4("Channel Detail 4", 2D) = "gray" {}

		_Texture5("Channel Texture 5", 2D) = "white" {}
		/*[NoScaleOffset]*/ _DetailTexture5("Channel Detail 5", 2D) = "gray" {}
		
		_Texture6("Channel Texture 6", 2D) = "white" {}
		/*[NoScaleOffset]*/ _DetailTexture6("Channel Detail 6", 2D) = "gray" {}
		
		_Texture7("Channel Texture 7", 2D) = "white" {}
		/*[NoScaleOffset]*/ _DetailTexture7("Channel Detail 7", 2D) = "gray" {}
		
		_Texture8("Channel Texture 8", 2D) = "white" {}
		/*[NoScaleOffset]*/ _DetailTexture8("Channel Detail 8", 2D) = "gray" {}

		_Offset("Offset", Vector) = (10,0,0,0)
		_FirstAngle("FirstAngle", Float) = 0
		_SecondAngle("SecondAngle", Float) = 0
		_ThirdAngle("ThirdAngle", Float) = 0
		[Toggle(Duplication)] _ToggleDuplication("ToggleDuplication", Float) = 1



		_Smoothness("Smoothness", Range(0, 1)) = 0.5
		[Gamma] _Metallic("Metallic", Range(0, 1)) = 0
		//_Tint("Tint", Color) = (1, 1, 1, 1)


		//[NoScaleOffset] _NormalMap("Normals", 2D) = "bump" {}
		//				_BumpScale("Bump Scale", Float) = 1
		//[NoScaleOffset] _DetailNormalMap("Detail Normals", 2D) = "bump" {}
		//				_DetailBumpScale("Detail Bump Scale", Float) = 1

		[NoScaleOffset] _NormalMap1("Normals 1", 2D) = "bump" {}
		[NoScaleOffset] _NormalMap2("Normals 2", 2D) = "bump" {}
		[NoScaleOffset] _NormalMap3("Normals 3", 2D) = "bump" {}
		[NoScaleOffset] _NormalMap4("Normals 4", 2D) = "bump" {}
		[NoScaleOffset] _NormalMap5("Normals 5", 2D) = "bump" {}
		[NoScaleOffset] _NormalMap6("Normals 6", 2D) = "bump" {}
		[NoScaleOffset] _NormalMap7("Normals 7", 2D) = "bump" {}
		[NoScaleOffset] _NormalMap8("Normals 8", 2D) = "bump" {}

		_BumpScale1("Bump Scale 1", Float) = 1
		_BumpScale2("Bump Scale 2", Float) = 1
		_BumpScale3("Bump Scale 3", Float) = 1
		_BumpScale4("Bump Scale 4", Float) = 1
		_BumpScale1("Bump Scale 5", Float) = 1
		_BumpScale2("Bump Scale 6", Float) = 1
		_BumpScale3("Bump Scale 7", Float) = 1
		_BumpScale4("Bump Scale 9", Float) = 1

		[NoScaleOffset] _DetailNormalMap1("Detail Normals 1", 2D) = "bump" {}
		[NoScaleOffset] _DetailNormalMap2("Detail Normals 2", 2D) = "bump" {}
		[NoScaleOffset] _DetailNormalMap3("Detail Normals 3", 2D) = "bump" {}
		[NoScaleOffset] _DetailNormalMap4("Detail Normals 4", 2D) = "bump" {}
		[NoScaleOffset] _DetailNormalMap5("Detail Normals 5", 2D) = "bump" {}
		[NoScaleOffset] _DetailNormalMap6("Detail Normals 6", 2D) = "bump" {}
		[NoScaleOffset] _DetailNormalMap7("Detail Normals 7", 2D) = "bump" {}
		[NoScaleOffset] _DetailNormalMap8("Detail Normals 8", 2D) = "bump" {}

		_DetailBumpScale1("Detail Bump Scale 1", Float) = 1
		_DetailBumpScale2("Detail Bump Scale 2", Float) = 1
		_DetailBumpScale3("Detail Bump Scale 3", Float) = 1
		_DetailBumpScale4("Detail Bump Scale 4", Float) = 1
		_DetailBumpScale1("Detail Bump Scale 5", Float) = 1
		_DetailBumpScale2("Detail Bump Scale 6", Float) = 1
		_DetailBumpScale3("Detail Bump Scale 7", Float) = 1
		_DetailBumpScale4("Detail Bump Scale 8", Float) = 1

		Ciao("Ciao", 2D) = "white" {}
	}
		CGINCLUDE

#define BINORMAL_PER_FRAGMENT

		ENDCG
		SubShader{
			Pass {
				Tags { "LightMode" = "ForwardBase" }

				HLSLPROGRAM
				#pragma require geometry
				#pragma target 3.5
				#pragma multi_compile _ VERTEXLIGHT_ON
				#pragma vertex MyVertexProgram
				#pragma fragment MyFragmentProgram
				#pragma geometry geom
				#pragma shader_feature Duplication

				#define FORWARD_BASE_PASS
				#include "UnityCG.cginc"
				#include "PassLighting.cginc"

				ENDHLSL
			}
			Pass {
				Tags { "LightMode" = "ForwardAdd" }

				Blend One One
				ZWrite Off

				HLSLPROGRAM
				#pragma require geometry
				#pragma target 3.5
				#pragma multi_compile_fwdadd
				#pragma vertex MyVertexProgram
				#pragma fragment MyFragmentProgram
				#pragma geometry geom
				#pragma shader_feature Duplication

				#include "UnityCG.cginc"
				#include "PassLighting.cginc"

				ENDHLSL
			}
	}
}
