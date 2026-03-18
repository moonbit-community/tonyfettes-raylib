# Core 3D Camera Free

Demonstrates the free-mode 3D camera with mouse-driven orbit, pan, and zoom controls around a simple cube and grid scene.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_3d_camera_free/
cd examples && ./_build/native/debug/build/raylib_core_3d_camera_free/raylib_core_3d_camera_free.exe
```

## Controls

- **Mouse Wheel**: Zoom in/out
- **Mouse Wheel Press (Middle Button)**: Pan
- **Mouse Movement**: Orbit around target
- **Z**: Reset camera target to origin (0, 0, 0)

## Key Concepts

- `Camera3D` in free mode with `update_camera(camera, CameraFree)`.
- `disable_cursor` for captured mouse input.
- `draw_cube`, `draw_cube_wires`, and `draw_grid` for basic 3D primitives.
- `begin_mode_3d` / `end_mode_3d` for 3D rendering context.
