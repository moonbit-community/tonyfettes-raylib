# Shapes Kaleidoscope

A drawing tool that creates kaleidoscope patterns with 6-fold rotational symmetry. Every mouse stroke is mirrored and rotated around the screen center to produce symmetric designs.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_kaleidoscope/
cd examples && ./_build/native/debug/build/raylib_shapes_kaleidoscope/raylib_shapes_kaleidoscope.exe
```

## Controls

- **Left Mouse Button**: Draw lines
- **Reset button**: Clear all lines
- **< / > buttons**: Step backward/forward through the drawing history

## Key Concepts

- Applies 6-fold rotational symmetry by rotating each line segment at 60-degree intervals
- Adds reflection symmetry by scaling the Y-axis by -1 for each rotated line
- Uses Camera2D with the screen center as the offset for centered symmetry
- Implements undo/redo through a line counter that can be stepped back and forward
- Uses raygui buttons for the Reset/Back/Next UI controls
