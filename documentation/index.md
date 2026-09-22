# TiCutoutView 0.3.0 API

## `createView(properties)`

Creates a Titanium container backed by one native UIKit shape. Standard Titanium child-management methods such as `add`, `remove`, and `removeAllChildren` remain available through `TiViewProxy`.

The same circular or rectangular path controls the material, border, drop shadow, optional child clipping, and shape-aware hit testing. See the project `README.md` for the full property table and shape, placement, and material constants.

## `animateCutout(options)`

Animates any combination of:

- `cutoutPlacement`
- `cutoutShape`
- `cutoutRadius`
- `cutoutSize`
- `cutoutCornerRadius`
- `cutoutCenterOffset`
- `cutoutSmoothing`
- `cutoutAlignment`

The shorter aliases `placement`, `shape`, `radius`, `size`, `shapeCornerRadius`, `centerOffset`, `smoothing`, and `alignment` are also accepted inside the options object.

Animation controls are `duration` and `delay` in milliseconds, `timing`, `dampingRatio`, `initialVelocity`, and `respectReducedMotion`. Timing may be `linear`, `easeIn`, `easeOut`, `easeInOut`, or `spring`.

Events:

- `cutoutanimationstart`: contains the requested `options`
- `cutoutanimationcomplete`: contains `finished`, `cutoutPlacement`, `cutoutShape`, `cutoutRadius`, `cutoutSize`, `cutoutCornerRadius`, `cutoutCenterOffset`, `cutoutSmoothing`, and `cutoutAlignment`

Directly setting animated geometry, or starting a replacement animation, cancels the active animation and emits a completion event with `finished: false`.
