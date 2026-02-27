# raylib_drift_police_chase_2026

A top-down driving game where you flee from police across a large open world. Collect cash pickups, deploy smoke screens, boost to escape, and drift around corners while avoiding cop cars.

## Build and Run

```bash
cd examples && moon build --target native raylib_drift_police_chase_2026/
cd examples && ./_build/native/debug/build/raylib_drift_police_chase_2026/raylib_drift_police_chase_2026.exe
```

## Controls

- **WASD / Arrow keys**: Steer and accelerate
- **Space/J**: Boost (temporary speed burst)
- **K/L**: Deploy smoke screen (obscures cops)
- **R**: Restart

## How to Play

- Drive through the open world collecting cash pickups to build your score
- Multiple cop types pursue you with increasing aggression
- Use boost to outrun pursuers and smoke screens to break line of sight
- Manage HP -- collisions with cops deal damage
- Build combos by collecting pickups in quick succession
- Game ends when HP reaches zero
