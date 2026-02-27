# Circuit Grid Operator 2026

A puzzle-management game where you operate a power grid by rotating circuit tiles, routing energy from sources to sinks while repairing faults and managing overloads.

## Build and Run

```bash
cd examples && moon build --target native raylib_circuit_grid_operator_2026/
cd examples && ./_build/native/debug/build/raylib_circuit_grid_operator_2026/raylib_circuit_grid_operator_2026.exe
```

## Controls

- **Mouse Click / Enter**: Rotate selected cell
- **F**: Patch a faulted cell
- **R**: Reroute row (shift tiles)
- **O**: Overcharge (boost power temporarily)
- **F11**: Toggle borderless windowed
- Mouse hover to select cells

## How to Play

The grid contains circuit tiles (straight, corner, tee, cross) connecting power sources to sinks. Rotate tiles to form continuous paths for energy to flow. Sinks have demand counters -- deliver enough charge to satisfy all demands. Cells develop faults over time that block energy flow; use the patch action to repair them. Balance throughput across the grid to keep all sinks powered.
