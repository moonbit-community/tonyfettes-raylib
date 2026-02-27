# raylib_deep_sea_salvage_2026

A deep-sea submarine salvage game. Dive underwater to collect valuable relics while avoiding mines, managing oxygen and fuel, and banking cargo at the surface before time runs out.

## Build and Run

```bash
cd examples && moon build --target native raylib_deep_sea_salvage_2026/
cd examples && ./_build/native/debug/build/raylib_deep_sea_salvage_2026/raylib_deep_sea_salvage_2026.exe
```

## Controls

- **WASD / Arrow keys**: Move submarine
- **R**: Restart

## How to Play

- Dive below the surface to collect gold relics scattered on the seabed
- Avoid drifting mines that damage hull and consume fuel on contact
- Oxygen depletes while submerged; surface to refill oxygen and refuel
- Surfacing also banks any collected cargo into your permanent score
- Game ends when hull reaches zero, fuel runs out, or the 210-second mission timer expires
