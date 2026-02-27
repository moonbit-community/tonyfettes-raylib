# Raft Rapids Escape 2026

A top-down river survival game where you steer a raft through rapids, dodging rocks, logs, and mines while collecting coins, fuel, shields, and repair pickups. Survive the 180-second run to escape.

## Build and Run

```bash
cd examples && moon build --target native raylib_raft_rapids_escape_2026/
cd examples && ./_build/native/debug/build/raylib_raft_rapids_escape_2026/raylib_raft_rapids_escape_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Steer the raft
- **Shift / J**: Boost (consumes fuel)
- **H**: Use a hint (shows safe path)
- **R**: Restart
- **Escape**: Return to title
- **Mouse / Touch**: On-screen D-pad, boost, hint, and restart buttons

## How to Play

Navigate the raft through increasingly turbulent rapids. Obstacles (rocks, logs, mines) scroll toward you and must be dodged. Collect coins for score, fuel canisters to refuel your boost, shields for temporary invulnerability, and repair kits to restore lives. Chain coin pickups to build combos for higher scores. The difficulty increases over time with more and faster obstacles. Survive for 180 seconds to complete the escape. Colliding with obstacles costs a life (3 total).
