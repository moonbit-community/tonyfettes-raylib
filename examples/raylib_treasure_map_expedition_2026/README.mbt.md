# raylib_treasure_map_expedition_2026

A fog-of-war exploration game on a grid map. Navigate jungle terrain to find hidden relics and return them to base camp before your stamina runs out or the storm timer expires.

## Build and Run

```bash
cd examples && moon build --target native raylib_treasure_map_expedition_2026/
cd examples && ./_build/native/debug/build/raylib_treasure_map_expedition_2026/raylib_treasure_map_expedition_2026.exe
```

## Controls

- **WASD/Arrows**: Move on the grid
- **R**: Restart expedition

## How to Play

- The map is hidden in fog; moving reveals tiles in a radius around you
- Find 4 relics scattered across the map and carry them back to camp (C tile)
- Returning to camp banks collected relics and restores stamina
- Each step costs 2 stamina; running out strands you in the wild
- A 240-second storm timer adds urgency; collect and bank all relics to complete the expedition
