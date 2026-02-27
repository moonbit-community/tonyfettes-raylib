# raylib_rocket_arena_soccer_2026

A physics-based car soccer game played 1v1 against an AI opponent. Drive rocket-powered cars to push the ball into the opposing goal. Features boost, dash, pulse strikes, and field pickups.

## Build and Run

```bash
cd examples && moon build --target native raylib_rocket_arena_soccer_2026/
cd examples && ./_build/native/debug/build/raylib_rocket_arena_soccer_2026/raylib_rocket_arena_soccer_2026.exe
```

## Controls

- **WASD / Arrows**: Steer and throttle
- **J** (hold): Boost (consumes boost meter)
- **K**: Dash (quick burst forward)
- **L**: Pulse strike (launches ball toward opponent's goal)
- **Enter**: Start match / return to menu
- **R**: Replay
- **F11**: Toggle fullscreen

## How to Play

Score 7 goals before the AI or have the lead when the 3:30 match timer expires. Car-ball and car-car collisions are physics-driven. Manage your boost meter for speed advantage. Dash for quick lunges and Pulse to remotely kick the ball. Pickups spawn on the field: Nitro cells (boost refill), Cooldown chips (reduce ability timers), and Overdrive orbs (instant speed burst). Style points are awarded for goals and pulse shots.
