# raylib_deep_tunnel_drill_rescue_2026

A tile-based underground rescue game. Pilot a drill vehicle through procedurally generated terrain, rescuing trapped miners while managing fuel, oxygen, hull integrity, and heat. Features sonar scanning, bombs, and multiple hazard types.

## Build and Run

```bash
cd examples && moon build --target native raylib_deep_tunnel_drill_rescue_2026/
cd examples && ./_build/native/debug/build/raylib_deep_tunnel_drill_rescue_2026/raylib_deep_tunnel_drill_rescue_2026.exe
```

## Controls

- **WASD / Arrow keys**: Move and drill through terrain
- **Space/J**: Drop bomb to clear nearby tiles
- **K/L**: Activate sonar to reveal hidden miners
- **R**: Restart

## How to Play

- Drill through dirt and rock to reach trapped miners shown on the grid
- Collect crystal deposits for bonus score
- Avoid gas pockets that damage hull
- Return miners to the surface base to score
- Manage fuel, oxygen, hull, and heat -- returning to base refills resources
- Game ends when all miners are rescued or hull/oxygen/fuel runs out
