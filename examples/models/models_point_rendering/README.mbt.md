# raylib_models_point_rendering

Renders a point cloud of up to 10 million points distributed in a sphere with per-point `DrawPoint3D` rendering.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_point_rendering/
cd examples && ./_build/native/debug/build/raylib_models_point_rendering/raylib_models_point_rendering.exe
```

## Controls

- **Mouse**: Orbital camera rotation
- **Up Arrow**: Increase point count (10x)
- **Down Arrow**: Decrease point count (10x)
## Key Concepts

- Generates spherical point clouds using spherical coordinate sampling
- Colors points by HSV hue mapped to radial distance
- Uses `DrawPoint3D`; raylib 6.0 removed the old `DrawModelPoints` API
- Dynamically regenerates the point cloud when the count changes
