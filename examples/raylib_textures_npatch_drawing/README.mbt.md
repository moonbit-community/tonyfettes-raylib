# raylib_textures_npatch_drawing

Demonstrates N-patch (nine-patch) texture drawing, allowing textures to scale without distorting their borders. Shows 9-patch, horizontal 3-patch, and vertical 3-patch modes.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_npatch_drawing/
cd examples && ./_build/native/debug/build/raylib_textures_npatch_drawing/raylib_textures_npatch_drawing.exe
```

## Controls

- **Mouse**: Move to stretch or shrink the N-patch rectangles

## Key Concepts

- Defining `NPatchInfo` with source rectangles and border sizes for 9-patch, horizontal 3-patch, and vertical 3-patch layouts
- Drawing scalable UI elements with `draw_texture_npatch`
- N-patches preserve border regions while stretching the interior, useful for buttons and panels
