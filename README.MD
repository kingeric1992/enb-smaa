# SMAA Enbseries Wrapper

A SMAA 2.8 Wrapper for Dx9 Enbseries 0.288+ by kingeric1992.

# Installation
This project can be deploy though following methods
* Download and place the project files uner the path of `\enbseries\SMAA`
* git subtree/submodule selected branch into `\enbseries\SMAA`

# Usage

Adding `#include "enbsmaa.fxh"` after other enb resources, use existing preset or create new ones and insert SMAA techniques into your technique sections.

```c
    //...
    #include "SMAA\enbsmaa.fxh"
    //...
    technique myTechniques3 {...}
    technique myTechniques4 SMAA_PASS0(SMAA_Preset_Low)
    technique myTechniques5 SMAA_PASS1(SMAA_Preset_Low)
    technique myTechniques6 SMAA_PASS2(SMAA_Preset_Low)
    technique myTechniques7 {...}
```

Built-in presets includes `SMAA_Preset_Low`, `SMAA_Preset_Medium`, `SMAA_Preset_High`, `SMAA_Preset_Ultra`
To use SMAA in first pass

```c
    technique myTechniques  SMAA_PASS0_NAME(  SMAA_Preset_Medium, "smaa demo")
    technique myTechniques2 SMAA_PASS1(       SMAA_Preset_Medium)
    technique myTechniques3 SMAA_PASS2(       SMAA_Preset_Medium)
    technique myTechniques4 {...}
```

To create custom preset, fill-in the SMAA_t struct by creating helper function:

```c
SMAA_t getMyPreset()
{
    SMAA_t o = SMAA_Preset_High; // Starting template

        // 0 = ColorEdge, 1 = LumaEdge, 2 = DepthEdge
        o.edgeMode           = ;
        // 0 = frameBuffer, 1 = edgeTex, 2 = blendWeight, 3 = SMAA
        o.stage              = ;

        o.smaa_threshold          = ;
        o.smaa_maxSearchSteps     = ;
        o.smaa_maxSearchStepsDiag = ;
        o.smaa_cornerRounding     = ;
        // local contrast adaptation factor
        o.smaa_adaptFactor        = ;

        // use predication
        o.pred_enabled       = ;
        o.pred_threshold     = ;
        o.pred_strength      = ;
        o.pred_scale         = ;
    return o;
}
```

Or fill in `SMAA_t` struct directly:

```c
static const SMAA_t myPreset = {
    edgeMode,
    smaa_threshold, smaa_maxSearchSteps, smaa_maxSearchStepDiag,
    smaa_cornerRounding, smaa_adaptFactor,
    pred_enabled,
    pred_threshold, pred_strength, pred_scale,
    stage
}
```

And use it in the techniques

```js
    technique myTechniques3 {...}
    technique myTechniques4 SMAA_PASS0(myPreset)
    technique myTechniques5 SMAA_PASS1(myPreset)
    technique myTechniques6 SMAA_PASS2(myPreset)
    technique myTechniques7 {...}
    //...
    technique myTechniques12 SMAA_PASS0(getMyPreset())
    technique myTechniques13 SMAA_PASS1(getMyPreset())
    technique myTechniques14 SMAA_PASS2(getMyPreset())
    technique myTechniques15 {...}
```

The wrapper also provides a helper macro to create UI preset

```js
    SMAA_UI( "UI Prefix ", myUIPreset )
```

Where the "UI Prefix" is what will be prepend to UI names.

```js
    technique11 myTechniques3 {...}
    technique11 myTechniques4 SMAA_PASS0(myUIPreset)
    technique11 myTechniques5 SMAA_PASS1(myUIPreset)
    technique11 myTechniques6 SMAA_PASS2(myUIPreset)
    technique11 myTechniques7 {...}
```

in addition, you can change internal rendertarget with :

```js
    #define  SMAA_EDGE_TEX texture0name // default is RenderTargetRGB32F (only require 2bit-RG channel)
    #define  SMAA_BLEND_TEX texture1name // default is RenderTargetRGBA64 (RGBA requred [0,1] )
```

prior to inclueing "enbsmaa.fx"

# Acknowledgments

* [Boris Vorontsov](http://enbdev.com/) for creating Enbseries.
* [Jorge Jimenez et al.](http://www.iryoku.com/smaa/) for creating SMAA.

# License

This project is using [SMAA](https://github.com/iryoku/smaa) under [MIT LICENSE](LICENSE.md)
