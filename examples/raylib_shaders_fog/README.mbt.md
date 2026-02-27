# raylib_shaders_fog

Demonstrates volumetric fog rendering using custom GLSL shaders with a point light system. Three textured 3D models (torus, cube, sphere) plus a row of tori are drawn in a scene with adjustable fog density.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_fog/
cd examples && ./_build/native/debug/build/raylib_shaders_fog/raylib_shaders_fog.exe
```

## Controls

- **Up/Down arrows**: Increase/decrease fog density (0.0 to 1.0)
- **Mouse**: Orbital camera rotation

## Key Concepts

- Loading and configuring custom vertex and fragment shaders (`lighting.vs` / `fog.fs`)
- Implementing a light system with shader uniform arrays (ported from `rlights.h`)
- Passing shader uniforms: `fogDensity` (float), `ambient` (vec4), light properties (vec3/vec4/int)
- Applying the same shader to multiple model materials
- Rotating a model's transform matrix each frame via `Matrix::multiply` and `Matrix::rotate_x`/`rotate_z`
