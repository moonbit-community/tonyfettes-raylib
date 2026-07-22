# raylib_textures_image_rotate

Demonstrates CPU-side image rotation at arbitrary angles (45, 90, and -90 degrees) applied before uploading to GPU.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_image_rotate/
cd examples && ./_build/native/debug/build/raylib_textures_image_rotate/raylib_textures_image_rotate.exe
```

## Controls

- **Left Mouse Button / Right Arrow**: Cycle through the three rotated versions

## Key Concepts

- Loads the same source image three times and applies `image_rotate` at different angles (45, 90, -90 degrees)
- The 45-degree rotation produces a larger image (~362x362 from a 256x256 source) to accommodate the rotated corners
- Each rotated image is converted to a separate GPU texture
- Demonstrates that `image_rotate` is a CPU-side operation performed before texture upload, unlike GPU-side rotation with `draw_texture_pro`
