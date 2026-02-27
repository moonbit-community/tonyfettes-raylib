# Shapes Splines Drawing

Interactive spline editor supporting four spline types: Linear, B-Spline, Catmull-Rom, and Cubic Bezier. Points can be added and dragged to shape the curve in real time.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_splines_drawing/
cd examples && ./_build/native/debug/build/raylib_shapes_splines_drawing/raylib_shapes_splines_drawing.exe
```

## Controls

- **Right Mouse Button**: Add a new spline point
- **Left Mouse Button**: Drag existing points (or Bezier control points)
- **1**: Linear spline
- **2**: B-Spline
- **3**: Catmull-Rom spline
- **4**: Cubic Bezier spline

## Key Concepts

- Uses `draw_spline_linear`, `draw_spline_basis`, `draw_spline_catmull_rom`, and `draw_spline_bezier_cubic`
- In Bezier mode, each segment has draggable start/end control points shown as gold circles
- Control lines connect points to their Bezier handles for visual clarity
- Point coordinates are displayed as text labels beneath each point
- Supports up to 32 spline points with 4x MSAA anti-aliasing
