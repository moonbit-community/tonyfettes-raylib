# Castle Siege Artillery 2026

A turn-based artillery duel where you and an AI opponent lob projectiles over a mountain, adjusting angle and power while accounting for wind to destroy each other's castle.

## Build and Run

```bash
cd examples && moon build --target native raylib_castle_siege_artillery_2026/
cd examples && ./_build/native/debug/build/raylib_castle_siege_artillery_2026/raylib_castle_siege_artillery_2026.exe
```

## Controls

- **A/D or Left/Right**: Adjust cannon angle
- **W/S or Up/Down**: Adjust shot power
- **Space**: Fire projectile
- **R**: Restart

## How to Play

Take turns firing artillery shells over a central mountain at the enemy castle. Adjust your angle and power to arc the shot over the terrain. Wind changes each turn, affecting projectile trajectory. Shells explode on impact, dealing damage based on proximity. Reduce the enemy castle's HP to zero to win. The AI opponent fires back each turn with its own angle/power calculations.
