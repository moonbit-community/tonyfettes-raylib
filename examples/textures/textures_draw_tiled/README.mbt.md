# raylib_textures_draw_tiled

Demonstrates tiling a texture pattern across a destination rectangle with configurable scale, rotation, pattern selection, and color tinting.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_draw_tiled/
cd examples && ./_build/native/debug/build/raylib_textures_draw_tiled/raylib_textures_draw_tiled.exe
```

## Controls

- **Click**: Select a pattern or color from the left panel
- **Up/Down**: Adjust tile scale
- **Left/Right**: Adjust tile rotation
- **Space**: Reset scale and rotation

## Key Concepts

- Implements a custom `draw_texture_tiled` function that tiles a source rectangle from a texture atlas across a destination area
- Handles partial tiles at edges by adjusting source rectangle coordinates
- Supports rotation and scaling of individual tiles via `draw_texture_pro`
- The window is resizable (`FlagWindowResizable`), and the tiled area adapts to the window size
- Provides 6 patterns from a single texture atlas and 10 tint colors
