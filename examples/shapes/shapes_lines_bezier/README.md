# Shapes Lines Bezier

Demonstrates drawing a cubic Bezier curve between two draggable endpoints. The start and end points can be repositioned with the mouse.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_lines_bezier/
cd examples && ./_build/native/debug/build/raylib_shapes_lines_bezier/raylib_shapes_lines_bezier.exe
```

## Controls

- **Left Mouse Button**: Click and drag the start or end circle to reposition it

## Key Concepts

- Uses `draw_line_bezier` to render a smooth cubic Bezier curve
- Implements drag-and-drop for both endpoints using `check_collision_point_circle`
- Highlights hovered endpoints by increasing their radius (8 to 14 pixels)
- Changes endpoint color to red while actively dragging
- Enables 4x MSAA for smooth anti-aliased line rendering
