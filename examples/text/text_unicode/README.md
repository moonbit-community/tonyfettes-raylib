# raylib_text_unicode

Demonstrates Unicode text rendering with emoji characters and multilingual text in German, Armenian, Polish, Romanian, Russian, French, Spanish, Greek, Chinese, Japanese, and Korean.

## Build and Run

```bash
cd examples && moon build --target native raylib_text_unicode/
cd examples && ./_build/native/debug/build/raylib_text_unicode/raylib_text_unicode.exe
```

## Controls

- **Click emoji**: Select an emoji to show its associated multilingual message in a chat bubble
- **Space**: Randomize emoji grid and message assignments

## Key Concepts

- Loads three specialized fonts: `dejavu.fnt` (Latin/Cyrillic/Greek), `noto_cjk.fnt` (CJK), and `symbola.fnt` (emoji)
- Renders a grid of 32 randomized emoji characters as font glyphs (not textures)
- Selects the appropriate font at runtime based on the message's language
- Displays messages in chat bubbles with word-wrapped text, character/byte counts, and automatic screen-edge clamping
