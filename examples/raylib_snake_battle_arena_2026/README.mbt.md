# Snake Battle Arena 2026

A competitive snake game where you grow your snake by eating food while battling AI-controlled rival snakes on a shared grid. Avoid traps, build combos, and use boost to outmaneuver opponents.

## Build and Run

```bash
cd examples && moon build --target native raylib_snake_battle_arena_2026/
cd examples && ./_build/native/debug/build/raylib_snake_battle_arena_2026/raylib_snake_battle_arena_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Change direction
- **Space / Shift**: Activate boost
- **Mouse / Touch**: On-screen touch controls supported

## How to Play

- Navigate a 34x20 grid, eating food to grow your snake and score points
- Compete against 2 AI rival snakes that also seek food and try to survive
- Avoid collisions with walls, your own body, rival snakes, and traps
- Chain kills and food pickups to build a combo multiplier
- Use the boost meter for temporary speed bursts to outmaneuver rivals
- Multiple food types provide different growth and score bonuses
- You have limited lives; the game ends when all lives are lost
