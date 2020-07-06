#ifndef _ENBSMAA_FXH_
#define _ENBSMAA_FXH_
/*===========================================================================================
 *                                 file descriptions
=============================================================================================
 *  Dx11 (SM50) SMAA 1x wrapper for Enbseries 0.288+ by kingeric1992
 *
 *  for individual SMAA parameter descriptions, refers to SMAA.hlsl
 *  for reference SMAA, visit https://github.com/iryoku/smaa
 *  for more detail, visit http://enbseries.enbdev.com/forum/viewtopic.php?f=7&t=4721
 *                      or https://github.com/kingeric1992/enb-smaa
 *                                                                      update.  July/6/2020
 *
=============================================================================================
 *  Usage:
 *      Adding
 *          #include "SMAA/enbsmaa.fxh"
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
 *              #define  SMAA_EDGE_TEX      texture0name   // default is RenderTargetRGB32F (only requires 2bit-RGB channel)
 *              #define  SMAA_BLEND_TEX     texture1name   // default is RenderTargetRGBA64 (RGBA requred [0,1] )
 *
 *                                          prior to inclueing "enbsmaa.fx"
 *
===========================================================================================*/


#define SMAA_STRING(a) #a
//#pragma warning( disable : 3571)

SamplerState SMAA_LinearSamp { Filter = MIN_MAG_LINEAR_MIP_POINT; };
SamplerState SMAA_PointSamp  { Filter = MIN_MAG_MIP_POINT; };

struct SMAA_enbTex2D {
    Texture2D   tex;
    bool        sRGB;
    float4 get(float4 col) { return sRGB? pow(col, 1./2.2):col;}
};

#define SMAA_CUSTOM_SL
#define SMAATexture2D(t)                            SMAA_enbTex2D t
#define SMAATexturePass2D(t)                        t
#define SMAASampleLevelZero(t, coord)               t.get(t.tex.SampleLevel(SMAA_LinearSamp, coord, 0))
#define SMAASampleLevelZeroPoint(t, coord)          t.get(t.tex.SampleLevel(SMAA_PointSamp, coord, 0))
#define SMAASampleLevelZeroOffset(t, coord, offset) t.get(t.tex.SampleLevel(SMAA_LinearSamp, coord, 0, offset))
#define SMAASample(t, coord)                        t.get(t.tex.Sample(SMAA_LinearSamp, coord))
#define SMAASamplePoint(t, coord)                   t.get(t.tex.Sample(SMAA_PointSamp, coord))
#define SMAASampleOffset(t, coord, offset)          t.get(t.tex.Sample(SMAA_LinearSamp, coord, offset))
#define SMAAGather(t, coord)                        t.get(t.tex.Gather(SMAA_LinearSamp, coord, (int2)0))
#define SMAA_FLATTEN [flatten]
#define SMAA_BRANCH [branch]

#define SMAA_RT_METRICS float4( ScreenSize.y, ScreenSize.y * ScreenSize.z, ScreenSize.x, ScreenSize.x * ScreenSize.w)
#define SMAA_THRESHOLD              (smaa_threshold)
#define SMAA_MAX_SEARCH_STEPS       (smaa_maxSearchSteps)
#define SMAA_MAX_SEARCH_STEPS_DIAG  (smaa_maxSearchStepDiag) // 0 == disabled?
#define SMAA_CORNER_ROUNDING        (smaa_cornerRounding)
#define SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR (smaa_adaptFactor)
#define SMAA_PREDICATION_THRESHOLD  (pred_threshold)
#define SMAA_PREDICATION_SCALE      (pred_scale)
#define SMAA_PREDICATION_STRENGTH   (pred_strength)

// Wrap SMAA methods into struct, so that the variables are per instance
#define discard return -1   // this is to address discard but not exit in dx10+
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
#undef  discard // clean up

static const SMAA_t SMAA_Preset_Low     = { 0, 0.15, 4, 0, 100, 2, true, 0.01, 0.4, 2, 3 };
static const SMAA_t SMAA_Preset_Medium  = { 0, 0.1,  8, 0, 100, 2, true, 0.01, 0.4, 2, 3 };
static const SMAA_t SMAA_Preset_High    = { 0, 0.1, 16, 8,  25, 2, true, 0.01, 0.4, 2, 3 };
static const SMAA_t SMAA_Preset_Ultra   = { 0, 0.05,32,16,  25, 2, true, 0.01, 0.4, 2, 3 };

#ifndef SMAA_EDGE_TEX
#define SMAA_EDGE_TEX   RenderTargetRGB32F //R11G11B10
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

// Assests --------------------------------------------------------------------------------------------------------------------

Texture2D SMAA_enbAreaTex   < string UIName = "SMAA Area Tex";   string ResourceName = "SMAA/AreaTex.dds";   >;
Texture2D SMAA_enbSearchTex < string UIName = "SMAA Search Tex"; string ResourceName = "SMAA/SearchTex.dds"; >;

static const SMAA_enbTex2D  SMAA_AreaTex        = { SMAA_enbAreaTex, false };
static const SMAA_enbTex2D  SMAA_SearchTex      = { SMAA_enbAreaTex, false };
static const SMAA_enbTex2D  SMAA_ColorTex       = { TextureColor, false };
static const SMAA_enbTex2D  SMAA_ColorTexGamma  = { TextureColor, true };   // adding Gamma to emulate sRGB texture linear read
static const SMAA_enbTex2D  SMAA_DepthTex       = { TextureDepth, false };
static const SMAA_enbTex2D  SMAA_EdgeTex        = { SMAA_EDGE_TEX, false};
static const SMAA_enbTex2D  SMAA_BlendTex       = { SMAA_BLEND_TEX, false};

struct SMAA_VS_Struct {
    float4 pos       : SV_POSITION;
    float4 uv        : TEXCOORD0;
    float4 offset[3] : TEXCOORD1;
};

//----------------------------------------------------------------------------------------------------------------------------
void SMAA_edgeDetectionVS( inout SMAA_VS_Struct io, uniform SMAA_t params) {
    params.SMAAEdgeDetectionVS(io.uv.xy, io.offset);
    io.pos.w = 1.;
}

// todo: test performance of different switch flags
float4 SMAA_edgeDetectionPS( SMAA_VS_Struct i, uniform SMAA_t params) : SV_Target {
    float2 res = 0;
    if (params.pred_enabled) {
        switch(params.edgeMode) {
            case 1:  res = params.pred().SMAALumaEdgeDetectionPS(  i.uv.xy, i.offset, SMAA_ColorTexGamma, SMAA_DepthTex).rg; break;
            case 2:  res = params.pred().SMAADepthEdgeDetectionPS( i.uv.xy, i.offset, SMAA_DepthTex).xy; break;
            default: res = params.pred().SMAAColorEdgeDetectionPS( i.uv.xy, i.offset, SMAA_ColorTexGamma, SMAA_DepthTex).rg; break;
        }
    } else {
        switch(params.edgeMode) {
            case 1:  res = params.SMAALumaEdgeDetectionPS(  i.uv.xy, i.offset, SMAA_ColorTexGamma).rg; break;
            case 2:  res = params.SMAADepthEdgeDetectionPS( i.uv.xy, i.offset, SMAA_DepthTex).xy; break;
            default: res = params.SMAAColorEdgeDetectionPS( i.uv.xy, i.offset, SMAA_ColorTexGamma).rg; break;
        }
    }
    return float4(res, res.x < 0, 0); // res.xy = -1 when no edges. (leaving alpha incase of using non-alpha tex)
}

//----------------------------------------------------------------------------------------------------------------------------
void SMAA_blendingWeightCalcVS( inout SMAA_VS_Struct io, uniform SMAA_t params) {
    params.SMAABlendingWeightCalculationVS(io.uv.xy, io.uv.zw, io.offset);
    io.pos.w = 1.;
}

float4 SMAA_blendingWeightCalcPS( SMAA_VS_Struct i, uniform SMAA_t params) : SV_Target {
    if(SMAA_EdgeTex.tex.Load(i.pos.xyw).b > .5) return 0;
    return params.SMAABlendingWeightCalculationPS( i.uv.xy, i.uv.zw, i.offset, SMAA_EdgeTex, SMAA_AreaTex, SMAA_SearchTex, 0);
}

//----------------------------------------------------------------------------------------------------------------------------
void SMAA_neighborhoodBlendingVS( inout SMAA_VS_Struct io, uniform SMAA_t params) {
    params.SMAANeighborhoodBlendingVS(io.uv.xy, io.offset[0]);
    io.pos.w = 1.;
}

// todo: test performance of different flags
float4 SMAA_NeighborhoodBlendingPS( SMAA_VS_Struct i, uniform SMAA_t params) : SV_Target {
    switch (params.stage) {
        case 0:  return SMAA_ColorTex.tex.Load(i.pos.xyw);
        case 1:  return SMAA_EdgeTex.tex.Load( i.pos.xyw);
        case 2:  return SMAA_BlendTex.tex.Load(i.pos.xyw);
        default: return params.SMAANeighborhoodBlendingPS( i.uv.xy, i.offset[0], SMAA_ColorTex, SMAA_BlendTex);
    }
}

//----------------techniques--------------------------------------------------------------------------------------------------

#define SMAA_PASS0(p) <string RenderTarget= SMAA_STRING(SMAA_EDGE_TEX); > {\
    pass EdgeDetection {\
        SetVertexShader(CompileShader(vs_5_0, SMAA_edgeDetectionVS(p)));\
        SetPixelShader(CompileShader(ps_5_0, SMAA_edgeDetectionPS(p)));\
    }\
}
#define SMAA_PASS0_NAMED(p, name) <string RenderTarget= SMAA_STRING(SMAA_EDGE_TEX); string UIName = name ; > {\
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
#define SMAA_PASS2(p) {\
    pass NeighborhoodBlending {\
        SetVertexShader(CompileShader(vs_5_0, SMAA_neighborhoodBlendingVS(p)));\
        SetPixelShader(CompileShader(ps_5_0, SMAA_NeighborhoodBlendingPS(p)));\
    }\
}
#endif  // SMAA.fxh