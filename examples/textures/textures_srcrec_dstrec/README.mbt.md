# raylib_textures_srcrec_dstrec

Demonstrates the use of source and destination rectangles with `draw_texture_pro` to scale, position, and continuously rotate a sprite around a custom origin point.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_srcrec_dstrec/
cd examples && ./_build/native/debug/build/raylib_textures_srcrec_dstrec/raylib_textures_srcrec_dstrec.exe
```

## Key Concepts

- **Source rectangle**: selects which portion of the texture to draw
- **Destination rectangle**: defines where and how large the sprite appears on screen
- **Origin point**: sets the rotation and scaling pivot relative to the destination rectangle
- Continuous rotation using `draw_texture_pro` with an incrementing angle
