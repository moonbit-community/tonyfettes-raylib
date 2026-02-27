# Battle Kart Arena 2026

A top-down kart racing combat game where you race around a track against 3 AI opponents, collecting pickups and shooting to gain an advantage across 3 laps.

## Build and Run

```bash
cd examples && moon build --target native raylib_battle_kart_arena_2026/
cd examples && ./_build/native/debug/build/raylib_battle_kart_arena_2026/raylib_battle_kart_arena_2026.exe
```

## Controls

- **W / Up**: Accelerate
- **S / Down**: Brake
- **A/D or Left/Right**: Steer
- **Space / J**: Shoot
- **Shift / K**: Boost
- **R**: Restart

## How to Play

Race around a rectangular track with inner and outer walls, passing through waypoints to complete laps. Shoot other karts to reduce their HP and pick up items scattered on the track. Boost for short bursts of extra speed. First kart to complete 3 laps wins. AI karts follow the waypoint path and fire automatically.
