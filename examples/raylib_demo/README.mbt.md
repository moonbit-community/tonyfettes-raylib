# raylib_demo

A simple interactive demo showcasing basic raylib drawing primitives and input handling in MoonBit. Move a ball around the screen while a crosshair follows the mouse.

## Build and Run

```bash
cd examples && moon build --target native raylib_demo/
cd examples && ./_build/native/debug/build/raylib_demo/raylib_demo.exe
```

## Controls

- **WASD / Arrow keys**: Move the ball
- **Mouse**: Crosshair follows cursor

## Key Concepts

- Basic shape drawing: circles, rectangles, triangles, polygons, rounded rectangles, gradient fills
- Line drawing between ball and mouse with `draw_line_ex`
- `get_frame_time()` for frame-rate-independent movement
- `get_mouse_position()` for mouse tracking
- Window is resizable with `FlagWindowResizable`
