# raylib_shapes_draw_rectangle_rounded

Interactive demonstration of rounded rectangle drawing. Adjust width, height, roundness, line thickness, and segment count, and toggle between filled, outlined, and standard rectangle rendering modes.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_draw_rectangle_rounded/
cd examples && ./_build/native/debug/build/raylib_shapes_draw_rectangle_rounded/raylib_shapes_draw_rectangle_rounded.exe
```

## Controls

- **Left/Right arrows**: Adjust width
- **Up/Down arrows**: Adjust height
- **W/S**: Adjust roundness (0.0 to 1.0)
- **A/D**: Adjust segment count (0 to 60; 0 = auto)
- **Q/E**: Adjust line thickness (0 to 20)
- **1**: Toggle rounded rectangle fill
- **2**: Toggle rounded rectangle outline
- **3**: Toggle standard rectangle fill

## Key Concepts

- Drawing rounded rectangles with `draw_rectangle_rounded`
- Drawing rounded rectangle outlines with `draw_rectangle_rounded_lines_ex`
- Controlling corner roundness, segment resolution, and line thickness parameters
