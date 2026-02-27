# Core 2D Camera

Demonstrates basic 2D camera usage with a scrollable cityscape of random buildings and a movable player rectangle.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_2d_camera/
cd examples && ./_build/native/debug/build/raylib_core_2d_camera/raylib_core_2d_camera.exe
```

## Controls

- **Right / Left**: Move the player horizontally
- **A / S**: Rotate the camera
- **Mouse Wheel**: Zoom in/out
- **R**: Reset zoom and rotation

## Key Concepts

- `Camera2D` setup with offset, target, rotation, and zoom.
- Camera target follows the player position each frame.
- `begin_mode_2d` / `end_mode_2d` for rendering in camera-transformed space.
- Crosshair lines drawn at the camera target position for visual reference.
