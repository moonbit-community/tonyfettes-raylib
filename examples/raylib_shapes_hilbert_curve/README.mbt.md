# Shapes Hilbert Curve

Generates and displays a Hilbert space-filling curve with configurable order, thickness, and size. The curve is drawn with rainbow coloring (HSV-based) and can be animated stroke by stroke.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_hilbert_curve/
cd examples && ./_build/native/debug/build/raylib_shapes_hilbert_curve/raylib_shapes_hilbert_curve.exe
```

## Controls

- **GUI Spinner**: Adjust Hilbert curve order (2-8)
- **GUI Sliders**: Adjust line thickness and total size
- **GUI Checkbox**: Toggle animated generation on parameter change

## Key Concepts

- Implements the Hilbert curve algorithm iteratively using bit manipulation
- Uses raygui for interactive parameter controls (spinner, sliders, checkbox)
- Colors each segment based on its position in the sequence using `color_from_hsv`
- Supports animated drawing (one stroke per frame) or instant full rendering
