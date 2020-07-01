#ifndef _ENBSMAA_FXH_
#define _ENBSMAA_FXH_
/*===========================================================================================
 *                                 file descriptions
=============================================================================================
 * implemented to enbeffectpostpass.fx by kingeric1992 for Fallout4/SkyrimSE ENB mod 0.288+
 *                                                                      update.  June/30/2020
 *      for more detail, visit http://enbseries.enbdev.com/forum/viewtopic.php?f=7&t=4721
 *
 ** Only SMAA 1x is avaliable
 *
 * SMAA T2x requires moving camera in sub pixel jitters.
 * SMAA S2x requires MSAA 2x buffer
 * SMAA 4x  requires both of the above
 *
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 *  Usage:
 *      Adding
 *          #include "enbsmaa.fxh"
 *                  after other enb resources, use existing preset ( or create new ones ),
 *  and insert SMAA techniques into your technique sections.
 *
 *          technique11 myTechniques3 {...}
 *          technique11 myTechniques4 SMAA_PASS0(SMAA_Preset_Low)
 *          technique11 myTechniques5 SMAA_PASS1(SMAA_Preset_Low)
 *          technique11 myTechniques6 SMAA_PASS2(SMAA_Preset_Low)
 *          technique11 myTechniques7 {...}
 *
 *  To use SMAA in first pass
 *          technique11 myTechniques  SMAA_PASS0_NAME(  SMAA_Preset_Mid, "smaa demo")
 *          technique11 myTechniques2 SMAA_PASS1(       SMAA_Preset_Mid)
 *          technique11 myTechniques3 SMAA_PASS2(       SMAA_Preset_Mid)
 *          technique11 myTechniques4 {...}
 *
 *  Presets includes SMAA_Preset_Low, SMAA_Preset_Mid, SMAA_Preset_High, SMAA_Preset_Ultra
 *
 *  To create custom preset, fill-in the SMAA_t struct directly
 *          static const SMAA_t myPreset = myPresetSetter() {
 *              SMAA_t o;
 *                  o.edgeMode           =
 *                  o.stage              =
 *
 *                  o.smaa_threshold          =
 *                  o.smaa_maxSearchSteps     =
 *                  o.smaa_maxSearchStepsDiag =
 *                  o.smaa_cornerRounding     =
 *                  o.smaa_adaptFactor        =
 *
 *                  o.pred_enabled       =
 *                  o.pred_threshold     =
 *                  o.pred_strength      =
 *                  o.pred_scale         =
 *              return o;
 *          }
 *  And use it in the techniques
 *
 *          technique11 myTechniques3 {...}
 *          technique11 myTechniques4 SMAA_PASS0(myPreset)
 *          technique11 myTechniques5 SMAA_PASS1(myPreset)
 *          technique11 myTechniques6 SMAA_PASS2(myPreset)
 *          technique11 myTechniques7 {...}
 *
 *  The SMAA header also includes a helper macro to create UI preset
 *
 *          SMAA_UI( "UI Prefix ", myUIPreset )
 *
 *  Where the "UI Prefix" is what will be prepend to UI elements.
 *
 *          technique11 myTechniques3 {...}
 *          technique11 myTechniques4 SMAA_PASS0(myUIPreset)
 *          technique11 myTechniques5 SMAA_PASS1(myUIPreset)
 *          technique11 myTechniques6 SMAA_PASS2(myUIPreset)
 *          technique11 myTechniques7 {...}
 *
 * in addition, you can change internal rendertarget with :
 *
 *              #define  SMAA_EDGE_TEX      texture0name   // default is RenderTargetRGB32F (only require 2bit-RG channel)
 *              #define  SMAA_BLEND_TEX     texture1name   // default is RenderTargetRGBA64 (RGBA requred [0,1] )
 *
 *                                          prior to inclueing "enbsmaa.fx"
 *
============================================================================================*/

/*============================================================================================
 * the following descriptions is provided in SMAA.h.
 *                                  for more detial on SMAA, visit http://www.iryoku.com/smaa/
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * SMAA_THRESHOLD specifies the threshold or sensitivity to edges.
 * Lowering this value you will be able to detect more edges at the expense of performance.
 *
 *      Range: [0, 0.5]
 *        0.1 is a reasonable value, and allows to catch most visible edges.
 *        0.05 is a rather overkill value, that allows to catch 'em all.
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 *
 * SMAA_MAX_SEARCH_STEPS specifies the maximum steps performed in the horizontal/vertical
 * pattern searches, at each side of the pixel.
 *
 *      Range: [0, 98]
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 *
 * SMAA_MAX_SEARCH_STEPS_DIAG specifies the maximum steps performed in the diagonal pattern
 * searches, at each side of the pixel. In this case we jump one pixel at time, instead of two.
 *
 *      Range: [0, 20]; set it to 0 to disable diagonal processing.
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 *
 * SMAA_CORNER_ROUNDING specifies how much sharp corners will be rounded.
 *
 *      Range: [0, 100]; set it to 100 to disable corner detection.
 *
=============================================================================================
 *                          Predicated thresholding
=============================================================================================
 * Predicated thresholding allows to better preserve texture details and to improve performance,
 * by decreasing the number of detected edges using an additional buffer like the light
 * accumulation buffer, object ids or even the depth buffer (the depth buffer usage may be
 * limited to indoor or short range scenes).
 *
 * It locally decreases the luma or color threshold if an edge is found in an additional buffer
 * (so the global threshold can be higher).
 *
 * This method was developed by Playstation EDGE MLAA team, and used in
 * Killzone 3, by using the light accumulation buffer. More information here:
 *     http://iryoku.com/aacourse/downloads/06-MLAA-on-PS3.pptx
 *
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * SMAA_PREDICATION_THRESHOLD: Threshold to be used in the additional predication buffer.
 *
 *      Range: depends on the input, so you'll have to find the magic number that works for you.
 *
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * SMAA_PREDICATION_SCALE: How much to scale the global threshold used for luma or color
 * edgedetection when using predication.
 *
 *      Range: [1, 5]
 *
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * SMAA_PREDICATION_STRENGTH:  How much to locally decrease the threshold.
 *
 *      Range: [0, 1]
 *
=============================================================================================
 *                             Copyright & Redistribution
=============================================================================================
 * Copyright (C) 2013 Jorge Jimenez (jorge@iryoku.com)
 * Copyright (C) 2013 Jose I. Echevarria (joseignacioechevarria@gmail.com)
 * Copyright (C) 2013 Belen Masia (bmasia@unizar.es)
 * Copyright (C) 2013 Fernando Navarro (fernandn@microsoft.com)
 * Copyright (C) 2013 Diego Gutierrez (diegog@unizar.es)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy this software
 * and associated documentation files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom
 * the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software. As clarification, there is no requirement that the
 * copyright notice and permission be included in binary distributions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
 * BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
=============================================================================================
 * end of descriptions
===========================================================================================*/


#define SMAA_STRING(a) #a
//#pragma warning( disable : 3571)

struct SMAA_enbTex2D {
    sampler2D   samp;
    bool        sRGB;

    float4 get(float4 col) {
        if (sRGB)   return pow(col, 1./2.2);
        else        return col;
    }
};

#define SMAATexture2D(tex)                              SMAA_enbTex2D tex
#define SMAATexturePass2D(tex)                          tex
#define SMAASampleLevelZero(tex, coord)                 tex.get( tex2Dlod(tex.samp, float4(coord, 0.0, 0.0) ))
#define SMAASampleLevelZeroPoint(tex, coord)            tex.get( tex2Dlod(tex.samp, float4(coord, 0.0, 0.0) ))
#define SMAASampleLevelZeroOffset(tex, coord, offset)   tex.get( tex2Dlod(tex.samp, float4(coord + offset * SMAA_RT_METRICS.xy, 0.0, 0.0)))
#define SMAASample(tex, coord)                          tex.get( tex2D(tex.samp, coord))
#define SMAASamplePoint(tex, coord)                     tex.get( tex2D(tex.samp, coord))
#define SMAASampleOffset(tex, coord, offset)            tex.get( tex2D(tex.samp, coord + offset * SMAA_RT_METRICS.xy))
#define SMAA_FLATTEN [flatten]
#define SMAA_BRANCH [branch]

#define SMAA_RT_METRICS             float4( ScreenSize.y, ScreenSize.y * ScreenSize.z, ScreenSize.x, ScreenSize.x * ScreenSize.w)
#define SMAA_THRESHOLD              (smaa_threshold)
#define SMAA_MAX_SEARCH_STEPS       (smaa_maxSearchSteps)
#define SMAA_MAX_SEARCH_STEPS_DIAG  (smaa_maxSearchStepDiag) // 0 == disabled?
#define SMAA_CORNER_ROUNDING        (smaa_cornerRounding)
#define SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR (smaa_adaptFactor)
#define SMAA_PREDICATION_THRESHOLD  (pred_threshold)
#define SMAA_PREDICATION_SCALE      (pred_scale)
#define SMAA_PREDICATION_STRENGTH   (pred_strength)

// Wrap SMAA methods into struct, so that the variables are per instance
struct SMAA_pred_t {
    float   smaa_threshold;
    uint    smaa_maxSearchSteps;
    uint    smaa_maxSearchStepDiag;
    uint    smaa_cornerRounding;
    float   smaa_adaptFactor;   // local contrast adaptation factor

    float   pred_threshold;
    float   pred_strength;
    float   pred_scale;

    #define SMAA_PREDICATION 1
    #include "SMAA/SMAA.hlsl"
};

struct SMAA_t {
    uint    edgeMode;  // 0 = ColorEdge, 1 = LumaEdge, 2 = DepthEdge

    float   smaa_threshold;
    uint    smaa_maxSearchSteps;
    uint    smaa_maxSearchStepDiag;
    uint    smaa_cornerRounding;
    float   smaa_adaptFactor;   // local contrast adaptation factor

    bool    pred_enabled;
    float   pred_threshold;
    float   pred_strength;
    float   pred_scale;

    uint    stage;     // 0 = frameBuffer, 1 = edgeTex, 2 = blendWeight, 3 = SMAA

    SMAA_pred_t pred() {
        SMAA_pred_t o = {
            smaa_threshold, smaa_maxSearchSteps, smaa_maxSearchStepDiag, smaa_cornerRounding,
            smaa_adaptFactor, pred_threshold, pred_strength, pred_scale
        };
        return o;
    }
    #undef  SMAA_PREDICATION
    #include "SMAA/SMAA.hlsl"
};

static const SMAA_t SMAA_Preset_Low     = { 0, 0.15, 4, 0, 100, 2, true, 0.01, 0.4, 2, 3 };
static const SMAA_t SMAA_Preset_Medium  = { 0, 0.1,  8, 0, 100, 2, true, 0.01, 0.4, 2, 3 };
static const SMAA_t SMAA_Preset_High    = { 0, 0.1, 16, 8,  25, 2, true, 0.01, 0.4, 2, 3 };
static const SMAA_t SMAA_Preset_Ultra   = { 0, 0.05,32,16,  25, 2, true, 0.01, 0.4, 2, 3 };

#ifndef SMAA_EDGE_TEX
#define SMAA_EDGE_TEX   RenderTargetRGB32F
#endif
#ifndef SMAA_BLEND_TEX
#define SMAA_BLEND_TEX  RenderTargetRGBA64
#endif

//-------------------Internal resource & helpers-------------------------------------------------------------------------------
#define SMAA_UI( prefix, var  ) \
uint    var##_edgeMode           < string UIName= prefix " Edge Mode";             int UIMin=0; int    UIMax=2;    > = {0};\
float   var##_threshold          < string UIName= prefix " Threshold";             int UIMin=0; float  UIMax=0.5;  > = {0.15};\
uint    var##_maxSearchSteps     < string UIName= prefix " Search Steps";          int UIMin=0; int    UIMax=98;   > = {64};\
uint    var##_maxSearchStepsDiag < string UIName= prefix " Diagonal Search Steps"; int UIMin=0; int    UIMax=20;   > = {16};\
uint    var##_cornerRounding     < string UIName= prefix " Corner Rounding";       int UIMin=0; int    UIMax=100;  > = {8};\
float   var##_contraAdapt        < string UIName= prefix " Contrast Adaptation";   int UIMin=0; float  UIMax=5.0;  > = {2.0};\
bool    var##_predication        < string UIName= prefix " Predication";           > = {true};\
uint    var##_thresholdP         < string UIName= prefix " Predication Threshold"; int UIMin=0; int    UIMax=1;    > = {0.01};\
uint    var##_strengthP          < string UIName= prefix " Predication Strength";  int UIMin=1; int    UIMax=5;    > = {2};\
uint    var##_scaleP             < string UIName= prefix " Predication Scale";     int UIMin=0; int    UIMax=1;    > = {0.4};\
\
static const SMAA_t var = {\
    var##_edgeMode,\
    var##_threshold,\
    var##_maxSearchSteps,\
    var##_maxSearchStepsDiag,\
    var##_cornerRounding,\
    var##_contraAdapt,\
    var##_predication,\
    var##_thresholdP,\
    var##_strengthP,\
    var##_scaleP, 3\
};

// note, the edge detection wants "gamma encoded" tex
#define SMAA_TEX(name, tex, gamma) sampler2D name##_s = sampler_state { \
    Texture   = <tex>; SRGBTexture=FALSE; \
    MinFilter = LINEAR; MagFilter = LINEAR; \
    AddressU  = Clamp; AddressV  = Clamp; \
}; static const SMAA_enbTex2D name = { name##s, gamma }

// Assests --------------------------------------------------------------------------------------------------------------------

texture2D SMAA_enbAreaTex   < string UIName = "SMAA Area Tex";   string ResourceName = "SMAA/SMAA_AreaTex.dds";   >;
texture2D SMAA_enbSearchTex < string UIName = "SMAA Search Tex"; string ResourceName = "SMAA/SMAA_SearchTex.dds"; >;

SMAA_TEX(SMAA_AreaTex,       SMAA_enbAreaTex,   false );
SMAA_TEX(SMAA_SearchTex,     SMAA_enbSearchTex, false );
SMAA_TEX(SMAA_ColorTex,      texColor,          false );
SMAA_TEX(SMAA_ColorTexGamma, texColor,          true  );
SMAA_TEX(SMAA_DepthTex,      texDepth,          false );
SMAA_TEX(SMAA_EdgeTex,       SMAA_EDGE_TEX,     false );
SMAA_TEX(SMAA_BlendTex,      SMAA_BLEND_TEX,    false );

struct SMAA_VS_Struct {
    float4 pos       : POSITION;
    float4 uv        : TEXCOORD0;
    float4 offset[3] : TEXCOORD1;
};

//----------------------------------------------------------------------------------------------------------------------------
void SMAA_edgeDetectionVS( inout SMAA_VS_Struct io, uniform SMAA_t params) {
    params.SMAAEdgeDetectionVS(io.uv.xy, io.offset);
    io.pos.w = 1.;
}

float4 SMAA_edgeDetectionPS( SMAA_VS_Struct i, uniform SMAA_t params) : COLOR {
    if (params.pred_enabled) {
        switch(params.edgeMode) {
            case 1:  return float4(params.pred().SMAALumaEdgeDetectionPS(  i.uv.xy, i.offset, SMAA_ColorTexGamma, SMAA_DepthTex).rg, 0, 1);
            case 2:  return float4(params.pred().SMAADepthEdgeDetectionPS( i.uv.xy, i.offset, SMAA_DepthTex).xy, 0, 1);
            default: return float4(params.pred().SMAAColorEdgeDetectionPS( i.uv.xy, i.offset, SMAA_ColorTexGamma, SMAA_DepthTex).rg, 0, 1);
        }
    } else {
        switch(params.edgeMode) {
            case 1:  return float4(params.SMAALumaEdgeDetectionPS(  i.uv.xy, i.offset, SMAA_ColorTexGamma).rg, 0, 1);
            case 2:  return float4(params.SMAADepthEdgeDetectionPS( i.uv.xy, i.offset, SMAA_DepthTex).xy, 0, 1);
            default: return float4(params.SMAAColorEdgeDetectionPS( i.uv.xy, i.offset, SMAA_ColorTexGamma).rg, 0, 1);
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------
void SMAA_blendingWeightCalcVS( inout SMAA_VS_Struct io, uniform SMAA_t params) {
    params.SMAABlendingWeightCalculationVS(io.uv.xy, io.uv.zw, io.offset);
    io.pos.w = 1.;
}

float4 SMAA_blendingWeightCalcPS( SMAA_VS_Struct i, uniform SMAA_t params) : COLOR {
    if(SMAA_EdgeTex.Load(i.pos.xyw).a < .5) discard;
    return params.SMAABlendingWeightCalculationPS( i.uv.xy, i.uv.zw, i.offset, SMAA_EdgeTex, SMAA_AreaTex, SMAA_SearchTex, 0);
}

//----------------------------------------------------------------------------------------------------------------------------
void SMAA_neighborhoodBlendingVS( inout SMAA_VS_Struct io, uniform SMAA_t params) {
    params.SMAANeighborhoodBlendingVS(io.uv.xy, io.offset[0]);
    io.pos.w = 1.;
}

float4 SMAA_NeighborhoodBlendingPS( SMAA_VS_Struct i, uniform SMAA_t params) : COLOR {
    switch (params.stage) {
        case 0:  return tex2D(SMAA_ColorTex.samp, i.uv.xy);
        case 1:  return tex2D(SMAA_EdgeTex.samp,  i.uv.xy);
        case 2:  return tex2D(SMAA_BlendTex.samp, i.uv.xy);
        default: return params.SMAANeighborhoodBlendingPS( i.uv.xy, i.offset[0], SMAA_ColorTex, SMAA_BlendTex);
    }
}

//----------------techniques--------------------------------------------------------------------------------------------------

#define SMAA_PASS0(p) <string RenderTarget= SMAA_STRING(SMAA_EDGE_TEX); > {\
    pass EdgeDetection {\
        VertexShader = compile vs_3_0 SMAA_edgeDetectionVS(p);\
        PixelShader  = compile ps_3_0 SMAA_edgeDetectionPS(p);\
    }\
}
#define SMAA_PASS0_NAMED(p, name) <string RenderTarget= SMAA_STRING(SMAA_EDGE_TEX); string UIName = name ; > {\
    pass EdgeDetection {\
        VertexShader = compile vs_3_0 SMAA_edgeDetectionVS(p);\
        PixelShader  = compile ps_3_0 SMAA_edgeDetectionPS(p);\
    }\
}
#define SMAA_PASS1(p) <string RenderTarget=SMAA_STRING(SMAA_BLEND_TEX);> {\
    pass BlendingWeightCalculation {\
        VertexShader = compile vs_3_0 SMAA_blendingWeightCalcVS(p);\
        PixelShader  = compile ps_3_0 SMAA_blendingWeightCalcPS(p);\
    }\
}
#define SMAA_PASS2(p) {\
    pass NeighborhoodBlending {\
        VertexShader = compile vs_3_0 SMAA_neighborhoodBlendingVS(p);\
        PixelShader  = compile ps_3_0 SMAA_NeighborhoodBlendingPS(p);\
    }\
}
#endif  // SMAA.fxh