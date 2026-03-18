# Core Random Values

Demonstrates `get_random_value` by generating a new random integer in the range [-8, 5] every 2 seconds and displaying it on screen.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_random_values/
cd examples && ./_build/native/debug/build/raylib_core_random_values/raylib_core_random_values.exe
```

## Key Concepts

- `get_random_value(min, max)` for generating random integers within a range.
- Frame counter pattern for time-based events (120 frames = 2 seconds at 60 FPS).
- Simple text rendering with `draw_text` to display the generated value.
