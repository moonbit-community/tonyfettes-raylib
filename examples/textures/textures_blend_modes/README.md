# raylib_textures_blend_modes

Demonstrates the four texture blend modes available in raylib: Alpha, Additive, Multiplied, and Add Colors.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_blend_modes/
cd examples && ./_build/native/debug/build/raylib_textures_blend_modes/raylib_textures_blend_modes.exe
```

## Controls

- **Space**: Cycle through blend modes

## Key Concepts

- Loads background and foreground images, converts them to textures, then unloads the images from RAM
- Draws the foreground over the background using `begin_blend_mode` / `end_blend_mode`
- Cycles through `BLEND_ALPHA`, `BLEND_ADDITIVE`, `BLEND_MULTIPLIED`, and `BLEND_ADD_COLORS`
- Visually demonstrates how each blend mode composites two overlapping textures
