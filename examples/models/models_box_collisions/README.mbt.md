# Models Box Collisions

A raylib API demo showing 3D collision detection between a player cube and two enemy shapes (a box and a sphere). The player turns red when overlapping either obstacle.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_box_collisions/
cd examples && ./_build/native/debug/build/raylib_models_box_collisions/raylib_models_box_collisions.exe
```

## Controls

- **Arrow Keys**: Move the player cube on the XZ plane

## Key Concepts

Demonstrates `check_collision_boxes` for axis-aligned bounding box (AABB) vs AABB collision and `check_collision_box_sphere` for AABB vs sphere collision. The player's bounding box is constructed from its position and size each frame, then tested against static enemy shapes. Visual feedback is provided by changing the player cube color on collision.
