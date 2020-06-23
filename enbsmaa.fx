#ifndef _ENBSMAA_FX_
#define _ENBSMAA_FX_
/*===========================================================================================
 *                                 file descriptions
=============================================================================================
 * implemented to enbeffectpostpass.fx by kingeric1992 for Fallout 4 ENB mod 0.288+
 *                                                                      update.  June/21/2020
 *      for more detail, visit http://enbseries.enbdev.com/forum/viewtopic.php?f=7&t=4721
 *
 ** Only SMAA 1x is avaliable
 *
 * SMAA T2x requires moving camera in sub pixel jitters.
 * SMAA S2x requires MSAA 2x buffer
 * SMAA 4x  requires both of the above
 *
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * Usage:
 * (optional)
 *              #define  SMAA_UINAME My Awsome Name
 * add
 *              #define  PASSNAME0   targetname
 *              #define  PASSNAME1   targetname1
 *              #define  PASSNAME2   targetname2
 *              #include "enbsmaa.fx"
 *                                          at the end of enbeffectpostpass.fx.
 * where the targetname(N) is follow up the technique chain and increment to one before, if
 * the last technique is called THISPASS4, then set targetname to THISPASS5 and the rest with
 * increasing index.  ( targetname index "0" is empty )
 *
 * If you wish to have SMAA as standalone effect that doesn't chain after other technique, set
 * SMAA_UINAME to 1 and have the pass index start from empty (which means "0").
 *
 * in addition, you can change internal rendertarget with :
 * (they will be cleard, so change to other texture if any of the default tex is in used to pass
 * along data, otherwise, ignore this.)
 *
 *              #define  SMAA_EDGE_TEX      texture0name   // default is RenderTargetRGB32F (only require 2bit-RG channel)
 *              #define  SMAA_BLEND_TEX     texture1name   // default is RenderTargetRGBA64 (RGBA requred [0,1] )
 *
 *                                          prior to inclueing "enbsmaa.fx"
 *
 * Loading multiple times with different PASSNAME is possible (under same name is not recommended).
 *
==============================================================================================
 *                              Settings
============================================================================================*/

#define SMAA_PREDICATION 1  // 0 == off, 1 == on, 2 == dynamic.



/*============================================================================================
 *                            setting descriptions
==============================================================================================
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


#ifndef SMAA_PREFIX
    #error  SMAA_PREFIX define required.
#endif

#define SMAA_STRING(a) #a
#define SMAA_CAT(a) SMAA_PREFIX##a


#ifndef SMAA_TEXTUREPATH
    #define SMAA_TEXTUREPATH
#endif

SamplerState SMAA_LinearSamp { Filter = MIN_MAG_LINEAR_MIP_POINT; };
SamplerState SMAA_PointSamp { Filter = MIN_MAG_MIP_POINT; };
struct SMAA_enbTex2D {
    Texture2D   tex;
    bool        sRGB;

    float4 get(float4 col) {
        //return col <= 0.0031308? (12.92 * col) : (1.055 * pow(col,1./2.4) - 0.055);
        if (sRGB)   return pow(col, 2.2);
        else        return col;
    }
    float4 SampleLevel(SamplerState samp, float2 coord, int lod) { return get(tex.SampleLevel(samp, coord, lod)); }
    float4 SampleLevel(SamplerState samp, float2 coord, int lod, float2 off) { return get(tex.SampleLevel(samp, coord, lod, off)); }
    float4 Load(int3 pos, int2 offset) { return get(tex.Load(pos, offset)); } // only used in multi-sample shader
    float4 Gather(SamplerState samp, float2 loc, int2 offset) { return get(tex.Gather(samp, loc, offset)); }
};

#define SMAA_CUSTOM_SL
#define SMAATexture2D(tex) SMAA_enbTex2D tex
#define SMAATexturePass2D(tex) tex
#define SMAASampleLevelZero(tex, coord) tex.SampleLevel(SMAA_LinearSamp, coord, 0)
#define SMAASampleLevelZeroPoint(tex, coord) tex.SampleLevel(SMAA_PointSamp, coord, 0)
#define SMAASampleLevelZeroOffset(tex, coord, offset) tex.SampleLevel(SMAA_LinearSamp, coord, 0, offset)
#define SMAASample(tex, coord) tex.Sample(SMAA_LinearSamp, coord)
#define SMAASamplePoint(tex, coord) tex.Sample(SMAA_PointSamp, coord)
#define SMAASampleOffset(tex, coord, offset) tex.Sample(SMAA_LinearSamp, coord, offset)
#define SMAA_FLATTEN [flatten]
#define SMAA_BRANCH [branch]
#define SMAAGather(tex, coord) tex.Gather(LinearSampler, coord, 0)
#define SMAA_RT_METRICS float2( ScreenSize.y, ScreenSize.y * ScreenSize.z, ScreenSize.x, ScreenSize.x * ScreenSize.w)
#define SMAA_THRESHOLD              (threshold)
#define SMAA_MAX_SEARCH_STEPS       (maxSearchSteps)
#define SMAA_MAX_SEARCH_STEPS_DIAG  (maxSearchStepDiag) // 0 == disabled?
#define SMAA_CORNER_ROUNDING        (cornerRounding)
#define SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR (contraAdapt)
#define SMAA_PREDICATION_THRESHOLD  (pred_threshold)
#define SMAA_PREDICATION_SCALE      (pred_scale)
#define SMAA_PREDICATION_STRENGTH   (pred_strength)
#define discard return 0   // this is to address discard but not exit in dx10+
// Wrap SMAA methods into struct, so that the variables are per instance

class SMAA_Base_t {
    uint edgeMode;  // 0 = ColorEdge, 1 = LumaEdge, 2 = DepthEdge
    uint stage;     // 0 = frameBuffer, 1 = edgeTex, 2 = blendWeight, 3 = SMAA

    float   threshold;
    uint    maxSearchSteps;
    uint    maxSearchStepDiag;
    uint    cornerRounding;
    float   contraAdapt;

    #include "SMAA.hlsl"
};

// this will override func with same signature
class SMAA_t : SMAA_Base_t {
    bool    pred_enabled;
    float   pred_threshold;
    float   pred_strength;
    float   pred_scale;

    #undef  SMAA_PREDICATION
    #define SMAA_PREDICATION 1
    #include "SMAA.hlsl"
};


static const uint SMAA_edgeMode = 0;
static const bool SMAA_predication = true;
static const SMAA_t SMAA_Preset_Low     = { SMAA_edgeMode, 3, 0.15, 4, 0, 100, SMAA_predication, 0.01, 0.4, 2.0 };
static const SMAA_t SMAA_Preset_Medium  = { SMAA_edgeMode, 3, 0.1,  8, 0, 100, SMAA_predication, 0.01, 0.4, 2.0 };
static const SMAA_t SMAA_Preset_High    = { SMAA_edgeMode, 3, 0.1, 16, 8,  25, SMAA_predication, 0.01, 0.4, 2.0 };
static const SMAA_t SMAA_Preset_Ultra   = { SMAA_edgeMode, 3, 0.05,32,16,  25, SMAA_predication, 0.01, 0.4, 2.0 };
//static const SMAA_t SMAA_Preset_Custom  = { SMAA_edgeMode, 3, 0.05,32,16,  25, SMAA_predication, 0.01, 0.4, 2.0 };
#undef  discard // clean up

#ifndef SMAA_EDGE_TEX
#define SMAA_EDGE_TEX   RenderTargetRGB32F
#endif
#ifndef SMAA_BLEND_TEX
#define SMAA_BLEND_TEX  RenderTargetRGBA64
#endif
#ifndef SMAA_UINAME
#define SMAA_UINAME 1
#endif

uint    prefix##_quality            < string UIName= #prefix " Presets";               int UIMin=0; int    UIMax=4;    > = {5};\
//-------------------Internal resource & helpers-------------------------------------------------------------------------------
#define SMAA_UI( prefix, var  ) \
uint    prefix##_edgeMode           < string UIName= #prefix " Edge Mode";             int UIMin=0; int    UIMax=2;    > = {0};\
float   prefix##_threshold          < string UIName= #prefix " Threshold";             int UIMin=0; float  UIMax=0.5;  > = {0.15};\
uint    prefix##_maxSearchSteps     < string UIName= #prefix " Search Steps";          int UIMin=0; int    UIMax=98;   > = {64};\
uint    prefix##_maxSearchStepsDiag < string UIName= #prefix " Diagonal Search Steps"; int UIMin=0; int    UIMax=20;   > = {16};\
uint    prefix##_cornerRounding     < string UIName= #prefix " Corner Rounding";       int UIMin=0; int    UIMax=100;  > = {8};\
float   prefix##_contraAdapt        < string UIName= #prefix " Contrast Adaptation";   int UIMin=0; float  UIMax=5.0;  > = {2.0};\
bool    prefix##_predication        < string UIName= #prefix " Predication";           > = {true};\
uint    prefix##_thresholdP         < string UIName= #prefix " Predication Threshold"; int UIMin=0; int    UIMax=1;    > = {0.01};\
uint    prefix##_strengthP          < string UIName= #prefix " Predication Strength";  int UIMin=1; int    UIMax=5;    > = {2};\
uint    prefix##_scaleP             < string UIName= #prefix " Predication Scale";     int UIMin=0; int    UIMax=1;    > = {0.4};\
uint    prefix##_Stagetex           < string UIName= #prefix " Show Stage Tex";        int UIMin=0; int    UIMax=3;    > = {3};\
\
static const SMAA_t var = {\
    prefix##_edgeMode,\
    prefix##_Stagetex,\
    prefix##_threshold,\
    prefix##_maxSearchSteps,\
    prefix##_maxSearchStepsDiag,\
    prefix##_cornerRounding,\
    prefix##_contraAdapt,\
    prefix##_predication,\
    prefix##_thresholdP,\
    prefix##_strengthP,\
    prefix##_scaleP\
};

// Assests --------------------------------------------------------------------------------------------------------------------

Texture2D SMAA_enbAreaTex   < string UIName = "SMAA Area Tex";   string ResourceName = SMAA_TEXTUREPATH "SMAA_AreaTex.dds";   >;
Texture2D SMAA_enbSearchTex < string UIName = "SMAA Search Tex"; string ResourceName = SMAA_TEXTUREPATH "SMAA_SearchTex.dds"; >;

static const SMAA_enbTex2D  SMAA_AreaTex        = { SMAA_enbAreaTex, false };
static const SMAA_enbTex2D  SMAA_SearchTex      = { SMAA_enbAreaTex, false };
static const SMAA_enbTex2D  SMAA_ColorTex       = { TextureColor, false };
static const SMAA_enbTex2D  SMAA_ColorTexGamma  = { TextureColor, true };   // sRGB texture
static const SMAA_enbTex2D  SMAA_DepthTex       = { TextureDepth, false };
static const SMAA_enbTex2D  SMAA_EdgeTex        = { SMAA_EDGE_TEX, false};
static const SMAA_enbTex2D  SMAA_BlendTex       = { SMAA_BLEND_TEX, false};

struct SMAA_VS_Struct
{
    float4 pos       : SV_POSITION;
    float4 uv        : TEXCOORD0;
    float4 offset[3] : TEXCOORD1;
};

//----------------------------------------------------------------------------------------------------------------------------
void SMAA_edgeDetectionVS( inout SMAA_VS_Struct io, uniform SMAA_t parmas) {
    params.SMAAEdgeDetectionVS(io.uv.xy, io.offset);
    io.pos.w = 1.;
}

float4 SMAA_edgeDetectionPS( SMAA_VS_Struct i, uniform SMAA_t params) : SV_Target {
    if (params.pred_enabled) {
        switch(params.edgeMode) {
            case 1:  return float4(params.SMAALumaEdgeDetectionPS( i.uv.xy, i.offset, SMAA_ColorTexGamma, SMAA_DepthTex).rgb, 1.);
            case 2:  return float4(params.SMAADepthEdgeDetectionPS( i.texcoord, i.offset, SMAA_DepthTex).xyz, 1.);
            default: return float4(params.SMAAColorEdgeDetectionPS( i.uv.xy, i.offset, SMAA_ColorTexGamma, SMAA_DepthTex).rgb, 1.);
        }
    } else {
        switch(params.edgeMode) {
            case 1:  return float4(params.SMAALumaEdgeDetectionPS( i.uv.xy, i.offset, SMAA_ColorTexGamma).rgb, 1.);
            case 2:  return float4(params.SMAADepthEdgeDetectionPS( i.texcoord, i.offset, SMAA_DepthTex).xyz, 1.);
            default: return float4(params.SMAAColorEdgeDetectionPS( i.uv.xy, i.offset, SMAA_ColorTexGamma).rgb, 1.);
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------
void SMAA_blendingWeightCalcVS( inout SMAA_VS_Struct io, uniform SMAA_t params) {
    params.SMAABlendingWeightCalculationVS(io.uv.xy, io.uv.zw, io.offset);
    io.pos.w = 1.;
}

float4 SMAA_blendingWeightCalcPS( SMAA_VS_Struct i, uniform SMAA_t params) : SV_Target {
    if(SMAA_EdgeTex.tex.Load(i.pos.xyw).a < .5) return 0;
    return params.SMAABlendingWeightCalculationPS( i.uv.xy, i.uv.zw, i.offset, SMAA_EdgeTex, SMAA_AreaTex, SMAA_SearchTex, 0);
}

//----------------------------------------------------------------------------------------------------------------------------
void SMAA_neighborhoodBlendingVS( inout SMAA_VS_Struct io, uniform SMAA_t params) {
    params.SMAANeighborhoodBlendingVS(io.uv.xy, io.offset[0]);
    io.pos.w = 1.;
}

float4 SMAA_NeighborhoodBlendingPS( VS_OUTPUT_SMAA i, uniform SMAA_t params) : SV_Target {
    switch (params.stage) {
        case 0:  return SMAA_ColorTex.tex.Load(i.pos.xyw);
        case 1:  return SMAA_EdgeTex.tex.Load(i.pos.xyw);
        case 2:  return SMAA_BlendTex.tex.Load(i.pos.xyw);
        default: return params.SMAANeighborhoodBlendingPS( i.uv.xy, i.offset[0], SMAA_ColorTex, SMAA_BlendTex);
    }
}
#endif  // SMAA.fxh


//----------------techniques--------------------------------------------------------------------------------------------------
#ifdef SMAA_UINAME
    #define SMAA_STRNAME string UIName=SMAA_STRING(SMAA_UINAME)
    #undef SMAA_UINAME
#else
    #define SMAA_STRNAME
#endif

#define SMAA_PASS0(p) <string RenderTarget= SMAA_STRING(SMAA_EDGE_TEX); SMAA_STRNAME; > {\
    pass EdgeDetection {\
        SetVertexShader(CompileShader(vs_5_0, SMAA_edgeDetectionVS(p)));\
        SetPixelShader(CompileShader(ps_5_0, SMAA_edgeDetectionPS(p)));\
    }\
}
#define SMAA_PASS1(p) <string RenderTarget=SMAA_STRING(SMAA_BLEND_TEX);> {\
    pass BlendingWeightCalculation {\
        SetVertexShader(CompileShader(vs_5_0, SMAA_blendingWeightCalcVS(p)));\
        SetPixelShader(CompileShader(ps_5_0, SMAA_blendingWeightCalcPS(p)));\
    }\
}
#define SMAA_PASS2 {\
    pass NeighborhoodBlending {\
        SetVertexShader(CompileShader(vs_5_0, SMAA_neighborhoodBlendingVS(p)));\
        SetPixelShader(CompileShader(ps_5_0, SMAA_NeighborhoodBlendingPS(p)));\
    }\
}