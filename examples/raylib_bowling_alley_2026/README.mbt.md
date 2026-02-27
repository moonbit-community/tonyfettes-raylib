# Bowling Alley 2026

A 10-frame bowling simulation with realistic pin physics, spin control, and full scoring including strikes, spares, and the 10th frame bonus.

## Build and Run

```bash
cd examples && moon build --target native raylib_bowling_alley_2026/
cd examples && ./_build/native/debug/build/raylib_bowling_alley_2026/raylib_bowling_alley_2026.exe
```

## Controls

- **A/D or Left/Right**: Aim ball position
- **Space / Touch**: Charge and release to throw
- **W/S or Up/Down**: Adjust spin
- **R**: Restart
- Touch controls available on-screen

## How to Play

Position your ball on the lane, charge your throw power by holding and releasing the action button, and apply spin for curve shots. The ball rolls up the lane and collides with 10 pins arranged in classic triangular formation. Standard bowling scoring applies -- strikes (all 10 on first roll) and spares (all 10 across two rolls) earn bonus points. Play all 10 frames for your final score.
