# raylib_shaders_shadowmap

Demonstrates real-time shadow mapping with a directional light. A depth-only render pass from the light's perspective generates a shadow map, which is then sampled during the main render pass to produce shadows.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_shadowmap/
cd examples && ./_build/native/debug/build/raylib_shaders_shadowmap/raylib_shaders_shadowmap.exe
```

## Controls

- **Arrow keys**: Rotate the light direction
- **F**: Take a screenshot
- **Mouse**: Orbital camera rotation

## Key Concepts

- Two-pass shadow mapping: render depth from light camera, then sample in main pass
- Using `load_shadowmap_render_texture` for a depth-only framebuffer
- Computing and passing the light's view-projection matrix (`lightVP`) to the shadow shader
- Binding the shadow map depth texture to a custom texture slot with `rl_active_texture_slot` / `rl_enable_texture`
- Loading and animating a GLB model (`robot.glb`) with `load_model_animations` / `update_model_animation`
