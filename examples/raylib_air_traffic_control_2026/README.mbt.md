# Air Traffic Control 2026

A stress-management simulation where you guide incoming planes to safe landings across three runways by toggling runway availability and managing congestion.

## Build and Run

```bash
cd examples && moon build --target native raylib_air_traffic_control_2026/
cd examples && ./_build/native/debug/build/raylib_air_traffic_control_2026/raylib_air_traffic_control_2026.exe
```

## Controls

- **1 / 2 / 3**: Toggle runway 1, 2, or 3 open/closed
- **R**: Restart

## How to Play

Planes spawn at the top and descend toward their assigned runway. A plane lands safely if its runway is open and not busy. Closed or occupied runways cause crashes. Planes running out of fuel are lost. Near-collisions on the same runway increase your stress meter. If stress hits 100 or lives reach zero, the tower closes. Score points for each safe landing with fuel bonus.
