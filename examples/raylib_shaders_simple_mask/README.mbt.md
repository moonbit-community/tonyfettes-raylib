# raylib_shaders_simple_mask

Demonstrates texture masking using a fragment shader. A plasma texture is drawn through a mask shader that uses a second texture as an alpha mask, with an animated frame counter driving the visual effect.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_simple_mask/
cd examples && ./_build/native/debug/build/raylib_shaders_simple_mask/raylib_shaders_simple_mask.exe
```

## Key Concepts

- Using a second texture as a mask via `set_shader_value_texture`
- Passing an integer frame counter to the shader for animation
- Drawing the same masked texture at multiple screen positions
