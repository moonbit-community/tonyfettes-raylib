# raylib_neon_2048_storm_2026

A neon-themed twist on 2048 played on a 5x5 grid with storm mechanics that periodically spawn blocker tiles, a zap ability to clear cells, and an undo system.

## Build and Run

```bash
cd examples && moon build --target native raylib_neon_2048_storm_2026/
cd examples && ./_build/native/debug/build/raylib_neon_2048_storm_2026/raylib_neon_2048_storm_2026.exe
```

## Controls

- **Mouse / Touch**: Swipe or click directional buttons to slide tiles
- **Keyboard**: Arrow keys or WASD to slide tiles

## How to Play

- Slide numbered tiles in four directions to merge matching values
- Every few turns a "storm" spawns blocker tiles that cannot be merged
- Charge and use the zap ability to destroy individual cells
- Undo your last move if you make a mistake
- Reach the target tile value to win, or fill the board to lose
- Neon spark effects and screen shake add visual flair to merges
