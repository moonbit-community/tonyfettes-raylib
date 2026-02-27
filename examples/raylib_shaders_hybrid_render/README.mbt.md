# raylib_shaders_hybrid_render

Demonstrates hybrid rendering that combines raymarched and rasterized geometry in a single scene with a shared depth buffer, so both rendering methods correctly occlude each other.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_hybrid_render/
cd examples && ./_build/native/debug/build/raylib_shaders_hybrid_render/raylib_shaders_hybrid_render.exe
```

## Controls

- **Mouse**: Orbital camera rotation

## Key Concepts

- Creating a render texture with a writable depth buffer via `load_render_texture_depth_tex`
- Using a raymarching fragment shader (`hybrid_raymarch.fs`) that writes both color and `gl_FragDepth`
- Using a rasterization shader (`hybrid_raster.fs`) that also writes depth for correct compositing
- Manually enabling depth testing with `rl_enable_depth_test` to coordinate both rendering passes
- Passing camera position and direction to the raymarching shader each frame
