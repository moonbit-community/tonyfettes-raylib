# Quantum Skater 2026

An endless runner with a quantum phase-shifting mechanic. Skate through a multi-lane track, jumping over obstacles, collecting orbs, and switching between alpha and beta phases to pass through phase-locked gates that only exist in one dimension.

## Build and Run

```bash
cd examples && moon build --target native raylib_quantum_skater_2026/
cd examples && ./_build/native/debug/build/raylib_quantum_skater_2026/raylib_quantum_skater_2026.exe
```

## Controls

- **A/D or Left/Right Arrow Keys**: Switch lanes (5 lanes)
- **W / Up / Space**: Jump
- **E / K / Left Shift**: Toggle quantum phase (alpha/beta)
- **R**: Restart
- **Escape**: Pause
- **Mouse / Touch**: On-screen lane, jump, phase, and restart buttons

## How to Play

The track scrolls toward you with walls, orbs, boost pads, jump bars, and phase-locked gates across 5 lanes. Collect orbs for score and chain pickups for combo bonuses. Alpha gates can only be passed in alpha phase; beta gates require beta phase -- toggle with E/K/Shift. Phase energy drains while active and recovers when not shifting. Jump over wall obstacles or switch lanes to avoid them. Complete each stage by covering the required distance, with speed and distance increasing each stage. Health drops to zero means game over.
