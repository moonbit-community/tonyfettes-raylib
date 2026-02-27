# raylib_shapes_basic_shapes

Demonstrates drawing basic 2D shapes available in raylib: circles (filled, gradient, lines), rectangles (filled, gradient, lines), triangles (filled, lines), and polygons (filled, lines, thick lines).

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_basic_shapes/
cd examples && ./_build/native/debug/build/raylib_shapes_basic_shapes/raylib_shapes_basic_shapes.exe
```

## Key Concepts

- Drawing circles: `draw_circle`, `draw_circle_gradient`, `draw_circle_lines`
- Drawing rectangles: `draw_rectangle`, `draw_rectangle_gradient_h`, `draw_rectangle_lines`
- Drawing triangles: `draw_triangle`, `draw_triangle_lines`
- Drawing polygons: `draw_poly`, `draw_poly_lines`, `draw_poly_lines_ex` (with thickness)
- Animating rotation on polygons
