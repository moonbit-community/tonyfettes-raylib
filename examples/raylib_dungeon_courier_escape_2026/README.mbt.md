# raylib_dungeon_courier_escape_2026

A stealth-action game where you play as a courier delivering parcels through a guarded dungeon. Sneak past patrolling guards, avoid traps, and deploy smoke bombs to escape detection across escalating waves.

## Build and Run

```bash
cd examples && moon build --target native raylib_dungeon_courier_escape_2026/
cd examples && ./_build/native/debug/build/raylib_dungeon_courier_escape_2026/raylib_dungeon_courier_escape_2026.exe
```

## Controls

- **WASD / Arrow keys**: Move
- **J/Enter**: Interact (pick up/deliver parcels)
- **K**: Deploy smoke bomb
- **Shift**: Sprint (faster but more visible)
- **R**: Restart

## How to Play

- Pick up parcels scattered in the dungeon and deliver them to exit markers
- Guards patrol set routes with vision cones; stay out of sight or use smoke to blind them
- Traps blink before activating; avoid stepping on them
- Sprinting is faster but reduces stealth
- Meet the delivery target each wave within the time limit to advance
- Health and stealth meters must be managed carefully
