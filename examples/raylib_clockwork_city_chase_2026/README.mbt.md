# Clockwork City Chase 2026

A vertically scrolling vehicular combat game set on a neon-lit clockwork highway. Pilot a car through a winding track, shoot enemies, collect pickups, and survive stage after stage.

## Build and Run

```bash
cd examples && moon build --target native raylib_clockwork_city_chase_2026/
cd examples && ./_build/native/debug/build/raylib_clockwork_city_chase_2026/raylib_clockwork_city_chase_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Steer the car
- **Space / J / Left Click**: Fire weapons
- **Shift / K**: Dash (brief invulnerability and ram)
- **L / E**: EMP pulse (destroys nearby enemies, clears projectiles)
- **R / Enter**: Restart or continue
- **Touch**: On-screen buttons for movement, fire, dash, and EMP

## How to Play

- The track scrolls upward continuously and sways side to side. Stay on the road or take armor damage from the walls.
- Destroy scouts, spinners, tanks, and gear walls for score and combo multipliers.
- Collect coins, coolant (restores heat), and EMP cells (reduces EMP cooldown).
- Manage armor (health) and heat (energy) resources -- running out of either ends the run.
- Reach the distance target each stage to advance. Difficulty scales with each stage.
