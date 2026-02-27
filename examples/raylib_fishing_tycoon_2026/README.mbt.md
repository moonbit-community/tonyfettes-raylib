# raylib_fishing_tycoon_2026

A fishing simulation tycoon game. Move your boat across the water surface, cast your hook to catch fish of varying rarity, sell catches to earn gold, and upgrade your equipment over multiple in-game days.

## Build and Run

```bash
cd examples && moon build --target native raylib_fishing_tycoon_2026/
cd examples && ./_build/native/debug/build/raylib_fishing_tycoon_2026/raylib_fishing_tycoon_2026.exe
```

## Controls

- **A/D or Left/Right**: Move boat horizontally
- **Space**: Drop/raise hook
- **R**: Restart

## How to Play

- Position your boat and drop the hook into the water
- Fish swim across the screen at different depths -- common (green), silver (blue), and golden (rare)
- The hook catches a fish when it touches one while descending
- Reel the hook back up to land the catch and earn gold
- Use gold to upgrade hook depth, reel speed, and rare fish chance
- Each day has a timer; maximize profit before the day ends
