# Matchlink Festival 2026

A tile-matching puzzle game where you clear pairs of identical tiles by connecting them with a path that bends at most twice (Shisen-Sho / Four Rivers style). Progress through a 10-level campaign with increasing board sizes.

## Build and Run

```bash
cd examples && moon build --target native raylib_matchlink_festival_2026/
cd examples && ./_build/native/debug/build/raylib_matchlink_festival_2026/raylib_matchlink_festival_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move cursor (hold to repeat)
- **J or Space**: Select tile at cursor
- **Mouse click**: Tap tile directly on the board
- **H**: Use hint (limited per level)
- **S**: Shuffle remaining tiles (limited)
- **C**: Clear current selection
- **R**: Reset current level
- **F11**: Toggle borderless windowed

## How to Play

Select two matching tiles that can be connected by a path with at most two 90-degree turns through empty cells. Successfully linked pairs are removed from the board. Clear all tiles to advance. Build combos with rapid matches for bonus points. Use hints to reveal valid pairs and shuffles to rearrange stuck boards. A timer counts down -- clear the board before time runs out across 10 progressively harder levels.
