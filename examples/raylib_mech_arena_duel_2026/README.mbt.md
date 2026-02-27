# Mech Arena Duel 2026

A top-down arena shooter where you pilot a mech against waves of enemy bots. Move, aim, and fire to destroy all bots in each wave while managing weapon heat and health.

## Build and Run

```bash
cd examples && moon build --target native raylib_mech_arena_duel_2026/
cd examples && ./_build/native/debug/build/raylib_mech_arena_duel_2026/raylib_mech_arena_duel_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move the mech
- **Mouse**: Aim direction
- **Space or Left Click**: Fire weapon
- **Shift**: Dash (dodge with cooldown)
- **R**: Restart game

## How to Play

Face increasingly tough waves of enemy bots that spawn across the arena. Each bot has directional movement, HP that scales with wave number, and its own fire cooldown. Your mech has 120 HP and a weapon that generates heat -- overheat and you briefly cannot fire. Dash to dodge incoming shots. Destroy all bots in a wave to advance. Each wave spawns more and tougher enemies. Score points per kill with wave completion bonuses.
