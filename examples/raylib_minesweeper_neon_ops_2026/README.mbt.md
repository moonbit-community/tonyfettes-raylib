# Minesweeper Neon Ops 2026

An enhanced minesweeper game with a neon aesthetic, featuring a 24x14 board with 58 mines, a lives system, combo scoring, hint assistance, and letter grades. Supports both keyboard and touch input.

## Build and Run

```bash
cd examples && moon build --target native raylib_minesweeper_neon_ops_2026/
cd examples && ./_build/native/debug/build/raylib_minesweeper_neon_ops_2026/raylib_minesweeper_neon_ops_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move cursor on the board
- **J or Space**: Reveal cell / confirm action
- **K**: Toggle flag mode (switch between reveal and flag)
- **L**: Use hint (limited uses, reveals a safe cell)
- **Mouse click**: Tap cells directly or use on-screen buttons
- **R**: Restart game

## How to Play

Navigate the board and reveal safe cells while flagging mines. Unlike classic minesweeper, hitting a mine costs a life instead of ending the game immediately -- you get 3 lives. Build combos by revealing cells in quick succession for bonus points. Use limited hints to safely reveal a cell when stuck. Your performance is graded from S to D based on score, mistakes, and combo streaks. Clear all safe cells to win.
