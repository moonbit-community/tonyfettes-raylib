# raylib_textures_mouse_painting

A mouse-driven painting application with a color palette, adjustable brush size, eraser, and image export. Draws onto a render texture canvas.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_mouse_painting/
cd examples && ./_build/native/debug/build/raylib_textures_mouse_painting/raylib_textures_mouse_painting.exe
```

## Controls

- **Left Mouse**: Paint with selected color
- **Right Mouse**: Erase (paint with background color)
- **Mouse Wheel**: Adjust brush size (2-50)
- **Left/Right Arrows**: Cycle through color palette
- **C**: Clear canvas
- **S** or **SAVE button**: Export painting as PNG

## Key Concepts

- Using `load_render_texture` as an offscreen canvas
- Drawing into the render texture with `begin_texture_mode` / `end_texture_mode`
- Color palette selection with collision detection via `check_collision_point_rec`
- Exporting render texture contents to a PNG file with `export_image`
