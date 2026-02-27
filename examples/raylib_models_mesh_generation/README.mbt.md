# raylib_models_mesh_generation

Showcases all built-in procedural mesh generators: plane, cube, sphere, hemisphere, cylinder, torus, knot, and polygon.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_mesh_generation/
cd examples && ./_build/native/debug/build/raylib_models_mesh_generation/raylib_models_mesh_generation.exe
```

## Controls

- **Mouse**: Orbital camera rotation
- **Left Click** or **Left/Right Arrow**: Cycle through mesh types

## Key Concepts

- Generates 8 parametric mesh types using `gen_mesh_plane`, `gen_mesh_cube`, `gen_mesh_sphere`, `gen_mesh_hemisphere`, `gen_mesh_cylinder`, `gen_mesh_torus`, `gen_mesh_knot`, and `gen_mesh_poly`
- Applies a procedurally generated checkerboard texture via `gen_image_checked`
- Converts each mesh to a model with `load_model_from_mesh`
- Displays the current mesh type name in the UI
