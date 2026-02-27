# raylib_rts_skirmish_2026

A minimalist real-time strategy game with 3 lanes. Train workers for income, then spawn swordsmen and rangers to push down the enemy base while defending your own.

## Build and Run

```bash
cd examples && moon build --target native raylib_rts_skirmish_2026/
cd examples && ./_build/native/debug/build/raylib_rts_skirmish_2026/raylib_rts_skirmish_2026.exe
```

## Controls

- **1 / 2 / 3**: Select lane
- **Q**: Train a worker (45 resources, increases income)
- **W**: Spawn a swordsman in the selected lane (70 resources)
- **E**: Spawn a ranger in the selected lane (90 resources)
- **R**: Restart

## How to Play

Both sides start with 2 workers generating 5 resources per second each. Spend resources to train more workers or deploy combat units. Swordsmen are melee fighters with high HP; rangers deal more damage at range but are fragile. Units auto-march down their lane, attack the nearest enemy, and damage the opposing base if they reach the end. The AI produces units on a regular timer. Destroy the enemy base (320 HP) to win.
