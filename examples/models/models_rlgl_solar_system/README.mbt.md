# raylib_models_rlgl_solar_system

Simulates a Sun-Earth-Moon solar system using low-level rlgl matrix push/pop transformations to create hierarchical orbital animations.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_rlgl_solar_system/
cd examples && ./_build/native/debug/build/raylib_models_rlgl_solar_system/raylib_models_rlgl_solar_system.exe
```

## Controls

- **Mouse**: Orbital camera rotation

## Key Concepts

- Uses `rl_push_matrix` / `rl_pop_matrix` for hierarchical coordinate transformations
- Applies `rl_scalef`, `rl_rotatef`, and `rl_translatef` for positioning and sizing celestial bodies
- Moon orbits Earth, which orbits Sun -- nested matrix transforms make this natural
- Draws spheres at the origin using raw `rl_begin`/`rl_vertex3f`/`rl_end` immediate-mode rendering
- Demonstrates the relationship between rlgl low-level API and higher-level raylib functions
