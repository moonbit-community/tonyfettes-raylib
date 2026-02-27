# raylib_text_codepoints_loading

Demonstrates loading a font with only the specific Unicode codepoints needed, rather than the full character set. Uses Japanese text to show efficient font atlas generation.

## Build and Run

```bash
cd examples && moon build --target native raylib_text_codepoints_loading/
cd examples && ./_build/native/debug/build/raylib_text_codepoints_loading/raylib_text_codepoints_loading.exe
```

## Controls

- **Space**: Toggle between text display and font atlas view

## Key Concepts

- Extracts codepoints from a Japanese text string (Iroha poem)
- Removes duplicate codepoints to minimize the font atlas size
- Loads a TTF font (`DotGothic16-Regular.ttf`) with only the required glyphs using `load_font_ex_codepoints`
- Displays total vs. deduplicated codepoint counts
- Toggles between rendered text and the generated font texture atlas
