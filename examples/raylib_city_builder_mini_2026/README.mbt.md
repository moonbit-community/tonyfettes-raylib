# City Builder Mini 2026

A simplified city builder where you zone residential, commercial, and industrial areas on a grid, connect them with roads, and watch your city grow economically.

## Build and Run

```bash
cd examples && moon build --target native raylib_city_builder_mini_2026/
cd examples && ./_build/native/debug/build/raylib_city_builder_mini_2026/raylib_city_builder_mini_2026.exe
```

## Controls

- **0**: Select bulldoze tool
- **1**: Select road tool
- **2**: Select residential zone
- **3**: Select commercial zone
- **4**: Select industrial zone
- **Mouse Click**: Place selected zone on grid
- **R**: Regenerate world

## How to Play

Build a city on a 16x12 grid. Place roads first, then zone residential (green), commercial (blue), and industrial (orange) areas adjacent to roads. Each zone type costs money. Zones near roads generate more income. Balance your budget -- income ticks in periodically based on your developed zones and road connectivity. Some terrain tiles (rocky) cannot be built on. Use bulldoze to clear mistakes.
