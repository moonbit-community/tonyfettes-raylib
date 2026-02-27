# Peking Opera Duel 2026

A rhythm-action fighting game inspired by Peking Opera performance. Match stances and timing to counter incoming prompts, maintain health and harmony, and build acclaim from the crowd during a 90-second duel.

## Build and Run

```bash
cd examples && moon build --target native raylib_peking_opera_duel_2026/
cd examples && ./_build/native/debug/build/raylib_peking_opera_duel_2026/raylib_peking_opera_duel_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move lane position (directional, pressed once per input)
- **J**: Hit -- strike to match the incoming prompt's stance and position
- **K**: Defend -- deflect an incoming prompt for reduced acclaim but less penalty
- **Space**: Burst -- activate a slow-motion effect (cooldown-based)
- **P**: Pause
- **R**: Restart
- **F11**: Toggle borderless windowed mode

## How to Play

Prompts appear on a 3x3 lane grid, each requiring a specific stance (Spear Lift, Fan Sweep, Guard Frame, or Sleeve Arc) and grid position. Move to the correct lane and press J with the right timing for a Perfect or Good hit to earn acclaim and recover health/harmony. Mistimed or mismatched strikes drain your health and harmony meters. Use K to deflect for a smaller penalty when out of position. The beat interval accelerates over time. The duel ends when health or harmony reaches zero, or the 90-second timer runs out.
