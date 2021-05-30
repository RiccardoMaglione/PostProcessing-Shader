Shader "MyShader/ExerciseShader"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}										//Texutre che rappresenta l'albedo principale
		_DetailMainTex("Detail Main Texture", 2D) = "grey" {}							//Texutre che rappresenta la detail dell'albedo
		_Tint("Tint", Color) = (1, 1, 1, 1)												//Colore dell'albedo principale

		_SplatTex("_SplatTex", 2D) = "white" {}											//Splat Map utilizzata per suddividere la texture in base RGB
		_Texture1("Texture 1", 2D) = "white" {}											//Texure 1 che formano la splat map
		_Texture2("Texture 2", 2D) = "white" {}											//Texure 2 che formano la splat map
		_Texture3("Texture 3", 2D) = "white" {}											//Texure 3 che formano la splat map
		_Texture4("Texture 4", 2D) = "white" {}											//Texure 4 che formano la splat map
		_Texture5("Texture 5", 2D) = "white" {}											//Texure 5 che formano la splat map
		_Texture6("Texture 6", 2D) = "white" {}											//Texure 6 che formano la splat map
		_Texture7("Texture 7", 2D) = "white" {}											//Texure 7 che formano la splat map
		_Texture8("Texture 8", 2D) = "white" {}											//Texure 8 che formano la splat map

		_Offset("Offset", Vector) = (10,0,0,0)											//Offset he consente di modificare la distanza degli oggetti creati dal geometry

		_FirstAxisX("First GameObject Axis X", Float) = 0										//Valore della rotazione sull'asse X del primo GameObject
		_FirstAxisY("First GameObject Axis Y", Float) = 0										//Valore della rotazione sull'asse Y del primo GameObject
		_FirstAxisZ("First GameObject Axis Z", Float) = 0										//Valore della rotazione sull'asse Z del primo GameObject
		
		_SecondAxisX("Second GameObject Axis X", Float) = 0										//Valore della rotazione sull'asse X del Secondo GameObject
		_SecondAxisY("Second GameObject Axis Y", Float) = 0										//Valore della rotazione sull'asse Y del Secondo GameObject
		_SecondAxisZ("Second GameObject Axis Z", Float) = 0										//Valore della rotazione sull'asse Z del Secondo GameObject

		_ThirdAxisX("Third GameObject Axis X", Float) = 0										//Valore della rotazione sull'asse X del Terzo GameObject
		_ThirdAxisY("Third GameObject Axis Y", Float) = 0										//Valore della rotazione sull'asse Y del Terzo GameObject
		_ThirdAxisZ("Third GameObject Axis Z", Float) = 0										//Valore della rotazione sull'asse Z del Terzo GameObject


		[Toggle(Duplication)] _ToggleDuplication("ToggleDuplication", Float) = 1		//Toggle che consente di attivare o disattivare il geometry shader

		_Smoothness("Smoothness", Range(0, 1)) = 0.5									//Canale Smoothness dello shader					
		[Gamma] _Metallic("Metallic", Range(0, 1)) = 0									//Canale Metallic dello shader


		_NormalMap("Normals 1", 2D) = "bump" {}											//Texutre che rappresenta la normal map
		_BumpScale("Bump Scale ", Float) = 1											//Valore di bump della normal map
		_DetailNormalMap("Detail Normals 1", 2D) = "bump" {}							//Texutre che rappresenta la detail normal map
		_DetailBumpScale("Detail Bump Scale", Float) = 1								//Valore di bump della detail normal map


	}

	CGINCLUDE

	#define BINORMAL_PER_FRAGMENT

	ENDCG

	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }										//Tag che permette l'uso della luce derivata dalla directional light

			HLSLPROGRAM
			#pragma target 4.0															//Target per utilizzare funzionalità specifiche - 4.0 per l'utilizzo della geometry
			#pragma multi_compile _ VERTEXLIGHT_ON										//Pragma che aggiunge il supporto al vertex light
			#pragma vertex MyVertexProgram												//Definizione del pragma del vertex
			#pragma fragment MyFragmentProgram											//Definizione del pragma del fragment
			#pragma geometry geom														//Definizione del pragma del geometry
			#pragma shader_feature Duplication											//Definizione della feature della duplication, usata per l'attivazione del geometry

			#define FORWARD_BASE_PASS
			#include "UnityCG.cginc"													//Accesso alle funzionalità del linguaggio CG
			#include "PassLighting.cginc"												//Referenza al file cginc che contiene lo shader

			ENDHLSL
		}
		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }											//Tag che permette l'uso degli altri punti luce

			Blend One One																//Utilizzato per blendare la base con l'addittive
			ZWrite Off																	//Disattiva la scrittura nel depth buffer

			HLSLPROGRAM
			#pragma target 4.0															//Target per utilizzare funzionalità specifiche - 4.0 per l'utilizzo della geometry
			#pragma multi_compile_fwdadd												//Pragma per l'utilizzo dei punti luci
			#pragma vertex MyVertexProgram												//Definizione del pragma del vertex
			#pragma fragment MyFragmentProgram											//Definizione del pragma del fragment
			#pragma geometry geom														//Definizione del pragma del geometry
			#pragma shader_feature Duplication											//Definizione della feature della duplication, usata per l'attivazione del geometry

			#include "UnityCG.cginc"													//Accesso alle funzionalità del linguaggio CG
			#include "PassLighting.cginc"												//Referenza al file cginc che contiene lo shader

			ENDHLSL
		}
	}
}