# Minesweeper

A classic Minesweeper implementation on a 16x16 grid with 40 mines. Left-click to reveal cells, right-click to place flags, and clear all non-mine cells to win.

## Build and Run

```bash
cd examples && moon build --target native raylib_minesweeper/
cd examples && ./_build/native/debug/build/raylib_minesweeper/raylib_minesweeper.exe
```

## Controls

- **Left Click**: Reveal a cell
- **Right Click**: Toggle flag on a cell
- **R**: Restart game

## How to Play

Click any cell to start -- the first click is always safe (mines are generated after, avoiding a 3x3 area around your click). Revealed cells show the count of adjacent mines (1-8) or are blank if no mines are nearby. Blank cells auto-expand (flood fill) to reveal all connected safe cells. Right-click to flag suspected mines. Reveal all non-mine cells to win. Clicking a mine ends the game and reveals all mine locations.
