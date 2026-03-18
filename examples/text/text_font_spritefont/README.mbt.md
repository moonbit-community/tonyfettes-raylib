# raylib_text_font_spritefont

Demonstrates loading and displaying multiple sprite-based bitmap fonts from PNG image files.

## Build and Run

```bash
cd examples && moon build --target native raylib_text_font_spritefont/
cd examples && ./_build/native/debug/build/raylib_text_font_spritefont/raylib_text_font_spritefont.exe
```

## Key Concepts

- Loads three custom sprite fonts from PNG files: `custom_mecha.png`, `custom_alagard.png`, and `custom_jupiter_crash.png`
- Each font is rendered at its base size with custom spacing using `draw_text_ex`
- Text is centered on screen using `measure_text_ex` to compute the text width
- Shows how raylib can extract glyph data directly from specially formatted PNG sprite sheets
