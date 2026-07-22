# raylib_textures_raw_data

Demonstrates loading a texture from raw binary image data (no file header) and generating a procedural checked texture by code.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_raw_data/
cd examples && ./_build/native/debug/build/raylib_textures_raw_data/raylib_textures_raw_data.exe
```

## Key Concepts

- Loading raw RGBA pixel data with `load_image_raw`, specifying dimensions and pixel format
- Generating procedural images with `gen_image_checked`
- Converting CPU images to GPU textures with `load_texture_from_image`
- Drawing semi-transparent textures using `fade`
