# raylib_models_geometric_shapes

Renders a variety of 3D geometric primitives including cubes, spheres, cylinders, cones, and capsules with both solid and wireframe views.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_geometric_shapes/
cd examples && ./_build/native/debug/build/raylib_models_geometric_shapes/raylib_models_geometric_shapes.exe
```

## Key Concepts

- Demonstrates `draw_cube`, `draw_sphere`, `draw_cylinder`, and `draw_capsule` along with their wireframe variants
- Uses a static perspective camera positioned above the scene
- Shows how to compose a 3D scene with multiple colored primitives on a grid
- Covers both solid fills and wireframe outlines for each shape type
