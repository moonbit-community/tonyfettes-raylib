# raylib_shaders_texture_waves

Demonstrates a wave distortion effect applied to 2D drawing using a fragment shader. A grid pattern and text are drawn through a `wave.fs` shader that distorts pixels with configurable frequency, amplitude, and speed parameters.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_texture_waves/
cd examples && ./_build/native/debug/build/raylib_shaders_texture_waves/raylib_shaders_texture_waves.exe
```

## Key Concepts

- Configuring wave shader parameters: `freqX`, `freqY`, `ampX`, `ampY`, `speedX`, `speedY`
- Passing elapsed time (`seconds`) to animate the wave distortion
- Applying the wave shader to both shapes and text drawn within `begin_shader_mode` / `end_shader_mode`
