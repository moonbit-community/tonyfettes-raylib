# raylib_textures_image_channel

Demonstrates extracting individual color channels (Red, Green, Blue, Alpha) from an image and displaying them as separate textures.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_image_channel/
cd examples && ./_build/native/debug/build/raylib_textures_image_channel/raylib_textures_image_channel.exe
```

## Key Concepts

- Uses `image_from_channel` to extract individual R, G, B, and A channels from a source image
- Applies `image_alpha_mask` to preserve the original transparency on each channel image
- Displays the original image alongside its four separated channel textures
- Uses a checkerboard background generated with `gen_image_checked` to visualize transparency
- All images are converted to textures and unloaded from RAM after upload to GPU
