# Xiao Xiao Le (Match-3)

A polished match-3 puzzle game (消消乐) with cascading combos, level progression, and a hint system.

## Build and Run

```bash
cd examples && moon build --target native raylib_xiaoxiaole/
cd examples && ./_build/native/debug/build/raylib_xiaoxiaole/raylib_xiaoxiaole.exe
```

## Controls

- **Mouse Click**: Select a gem, then click an adjacent gem to swap
- **H**: Show hint (highlights a valid swap)
- **R**: Restart (returns to level 1)
- **Enter / Space**: Start game, advance to next level after clearing
- **Esc**: Return to title screen

## How to Play

Swap adjacent gems on an 8x8 board to form matches of 3 or more in a row or column. Matched gems are removed and new ones fall in from above, potentially creating chain combos for bonus points. Each level has a **move limit** and a **target score** -- reach the target before running out of moves to advance. Difficulty increases each level with higher targets.

## Architecture

| File | Purpose |
|------|---------|
| `constants.mbt` | Screen layout, gem colors, animation speeds, game parameters |
| `types.mbt` | `Game` and `Gem` structs, coordinate helpers |
| `logic.mbt` | Match detection, gravity, cascades, swap validation, hint finder |
| `input.mbt` | Mouse selection and swap input, end-state navigation |
| `render.mbt` | Drawing: title, game panel, board, gems, overlays, hint pulse |
| `main.mbt` | Game loop |
