//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ENBSeries Fallout 4 hlsl DX11 format, sample file
// visit http://enbdev.com for updates
// Author: Boris Vorontsov
// It's similar to effect.txt shaders and works with ldr input and output
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// This is a demo file on bare-bone enbsmaa.fx implementation

//+++++++++++++++++++++++++++++
//external enb parameters, do not modify
//+++++++++++++++++++++++++++++
//x = generic timer in range 0..1, period of 16777216 ms (4.6 hours), y = average fps, w = frame time elapsed (in seconds)
float4	Timer;
//x = Width, y = 1/Width, z = aspect, w = 1/aspect, aspect is Width/Height
float4	ScreenSize;
//x = current weather index, y = outgoing weather index, z = weather transition, w = time of the day in 24 standart hours. Weather index is value from weather ini file, for example WEATHER002 means index==2, but index==0 means that weather not captured.
float4	Weather;
//x = dawn, y = sunrise, z = day, w = sunset. Interpolators range from 0..1
float4	TimeOfDay1;
//x = dusk, y = night. Interpolators range from 0..1
float4	TimeOfDay2;
//changes in range 0..1, 0 means that night time, 1 - day time
float	ENightDayFactor;
//changes 0 or 1. 0 means that exterior, 1 - interior
float	EInteriorFactor;
//changes in range 0..1, 0 means full quality, 1 lowest dynamic quality (0.33, 0.66 are limits for quality levels)
float	AdaptiveQuality;

//+++++++++++++++++++++++++++++
//external enb debugging parameters for shader programmers, do not modify
//+++++++++++++++++++++++++++++
//keyboard controlled temporary variables. Press and hold key 1,2,3...8 together with PageUp or PageDown to modify. By default all set to 1.0
float4	tempF1, tempF2, tempF3; //1, 2, 3, 4, 5, 6, 7, 8, 9, 0
// xy = cursor position in range 0..1 of screen;
// z = is shader editor window active;
// w = mouse buttons with values 0..7 as follows:
//    0 = none
//    1 = left
//    2 = right
//    3 = left+right
//    4 = middle
//    5 = left+middle
//    6 = right+middle
//    7 = left+right+middle (or rather cat is sitting on your mouse)
float4	tempInfo1;
// xy = cursor position of previous left mouse button click
// zw = cursor position of previous right mouse button click
float4	tempInfo2;

//+++++++++++++++++++++++++++++
//mod parameters, do not modify
//+++++++++++++++++++++++++++++
Texture2D			TextureOriginal; //color R10B10G10A2 32 bit ldr format
Texture2D			TextureColor; //color which is output of previous technique (except when drawed to temporary render target), R10B10G10A2 32 bit ldr format
Texture2D			TextureDepth; //scene depth R32F 32 bit hdr format

//temporary textures which can be set as render target for techniques via annotations like <string RenderTarget="RenderTargetRGBA32";>
Texture2D			RenderTargetRGBA32; //R8G8B8A8 32 bit ldr format
Texture2D			RenderTargetRGBA64; //R16B16G16A16 64 bit ldr format
Texture2D			RenderTargetRGBA64F; //R16B16G16A16F 64 bit hdr format
Texture2D			RenderTargetR16F; //R16F 16 bit hdr format with red channel only
Texture2D			RenderTargetR32F; //R32F 32 bit hdr format with red channel only
Texture2D			RenderTargetRGB32F; //32 bit hdr format without alpha

// change including path if required.
#include "enbsmaa.fxh"

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
uniform uint SMAA_Quality < string UIName = "SMAA Quality"; int UIMin = 0; int uiMax = 4; > = {0};
static const SMAA_t presetArr[5] = {
    SMAA_Preset_Low,
    SMAA_Preset_Medium,
    SMAA_Preset_High,
    SMAA_Preset_Ultra,
    g0
};

technique11 myTech    SMAA_PASS0_NAMED(  SMAA_Preset_Medium, "smaa")
technique11 myTech2   SMAA_PASS1(        SMAA_Preset_Medium)
technique11 myTech3   SMAA_PASS2(        SMAA_Preset_Medium)

// use the custom preset created by UI helper
technique11 myTech4   SMAA_PASS0( g0 )
technique11 myTech5   SMAA_PASS1( g0 )
technique11 myTech6   SMAA_PASS2( g0 )

technique11 myTech7   SMAA_PASS0( myPresetGet() )
technique11 myTech8   SMAA_PASS1( myPresetGet() )
technique11 myTech9   SMAA_PASS2( myPresetGet() )

technique11 myTech10  SMAA_PASS0( presetArr[SMAA_Quality] )
technique11 myTech11  SMAA_PASS1( presetArr[SMAA_Quality] )
technique11 myTech12  SMAA_PASS2( presetArr[SMAA_Quality] )