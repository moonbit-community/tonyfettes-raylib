# raylib_pac_dash_2026

A Pac-Man-inspired maze game with classic mechanics: eat all pellets, avoid four colored ghosts, grab power pellets to turn the tables, and clear the maze to win.

## Build and Run

```bash
cd examples && moon build --target native raylib_pac_dash_2026/
cd examples && ./_build/native/debug/build/raylib_pac_dash_2026/raylib_pac_dash_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move player through the maze

## How to Play

- Navigate a 21x23 tile maze eating pellets for points (10 points each)
- Collect power pellets to enter frightened mode where you can eat ghosts
- Four ghosts with distinct colors chase you using alternating chase and scatter phases
- Eat all pellets to win the level
- You have 3 lives -- losing them all ends the game
- Ghosts eaten during frightened mode award bonus points
