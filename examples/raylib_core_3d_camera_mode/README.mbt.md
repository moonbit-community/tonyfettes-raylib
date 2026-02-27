# Core 3D Camera Mode

The simplest 3D example -- sets up a static perspective camera and renders a cube with wireframe and a grid. No interactivity beyond the window.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_3d_camera_mode/
cd examples && ./_build/native/debug/build/raylib_core_3d_camera_mode/raylib_core_3d_camera_mode.exe
```

## Key Concepts

- Minimal `Camera3D` setup with position, target, up vector, FOV, and projection.
- `begin_mode_3d` / `end_mode_3d` to render 3D content.
- `draw_cube`, `draw_cube_wires`, and `draw_grid` for basic 3D primitives.
- `draw_fps` for on-screen frame rate display.
