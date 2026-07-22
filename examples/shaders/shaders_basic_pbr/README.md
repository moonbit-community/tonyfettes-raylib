# raylib_shaders_basic_pbr

Demonstrates physically-based rendering (PBR) with raylib shaders. Loads a car model with albedo, normal, metalness/roughness/AO, and emissive texture maps, then renders it under four colored point lights on a textured road surface.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_basic_pbr/
cd examples && ./_build/native/debug/build/raylib_shaders_basic_pbr/raylib_shaders_basic_pbr.exe
```

## Controls

- **1 / 2 / 3 / 4**: Toggle the four point lights
- **Mouse**: Orbital camera rotation

## Key Concepts

- Loads PBR vertex/fragment shaders (`pbr.vs` / `pbr.fs`) with full material map support: albedo, MRA (metalness/roughness/AO packed), normal, and emissive.
- Configures shader locations for albedo, metalness, normal, emission, diffuse color, and view position.
- Sets up per-light intensity as an additional uniform beyond the basic lighting example.
- Demonstrates texture tiling, emissive color/power configuration, and ambient color/intensity control.
- Uses a `.glb` model with multiple PBR texture maps applied via `set_material_texture`.
