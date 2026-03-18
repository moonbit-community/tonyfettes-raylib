# raylib_textures_sprite_anim

Demonstrates sprite sheet animation by cycling through frames of a horizontal strip texture at an adjustable speed.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_sprite_anim/
cd examples && ./_build/native/debug/build/raylib_textures_sprite_anim/raylib_textures_sprite_anim.exe
```

## Controls

- **Right Arrow**: Increase animation speed
- **Left Arrow**: Decrease animation speed

## Key Concepts

- Extracting individual frames from a sprite sheet using source rectangles
- Frame-based animation timing with a configurable frames-per-second counter
- Drawing a sub-region of a texture with `draw_texture_rec`
- Visual speed indicator using filled/empty rectangle bars
