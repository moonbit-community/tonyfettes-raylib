# Core Input Keys

Demonstrates basic keyboard input by moving a ball on screen using the arrow keys.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_input_keys/
cd examples && ./_build/native/debug/build/raylib_core_input_keys/raylib_core_input_keys.exe
```

## Controls

- **Arrow Keys**: Move the ball in four directions

## Key Concepts

- `is_key_down` for continuous key state polling (held keys).
- Updating a `Vector2` position based on input each frame.
- `draw_circle_v` for rendering a circle at a vector position.
