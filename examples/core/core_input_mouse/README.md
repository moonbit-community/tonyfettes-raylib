# Core Input Mouse

Demonstrates mouse input by tracking the cursor position and changing a ball's color based on which mouse button is pressed.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_input_mouse/
cd examples && ./_build/native/debug/build/raylib_core_input_mouse/raylib_core_input_mouse.exe
```

## Controls

- **Mouse Movement**: Ball follows the cursor
- **Mouse Buttons**: Left, Middle, Right, Side, Extra, Forward, Back each set a different ball color

## Key Concepts

- `get_mouse_position` for cursor tracking.
- `is_mouse_button_pressed` for detecting mouse button click events.
- Support for 7 mouse button types including side/extra/forward/back.
