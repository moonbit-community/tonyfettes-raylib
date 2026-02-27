# raylib_flappy_sky_ruins_2026

A flappy-bird-style game set in ancient sky ruins. Flap through gates, dodge beams and spinners, collect pickups (score, boost, shield, hearts), and survive as long as possible with escalating difficulty levels.

## Build and Run

```bash
cd examples && moon build --target native raylib_flappy_sky_ruins_2026/
cd examples && ./_build/native/debug/build/raylib_flappy_sky_ruins_2026/raylib_flappy_sky_ruins_2026.exe
```

## Controls

- **Space/J or click FLAP button**: Flap (gain altitude)
- **K or click BOOST button**: Activate boost (temporary speed and invulnerability)
- **R**: Restart
- Touch buttons available in the side panel

## How to Play

- Tap to flap and navigate through gaps in obstacle gates
- Three obstacle types: standard gates, horizontal beams, and rotating spinners
- Collect pickups: score gems, boost charges, shields (temporary invulnerability), and extra hearts
- Build combos by passing through gates without getting hit
- Shield absorbs one hit; boost meter fills from pickups
- Difficulty increases over time with faster and tighter obstacles
- 3 lives; game ends when all are lost
