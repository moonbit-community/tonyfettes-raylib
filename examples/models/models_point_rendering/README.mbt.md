# raylib_models_point_rendering

Renders a point cloud of up to 10 million points distributed in a sphere, comparing GPU-accelerated `DrawModelPoints` with per-point `DrawPoint3D` rendering.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_point_rendering/
cd examples && ./_build/native/debug/build/raylib_models_point_rendering/raylib_models_point_rendering.exe
```

## Controls

- **Mouse**: Orbital camera rotation
- **Up Arrow**: Increase point count (10x)
- **Down Arrow**: Decrease point count (10x)
- **Space**: Toggle between DrawModelPoints and DrawPoint3D

## Key Concepts

- Generates spherical point clouds using spherical coordinate sampling
- Colors points by HSV hue mapped to radial distance
- Builds a mesh from raw vertex and color byte arrays via `gen_mesh_from_points`
- Compares batch-uploaded GPU point rendering vs. immediate-mode per-point drawing
- Dynamically regenerates the point cloud when the count changes
