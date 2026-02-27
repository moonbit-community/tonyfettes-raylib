# Jetpack Cavern Rush 2026

A side-scrolling shooter where you pilot a jetpack through procedurally generated caverns, collecting crystals while fighting cave-dwelling enemies. Reach the exit portal with enough crystals to clear each level.

## Build and Run

```bash
cd examples && moon build --target native raylib_jetpack_cavern_rush_2026/
cd examples && ./_build/native/debug/build/raylib_jetpack_cavern_rush_2026/raylib_jetpack_cavern_rush_2026.exe
```

## Controls

- **W/Up**: Thrust (jetpack, costs fuel)
- **A/D or Left/Right**: Horizontal movement
- **J or Mouse Click**: Fire weapon (auto-aim toward mouse)
- **K**: Pulse wave (AoE slow + damage, cooldown)
- **L**: Lightning storm (chain damage to nearby enemies, cooldown)
- **Space/Shift**: Dash (brief speed burst + invulnerability)
- **R**: Restart level
- **F11**: Toggle fullscreen
- **Touch buttons**: On-screen controls for all actions

## How to Play

Fly through a randomly generated cavern using your jetpack. Collect scattered crystals to meet the quota, then reach the exit portal at the far end. Two enemy types chase you -- small fast biters and large ranged shooters. Fuel regenerates slowly and is consumed by thrust, firing, and abilities. Hitting cave walls damages you. Build kill combos for bonus score. Levels get progressively harder with more enemies and tighter crystal quotas across 8 stages.
