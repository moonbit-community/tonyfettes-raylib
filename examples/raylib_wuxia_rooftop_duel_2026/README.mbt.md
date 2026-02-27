# raylib_wuxia_rooftop_duel_2026

A martial arts action game set on rooftops. Fight waves of enemies using light attacks, heavy attacks, parry-dashes, and precise timing. Features a combo system, stamina management, and enemies with telegraph-strike-recover AI patterns.

## Build and Run

```bash
cd examples && moon build --target native raylib_wuxia_rooftop_duel_2026/
cd examples && ./_build/native/debug/build/raylib_wuxia_rooftop_duel_2026/raylib_wuxia_rooftop_duel_2026.exe
```

## Controls

- **WASD/Arrows**: Move
- **J / Left Click**: Light attack (fast, short range)
- **K / Right Click**: Heavy attack (slow, wide arc, more damage)
- **Space/L**: Parry-dash (invulnerable dash; counters if timed during enemy strike)
- **R**: Restart

## How to Play

- Enemies telegraph their attacks before striking; time your parry to counter for bonus damage
- Light attacks are quick but short-ranged; heavy attacks have a wider arc and more damage
- Stamina regenerates faster when not attacking; manage it to avoid being caught empty
- Build combos by chaining kills within the combo timeout window
- Waves grow larger and enemies get tougher; survive as long as possible for a high score
