# Polar Train Heist 2026

A side-scrolling action game set on a moving train in a polar landscape. Fight through stages of guards, drones, and turrets while collecting loot, managing armor and heat, and using dash and grappling hook abilities.

## Build and Run

```bash
cd examples && moon build --target native raylib_polar_train_heist_2026/
cd examples && ./_build/native/debug/build/raylib_polar_train_heist_2026/raylib_polar_train_heist_2026.exe
```

## Controls

- **A/D or Left/Right Arrow Keys**: Move left/right
- **W / Up / Space**: Jump (with coyote time and jump buffering)
- **J / Z / Left Mouse**: Fire weapon (hold to auto-fire)
- **Shift / K**: Dash (cooldown-based)
- **L / E**: Grappling hook (pulls nearby enemies, cooldown-based)
- **R / Enter**: Restart
- **Mouse / Touch**: On-screen buttons for movement, jump, fire, dash, and hook

## How to Play

Progress through multi-stage train cars by defeating enemies and traveling the required distance. Guards, drones, and turrets spawn ahead and shoot back. Collect crates for loot, medkits for armor repair, and batteries for heat recovery. Chain kills to build combos for bonus score. The scroll speed increases with each stage. Armor acts as health -- when it runs out, the heist is over.
