# raylib_textures_fog_of_war

Demonstrates a fog of war effect using a render texture, where only tiles near the player are visible and previously visited tiles appear dimmed.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_fog_of_war/
cd examples && ./_build/native/debug/build/raylib_textures_fog_of_war/raylib_textures_fog_of_war.exe
```

## Controls

- **Arrow Keys**: Move the player around the tile map

## Key Concepts

- Uses a small render texture (25x15 pixels, one per tile) as a fog mask, scaled up over the full map
- Three fog states per tile: unexplored (black), currently visible (clear), previously visited (80% black)
- Fog texture uses bilinear filtering for smooth transitions between fog states
- The render texture is drawn over the tile map using `draw_render_texture_pro` with y-flip handling
- Player visibility radius is 2 tiles in each direction
