# Shapes Rectangle Scaling

Demonstrates interactive rectangle scaling by dragging a resize handle at the bottom-right corner.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_rectangle_scaling/
cd examples && ./_build/native/debug/build/raylib_shapes_rectangle_scaling/raylib_shapes_rectangle_scaling.exe
```

## Controls

- **Left Mouse Button**: Drag the bottom-right corner triangle to resize the rectangle

## Key Concepts

- Detects hover over a small corner region using `check_collision_point_rec`
- Tracks drag state to allow continuous resizing while the mouse button is held
- Clamps the rectangle to minimum (12x12) and maximum (screen bounds) sizes
- Draws a red triangle indicator at the resize handle when hovering or dragging
- Highlights the rectangle border in red when the resize handle is active
