# raylib_textures_sprite_button

Demonstrates creating an interactive button from a sprite sheet with three visual states (normal, hover, pressed) and a sound effect on click.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_sprite_button/
cd examples && ./_build/native/debug/build/raylib_textures_sprite_button/raylib_textures_sprite_button.exe
```

## Controls

- **Mouse**: Hover over and click the button

## Key Concepts

- Using a vertically-stacked sprite sheet with three frames for button states
- Hit detection with `check_collision_point_rec` for mouse-over-rectangle checks
- Playing a sound effect on button release with `play_sound`
- Selecting the correct sprite frame based on interaction state
