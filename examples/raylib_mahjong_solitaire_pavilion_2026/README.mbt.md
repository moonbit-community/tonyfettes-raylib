# Mahjong Solitaire Pavilion 2026

A tile-matching solitaire game inspired by mahjong solitaire. Clear the board by matching pairs of identical tiles that share an open edge, progressing through a 10-level campaign with increasing board sizes and tile variety.

## Build and Run

```bash
cd examples && moon build --target native raylib_mahjong_solitaire_pavilion_2026/
cd examples && ./_build/native/debug/build/raylib_mahjong_solitaire_pavilion_2026/raylib_mahjong_solitaire_pavilion_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move cursor (hold to repeat)
- **J or Space**: Select tile at cursor / confirm match
- **Mouse click**: Tap tile directly on the board
- **H**: Use hint (limited per level)
- **U**: Undo last match (limited)
- **S**: Shuffle remaining tiles (limited)
- **C**: Clear selection
- **R**: Reset current level
- **F11**: Toggle borderless windowed

## How to Play

Select two matching tiles that are "free" (have at least one open side) to remove them from the board. Clear all tiles to complete the level. Use hints to highlight a valid pair, shuffle to rearrange stuck boards, or undo to reverse a mistake. Build combos by matching quickly for bonus points. A timer ticks down -- if it expires or no valid moves remain, the level fails. Progress through 10 levels of increasing difficulty.
