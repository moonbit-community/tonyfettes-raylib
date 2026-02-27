# Abyss Signal Runner 2026

A deep-sea survival runner where you pilot a submersible through procedurally generated cave systems, dodging obstacles and collecting data signals while managing hull integrity and oxygen.

## Build and Run

```bash
cd examples && moon build --target native raylib_abyss_signal_runner_2026/
cd examples && ./_build/native/debug/build/raylib_abyss_signal_runner_2026/raylib_abyss_signal_runner_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move submersible
- **Shift / K**: Dash (with cooldown)
- **Space / J / L**: Sonar pulse (reveals cloaked objects, destroys nearby mines)
- **R / Enter**: Restart
- Touch controls available on-screen

## How to Play

Navigate your submersible through an abyss cave that scrolls vertically. Avoid rocks, mines, and currents while collecting data nodes and oxygen pickups. Use sonar to reveal hidden objects and dash to evade hazards. Each stage increases scroll speed and narrows the cave. Manage your hull HP and oxygen -- running out of either ends the run. Build combos by collecting data in quick succession for higher scores.
