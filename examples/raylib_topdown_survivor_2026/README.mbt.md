# raylib_topdown_survivor_2026

A top-down auto-shooting survival game. Move to avoid swarms of enemies while your character automatically fires at the nearest target. Survive for 3 minutes, leveling up and choosing upgrades along the way.

## Build and Run

```bash
cd examples && moon build --target native raylib_topdown_survivor_2026/
cd examples && ./_build/native/debug/build/raylib_topdown_survivor_2026/raylib_topdown_survivor_2026.exe
```

## Controls

- **WASD/Arrows**: Move
- **1**: Upgrade - Faster attack speed
- **2**: Upgrade - More bullet damage
- **3**: Upgrade - Speed + HP boost
- **R**: Restart

## How to Play

- Enemies spawn from screen edges and chase you; contact drains HP
- Your weapon auto-fires at the nearest enemy
- Killing enemies earns XP; filling the XP bar triggers a level-up with 3 upgrade choices
- Survive 180 seconds to win; reaching 0 HP means defeat
