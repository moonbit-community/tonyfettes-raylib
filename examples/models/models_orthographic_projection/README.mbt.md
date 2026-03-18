# raylib_models_orthographic_projection

Demonstrates toggling between perspective and orthographic camera projection modes, showing how the same 3D scene looks under each projection type.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_orthographic_projection/
cd examples && ./_build/native/debug/build/raylib_models_orthographic_projection/raylib_models_orthographic_projection.exe
```

## Controls

- **Space**: Toggle between perspective and orthographic projection

## Key Concepts

- Switches camera projection by reconstructing `Camera3D` with `CameraPerspective` or `CameraOrthographic`
- Uses `fovy` for perspective field-of-view and orthographic width depending on projection mode
- Renders the same geometric shapes (cubes, spheres, cylinders) under both projections for comparison
- Displays the current projection mode label on screen
