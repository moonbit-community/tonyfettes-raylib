# raylib_grappling_tower_climb_2026

A vertical tower climbing game with grappling hook mechanics. Swing between anchor points, land on platforms, avoid enemy drones, and climb as high as possible. Features moving platforms, multiple drone types, bombs, and an energy/dash system.

## Build and Run

```bash
cd examples && moon build --target native raylib_grappling_tower_climb_2026/
cd examples && ./_build/native/debug/build/raylib_grappling_tower_climb_2026/raylib_grappling_tower_climb_2026.exe
```

## Controls

- **A/D or Left/Right**: Move horizontally
- **W or Up or Space**: Jump
- **J**: Grapple to nearest anchor point (hold to swing, release to detach)
- **K**: Dash (invulnerable burst of speed)
- **L**: Drop bomb (clears nearby drones)
- **R**: Restart

## How to Play

- Climb the tower by jumping between platforms and grappling to anchor points
- Grappling creates a pendulum swing; release at the right moment for maximum height
- Platforms may be static or moving horizontally
- Enemy drones patrol the tower; some shoot bullets
- Dash grants brief invulnerability; bombs clear surrounding enemies
- Manage energy (used by grapple and dash) and HP
- Collect crystals for bonus score; build combos by chaining actions
- Camera scrolls upward as you climb; falling off-screen is not an option
