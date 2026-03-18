# raylib_shaders_basic_lighting

Demonstrates basic forward lighting with GLSL shaders. Renders a 3D scene with a plane and cube lit by four colored point lights that can be toggled individually.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_basic_lighting/
cd examples && ./_build/native/debug/build/raylib_shaders_basic_lighting/raylib_shaders_basic_lighting.exe
```

## Controls

- **Y**: Toggle yellow light
- **R**: Toggle red light
- **G**: Toggle green light
- **B**: Toggle blue light
- **Mouse**: Orbital camera rotation

## Key Concepts

- Loads a custom vertex/fragment shader pair (`lighting.vs` / `lighting.fs`) implementing Phong-style lighting.
- Implements a reusable light system (ported from raylib's `rlights.h`) that passes light parameters to the shader via uniform locations.
- Demonstrates setting shader uniforms for ambient light, camera view position, and per-light enabled/type/position/target/color values.
- Light source positions are visualized as small colored spheres.
