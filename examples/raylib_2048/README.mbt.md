# 2048

A faithful recreation of the classic 2048 sliding puzzle game with smooth tile animations, warm color palette, and undo support.

## Build and Run

```bash
cd examples && moon build --target native raylib_2048/
cd examples && ./_build/native/debug/build/raylib_2048/raylib_2048.exe
```

## Controls

- **Arrow Keys / WASD**: Slide tiles
- **Z / U**: Undo last move
- **R**: Restart game
- **Enter / Space**: Start game, continue after winning

## How to Play

Slide tiles on a 4x4 grid. When two tiles with the same number collide, they merge into one with double the value. Reach the **2048** tile to win. After winning, you can keep playing for a higher score. If no valid moves remain, the game is over.

## Architecture

| File | Purpose |
|------|---------|
| `constants.mbt` | Screen layout, tile colors, animation speeds |
| `types.mbt` | `Game` and `Tile` structs, utility functions |
| `logic.mbt` | Core 2048 merge/slide algorithm, spawn, undo, animation updates |
| `input.mbt` | Keyboard and mouse input handling per game state |
| `render.mbt` | Drawing: title screen, board, tiles, score boxes, overlays |
| `main.mbt` | Game loop |
