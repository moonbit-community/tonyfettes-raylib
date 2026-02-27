# Picross Harbor 2026

A nonogram (picross) puzzle game with a 12-level campaign. Solve grid-based logic puzzles by filling or crossing out cells based on row and column clues to reveal hidden pictures.

## Build and Run

```bash
cd examples && moon build --target native raylib_picross_harbor_2026/
cd examples && ./_build/native/debug/build/raylib_picross_harbor_2026/raylib_picross_harbor_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move cursor on the grid
- **Space / F**: Fill the current cell
- **X / C**: Cross out the current cell (mark as empty)
- **Tab / T**: Toggle between fill and cross tool modes
- **Z / Backspace**: Undo last action
- **H**: Use a hint (limited per level)
- **R**: Reset the current level
- **Mouse / Touch**: Click grid cells directly, or use on-screen D-pad and action buttons
- **F11**: Toggle borderless windowed mode

## How to Play

Each level presents a grid with numeric clues along the rows and columns indicating consecutive groups of filled cells. Use logic to determine which cells to fill and which to cross out. Mistakes count against you -- exceeding the mistake limit fails the level. Complete puzzles quickly with fewer mistakes and hints to earn more stars. Progress through all 12 levels to complete the campaign. Undo support and limited hints are available to help.
