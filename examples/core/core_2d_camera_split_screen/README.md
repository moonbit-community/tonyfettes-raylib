# Core 2D Camera Split Screen

Demonstrates split-screen rendering with two independent 2D cameras, each following a separate player, using render textures.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_2d_camera_split_screen/
cd examples && ./_build/native/debug/build/raylib_core_2d_camera_split_screen/raylib_core_2d_camera_split_screen.exe
```

## Controls

- **Player 1 (left half)**: W/S/A/D to move
- **Player 2 (right half)**: Arrow keys to move

## Key Concepts

- `load_render_texture` to create off-screen render targets for each viewport.
- Each player has its own `Camera2D` tracking its position independently.
- `begin_texture_mode` / `end_texture_mode` for rendering to textures.
- `draw_render_texture_rec` to draw each half-screen texture side by side.
- Flipped rectangle height (negative) to correct texture UV orientation.
