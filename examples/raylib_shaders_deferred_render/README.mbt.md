# raylib_shaders_deferred_render

Demonstrates deferred rendering using a G-buffer with multiple render targets. The scene is rendered in two passes: a geometry pass fills position, normal, and albedo textures, then a deferred shading pass computes lighting from four point lights.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_deferred_render/
cd examples && ./_build/native/debug/build/raylib_shaders_deferred_render/raylib_shaders_deferred_render.exe
```

## Controls

- **Y / R / G / B**: Toggle yellow, red, green, blue point lights
- **1**: View position G-buffer texture
- **2**: View normal G-buffer texture
- **3**: View albedo G-buffer texture
- **4**: View final deferred shading result (default)
- **Mouse**: Orbital camera rotation

## Key Concepts

- Creates a framebuffer with three color attachments (position, normal, albedo+specular) and a depth renderbuffer using low-level `rl_*` functions.
- Geometry pass uses `gbuffer.vs`/`gbuffer.fs` to write world-space position, normals, and albedo into separate textures.
- Deferred pass draws a fullscreen quad with `deferred_shading.vs`/`deferred_shading.fs`, sampling the G-buffer textures to compute per-pixel lighting.
- Demonstrates depth buffer blitting between framebuffers for correct forward-rendered light spheres on top of the deferred result.
