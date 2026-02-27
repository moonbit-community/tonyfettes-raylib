# Contra 1987 Lite

A full-featured Battle City / tank game inspired by classic NES titles. Defend your base from waves of enemy tanks across a 96-level procedurally generated campaign, with optional 2-player co-op.

## Build and Run

```bash
cd examples && moon build --target native raylib_contra_1987_lite/
cd examples && ./_build/native/debug/build/raylib_contra_1987_lite/raylib_contra_1987_lite.exe
```

## Controls

- **Player 1**: WASD to move, Space to fire, P to pause
- **Player 2**: Arrow Keys to move, Numpad 0 to fire
- **Menu**: Up/Down to select, Enter to confirm
- **Pause**: P to toggle pause

## How to Play

- Destroy all enemy tanks in each stage while protecting your base (eagle icon).
- Pick up powerups dropped by flashing enemies: shield, weapon upgrades, grenades, freeze, shovel, and extra lives.
- Enemy types include basic, fast, heavy (4 HP), and sniper tanks.
- Some stages feature bio-cores that must be destroyed for bonus points.
- Brick walls are destructible; steel walls require upgraded weapons; water and bushes add tactical variety.
- The game features a demo/attract mode, kill combos, camera shake, and particle effects.
