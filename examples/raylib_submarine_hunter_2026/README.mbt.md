# Submarine Hunter 2026

A side-scrolling submarine combat game where you defend against waves of enemy submarines. Some enemies use stealth to stay hidden until revealed by sonar pings.

## Build and Run

```bash
cd examples && moon build --target native raylib_submarine_hunter_2026/
cd examples && ./_build/native/debug/build/raylib_submarine_hunter_2026/raylib_submarine_hunter_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move your submarine
- **J / Space**: Fire torpedoes
- **K**: Activate sonar ping (reveals stealth enemies, 4s cooldown)
- **R**: Restart mission

## How to Play

Command a submarine defending against incoming enemy submarines from the right side of the screen. Enemies vary in toughness (1-2 HP) and some are stealthy, appearing only as faint shadows until revealed by sonar. Destroy enemies for points (stealth kills award bonus score). Enemies that slip past your defense line or hit you with torpedoes reduce your hull integrity. The mission ends when hull reaches zero.
