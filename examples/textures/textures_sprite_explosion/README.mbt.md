# raylib_textures_sprite_explosion

Demonstrates a click-triggered explosion animation using a 5x5 sprite sheet grid, with an accompanying sound effect.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_sprite_explosion/
cd examples && ./_build/native/debug/build/raylib_textures_sprite_explosion/raylib_textures_sprite_explosion.exe
```

## Controls

- **Left Mouse**: Click anywhere to trigger an explosion at the cursor position

## Key Concepts

- Animating through a grid-based sprite sheet (5 columns x 5 rows, 25 total frames)
- One-shot animation triggered by user input, with active/inactive state tracking
- Centering the explosion sprite on the click position
- Combining audio (`load_sound`, `play_sound`) with visual sprite animation
