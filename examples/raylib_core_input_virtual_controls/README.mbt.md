# Core Input Virtual Controls

Demonstrates on-screen virtual D-pad controls for touch devices, moving a player rectangle based on touch/mouse proximity to virtual button positions.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_input_virtual_controls/
cd examples && ./_build/native/debug/build/raylib_core_input_virtual_controls/raylib_core_input_virtual_controls.exe
```

## Controls

- **Touch / Mouse**: Tap the on-screen D-pad circles (X=Up, Y=Left, B=Right, A=Down)

## Key Concepts

- Virtual D-pad implemented with circle colliders and Manhattan distance hit testing.
- `get_touch_x` / `get_touch_y` with fallback to `get_mouse_x` / `get_mouse_y`.
- Frame-time-based movement using `get_frame_time`.
- Pattern for mobile-friendly touch controls in desktop applications.
