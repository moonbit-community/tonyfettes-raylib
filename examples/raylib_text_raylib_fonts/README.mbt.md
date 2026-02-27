# raylib_text_raylib_fonts

Showcases all 8 free pixel fonts bundled with raylib, each displayed with its designer credit and unique color.

## Build and Run

```bash
cd examples && moon build --target native raylib_text_raylib_fonts/
cd examples && ./_build/native/debug/build/raylib_text_raylib_fonts/raylib_text_raylib_fonts.exe
```

## Key Concepts

- Loads 8 bitmap fonts from PNG sprite sheets: Alagard, Pixelplay, Mecha, Setback, Romulus, Pixantiqua, Alpha Beta, and Jupiter Crash
- Each font is rendered at 2x its base size with custom per-font spacing
- Text positions are centered horizontally using `measure_text_ex`
- Demonstrates the variety of visual styles available through raylib's bundled fonts
