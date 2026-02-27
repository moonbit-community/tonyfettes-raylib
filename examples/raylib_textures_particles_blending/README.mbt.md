# raylib_textures_particles_blending

A particle system that follows the mouse cursor, demonstrating texture-based particles with switchable alpha and additive blending modes.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_particles_blending/
cd examples && ./_build/native/debug/build/raylib_textures_particles_blending/raylib_textures_particles_blending.exe
```

## Controls

- **Mouse**: Move to emit particles
- **Space**: Toggle between alpha blending and additive blending

## Key Concepts

- Object pool pattern for particle management (200 particles, reused when inactive)
- Drawing rotated, scaled texture sprites with `draw_texture_pro`
- Switching blend modes with `begin_blend_mode` / `end_blend_mode`
- Fading particle colors over time with the `fade` function
