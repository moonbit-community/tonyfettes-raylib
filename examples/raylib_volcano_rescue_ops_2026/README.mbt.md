# raylib_volcano_rescue_ops_2026

A turn-based route-planning puzzle game set on a volcanic grid. Plan a path for your rescue truck to collect civilians from sites and deliver them to a shelter, while managing heat, fuel, and coolant as lava spreads across the map.

## Build and Run

```bash
cd examples && moon build --target native raylib_volcano_rescue_ops_2026/
cd examples && ./_build/native/debug/build/raylib_volcano_rescue_ops_2026/raylib_volcano_rescue_ops_2026.exe
```

## Controls

- **Click map tiles**: Set route destination (auto-pathfinds)
- **Arrow buttons / WASD**: Manually append directional steps to route
- **EXECUTE button**: Run the planned route
- **CLEAR button**: Clear planned route
- **COOLANT button**: Use coolant to reduce heat
- **R / Restart button**: Restart current level
- Touch-friendly UI with on-screen buttons

## How to Play

- Plan routes on a grid to visit civilian sites and collect survivors (vehicle capacity: 6)
- Return to the shelter to offload rescued civilians
- Each move costs fuel and generates heat; overheating is dangerous
- Lava spreads each turn, blocking tiles and threatening civilian sites
- Complete 3 progressively harder levels by meeting the rescue quota before time runs out
