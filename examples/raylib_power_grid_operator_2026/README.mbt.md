# Power Grid Operator 2026

A real-time power grid balancing simulation. Manage three power plants to match fluctuating demand across four city sectors while avoiding blackouts and overloads.

## Build and Run

```bash
cd examples && moon build --target native raylib_power_grid_operator_2026/
cd examples && ./_build/native/debug/build/raylib_power_grid_operator_2026/raylib_power_grid_operator_2026.exe
```

## Controls

- **Q/A**: Increase/decrease Plant 1 output
- **W/S**: Increase/decrease Plant 2 output
- **E/D**: Increase/decrease Plant 3 output
- **Space**: Activate emergency battery reserve (+90 supply for 6 seconds, 20-second cooldown)
- **R**: Restart

## How to Play

Four sectors have independently fluctuating power demands with random trends. Adjust the output of three power plants to keep total supply close to total demand. If supply falls too far below demand, outage risk accumulates and triggers blackout penalties. If supply exceeds demand too much, overheat builds and causes plant shutdown penalties. Keep the balance within +/-15 for bonus points. Each penalty costs a life (5 total). Use the emergency battery reserve in critical moments.
