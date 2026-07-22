# Core 3D Camera First Person

Demonstrates 3D camera with multiple camera modes (free, first-person, third-person, orbital) and switchable perspective/orthographic projection.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_3d_camera_first_person/
cd examples && ./_build/native/debug/build/raylib_core_3d_camera_first_person/raylib_core_3d_camera_first_person.exe
```

## Controls

- **W/A/S/D/Space/Left-Ctrl**: Move the camera
- **Arrow Keys / Mouse**: Look around
- **1/2/3/4**: Switch camera mode (Free, First Person, Third Person, Orbital)
- **P**: Toggle perspective/orthographic projection
- **Num +/-** or **Mouse Scroll**: Zoom

## Key Concepts

- `Camera3D` with position, target, up vector, FOV, and projection type.
- `update_camera` with different camera modes for built-in camera control.
- Switching between `CameraPerspective` and `CameraOrthographic` at runtime.
- Random colored columns rendered in a walled 3D arena.
- `disable_cursor` for relative mouse movement in first-person mode.
