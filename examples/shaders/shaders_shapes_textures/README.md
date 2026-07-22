# raylib_shaders_shapes_textures

Demonstrates applying a shader to basic 2D shape and texture drawing. A grayscale fragment shader is selectively applied to some shapes while others are drawn with default colors, showing how `begin_shader_mode` / `end_shader_mode` scoping works.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_shapes_textures/
cd examples && ./_build/native/debug/build/raylib_shaders_shapes_textures/raylib_shaders_shapes_textures.exe
```

## Key Concepts

- Using `begin_shader_mode` / `end_shader_mode` to apply a shader to specific draw calls
- Demonstrating that shapes drawn outside the shader block retain their original colors
- Drawing a variety of 2D shapes: circles, rectangles, triangles, polygons, gradients
