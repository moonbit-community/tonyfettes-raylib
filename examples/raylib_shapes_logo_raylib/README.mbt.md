# Shapes Logo Raylib

Draws the raylib logo using only basic shape primitives (rectangles and text) -- no textures involved.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_logo_raylib/
cd examples && ./_build/native/debug/build/raylib_shapes_logo_raylib/raylib_shapes_logo_raylib.exe
```

## Key Concepts

- Recreates the raylib logo purely with `draw_rectangle` and `draw_text` calls
- Uses a black outer rectangle with a white inner rectangle to form the logo border
- Demonstrates that complex visuals can be built from simple shape primitives
