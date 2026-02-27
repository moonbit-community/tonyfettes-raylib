# raylib_warehouse_forklift_2026

A Sokoban-style puzzle game set in a warehouse. Push crates onto yellow dock markers using a forklift, navigating around rack obstacles on a grid.

## Build and Run

```bash
cd examples && moon build --target native raylib_warehouse_forklift_2026/
cd examples && ./_build/native/debug/build/raylib_warehouse_forklift_2026/raylib_warehouse_forklift_2026.exe
```

## Controls

- **WASD/Arrows**: Move forklift
- **R**: Restart level

## How to Play

- Push all 4 crates onto the yellow dock markers to complete the shipment
- You can only push crates (not pull); a crate cannot be pushed into a wall or another crate
- Plan your moves carefully to avoid getting crates stuck in corners
- Score is based on moves and pushes; fewer moves means a better score
