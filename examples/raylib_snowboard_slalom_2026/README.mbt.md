# Snowboard Slalom 2026

A downhill snowboard racing game where you weave through slalom gates, dodge obstacles, collect pickups, and perform tricks to build your score and combo multiplier.

## Build and Run

```bash
cd examples && moon build --target native raylib_snowboard_slalom_2026/
cd examples && ./_build/native/debug/build/raylib_snowboard_slalom_2026/raylib_snowboard_slalom_2026.exe
```

## Controls

- **A/D or Left/Right**: Steer the rider horizontally
- **Space**: Activate speed boost (uses stamina)
- **Mouse / Touch**: On-screen touch controls for mobile-style input
- **R**: Restart

## How to Play

- Race downhill through slalom gates to earn points and maintain combos
- Avoid obstacles like rocks and trees that deal damage
- Collect pickups for health, stamina, and score bonuses
- Build up your combo by passing through consecutive gates cleanly
- Use boost for temporary speed at the cost of stamina
- The run ends when HP reaches zero
