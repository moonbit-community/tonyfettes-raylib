# Jackal 1988 Lite

A top-down tank combat game inspired by the classic Jackal/Battle City. Control a tank to defend your base from waves of enemy tanks across 96 procedurally generated stages, with optional 2-player co-op and a hostage rescue system.

## Build and Run

```bash
cd examples && moon build --target native raylib_jackal_1988_lite/
cd examples && ./_build/native/debug/build/raylib_jackal_1988_lite/raylib_jackal_1988_lite.exe
```

## Controls

- **W/A/S/D**: Player 1 movement
- **Space**: Player 1 fire
- **Arrow Keys**: Player 2 movement (co-op)
- **Right Ctrl/Shift**: Player 2 fire (co-op)
- **P**: Pause
- **Enter**: Menu select / advance

## How to Play

Defend your base (eagle) at the bottom of the map from enemy tanks spawning at the top. Destroy all enemies in each stage to advance. Four enemy types: Basic, Fast, Heavy (4 HP), and Sniper. Destructible terrain includes brick walls, steel walls, water, bushes, and ice. Collect powerups (shield, star weapon upgrade, grenade, clock freeze, shovel fortification, extra tank). Rescue hostages from enemy camps for bonus score. If the base is destroyed or all lives are lost, the game ends.
