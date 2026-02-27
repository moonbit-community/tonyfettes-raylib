# Breakout Lab 2026

A classic brick-breaker game with multi-hit bricks, power-ups, and 3 lives.

## Build and Run

```bash
cd examples && moon build --target native raylib_breakout_lab_2026/
cd examples && ./_build/native/debug/build/raylib_breakout_lab_2026/raylib_breakout_lab_2026.exe
```

## Controls

- **A/D or Left/Right**: Move paddle
- **R**: Restart

## How to Play

Bounce a ball off your paddle to break bricks arranged at the top of the screen. Bricks have 1-3 HP depending on their row -- top rows require more hits and are worth more points. The ball speeds up as bricks are destroyed. Losing the ball below the paddle costs a life. Some bricks drop a wide-paddle power-up. Clear all 96 bricks to win.
