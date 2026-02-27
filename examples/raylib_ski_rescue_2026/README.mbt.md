# Ski Rescue 2026

A downhill skiing game where you navigate between lanes to rescue stranded civilians while avoiding trees and rocks. Collect speed boosts to cover more distance.

## Build and Run

```bash
cd examples && moon build --target native raylib_ski_rescue_2026/
cd examples && ./_build/native/debug/build/raylib_ski_rescue_2026/raylib_ski_rescue_2026.exe
```

## Controls

- **A / Left Arrow**: Move one lane left
- **D / Right Arrow**: Move one lane right
- **R**: Restart the game

## How to Play

- Ski downhill across 5 lanes, dodging obstacles that scroll toward you
- Trees (green triangles) and rocks (gray circles) cost a life on collision
- Rescue civilians (orange circles with "!") for 120 bonus points
- Collect speed boosts (green circles with "+") for a temporary 45% speed increase
- You have 3 lives; the run ends when all lives are lost
- Speed gradually increases over time, making obstacles harder to dodge
