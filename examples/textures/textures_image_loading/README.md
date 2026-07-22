# raylib_textures_image_loading

Demonstrates the basic image-to-texture loading pipeline: load an image into CPU memory, convert it to a GPU texture, then free the CPU copy.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_image_loading/
cd examples && ./_build/native/debug/build/raylib_textures_image_loading/raylib_textures_image_loading.exe
```

## Key Concepts

- Loads a PNG image into RAM with `load_image`
- Converts it to a GPU texture with `load_texture_from_image`
- Immediately frees the RAM copy with `unload_image` since only the GPU texture is needed for rendering
- Displays the texture centered on screen with `draw_texture`
- Demonstrates the standard raylib pattern for efficient texture management
