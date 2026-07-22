# raylib_shapes_collision_area

Demonstrates rectangle collision detection. A moving box bounces horizontally across the screen while a second box follows the mouse cursor. When the two boxes overlap, the collision area is highlighted and its size is displayed.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_collision_area/
cd examples && ./_build/native/debug/build/raylib_shapes_collision_area/raylib_shapes_collision_area.exe
```

## Controls

- **Mouse**: Move the blue box
- **Space**: Pause / resume the gold box's movement

## Key Concepts

- Rectangle collision detection with `check_collision_recs`
- Computing collision overlap with `get_collision_rec`
- Clamping the mouse-controlled box within screen bounds
- Visual feedback: color changes and collision area display on overlap
