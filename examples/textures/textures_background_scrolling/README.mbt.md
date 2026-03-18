# raylib_textures_background_scrolling

Demonstrates parallax background scrolling using three texture layers moving at different speeds to create a depth illusion.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_background_scrolling/
cd examples && ./_build/native/debug/build/raylib_textures_background_scrolling/raylib_textures_background_scrolling.exe
```

## Key Concepts

- Loads three cyberpunk street scene layers: background, midground, and foreground
- Each layer scrolls at a different speed (0.1, 0.5, 1.0 pixels/frame) creating parallax depth
- Textures are drawn twice side by side and wrap seamlessly using `draw_texture_ex` at 2x scale
- When a layer scrolls past its double-width, the offset resets to create infinite scrolling
