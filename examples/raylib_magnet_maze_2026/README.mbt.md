# Magnet Maze 2026

A grid-based puzzle game where you navigate a maze and use magnetic pulses to push or pull orbs onto goal positions. Solve each level by placing all orbs on their targets within a move limit.

## Build and Run

```bash
cd examples && moon build --target native raylib_magnet_maze_2026/
cd examples && ./_build/native/debug/build/raylib_magnet_maze_2026/raylib_magnet_maze_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move the player on the 14x10 grid
- **Space or J**: Emit attract pulse (pulls orbs toward you)
- **K**: Emit repel pulse (pushes orbs away from you)
- **R**: Restart level

## How to Play

Move through a walled maze containing 4 magnetic orbs and 4 goal positions. You cannot push orbs directly -- instead, emit magnetic pulses to attract or repel all orbs simultaneously. Orbs move one cell at a time in the direction toward (attract) or away from (repel) you, unless blocked by walls or other orbs. Solve each of the 3 levels by maneuvering all orbs onto their matching goal squares within the move limit.
