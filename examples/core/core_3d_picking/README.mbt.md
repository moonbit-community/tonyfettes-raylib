# Core 3D Picking

Demonstrates mouse-based 3D object picking using ray-box collision detection. Click on a cube in 3D space to select it.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_3d_picking/
cd examples && ./_build/native/debug/build/raylib_core_3d_picking/raylib_core_3d_picking.exe
```

## Controls

- **Left Click**: Cast a ray and select/deselect the cube
- **Right Click**: Toggle camera controls (free camera mode)
- **Mouse**: Look around (when camera controls are active)

## Key Concepts

- `get_screen_to_world_ray` to create a ray from mouse position through the camera.
- `BoundingBox` construction from cube position and size.
- `get_ray_collision_box` for ray-AABB intersection testing.
- `draw_ray` to visualize the picking ray in 3D space.
- Visual feedback: selected cube turns red with a green wireframe highlight.
