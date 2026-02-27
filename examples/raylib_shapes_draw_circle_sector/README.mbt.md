# raylib_shapes_draw_circle_sector

Interactive demonstration of `draw_circle_sector` and `draw_circle_sector_lines`. Adjust the start angle, end angle, radius, and segment count with keyboard controls to explore how circle sectors are rendered.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_draw_circle_sector/
cd examples && ./_build/native/debug/build/raylib_shapes_draw_circle_sector/raylib_shapes_draw_circle_sector.exe
```

## Controls

- **Left/Right arrows**: Adjust start angle (0 to 720)
- **Up/Down arrows**: Adjust end angle (0 to 720)
- **W/S**: Adjust radius (0 to 200)
- **A/D**: Adjust segment count (0 to 100; 0 = auto mode)

## Key Concepts

- Drawing filled circle sectors with `draw_circle_sector`
- Drawing circle sector outlines with `draw_circle_sector_lines`
- Auto vs. manual segment mode (segment count of 0 lets raylib choose automatically)
