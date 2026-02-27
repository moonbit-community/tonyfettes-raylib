# Subway Signal Saboteur 2026

A puzzle-strategy game where you sabotage subway signals to route trains into the correct lanes while avoiding patrolling inspectors on a grid-based map.

## Build and Run

```bash
cd examples && moon build --target native raylib_subway_signal_saboteur_2026/
cd examples && ./_build/native/debug/build/raylib_subway_signal_saboteur_2026/raylib_subway_signal_saboteur_2026.exe
```

## Controls

- **Arrow Keys / WASD / D-pad**: Move player on the grid
- **Action button**: Toggle signal switches at junctions, or trigger EMP smoke off-panel
- **Mouse/Touch**: On-screen buttons for mobile-style input

## How to Play

Navigate a grid-based subway system, toggling junction signals to route colored trains to their matching target lanes before they exit. Avoid patrolling inspectors who chase you on alert -- stun them with EMP smoke (costs energy). Successfully route 20 trains within the time limit to win. Misrouted trains and collisions cost points and lives.
