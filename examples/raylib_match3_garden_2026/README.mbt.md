# Match-3 Garden 2026

A classic match-3 puzzle game on an 8x8 grid with 6 tile types. Swap adjacent tiles to form rows or columns of 3 or more matching tiles, which are cleared and replaced by new tiles falling from above.

## Build and Run

```bash
cd examples && moon build --target native raylib_match3_garden_2026/
cd examples && ./_build/native/debug/build/raylib_match3_garden_2026/raylib_match3_garden_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move cursor on the board
- **Space**: Select tile / swap with previously selected tile
- **R**: Restart game

## How to Play

Select a tile with Space, then move to an adjacent tile and press Space again to swap them. If the swap creates a line of 3 or more matching tiles (horizontally or vertically), those tiles are cleared and you earn points. Tiles above drop down to fill gaps, and new random tiles appear at the top. Chain reactions from cascading matches award bonus points. The board is initialized without pre-existing matches.
