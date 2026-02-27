# raylib_text_font_sdf

Demonstrates Signed Distance Field (SDF) font rendering, which produces sharp text at any scale compared to standard bitmap font rendering.

## Build and Run

```bash
cd examples && moon build --target native raylib_text_font_sdf/
cd examples && ./_build/native/debug/build/raylib_text_font_sdf/raylib_text_font_sdf.exe
```

## Controls

- **Space (hold)**: Switch to SDF font rendering
- **Mouse Wheel**: Scale the rendered text size

## Key Concepts

- Builds two fonts from the same TTF data: one with `FontDefault` and one with `FontSdf` using `build_font_from_data`
- SDF rendering requires a custom fragment shader (`sdf.fs`) activated with `begin_shader_mode`
- SDF fonts stay sharp at any scale, while default fonts become pixelated or blurry
- Displays the font texture atlas alongside the rendered text for comparison
