# Tetris Meteor Fall 2026

A classic Tetris implementation with all 7 standard tetrominoes, hold piece, next piece preview, ghost piece, and increasing difficulty through levels.

## Build and Run

```bash
cd examples && moon build --target native raylib_tetris_meteor_fall_2026/
cd examples && ./_build/native/debug/build/raylib_tetris_meteor_fall_2026/raylib_tetris_meteor_fall_2026.exe
```

## Controls

- **Left/Right**: Move piece horizontally
- **Down**: Soft drop
- **Up / Space**: Hard drop
- **Z**: Rotate counter-clockwise
- **X**: Rotate clockwise
- **C**: Hold piece
- **R**: Restart

## How to Play

Standard Tetris gameplay on a 10x20 board. Place falling tetrominoes to complete horizontal lines. Clearing multiple lines at once awards more points (100/300/500/800 for single/double/triple/tetris). The drop speed increases with each level. Uses a 7-bag randomizer for fair piece distribution. A ghost piece shows where the current piece will land.
