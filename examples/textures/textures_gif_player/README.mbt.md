# raylib_textures_gif_player

Demonstrates loading and playing an animated GIF file by extracting individual frames and updating a texture each frame.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_gif_player/
cd examples && ./_build/native/debug/build/raylib_textures_gif_player/raylib_textures_gif_player.exe
```

## Controls

- **Left/Right Arrow Keys**: Decrease/increase frame delay (animation speed)

## Key Concepts

- Loads all GIF frames into a single image using `load_image_anim` and queries the frame count with `image_frame_count`
- Creates a single texture and updates it per-frame with `update_texture_from_image_frame`
- Frame delay is adjustable from 1 to 20 frames between animation steps
- Displays total frames, current frame index, and a visual delay indicator bar
