# raylib_ghost_mansion_investigation_2026

A top-down horror investigation game. Explore a haunted mansion as an investigator, collect clues, avoid ghosts, manage sanity and flashlight battery, and use pulse attacks to stun ghosts.

## Build and Run

```bash
cd examples && moon build --target native raylib_ghost_mansion_investigation_2026/
cd examples && ./_build/native/debug/build/raylib_ghost_mansion_investigation_2026/raylib_ghost_mansion_investigation_2026.exe
```

## Controls

- **WASD / Arrow keys**: Move investigator
- **Space/J**: Flashlight pulse (stuns nearby ghosts)
- **R**: Restart

## How to Play

- Explore multi-level mansion rooms to find and collect clues
- Ghosts wander the mansion; they become alert and chase you when close
- Use flashlight pulse to stun ghosts temporarily (costs battery)
- Battery depletes over time; sanity drops near ghosts
- Collect enough clues to advance through mansion levels
- Walls and furniture create blocked areas for tactical movement
- Game ends when HP reaches zero
