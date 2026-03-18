# raylib_textures_image_text

Demonstrates drawing text onto an image using a custom TTF font, then displaying the result as a texture. Shows both image-level text rendering (baked into the texture) and real-time sprite font drawing.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_image_text/
cd examples && ./_build/native/debug/build/raylib_textures_image_text/raylib_textures_image_text.exe
```

## Key Concepts

- Loading a TTF font with `load_font_ex` at a specific size
- Drawing text onto an image in CPU memory with `image_draw_text_ex`
- Converting the modified image to a GPU texture with `load_texture_from_image`
- Drawing text at runtime using `draw_text_ex` with the same sprite font
- Proper resource lifecycle: image unloaded after texture creation, texture and font cleaned up on exit
