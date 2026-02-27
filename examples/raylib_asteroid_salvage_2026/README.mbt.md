# Asteroid Salvage 2026

A classic Asteroids-style space shooter where you pilot a ship, destroy asteroids, and survive increasingly difficult waves.

## Build and Run

```bash
cd examples && moon build --target native raylib_asteroid_salvage_2026/
cd examples && ./_build/native/debug/build/raylib_asteroid_salvage_2026/raylib_asteroid_salvage_2026.exe
```

## Controls

- **Left/Right or A/D**: Rotate ship
- **Up or W**: Thrust forward
- **Space or X**: Fire bullets
- **R**: Restart

## How to Play

Rotate and thrust your ship through space while shooting asteroids. Large asteroids split into smaller ones when destroyed. The screen wraps around -- flying off one edge brings you out the other side. Clear all asteroids to advance to the next wave. You have 3 lives; colliding with an asteroid costs a life (with brief invulnerability after respawn).
