//--------------------------------------------------------------------------
// This is a demo file on using enbsmaa.fxh
//                                                      update.  July/6/2020
//--------------------------------------------------------------------------
// Loading enbseries resources.

float4	  ScreenSize; //x = Width, y = 1/Width, z = Width/Height, w = Height/Width
Texture2D TextureColor;
Texture2D TextureDepth;
Texture2D RenderTargetRGBA64; // R16G16B16A16
Texture2D RenderTargetRGB32F; // R11G11B10

//--------------------------------------------------------------------------
// Load wrapper, change including path if required. (note: path is relative to enbseres/)
#include "SMAA/enbsmaa.fxh"

// use built-in UI helper
SMAA_UI( "SMAA", g0 )

// build custom preset
uniform uint SMAA_Stage < string UIName = "SMAA Debug Stage"; int UIMin = 0; int uiMax = 3; > = {3};
SMAA_t myPresetGet() {
    SMAA_t o = SMAA_Preset_Ultra; // can be based on existing preset;
    o.pred_enabled = false;
    o.stage = SMAA_Stage;
    return o;
}

//alternatively
uniform uint SMAA_Quality < string UIName = "SMAA Quality"; int UIMin = 0; int uiMax = 5; > = {0};
static const SMAA_t presetArr[6] = {
    SMAA_Preset_Low,
    SMAA_Preset_Medium,
    SMAA_Preset_High,
    SMAA_Preset_Ultra,
    g0,
    myPresetGet()
};

//--------------------------------------------------------------------------
// Techniques

// use Preset
technique11 myTech    SMAA_PASS0_NAMED(  SMAA_Preset_Medium, "smaa")
technique11 myTech2   SMAA_PASS1(        SMAA_Preset_Medium)
technique11 myTech3   SMAA_PASS2(        SMAA_Preset_Medium)

// use the custom preset created by UI helper
technique11 myTech4   SMAA_PASS0( g0 )
technique11 myTech5   SMAA_PASS1( g0 )
technique11 myTech6   SMAA_PASS2( g0 )

// use custom preset built by function
technique11 myTech7   SMAA_PASS0( myPresetGet() )
technique11 myTech8   SMAA_PASS1( myPresetGet() )
technique11 myTech9   SMAA_PASS2( myPresetGet() )

// access preset through array
technique11 myTech10  SMAA_PASS0( presetArr[SMAA_Quality] )
technique11 myTech11  SMAA_PASS1( presetArr[SMAA_Quality] )
technique11 myTech12  SMAA_PASS2( presetArr[SMAA_Quality] )