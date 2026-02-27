# Bomber Grid 2026

A classic Bomberman-style game on a grid map where you place bombs to destroy breakable walls and enemies while navigating the blast radius.

## Build and Run

```bash
cd examples && moon build --target native raylib_bomber_grid_2026/
cd examples && ./_build/native/debug/build/raylib_bomber_grid_2026/raylib_bomber_grid_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move on the grid
- **Space**: Place bomb
- **R**: Restart

## How to Play

Navigate a grid-based map with indestructible pillars and breakable walls. Place bombs that detonate after a short fuse, sending blasts in four directions. Destroy walls to open paths and eliminate enemies. Avoid your own bomb blasts and enemy contact. Clear all enemies to win. The map is randomly generated each game with guaranteed safe zones at spawn points.
