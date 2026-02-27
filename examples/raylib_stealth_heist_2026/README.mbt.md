# Stealth Heist 2026

A turn-based stealth puzzle game on a grid map. Sneak past patrolling guards, collect keycards, and reach the exit without being spotted. Guards have line-of-sight detection and patrol routes.

## Build and Run

```bash
cd examples && moon build --target native raylib_stealth_heist_2026/
cd examples && ./_build/native/debug/build/raylib_stealth_heist_2026/raylib_stealth_heist_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move one tile per turn
- **R**: Restart the level

## How to Play

- Navigate an 18x12 tile grid with walls and open corridors
- Collect all 3 keycards scattered across the map to unlock the exit
- 4 guards patrol the facility, each following a patrol direction
- Guards have line-of-sight detection along straight corridors (blocked by walls)
- If a guard spots you, they pursue; getting caught ends the attempt
- Guards can be temporarily stunned by approaching from behind
- Plan your route to avoid detection and collect all keycards efficiently
