# Shapes RLGL Color Wheel

A color picker built with low-level rlgl rendering. Displays an HSV color wheel rendered as a triangle fan, with a draggable handle for selecting hue and saturation, and a value slider.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_rlgl_color_wheel/
cd examples && ./_build/native/debug/build/raylib_shapes_rlgl_color_wheel/raylib_shapes_rlgl_color_wheel.exe
```

## Controls

- **Left Mouse Button**: Click/drag on the wheel to select a color
- **Mouse Wheel**: Adjust triangle count (3-256) for wheel smoothness
- **Up/Down Arrows**: Scale the color wheel size
- **Space (hold)**: Toggle wireframe rendering mode
- **Ctrl+C**: Copy selected color as hex to clipboard
- **GUI Slider**: Adjust the value (brightness) component

## Key Concepts

- Renders a color wheel using `rl_begin(RlTriangles)` with per-vertex HSV coloring
- Converts mouse position to hue (angle) and saturation (distance from center)
- Uses `color_from_hsv` and `color_lerp` for HSV-to-RGB conversion
- Displays the selected color preview with hex and RGB decimal values
- Supports wireframe mode via `rl_begin(RlLines)` for visualization
