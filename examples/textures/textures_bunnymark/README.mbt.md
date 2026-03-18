# raylib_textures_bunnymark

A classic rendering performance benchmark that spawns thousands of bouncing bunny sprites to stress-test the renderer and measure FPS.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_bunnymark/
cd examples && ./_build/native/debug/build/raylib_textures_bunnymark/raylib_textures_bunnymark.exe
```

## Controls

- **Left Mouse Button (hold)**: Spawn 100 bunnies per frame at the cursor position

## Key Concepts

- Supports up to 50,000 bunnies, each with independent position, velocity, and random color
- Bunnies bounce off screen edges with velocity reversal
- Displays live bunny count, batched draw call count (based on `MAX_BATCH_ELEMENTS = 8192`), and FPS
- Demonstrates raylib's batch rendering efficiency with `draw_texture`
