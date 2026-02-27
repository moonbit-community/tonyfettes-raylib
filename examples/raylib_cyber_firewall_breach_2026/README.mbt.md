# raylib_cyber_firewall_breach_2026

A side-scrolling cyber defense game. You control a firewall turret protecting a core from waves of incoming malware across 3 sectors. Features shooting, pulse attacks, heat management, and screen shake effects.

## Build and Run

```bash
cd examples && moon build --target native raylib_cyber_firewall_breach_2026/
cd examples && ./_build/native/debug/build/raylib_cyber_firewall_breach_2026/raylib_cyber_firewall_breach_2026.exe
```

## Controls

- **W/S or Up/Down**: Move turret vertically
- **Space/J**: Fire projectiles
- **K/L**: Pulse attack (area damage, cooldown-based)
- **R**: Restart
- Touch buttons also available on-screen

## How to Play

- Defend the core on the left from enemies approaching from the right
- Three enemy types: small (fast), medium, and large (splits into smaller enemies on death)
- Manage heat: firing and pulsing generate heat; overheating disables weapons
- Survive all 3 sectors (42 seconds each) to win
- Core HP reaching zero means defeat
