# Core 3D Camera Split Screen

Demonstrates split-screen 3D rendering with two players, each having their own camera and render texture, in a world of cube trees.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_3d_camera_split_screen/
cd examples && ./_build/native/debug/build/raylib_core_3d_camera_split_screen/raylib_core_3d_camera_split_screen.exe
```

## Controls

- **Player 1 (left half)**: W/S to move forward/backward
- **Player 2 (right half)**: Up/Down arrows to move forward/backward

## Key Concepts

- Two independent `Camera3D` instances, each rendering to its own `RenderTexture`.
- `begin_texture_mode` / `end_texture_mode` for off-screen 3D rendering.
- `draw_render_texture_rec` to composite both views side by side.
- A grid of cube "trees" on a plane for a simple 3D world.
- Each player's cube is visible in both viewports.
