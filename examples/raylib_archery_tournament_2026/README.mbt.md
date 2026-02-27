# Archery Tournament 2026

A physics-based archery game where you adjust power and arc to hit moving targets at varying distances while compensating for wind.

## Build and Run

```bash
cd examples && moon build --target native raylib_archery_tournament_2026/
cd examples && ./_build/native/debug/build/raylib_archery_tournament_2026/raylib_archery_tournament_2026.exe
```

## Controls

- **A/D or Left/Right**: Adjust shot power
- **W/S or Up/Down**: Adjust arc (vertical lift)
- **Space**: Shoot arrow
- **R**: Restart tournament

## How to Play

Aim your bow by tuning power (horizontal velocity) and arc (vertical lift), then fire. Targets move horizontally at different heights and speeds -- smaller targets are worth more points. Wind shifts periodically and affects arrow trajectory. You have 18 arrows; hit as many targets as possible to maximize your score. Build combos with consecutive hits.
