# raylib_shapes_bouncing_ball

A simple bouncing ball animation that moves around the screen, bouncing off the window edges. Includes pause functionality with a blinking indicator.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_bouncing_ball/
cd examples && ./_build/native/debug/build/raylib_shapes_bouncing_ball/raylib_shapes_bouncing_ball.exe
```

## Controls

- **Space**: Pause / resume ball movement

## Key Concepts

- Basic 2D physics: velocity-based movement with wall collision detection and reflection
- Drawing a circle at a dynamic position with `draw_circle_v`
- Implementing pause with a frame-counter-based blinking text effect
