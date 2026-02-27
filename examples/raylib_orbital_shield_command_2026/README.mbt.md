# raylib_orbital_shield_command_2026

A circular defense game where you rotate a shield arc around a planet to deflect incoming enemies and fire shots to protect the planet from asteroid waves.

## Build and Run

```bash
cd examples && moon build --target native raylib_orbital_shield_command_2026/
cd examples && ./_build/native/debug/build/raylib_orbital_shield_command_2026/raylib_orbital_shield_command_2026.exe
```

## Controls

- **A/D or Left/Right**: Rotate shield around the planet
- **Space / J / K**: Fire shots outward
- **R**: Restart

## How to Play

- A planet sits at the center of the screen with a shield arc orbiting it
- Enemies of varying sizes approach from all directions
- Rotate the shield to block incoming enemies and fire shots to destroy them
- Larger enemies take more hits and award more points
- If enemies reach the planet, you take damage
- Survive as long as possible and rack up a high score with neon spark effects
