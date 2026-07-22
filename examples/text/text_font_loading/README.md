# raylib_text_font_loading

Demonstrates loading fonts from different formats: BMFont (AngelCode `.fnt`) and TTF, and switching between them at runtime.

## Build and Run

```bash
cd examples && moon build --target native raylib_text_font_loading/
cd examples && ./_build/native/debug/build/raylib_text_font_loading/raylib_text_font_loading.exe
```

## Controls

- **Space (hold)**: Switch from BMFont to TTF font display

## Key Concepts

- Loads the same font in two formats: BMFont (`pixantiqua.fnt`) via `load_font` and TTF (`pixantiqua.ttf`) via `load_font_ex` at size 32
- Displays the full printable ASCII character set using `draw_text_ex`
- Shows the visual difference between pre-rendered bitmap fonts and dynamically generated TTF fonts
