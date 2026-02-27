# raylib_moon_gate_defense_2026

A grid-based tower defense game where you place directional turret nodes on a lunar grid to defend a gate from waves of alien enemies.

## Build and Run

```bash
cd examples && moon build --target native raylib_moon_gate_defense_2026/
cd examples && ./_build/native/debug/build/raylib_moon_gate_defense_2026/raylib_moon_gate_defense_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move cursor on the grid
- **J**: Place or upgrade a turret node
- **K**: Cancel / remove a node
- **Space**: Activate barrier
- **P**: Pause
- **R**: Restart

## How to Play

- Place turret nodes on the grid to intercept incoming enemies before they reach the gate
- Nodes fire bolts in their facing direction; spend energy to place and upgrade them
- Build combos by killing enemies in quick succession for bonus energy
- Activate the barrier to block enemies temporarily when the gate is under heavy fire
- Survive escalating waves of skitters and other alien types to achieve a high score
