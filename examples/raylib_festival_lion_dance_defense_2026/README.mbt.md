# raylib_festival_lion_dance_defense_2026

A lane-based defense game set during a festival lion dance performance. Control a dance troupe to strike, guard against, and burst incoming threats (firecrackers and incidents) across 6 lanes while maintaining crowd morale and order.

## Build and Run

```bash
cd examples && moon build --target native raylib_festival_lion_dance_defense_2026/
cd examples && ./_build/native/debug/build/raylib_festival_lion_dance_defense_2026/raylib_festival_lion_dance_defense_2026.exe
```

## Controls

- **W/S or Up/Down**: Switch lanes
- **J**: Strike (destroy nearby threats)
- **K**: Guard (block incoming threats)
- **L**: Burst (area attack, longer cooldown)
- **P**: Pause
- **R**: Restart

## How to Play

- Move between 6 lanes to intercept threats before they pass
- Strike to destroy firecrackers and incidents; guard to block damage
- Use burst for area-of-effect clearing when overwhelmed
- Build combos by clearing threats in succession to boost hype
- Maintain morale (drops when threats leak) and crowd order
- Game ends when morale reaches zero
