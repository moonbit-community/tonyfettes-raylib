# Magnet Lab Escape 2026

A side-scrolling platformer set in a malfunctioning magnet laboratory. Use magnetic polarity to attract or repel objects as you collect energy cores, fight drones, and navigate to the reactor exit.

## Build and Run

```bash
cd examples && moon build --target native raylib_magnet_lab_escape_2026/
cd examples && ./_build/native/debug/build/raylib_magnet_lab_escape_2026/raylib_magnet_lab_escape_2026.exe
```

## Controls

- **A/D or Left/Right**: Move horizontally
- **W or Up / Space**: Jump (with coyote time and jump buffering)
- **J**: Fire weapon (costs energy, generates heat)
- **K**: Toggle magnet polarity (attract/repel nearby objects)
- **L or Shift**: Dash (brief invulnerability burst)
- **R**: Restart

## How to Play

Traverse a long side-scrolling lab filled with platforms, gates, and hazards. Collect magnetized energy cores and deliver them to the reactor at the far end. Toggle your magnetic polarity to attract cores toward you or repel enemy projectiles and boxes. Gates require a minimum core count to open. Drones patrol the lab and fire at you. Manage HP, energy, and weapon heat across the 5600-unit wide level. Collect 120 cores and reach the reactor to escape.
