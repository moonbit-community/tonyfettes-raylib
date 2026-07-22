# raylib_shaders_mesh_instancing

Demonstrates GPU-accelerated mesh instancing by rendering 10,000 cubes in a single draw call using `draw_mesh_instanced` with per-instance transform matrices and a lighting shader.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_mesh_instancing/
cd examples && ./_build/native/debug/build/raylib_shaders_mesh_instancing/raylib_shaders_mesh_instancing.exe
```

## Controls

- **Mouse**: Orbital camera rotation

## Key Concepts

- Generating random per-instance transform matrices (translation + rotation)
- Using `draw_mesh_instanced` to render thousands of meshes in one draw call
- Loading an instancing-aware vertex shader (`lighting_instancing.vs`) with `instanceTransform` attribute
- Setting up `ShaderLocMatrixMvp` and `ShaderLocMatrixModel` shader locations for instancing
- Implementing a basic directional light system with ambient lighting
