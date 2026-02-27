# Shapes Triangle Strip

Renders a star/gear-like shape using triangle strips with alternating inner and outer radii. Each triangle is colored based on its angle using HSV color space.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_triangle_strip/
cd examples && ./_build/native/debug/build/raylib_shapes_triangle_strip/raylib_shapes_triangle_strip.exe
```

## Controls

- **GUI Slider**: Adjust number of segments (6-60)
- **GUI Checkbox**: Toggle outline rendering

## Key Concepts

- Builds a triangle strip by alternating vertices on inner (100px) and outer (150px) radii
- Draws individual triangles with `draw_triangle` rather than using a strip primitive
- Colors each triangle using `color_from_hsv` based on its angular position
- Optional black outline via `draw_triangle_lines` for each triangle pair
- Uses raygui for real-time segment count and outline toggle controls
