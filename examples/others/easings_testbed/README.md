# raylib_easings_testbed

An interactive testbed for visualizing 29 different easing functions (linear, sine, circular, cubic, quadratic, exponential, back, bounce, elastic). Animate a ball across the screen using any easing curve.

## Build and Run

```bash
cd examples && moon build --target native raylib_easings_testbed/
cd examples && ./_build/native/debug/build/raylib_easings_testbed/raylib_easings_testbed.exe
```

## Controls

- **Up/Down or mouse click**: Cycle through easing functions
- **Space**: Reset/replay the current animation
- **D**: Change animation duration

## Key Concepts

- Complete implementation of standard easing functions: Linear, Sine, Circ, Cubic, Quad, Expo, Back, Bounce, Elastic -- each with In, Out, and InOut variants
- All easing functions follow the signature `(t, b, c, d) -> Float` where t=time, b=begin, c=change, d=duration
- Useful reference for adding smooth animations and transitions to games
