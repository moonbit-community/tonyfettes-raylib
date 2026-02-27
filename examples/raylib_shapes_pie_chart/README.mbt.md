# Shapes Pie Chart

Interactive pie chart with configurable slices, hover highlighting, value/percentage labels, donut mode, and a scrollable editor panel for customizing each slice's label and value.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_pie_chart/
cd examples && ./_build/native/debug/build/raylib_shapes_pie_chart/raylib_shapes_pie_chart.exe
```

## Controls

- **Mouse hover**: Highlight and expand a pie slice
- **GUI Spinner**: Adjust number of slices (1-10)
- **GUI Checkboxes**: Toggle value display, percentage display, and donut mode
- **GUI Slider**: Adjust donut inner radius
- **Scroll Panel**: Edit slice labels and values

## Key Concepts

- Draws colored pie slices using `draw_circle_sector` with HSV-based coloring
- Hovered slices "pop out" with an enlarged radius for visual feedback
- Uses raygui scroll panel with text boxes and slider bars for per-slice editing
- Supports donut chart mode by overlaying a center circle
- Calculates label positions at 70% radius using midpoint angle trigonometry
