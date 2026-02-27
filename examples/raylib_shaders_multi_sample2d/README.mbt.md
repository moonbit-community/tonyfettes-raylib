# raylib_shaders_multi_sample2d

Demonstrates using multiple `sampler2D` texture units in a single fragment shader. A red texture and a blue texture are blended together with an adjustable divider parameter.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_multi_sample2d/
cd examples && ./_build/native/debug/build/raylib_shaders_multi_sample2d/raylib_shaders_multi_sample2d.exe
```

## Controls

- **Left/Right arrows**: Adjust the mix ratio between the two textures (0.0 to 1.0)

## Key Concepts

- Binding a second texture to a shader via `set_shader_value_texture`
- Using `get_shader_location` to obtain a `sampler2D` uniform location for an additional texture unit
- Controlling texture blending with a `divider` float uniform
- Generating solid-color textures programmatically with `gen_image_color` and `load_texture_from_image`
