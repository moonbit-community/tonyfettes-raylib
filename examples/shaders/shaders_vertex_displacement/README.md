# raylib_shaders_vertex_displacement

Demonstrates vertex displacement on a 3D plane mesh using a custom vertex shader driven by a Perlin noise texture. The plane's vertices are displaced over time to create an animated terrain-like surface.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_vertex_displacement/
cd examples && ./_build/native/debug/build/raylib_shaders_vertex_displacement/raylib_shaders_vertex_displacement.exe
```

## Controls

- **Mouse + WASD**: Free camera movement

## Key Concepts

- Generating a Perlin noise image and loading it as a texture for vertex displacement
- Binding a noise texture to a custom texture slot using `rl_active_texture_slot` / `rl_enable_texture` / `rl_set_uniform_sampler`
- Using a vertex shader (`vertex_displacement.vs`) that samples the noise map to displace vertices
- Passing time as a uniform to animate the displacement
