# Core 2D Camera Platformer

Demonstrates five different 2D camera follow strategies for a simple platformer, showcasing how camera behavior affects game feel.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_2d_camera_platformer/
cd examples && ./_build/native/debug/build/raylib_core_2d_camera_platformer/raylib_core_2d_camera_platformer.exe
```

## Controls

- **Left / Right**: Move the player horizontally
- **Space**: Jump
- **Mouse Wheel**: Zoom in/out
- **C**: Cycle through camera modes
- **R**: Reset player position and zoom

## Key Concepts

- Five camera update strategies, switchable at runtime:
  1. Follow player center
  2. Follow player center, clamped to map edges
  3. Smooth follow with interpolation
  4. Horizontal follow with vertical even-out on landing
  5. Player-push (camera moves only when player nears screen edge)
- Basic platformer physics with gravity, jumping, and platform collision.
- `get_world_to_screen_2d` / `get_screen_to_world_2d` for coordinate conversion.
