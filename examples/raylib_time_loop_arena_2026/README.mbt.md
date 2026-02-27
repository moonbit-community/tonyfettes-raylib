# raylib_time_loop_arena_2026

A twin-stick arena shooter with a time loop mechanic. Each 20-second loop records the player's actions, and previous loops replay as AI-controlled "ghosts" that fight alongside you in subsequent rounds. Survive escalating enemy waves while collecting energy cores.

## Build and Run

```bash
cd examples && moon build --target native raylib_time_loop_arena_2026/
cd examples && ./_build/native/debug/build/raylib_time_loop_arena_2026/raylib_time_loop_arena_2026.exe
```

## Controls

- **WASD/Arrows**: Move
- **J** or **Left Click**: Shoot toward cursor/aim direction
- **K**: Dash (costs energy)
- **L**: Bomb (area attack, costs energy)
- **R**: Restart

## How to Play

- Survive 4 time loops, each lasting 20 seconds
- Your actions from previous loops are replayed by ghost allies
- Destroy enemies to spawn energy cores; collect them for points and energy
- Build combos by chaining kills without taking damage
- Clear all loops to win; losing all HP ends the run
