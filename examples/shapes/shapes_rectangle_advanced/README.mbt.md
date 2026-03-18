# Shapes Rectangle Advanced

Demonstrates custom-drawn rounded rectangles with horizontal gradients and independently configurable left/right corner roundness using low-level rlgl triangle rendering.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_rectangle_advanced/
cd examples && ./_build/native/debug/build/raylib_shapes_rectangle_advanced/raylib_shapes_rectangle_advanced.exe
```

## Key Concepts

- Implements `draw_rectangle_rounded_gradient_h` from scratch using `rl_begin`/`rl_end`
- Draws rounded corners as triangle fans with per-vertex coloring via `rl_color4ub`
- Supports asymmetric roundness (different left vs. right corner radii)
- Fills the rectangle body as 5 sub-rectangles (upper, right, bottom, left, middle)
- Displays 5 example rectangles with varying roundness and color gradient combinations
