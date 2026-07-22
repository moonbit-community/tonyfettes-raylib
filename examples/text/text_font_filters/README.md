# raylib_text_font_filters

Demonstrates the visual difference between texture filtering modes (Point, Bilinear, Trilinear) when scaling TTF fonts, with interactive font size control.

## Build and Run

```bash
cd examples && moon build --target native raylib_text_font_filters/
cd examples && ./_build/native/debug/build/raylib_text_font_filters/raylib_text_font_filters.exe
```

## Controls

- **Mouse Wheel**: Change font render size
- **Left/Right Arrow Keys**: Move text horizontally
- **1**: Set Point filter (pixelated)
- **2**: Set Bilinear filter (smooth)
- **3**: Set Trilinear filter (smooth with mipmaps)

## Key Concepts

- Loads a TTF font at base size 96 and generates mipmaps with `gen_font_texture_mipmaps`
- Switches between `TEXTURE_FILTER_POINT`, `TEXTURE_FILTER_BILINEAR`, and `TEXTURE_FILTER_TRILINEAR` at runtime
- Shows how filter choice affects text quality at different scales
- Displays current font size and measured text dimensions
