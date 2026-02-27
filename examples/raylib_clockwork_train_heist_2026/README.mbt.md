# Clockwork Train Heist 2026

A tile-based stealth puzzle game set on a moving train. Navigate through train cars, avoid patrolling guards, collect loot, and escape before time runs out.

## Build and Run

```bash
cd examples && moon build --target native raylib_clockwork_train_heist_2026/
cd examples && ./_build/native/debug/build/raylib_clockwork_train_heist_2026/raylib_clockwork_train_heist_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move one tile at a time
- **Space / E**: Smoke pulse -- stuns nearby guards and blocks vision
- **Touch**: On-screen D-pad and action button
- **H**: Cycle through hint tips

## How to Play

- Collect 6 loot pieces (blueprints, keycards, gold) scattered across the train cars to unlock the escape cable.
- Guards patrol corridors and will chase you if they spot you. Use walls and smoke to break line of sight.
- Smoke pulses stun guards and cost smoke energy, which regenerates over time.
- Reach the exit tile after collecting enough loot to win.
- You have 3 lives and a 210-second time limit per run.
