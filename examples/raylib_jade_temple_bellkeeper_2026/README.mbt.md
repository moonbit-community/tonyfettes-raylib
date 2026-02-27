# Jade Temple Bellkeeper 2026

An action-defense game where you play as the bellkeeper of a jade temple, defending a central shrine from waves of spirit foes by ringing sacred bells that emit shockwaves.

## Build and Run

```bash
cd examples && moon build --target native raylib_jade_temple_bellkeeper_2026/
cd examples && ./_build/native/debug/build/raylib_jade_temple_bellkeeper_2026/raylib_jade_temple_bellkeeper_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move the hero
- **J or Space**: Ring the nearest bell (costs spirit energy)
- **K**: Dash (costs spirit, brief invulnerability)
- **R**: Restart
- **Touch buttons**: On-screen d-pad, ring, and dash buttons

## How to Play

Four sacred bells orbit the central shrine. Move near a bell and ring it to emit a damaging shockwave that destroys nearby foes (wisps, brutes, shamans, and relics). Foes advance toward the shrine and drain its HP on contact. Manage your spirit energy -- it regenerates over time but is consumed by ringing bells and dashing. Build combos by defeating foes in quick succession. Reach the stage score goal within the time limit to advance to harder stages.
