# SMAA Enbseries Wrapper
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](https://opensource.org/licenses/MIT)

A SMAA 2.8 Wrapper for Dx9 Enbseries 0.288+ by kingeric1992.


## Installation

This project can be deployed though following methods:

* Download and place the project files under the path `\enbseries\SMAA`
* git subtree/submodule selected branch into `\enbseries\SMAA`

## Usage

Add `#include "SMAA/enbSMAA.fxh"` after other enb resources, use existing preset or create new ones and insert SMAA techniques into your technique sections.

```js
    //...
    #include "SMAA/enbSMAA.fxh"
    //...
    technique myTechniques3 {...}
    technique myTechniques4 SMAA_PASS0(SMAA_Preset_Low)
    technique myTechniques5 SMAA_PASS1(SMAA_Preset_Low)
    technique myTechniques6 SMAA_PASS2(SMAA_Preset_Low)
    technique myTechniques7 {...}
```

Built-in presets includes `SMAA_Preset_Low`, `SMAA_Preset_Medium`, `SMAA_Preset_High`, `SMAA_Preset_Ultra`

To use SMAA in first pass

```js
    technique myTechniques  SMAA_PASS0_NAME(  SMAA_Preset_Medium, "smaa demo")
    technique myTechniques2 SMAA_PASS1(       SMAA_Preset_Medium)
    technique myTechniques3 SMAA_PASS2(       SMAA_Preset_Medium)
    technique myTechniques4 {...}
```

To create custom preset, fill-in the SMAA_t struct by creating helper function:

```js
SMAA_t getMyPreset()
{
    SMAA_t o = SMAA_Preset_High; // Starting template

        o.edgeMode           = ; // 0 = ColorEdge, 1 = LumaEdge, 2 = DepthEdge
        o.stage              = ; // 0 = frameBuffer, 1 = edgeTex, 2 = blendWeight, 3 = SMAA

        o.smaa_threshold          = ;
        o.smaa_maxSearchSteps     = ;
        o.smaa_maxSearchStepsDiag = ;
        o.smaa_cornerRounding     = ;
        o.smaa_adaptFactor        = ; // local contrast adaptation factor

        o.pred_enabled       = ; // use predication
        o.pred_threshold     = ;
        o.pred_strength      = ;
        o.pred_scale         = ;
    return o;
}
```

Or fill in `SMAA_t` struct directly:

```js
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
    technique myTechniques3 {...}
    technique myTechniques4 SMAA_PASS0(myUIPreset)
    technique myTechniques5 SMAA_PASS1(myUIPreset)
    technique myTechniques6 SMAA_PASS2(myUIPreset)
    technique myTechniques7 {...}
```

in addition, you can change internal rendertarget with :

```c
    #define  SMAA_EDGE_TEX texture0name // default is RenderTargetRGBA32 (requires 2bit-RGB)
    #define  SMAA_BLEND_TEX texture1name // default is RenderTargetRGBA64F (RGBA required [0,1] )
```

prior to including `SMAA/enbSMAA.fxh`

## Acknowledgments

* [Boris Vorontsov](http://enbdev.com/) for creating Enbseries.
* [Jorge Jimenez et al.](http://www.iryoku.com/smaa/) for creating SMAA.

## License

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](https://opensource.org/licenses/MIT)

- Copyright 2020 (C) kingeric1992 ( king_eric1992@hotmail.com )

This project is using [SMAA](https://github.com/iryoku/smaa) under [MIT LICENSE](LICENSE.md)
