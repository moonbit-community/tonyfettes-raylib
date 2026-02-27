# Clocktower Heist 2026

A top-down stealth action game where you play as a thief infiltrating a clocktower across 3 floors, collecting keycards, hacking a vault, and escaping before the clock runs out.

## Build and Run

```bash
cd examples && moon build --target native raylib_clocktower_heist_2026/
cd examples && ./_build/native/debug/build/raylib_clocktower_heist_2026/raylib_clocktower_heist_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move
- **J / Left Shift**: Sprint (drains stamina)
- **K**: EMP pulse -- stuns nearby guards
- **L**: Cloak -- become harder to detect
- **R**: Restart
- **Touch**: On-screen D-pad and action buttons

## How to Play

- Collect the required number of keycards on each floor.
- Once enough keycards are gathered, stand near the vault to hack it open.
- After the vault opens, reach the exit zone to clear the floor.
- Guards patrol between waypoints and chase you when spotted. They shoot darts.
- EMP pulse and cloak consume stamina, which regenerates over time.
- Complete all 3 floors to win. Walls, guards, and difficulty increase each floor.
