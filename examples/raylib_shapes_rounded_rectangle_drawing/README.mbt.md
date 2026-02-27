# Shapes Rounded Rectangle Drawing

Interactive demo for drawing rounded rectangles with configurable width, height, roundness, line thickness, and segment count using raygui controls.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_rounded_rectangle_drawing/
cd examples && ./_build/native/debug/build/raylib_shapes_rounded_rectangle_drawing/raylib_shapes_rounded_rectangle_drawing.exe
```

## Controls

- **GUI Sliders**: Adjust width, height, roundness, thickness, and segments
- **GUI Checkboxes**: Toggle DrawRoundedRect, DrawRoundedLines, and DrawRect

## Key Concepts

- Uses `draw_rectangle_rounded` for filled rounded rectangles
- Uses `draw_rectangle_rounded_lines_ex` for outlined rounded rectangles with configurable thickness
- Segments control corner smoothness: values below 4 use AUTO mode, 4+ use MANUAL
- Demonstrates layering filled shapes with outlines and regular rectangles
- All parameters are adjustable in real-time through the raygui side panel
