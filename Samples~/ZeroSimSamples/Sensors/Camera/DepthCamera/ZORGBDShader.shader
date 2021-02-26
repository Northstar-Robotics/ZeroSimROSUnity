﻿Shader "ZOSim/ZODepthShader"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // markers that specify that we don't need culling 
        // or comparing/writing to the depth buffer
        Cull Off
        ZWrite Off 
        ZTest Always

        Pass
        {
            Tags{ "RenderType" = "Opaque" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;

            /// Depth textures are available for sampling in shaders as global shader properties. 
            /// By declaring a sampler called _CameraDepthTexture you will be able to sample the main 
            /// depth texture for the camera.
            /// See: https://docs.unity3d.com/Manual/SL-CameraDepthTexture.html
            sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                //convert the vertex positions from object space to clip space so they can be rendered
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                //get depth from depth texture
                float depth = tex2D(_CameraDepthTexture, i.uv).r;
                // //linear depth between camera and far clipping plane
                depth = Linear01Depth(depth);
                //depth as distance from camera in units 
                depth = depth * _ProjectionParams.z;
                col.a = depth;
                return col;
            }
            ENDCG
        }
    }
}