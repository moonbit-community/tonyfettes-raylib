# raylib_shaders_raymarching

Renders a complete 3D scene using raymarching in a fragment shader (by Inigo Quilez). The entire frame is generated on the GPU; only a full-screen quad is drawn from the CPU side.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_raymarching/
cd examples && ./_build/native/debug/build/raylib_shaders_raymarching/raylib_shaders_raymarching.exe
```

## Controls

- **Mouse + WASD**: First-person camera movement
- **Esc**: Exit

## Key Concepts

- Full-screen raymarching driven entirely by a fragment shader (`raymarching.fs`)
- Passing camera eye position (`viewEye`), look direction (`viewCenter`), time, and resolution as uniforms
- Handling window resize by updating the `resolution` uniform dynamically
- Using `FlagWindowResizable` to allow runtime window resizing
