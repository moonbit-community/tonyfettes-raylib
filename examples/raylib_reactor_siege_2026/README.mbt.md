# raylib_reactor_siege_2026

A top-down twin-stick defense game. Protect the reactor core from waves of enemies by shooting, dashing, deploying EMP pulses, and building turrets on pads around the core.

## Build and Run

```bash
cd examples && moon build --target native raylib_reactor_siege_2026/
cd examples && ./_build/native/debug/build/raylib_reactor_siege_2026/raylib_reactor_siege_2026.exe
```

## Controls

- **WASD / Arrows**: Move the hero
- **Mouse / J**: Fire bullets toward the cursor
- **Shift / Space**: Dash (short burst of speed with cooldown)
- **Q**: EMP Pulse (stuns and damages nearby enemies, long cooldown)
- **E**: Build or repair a turret on a nearby pad (costs scrap)
- **R**: Restart the current wave
- **F11**: Toggle fullscreen
- **Enter**: Start game / advance to next wave

## How to Play

Survive timed waves of enemies that swarm toward the reactor core. Destroy enemies to collect scrap drops, then spend scrap at build pads to place auto-targeting turrets. The reactor has a regenerating shield. If your HP or the reactor's HP reaches zero, the siege is lost. Clear the timer to advance to harder waves with faster and tougher enemies.
