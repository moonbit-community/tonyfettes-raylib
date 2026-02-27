# raylib_models_mesh_picking

Demonstrates ray casting and collision detection against multiple 3D object types: ground quad, triangle, sphere, bounding box, and mesh.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_mesh_picking/
cd examples && ./_build/native/debug/build/raylib_models_mesh_picking/raylib_models_mesh_picking.exe
```

## Controls

- **Mouse**: Aim ray (first-person camera when cursor hidden)
- **Right Click**: Toggle camera controls on/off

## Key Concepts

- Casts a ray from the mouse position using `get_screen_to_world_ray`
- Tests ray intersection against multiple primitives: `get_ray_collision_quad`, `get_ray_collision_triangle`, `get_ray_collision_sphere`, `get_ray_collision_box`, and `get_ray_collision_mesh`
- Selects the closest hit and displays collision point, distance, normal, and barycentric coordinates
- Draws visual feedback with a colored cube at the hit point and a normal direction line
