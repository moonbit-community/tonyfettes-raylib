# raylib_text_format_text

Demonstrates text formatting using MoonBit's string interpolation as a replacement for C's `TextFormat` / `sprintf`.

## Build and Run

```bash
cd examples && moon build --target native raylib_text_format_text/
cd examples && ./_build/native/debug/build/raylib_text_format_text/raylib_text_format_text.exe
```

## Key Concepts

- Uses MoonBit string interpolation (`\{variable}`) to embed integers and floats directly in text strings
- Displays formatted score, high score, lives count, and real-time frame time
- Demonstrates the MoonBit-idiomatic approach to dynamic text rendering without C-style format strings
