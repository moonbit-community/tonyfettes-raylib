# raylib_shapes_draw_ring

Interactive demonstration of ring (annulus) drawing. Adjust inner radius, outer radius, start angle, end angle, and segment count, and toggle between filled ring, ring lines, and circle sector lines.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_draw_ring/
cd examples && ./_build/native/debug/build/raylib_shapes_draw_ring/raylib_shapes_draw_ring.exe
```

## Controls

- **Left/Right arrows**: Adjust start angle (-450 to 450)
- **Up/Down arrows**: Adjust end angle (-450 to 450)
- **W/S**: Adjust inner radius (0 to 100)
- **A/D**: Adjust outer radius (0 to 200)
- **Q/E**: Adjust segment count (0 to 100; 0 = auto)
- **1**: Toggle filled ring
- **2**: Toggle ring lines
- **3**: Toggle circle sector lines

## Key Concepts

- Drawing filled rings with `draw_ring`
- Drawing ring outlines with `draw_ring_lines`
- Comparing ring drawing with circle sector lines (`draw_circle_sector_lines`)
