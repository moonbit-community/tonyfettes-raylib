# raylib_rogue_dungeon_2026

A turn-based roguelike dungeon crawler on a procedurally generated tile map. Move your hero through corridors, fight monsters in melee, and clear the dungeon.

## Build and Run

```bash
cd examples && moon build --target native raylib_rogue_dungeon_2026/
cd examples && ./_build/native/debug/build/raylib_rogue_dungeon_2026/raylib_rogue_dungeon_2026.exe
```

## Controls

- **WASD / Arrows**: Move one tile (or attack an adjacent enemy)
- **R**: Restart with a new dungeon layout

## How to Play

You control the "@" hero on a 21x15 grid. Walls are randomly placed with a guaranteed center corridor. Four monsters ("M") patrol the dungeon. Moving into a monster attacks it for 3 damage; monsters retaliate when adjacent. Enemies chase you using simple pathfinding and deal 1-2 damage per turn. Defeat all four monsters to clear the dungeon. Score is earned from movement, hits, and kills. The game ends in defeat if your HP drops to zero.
