// Crest Ocean System

// This file is subject to the MIT License as seen in the root of this folder structure (LICENSE)

// A batch of Gerstner components
Shader "Crest/Inputs/Animated Waves/Gerstner Batch Geometry"
{
	Properties
	{
		// This is purely for convenience - it makes the value appear in material section of the inspector and is useful for debugging.
		_NumInBatch("_NumInBatch", float) = 0
	}

	SubShader
	{
		Pass
		{
			Blend One One
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile __ _DIRECT_TOWARDS_POINT

			#include "UnityCG.cginc"

			#include "../../OceanGlobals.hlsl"
			#include "../../OceanInputsDriven.hlsl"
			#include "../../OceanLODData.hlsl"

			#include "GerstnerShared.hlsl"

			struct Attributes
			{
				float3 positionOS : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 worldPosXZ_uv : TEXCOORD0;
				float4 uv_slice_wt : TEXCOORD1;
			};

			Varyings Vert(Attributes input)
			{
				Varyings o;
				o.positionCS = UnityObjectToClipPos(input.positionOS);

				o.worldPosXZ_uv.xy = mul(unity_ObjectToWorld, float4(input.positionOS, 1.0)).xz;
				o.worldPosXZ_uv.zw = input.uv;

				o.uv_slice_wt.xyz = WorldToUV(o.worldPosXZ_uv.xy, _LD_SliceIndex);
				o.uv_slice_wt.w = 1.0;
				return o;
			}

			half4 Frag(Varyings input) : SV_Target
			{
				float2 offset = abs(input.worldPosXZ_uv.zw - 0.5);
				float r_l1 = max(offset.x, offset.y);
				float wt = saturate(1.0 - (r_l1 - 0.4) / 0.1);
				return wt * ComputeGerstner(input.worldPosXZ_uv.xy, input.uv_slice_wt.xyz);
			}
			ENDCG
		}
	}
}
