# raylib_river_raid_2026

A vertical-scrolling river shooter inspired by the classic River Raid. Fly an aircraft up a winding river, shoot enemies, avoid banks, and collect fuel crates to stay airborne.

## Build and Run

```bash
cd examples && moon build --target native raylib_river_raid_2026/
cd examples && ./_build/native/debug/build/raylib_river_raid_2026/raylib_river_raid_2026.exe
```

## Controls

- **WASD / Arrows**: Steer the aircraft
- **Space / J**: Fire bullets
- **R**: Restart mission

## How to Play

Your aircraft auto-scrolls upriver at increasing speed. The river bends randomly, and hitting the banks damages your hull. Three enemy types appear: red drones that weave side to side, maroon gunboats that track your position, and gold fuel crates marked "F" that replenish your fuel. Fuel depletes constantly -- collect crates to survive. The game ends when HP or fuel reaches zero.
