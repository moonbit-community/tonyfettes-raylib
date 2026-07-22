# raylib_textures_image_generation

Demonstrates raylib's procedural image generation functions, cycling through 9 different algorithmically generated textures.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_image_generation/
cd examples && ./_build/native/debug/build/raylib_textures_image_generation/raylib_textures_image_generation.exe
```

## Controls

- **Left Mouse Button / Right Arrow**: Cycle to the next procedural texture

## Key Concepts

- Generates 9 procedural images using built-in functions:
  - `gen_image_gradient_linear` (vertical, horizontal, diagonal)
  - `gen_image_gradient_radial` and `gen_image_gradient_square`
  - `gen_image_checked` (checkerboard pattern)
  - `gen_image_white_noise` and `gen_image_perlin_noise`
  - `gen_image_cellular` (Voronoi-like cells)
- All images are generated at screen resolution, converted to textures, then freed from RAM
