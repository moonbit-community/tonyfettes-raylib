# Sokoban Warehouse Master 2026

A classic Sokoban puzzle game with multiple levels, undo support, and a star rating system. Push crates onto goal tiles using the fewest moves possible.

## Build and Run

```bash
cd examples && moon build --target native raylib_sokoban_warehouse_master_2026/
cd examples && ./_build/native/debug/build/raylib_sokoban_warehouse_master_2026/raylib_sokoban_warehouse_master_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move the player (and push boxes)
- **Z / Undo button**: Undo the last move
- **R / Reset button**: Reset the current level
- **Mouse / Touch**: On-screen directional touch controls

## How to Play

- Push all crates onto the goal tiles to clear each level
- Crates can only be pushed, never pulled
- Each level has a par score for moves; earn stars based on efficiency
- Undo individual moves to recover from mistakes
- Progress through a campaign of increasingly challenging warehouse layouts
- Track total moves, pushes, and elapsed time across all levels
