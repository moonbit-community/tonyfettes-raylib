# raylib_shapes_colors_palette

Displays the 21 built-in raylib color constants as a grid of interactive color swatches. Hovering over a swatch highlights it and reveals its name; pressing Space reveals all names at once.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_colors_palette/
cd examples && ./_build/native/debug/build/raylib_shapes_colors_palette/raylib_shapes_colors_palette.exe
```

## Controls

- **Mouse hover**: Highlight a color swatch and show its name
- **Space (hold)**: Show all color names simultaneously

## Key Concepts

- Using `check_collision_point_rec` for mouse hover detection on a grid of rectangles
- Displaying raylib's built-in color constants (darkgray through beige)
- Applying `fade` to adjust alpha transparency on hover
- Measuring text width with `measure_text` for right-aligned label positioning
