# raylib_textures_image_processing

Demonstrates 9 CPU-side image processing operations with an interactive toggle menu, applying effects to a source image in real time.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_image_processing/
cd examples && ./_build/native/debug/build/raylib_textures_image_processing/raylib_textures_image_processing.exe
```

## Controls

- **Up/Down Arrow Keys**: Cycle through processing modes
- **Click**: Select a processing mode from the left panel

## Key Concepts

- Applies one of 9 image operations on each selection change:
  - No processing, Color Grayscale, Color Tint, Color Invert, Color Contrast, Color Brightness, Gaussian Blur, Flip Vertical, Flip Horizontal
- Each operation works on a fresh `image_copy` of the original to allow non-destructive switching
- Updates the GPU texture with `update_texture` using pixel data from `load_image_colors`
- Uses `image_format` to ensure consistent `PIXELFORMAT_UNCOMPRESSED_R8G8B8A8` format
