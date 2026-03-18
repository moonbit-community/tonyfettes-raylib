# Shapes Top Down Lights

Demonstrates a 2D top-down lighting system with shadow casting. Multiple lights cast radial gradients that are occluded by box obstacles, creating realistic shadow volumes.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_top_down_lights/
cd examples && ./_build/native/debug/build/raylib_shapes_top_down_lights/raylib_shapes_top_down_lights.exe
```

## Controls

- **Left Mouse Button**: Drag the primary light
- **Right Mouse Button**: Place a new light (up to 16)
- **F1**: Toggle shadow volume debug visualization

## Key Concepts

- Each light has its own RenderTexture mask for shadow computation
- Shadow volumes are computed per-edge of each box, projected outward from the light
- Uses custom blend modes (`rl_set_blend_factors` with GL min/max) to composite light masks
- The global light mask merges all individual light masks for final rendering
- Draws a checkerboard ground texture with the light mask overlaid as an alpha mask
- Supports up to 16 dynamic lights and 20 box obstacles
