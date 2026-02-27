# Shapes Math Sine Cosine

Interactive visualization of trigonometric functions on a unit circle. Displays sine, cosine, tangent, and cotangent values along with complementary, supplementary, and explementary angle arcs.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_math_sine_cosine/
cd examples && ./_build/native/debug/build/raylib_shapes_math_sine_cosine/raylib_shapes_math_sine_cosine.exe
```

## Controls

- **Angle Slider**: Adjust the current angle (0-360 degrees)
- **Pause Toggle**: Pause/resume the auto-rotating angle

## Key Concepts

- Draws a unit circle with a rotating radius showing the current angle
- Visualizes sine (red, vertical), cosine (blue, horizontal), tangent (purple), and cotangent (orange) as geometric line segments
- Renders sine and cosine waveforms using `draw_spline_linear`
- Shows complementary, supplementary, and explementary angles as colored sector arcs
- Uses raygui for the angle slider, pause toggle, and angle values panel
