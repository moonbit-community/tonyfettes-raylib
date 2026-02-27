# Sky Convoy Defense 2026

A turret defense game where you protect a moving convoy from waves of hostile drones and their bombs across 3 sectors. Aim your turret and shoot down aerial threats before they destroy the convoy.

## Build and Run

```bash
cd examples && moon build --target native raylib_sky_convoy_defense_2026/
cd examples && ./_build/native/debug/build/raylib_sky_convoy_defense_2026/raylib_sky_convoy_defense_2026.exe
```

## Controls

- **A/D or Left/Right**: Move turret horizontally
- **W/S or Up/Down**: Adjust aim angle
- **Space / J / K**: Fire bullets
- **R**: Restart the mission
- **Touch buttons**: On-screen controls for mobile-style input

## How to Play

- Defend the convoy as it progresses through 3 sectors of increasing difficulty
- Shoot down 3 drone types: small (1 HP), medium (2 HP), and large (3 HP)
- Drones drop bombs that damage the convoy on impact
- The convoy has 300 HP; if it reaches zero, the mission fails
- Complete all 3 sectors to achieve victory; convoy HP partially restores between sectors
