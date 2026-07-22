# raylib_textures_to_image

Demonstrates the round-trip conversion between images (CPU/RAM) and textures (GPU/VRAM): loading an image, uploading to GPU, reading back to CPU, and re-uploading.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_to_image/
cd examples && ./_build/native/debug/build/raylib_textures_to_image/raylib_textures_to_image.exe
```

## Key Concepts

- `load_image` loads pixel data into CPU memory (RAM)
- `load_texture_from_image` uploads image data to GPU memory (VRAM)
- `load_image_from_texture` reads texture data back from GPU to CPU
- Demonstrates the full RAM -> VRAM -> RAM -> VRAM lifecycle for image/texture data
