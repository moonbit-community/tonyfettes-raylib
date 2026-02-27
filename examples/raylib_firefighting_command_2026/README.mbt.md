# raylib_firefighting_command_2026

A grid-based firefighting strategy game. Command a fire truck across a 5x3 grid of zones, spraying water to extinguish fires before they spread and destroy houses.

## Build and Run

```bash
cd examples && moon build --target native raylib_firefighting_command_2026/
cd examples && ./_build/native/debug/build/raylib_firefighting_command_2026/raylib_firefighting_command_2026.exe
```

## Controls

- **WASD / Arrow keys**: Move fire truck between grid cells
- **Space**: Spray water on the current cell
- **R**: Restart

## How to Play

- Move the fire truck to burning zones and spray water to reduce fire intensity
- Fires spread to adjacent cells over time and new fires ignite randomly
- Each zone contains a house; if fire reaches 100%, the house is destroyed and you lose a life
- Water is limited and regenerates slowly
- Save as many houses as possible; game ends when all lives are lost
