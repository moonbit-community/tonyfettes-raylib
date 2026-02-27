# Core Input Mouse Wheel

Demonstrates mouse wheel input by scrolling a box up and down on screen.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_input_mouse_wheel/
cd examples && ./_build/native/debug/build/raylib_core_input_mouse_wheel/raylib_core_input_mouse_wheel.exe
```

## Controls

- **Mouse Wheel**: Scroll the box up and down

## Key Concepts

- `get_mouse_wheel_move` for reading the scroll wheel delta each frame.
- Applying a scroll speed multiplier to the wheel input.
- Displaying the current Y position as on-screen text.
