# raylib_core_world_screen

Demonstrates converting 3D world coordinates to 2D screen coordinates using `get_world_to_screen`. A text label ("Enemy: 100 / 100") is drawn in 2D space but tracks a 3D cube's position.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_world_screen/
cd examples && ./_build/native/debug/build/raylib_core_world_screen/raylib_core_world_screen.exe
```

## Controls

- **Mouse**: Orbit the camera around the cube (third-person camera)

## Key Concepts

- `get_world_to_screen` projects a `Vector3` world position into `Vector2` screen coordinates
- Drawing 2D UI elements (health bars, labels) that follow 3D objects
- `measure_text` for centering text above the projected position
- Third-person camera with `update_camera` and `CameraThirdPerson` mode
