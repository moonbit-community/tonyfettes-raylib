# raylib_shaders_texture_drawing

Demonstrates using a shader to generate animated procedural textures. A blank texture is drawn through a `cubes_panning.fs` shader that produces a time-animated panning cube pattern entirely on the GPU.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_texture_drawing/
cd examples && ./_build/native/debug/build/raylib_shaders_texture_drawing/raylib_shaders_texture_drawing.exe
```

## Key Concepts

- Generating a blank image and loading it as a texture to serve as a shader canvas
- Passing elapsed time (`uTime`) to a fragment shader for animation
- Using `get_time` for a high-precision time source
