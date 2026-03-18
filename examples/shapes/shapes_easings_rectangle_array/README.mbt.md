# Shapes Easings Rectangle Array

Demonstrates easing functions applied to an array of rectangles. A grid of red rectangles shrinks and rotates using circular-out and linear-in easing curves, creating a synchronized animation effect.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_easings_rectangle_array/
cd examples && ./_build/native/debug/build/raylib_shapes_easings_rectangle_array/raylib_shapes_easings_rectangle_array.exe
```

## Controls

- **Space**: Replay the animation after it completes

## Key Concepts

- Implements `ease_circ_out` and `ease_linear_in` easing functions from scratch
- Animates width, height, and rotation of a 16x9 grid of rectangles over 240 frames
- Uses `draw_rectangle_pro` with per-frame rotation and shrinking dimensions
- State machine toggles between animating (state 0) and waiting for replay (state 1)
