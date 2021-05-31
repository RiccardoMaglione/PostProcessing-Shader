Shader "MyShader/ExerciseShader"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}										//Texture che rappresenta l'albedo principale
		_DetailMainTex("Detail Main Texture", 2D) = "grey" {}							//Texture che rappresenta la detail dell'albedo
		_Tint("Tint", Color) = (1, 1, 1, 1)												//Colore dell'albedo principale

		_SplatTex("_SplatTex", 2D) = "white" {}											//Splat Map utilizzata per suddividere la texture in base RGB

		_Texture1("Texture 1", 2D) = "white" {}											//Texture 1 che formano la splat map
		_DetailTexture1("Detail Texture 1", 2D) = "grey" {}								//Detail Texture 1 utilizzata per dare più dettagli alla texture 1
		_Texture2("Texture 2", 2D) = "white" {}											//Texture 2 che formano la splat map
		_DetailTexture2("Detail Texture 2", 2D) = "grey" {}								//Detail Texture 2 utilizzata per dare più dettagli alla texture 2
		_Texture3("Texture 3", 2D) = "white" {}											//Texture 3 che formano la splat map
		_DetailTexture3("Detail Texture 3", 2D) = "grey" {}								//Detail Texture 3 utilizzata per dare più dettagli alla texture 3
		_Texture4("Texture 4", 2D) = "white" {}											//Texture 4 che formano la splat map
		_DetailTexture4("Detail Texture 4", 2D) = "grey" {}								//Detail Texture 4 utilizzata per dare più dettagli alla texture 4
		_Texture5("Texture 5", 2D) = "white" {}											//Texture 5 che formano la splat map
		_DetailTexture5("Detail Texture 5", 2D) = "grey" {}								//Detail Texture 5 utilizzata per dare più dettagli alla texture 5
		_Texture6("Texture 6", 2D) = "white" {}											//Texture 6 che formano la splat map
		_DetailTexture6("Detail Texture 6", 2D) = "grey" {}								//Detail Texture 6 utilizzata per dare più dettagli alla texture 6
		_Texture7("Texture 7", 2D) = "white" {}											//Texture 7 che formano la splat map
		_DetailTexture7("Detail Texture 7", 2D) = "grey" {}								//Detail Texture 7 utilizzata per dare più dettagli alla texture 7
		_Texture8("Texture 8", 2D) = "white" {}											//Texture 8 che formano la splat map
		_DetailTexture8("Detail Texture 8", 2D) = "grey" {}								//Detail Texture 8 utilizzata per dare più dettagli alla texture 8

		_Offset("Offset", Vector) = (10,0,0,0)											//Offset he consente di modificare la distanza degli oggetti creati dal geometry

		_FirstAxisX("First GameObject Axis X", Float) = 0								//Valore della rotazione sull'asse X del primo GameObject
		_FirstAxisY("First GameObject Axis Y", Float) = 0								//Valore della rotazione sull'asse Y del primo GameObject
		_FirstAxisZ("First GameObject Axis Z", Float) = 0								//Valore della rotazione sull'asse Z del primo GameObject
		
		_SecondAxisX("Second GameObject Axis X", Float) = 0								//Valore della rotazione sull'asse X del Secondo GameObject
		_SecondAxisY("Second GameObject Axis Y", Float) = 0								//Valore della rotazione sull'asse Y del Secondo GameObject
		_SecondAxisZ("Second GameObject Axis Z", Float) = 0								//Valore della rotazione sull'asse Z del Secondo GameObject

		_ThirdAxisX("Third GameObject Axis X", Float) = 0								//Valore della rotazione sull'asse X del Terzo GameObject
		_ThirdAxisY("Third GameObject Axis Y", Float) = 0								//Valore della rotazione sull'asse Y del Terzo GameObject
		_ThirdAxisZ("Third GameObject Axis Z", Float) = 0								//Valore della rotazione sull'asse Z del Terzo GameObject

		[Toggle(Duplication)] _ToggleDuplication("ToggleDuplication", Float) = 1		//Toggle che consente di attivare o disattivare il geometry shader

		_Smoothness("Smoothness", Range(0, 1)) = 0.5									//Canale Smoothness dello shader					
		[Gamma] _Metallic("Metallic", Range(0, 1)) = 0									//Canale Metallic dello shader

		_NormalMap1("Normals 1", 2D) = "bump" {}										//Texture che rappresenta la normal map 1
		_BumpScale1("Bump Scale 1", Float) = 1											//Valore di bump della normal map 1
		_DetailNormalMap1("Detail Normals 1", 2D) = "bump" {}							//Texture che rappresenta la detail normal map 1
		_DetailBumpScale1("Detail Bump Scale 1", Float) = 1								//Valore di bump della detail normal map 1
		
		_NormalMap2("Normals 2", 2D) = "bump" {}										//Texture che rappresenta la normal map 2
		_BumpScale2("Bump Scale 2", Float) = 1											//Valore di bump della normal map 2
		_DetailNormalMap2("Detail Normals 2", 2D) = "bump" {}							//Texture che rappresenta la detail normal map 2
		_DetailBumpScale2("Detail Bump Scale 2", Float) = 1								//Valore di bump della detail normal map 2
		
		_NormalMap3("Normals 3", 2D) = "bump" {}										//Texture che rappresenta la normal map 3
		_BumpScale3("Bump Scale 3", Float) = 1											//Valore di bump della normal map 3
		_DetailNormalMap3("Detail Normals 3", 2D) = "bump" {}							//Texture che rappresenta la detail normal map 3
		_DetailBumpScale3("Detail Bump Scale 3", Float) = 1								//Valore di bump della detail normal map 3
		
		_NormalMap4("Normals 4", 2D) = "bump" {}										//Texture che rappresenta la normal map 4
		_BumpScale4("Bump Scale 4", Float) = 1											//Valore di bump della normal map 4
		_DetailNormalMap4("Detail Normals 4", 2D) = "bump" {}							//Texture che rappresenta la detail normal map 4
		_DetailBumpScale4("Detail Bump Scale 4", Float) = 1								//Valore di bump della detail normal map 4
		
		_NormalMap5("Normals 5", 2D) = "bump" {}										//Texture che rappresenta la normal map 5
		_BumpScale5("Bump Scale 5", Float) = 1											//Valore di bump della normal map 5
		_DetailNormalMap5("Detail Normals 5", 2D) = "bump" {}							//Texture che rappresenta la detail normal map 5
		_DetailBumpScale5("Detail Bump Scale 5", Float) = 1								//Valore di bump della detail normal map 5
		
		_NormalMap6("Normals 6", 2D) = "bump" {}										//Texture che rappresenta la normal map 6
		_BumpScale6("Bump Scale 6", Float) = 1											//Valore di bump della normal map 6
		_DetailNormalMap6("Detail Normals 6", 2D) = "bump" {}							//Texture che rappresenta la detail normal map 6
		_DetailBumpScale6("Detail Bump Scale 6", Float) = 1								//Valore di bump della detail normal map 6
		
		_NormalMap7("Normals 7", 2D) = "bump" {}										//Texture che rappresenta la normal map 7
		_BumpScale7("Bump Scale 7", Float) = 1											//Valore di bump della normal map 7
		_DetailNormalMap7("Detail Normals 7", 2D) = "bump" {}							//Texture che rappresenta la detail normal map 7
		_DetailBumpScale7("Detail Bump Scale 7", Float) = 1								//Valore di bump della detail normal map 7
		
		_NormalMap8("Normals 8", 2D) = "bump" {}										//Texture che rappresenta la normal map 8
		_BumpScale8("Bump Scale 8", Float) = 1											//Valore di bump della normal map 8
		_DetailNormalMap8("Detail Normals 8", 2D) = "bump" {}							//Texture che rappresenta la detail normal map 8
		_DetailBumpScale8("Detail Bump Scale 8", Float) = 1								//Valore di bump della detail normal map 8
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