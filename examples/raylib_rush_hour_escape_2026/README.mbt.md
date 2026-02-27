# raylib_rush_hour_escape_2026

A sliding-block puzzle game inspired by Rush Hour. Slide cars on a 6x6 grid to clear a path for the red player car to reach the exit gate on the right side.

## Build and Run

```bash
cd examples && moon build --target native raylib_rush_hour_escape_2026/
cd examples && ./_build/native/debug/build/raylib_rush_hour_escape_2026/raylib_rush_hour_escape_2026.exe
```

## Controls

- **Mouse Click**: Select a car on the grid
- **WASD / Arrows**: Slide the selected car along its axis
- **R**: Restart from level 1

## How to Play

Each level presents a grid of colored cars and trucks. Cars marked with "P" (red) must reach the EXIT gate on the right edge of row 3. Horizontal cars slide left/right; vertical cars slide up/down. Only one cell of movement is allowed per keypress. The game tracks your move count against a par target -- fewer moves earn more stars and a higher score. Three increasingly difficult levels are included. Solve all three to earn the "Traffic Master" title.
