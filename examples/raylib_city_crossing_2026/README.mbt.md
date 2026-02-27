# City Crossing 2026

A Frogger-style road and river crossing game. Guide a character across busy roads and log-filled rivers to reach home slots at the top of the grid.

## Build and Run

```bash
cd examples && moon build --target native raylib_city_crossing_2026/
cd examples && ./_build/native/debug/build/raylib_city_crossing_2026/raylib_city_crossing_2026.exe
```

## Controls

- **Arrow Keys / WASD**: Move one cell at a time
- **Mouse/Touch**: On-screen directional pad (bottom-left)
- **R**: Restart the game

## How to Play

- Cross roads without getting hit by cars and rivers by hopping onto floating logs.
- Reach all 5 home slots at the top to advance to the next level.
- Logs carry you sideways -- avoid drifting off-screen.
- Each level increases traffic speed. A 55-second timer resets per life.
- Moving forward earns points; filling all home slots grants a level bonus.
- Lose all 4 lives and the game is over.
