#ifndef _ENBSMAA_FXH_
#define _ENBSMAA_FXH_
/*===========================================================================================
 *                                 file descriptions
=============================================================================================
 *  Dx9 (SM30) SMAA 1x wrapper for Enbseries 0.288+ by kingeric1992
 *
 *  for individual SMAA parameter descriptions, refers to SMAA.hlsl
 *  for reference SMAA, visit https://github.com/iryoku/smaa
 *  for more detail, visit http://enbseries.enbdev.com/forum/viewtopic.php?f=7&t=4721
 *                      or https://github.com/kingeric1992/enb-smaa
 *                                                                      update.  July/20/2021
 *  note: SMAA.hlsl was modified for dx9 compatibility.
 *
=============================================================================================
 *  Usage:
 *      Adding
 *          #include "SMAA/enbsmaa.fxh"
 *                  after other enb resources, use existing preset ( or create new ones ),
 *  and insert SMAA techniques into your technique sections.
 *
 *          technique myTechniques3 {...}
 *          technique myTechniques4 SMAA_PASS0(SMAA_Preset_Low)
 *          technique myTechniques5 SMAA_PASS1(SMAA_Preset_Low)
 *          technique myTechniques6 SMAA_PASS2(SMAA_Preset_Low)
 *          technique myTechniques7 {...}
 *
 *  To use SMAA in first pass
 *          technique myTechniques  SMAA_PASS0_NAME(  SMAA_Preset_Mid, "smaa demo")
 *          technique myTechniques2 SMAA_PASS1(       SMAA_Preset_Mid)
 *          technique myTechniques3 SMAA_PASS2(       SMAA_Preset_Mid)
 *          technique myTechniques4 {...}
 *
 *  Presets includes SMAA_Preset_Low, SMAA_Preset_Mid, SMAA_Preset_High, SMAA_Preset_Ultra
 *
 *  To create custom preset, fill-in the SMAA_t struct directly with helper function,
 *          static const SMAA_t myPreset = myPresetSetter() {
 *              SMAA_t o;
 *                  o.edgeMode           =  // 0 = ColorEdge, 1 = LumaEdge, 2 = DepthEdge
 *                  o.stage              =  // 0 = frameBuffer, 1 = edgeTex, 2 = blendWeight, 3 = SMAA
 *
 *                  o.smaa_threshold          =
 *                  o.smaa_maxSearchSteps     =
 *                  o.smaa_maxSearchStepsDiag =
 *                  o.smaa_cornerRounding     =
 *                  o.smaa_adaptFactor        = // local contrast adaptation factor
 *
 *                  o.pred_enabled       =  // use predication
 *                  o.pred_threshold     =
 *                  o.pred_strength      =
 *                  o.pred_scale         =
 *              return o;
 *          }
 *  Or directly
 *          static const SMAA_t myPreset = {
 *              edgeMode,
 *              smaa_threshold, smaa_maxSearchSteps, smaa_maxSearchStepDiag,
 *              smaa_cornerRounding, smaa_adaptFactor,
 *              pred_enabled,
 *              pred_threshold, pred_strength, pred_scale,
 *              stage
 *          }
 *  And use it in the techniques
 *
 *          technique myTechniques3 {...}
 *          technique myTechniques4 SMAA_PASS0(myPreset)
 *          technique myTechniques5 SMAA_PASS1(myPreset)
 *          technique myTechniques6 SMAA_PASS2(myPreset)
 *          technique myTechniques7 {...}
 *
 *  The SMAA header also includes a helper macro to create UI preset
 *
 *          SMAA_UI( "UI Prefix ", myUIPreset )
 *
 *  Where the "UI Prefix" is what will be prepend to UI names.
 *
 *          technique myTechniques3 {...}
 *          technique myTechniques4 SMAA_PASS0(myUIPreset)
 *          technique myTechniques5 SMAA_PASS1(myUIPreset)
 *          technique myTechniques6 SMAA_PASS2(myUIPreset)
 *          technique myTechniques7 {...}
 *
 * in addition, you can change internal rendertarget with :
 *
 *              #define  SMAA_EDGE_TEX      texture0name   // default is RenderTargetRGBA32  (requires 2bit-RGB)
 *              #define  SMAA_BLEND_TEX     texture1name   // default is RenderTargetRGBA64F (RGBA requred [0,1] )
 *
 *                                          prior to inclueing "SMAA/enbSMAA.fxh"
 *
===========================================================================================*/


#define SMAA_STRING(a) #a
//#pragma warning( disable : 3571)

struct SMAA_enbTex2D {
    sampler2D   samp;
    bool        sRGB;
    float4 get(float4 col) { [flatten] if(sRGB) return  pow(col, 1./2.2); else return col; }
};

#define SMAA_CUSTOM_SL
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
#define SMAA_MAX_SEARCH_STEPS_DIAG  (smaa_maxSearchStepDiag - 0.5) // 0 == disabled?
#define SMAA_CORNER_ROUNDING        (smaa_cornerRounding)
#define SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR (smaa_adaptFactor)
#define SMAA_PREDICATION_THRESHOLD  (pred_threshold)
#define SMAA_PREDICATION_SCALE      (pred_scale)
#define SMAA_PREDICATION_STRENGTH   (pred_strength)

#define discard return -1
// Wrap SMAA methods into struct, so that the variables are per instance
struct SMAA_pred_t {
    float   smaa_threshold;
    int     smaa_maxSearchSteps;
    int     smaa_maxSearchStepDiag;
    int     smaa_cornerRounding;
    float   smaa_adaptFactor;   // local contrast adaptation factor

    float   pred_threshold;
    float   pred_strength;
    float   pred_scale;

    // had to modify the SMAA
    #define SMAA_PREDICATION 1
    #include "SMAA/SMAA.hlsl"
};
struct SMAA_t {
    int     edgeMode;  // 0 = ColorEdge, 1 = LumaEdge, 2 = DepthEdge

    float   smaa_threshold;
    int     smaa_maxSearchSteps;
    int     smaa_maxSearchStepDiag;
    int     smaa_cornerRounding;
    float   smaa_adaptFactor;   // local contrast adaptation factor

    bool    pred_enabled;
    float   pred_threshold;
    float   pred_strength;
    float   pred_scale;

    int     stage;     // 0 = frameBuffer, 1 = edgeTex, 2 = blendWeight, 3 = SMAA

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
#undef discard

static const SMAA_t SMAA_Preset_Low     = { 0, 0.15, 4, 0, 100, 2, true, 0.01, 0.4, 2, 3 };
static const SMAA_t SMAA_Preset_Medium  = { 0, 0.1,  8, 0, 100, 2, true, 0.01, 0.4, 2, 3 };
static const SMAA_t SMAA_Preset_High    = { 0, 0.1, 16, 8,  25, 2, true, 0.01, 0.4, 2, 3 };
static const SMAA_t SMAA_Preset_Ultra   = { 0, 0.05,32,16,  25, 2, true, 0.01, 0.4, 2, 3 };

#ifndef SMAA_EDGE_TEX
#define SMAA_EDGE_TEX   RenderTargetRGBA32
#endif
#ifndef SMAA_BLEND_TEX
#define SMAA_BLEND_TEX  RenderTargetRGBA64F
#endif

//-------------------Internal resource & helpers-------------------------------------------------------------------------------
#define SMAA_UI( prefix, var  ) \
int     var##_edgeMode           < string UIName= prefix " Edge Mode";             int UIMin=0; int    UIMax=2;    > = {0};\
float   var##_threshold          < string UIName= prefix " Threshold";             int UIMin=0; float  UIMax=0.5;  > = {0.15};\
int     var##_maxSearchSteps     < string UIName= prefix " Search Steps";          int UIMin=0; int    UIMax=98;   > = {64};\
int     var##_maxSearchStepsDiag < string UIName= prefix " Diagonal Search Steps"; int UIMin=0; int    UIMax=20;   > = {16};\
int     var##_cornerRounding     < string UIName= prefix " Corner Rounding";       int UIMin=0; int    UIMax=100;  > = {8};\
float   var##_contraAdapt        < string UIName= prefix " Contrast Adaptation";   int UIMin=0; float  UIMax=5.0;  > = {2.0};\
bool    var##_predication        < string UIName= prefix " Predication";           > = {true};\
float   var##_thresholdP         < string UIName= prefix " Predication Threshold"; int UIMin=0; int    UIMax=1;    > = {0.01};\
float   var##_strengthP          < string UIName= prefix " Predication Strength";  int UIMin=0; int    UIMax=1;    > = {0.4};\
float   var##_scaleP             < string UIName= prefix " Predication Scale";     int UIMin=1; int    UIMax=5;    > = {2.0};\
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
}; static const SMAA_enbTex2D name = { name##_s, gamma }

// Assests --------------------------------------------------------------------------------------------------------------------

texture2D SMAA_enbAreaTex   < string UIName = "SMAA Area Tex";   string ResourceName = "SMAA/AreaTex.dds";   >;
texture2D SMAA_enbSearchTex < string UIName = "SMAA Search Tex"; string ResourceName = "SMAA/SearchTex.dds"; >;

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
    float2 res = 0;
    int sel = params.edgeMode*2 + params.pred_enabled;

    // these functions returns -1 when no edges is found.
    switch(sel) 
    {
        case 0:  res = params.SMAAColorEdgeDetectionPS( i.uv.xy, i.offset, SMAA_ColorTexGamma).rg; break;
        case 1:  res = params.pred().SMAAColorEdgeDetectionPS( i.uv.xy, i.offset, SMAA_ColorTexGamma, SMAA_DepthTex).rg; break;
        case 2:  res = params.SMAALumaEdgeDetectionPS(  i.uv.xy, i.offset, SMAA_ColorTexGamma).rg; break;
        case 3:  res = params.pred().SMAALumaEdgeDetectionPS(  i.uv.xy, i.offset, SMAA_ColorTexGamma, SMAA_DepthTex).rg; break;
        default: res = params.SMAADepthEdgeDetectionPS( i.uv.xy, i.offset, SMAA_DepthTex).xy; break;
    }
    return float4(res, res.x < 0, 0); // no edge when x = -1
}

//----------------------------------------------------------------------------------------------------------------------------
void SMAA_blendingWeightCalcVS( inout SMAA_VS_Struct io, uniform SMAA_t params) {
    params.SMAABlendingWeightCalculationVS(io.uv.xy, io.uv.zw, io.offset);
    io.pos.w = 1.;
}

float4 SMAA_blendingWeightCalcPS( SMAA_VS_Struct i, uniform SMAA_t params) : COLOR {
    if(tex2D(SMAA_EdgeTex.samp, i.uv.xy).b > .5) return 0; // if no edge.
    return params.SMAABlendingWeightCalculationPS( i.uv.xy, i.uv.zw, i.offset, SMAA_EdgeTex, SMAA_AreaTex, SMAA_SearchTex, 0);
}

//----------------------------------------------------------------------------------------------------------------------------
void SMAA_neighborhoodBlendingVS( inout SMAA_VS_Struct io, uniform SMAA_t params) {
    params.SMAANeighborhoodBlendingVS(io.uv.xy, io.offset[0]);
    io.pos.w = 1.;
}

float4 SMAA_NeighborhoodBlendingPS( SMAA_VS_Struct i, uniform SMAA_t params) : COLOR {
    [flatten]
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
#endif  // enbSMAA.fxh
