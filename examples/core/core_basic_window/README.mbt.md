# Core Basic Window

The minimal raylib example -- creates a window and displays a text message. This is the starting point for any raylib application.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_basic_window/
cd examples && ./_build/native/debug/build/raylib_core_basic_window/raylib_core_basic_window.exe
```

## Key Concepts

- `init_window` / `close_window` lifecycle.
- `set_target_fps` for frame rate control.
- `window_should_close` for the main loop exit condition.
- `begin_drawing` / `end_drawing` and `clear_background` for the render loop.
- `draw_text` for basic text rendering.
