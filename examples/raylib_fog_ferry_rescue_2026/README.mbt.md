# raylib_fog_ferry_rescue_2026

A nautical rescue game set in dense fog. Navigate a ferry through fog-covered waters, locate stranded groups using sonar pings, pick up survivors, deliver them to docks, and avoid floating debris.

## Build and Run

```bash
cd examples && moon build --target native raylib_fog_ferry_rescue_2026/
cd examples && ./_build/native/debug/build/raylib_fog_ferry_rescue_2026/raylib_fog_ferry_rescue_2026.exe
```

## Controls

- **WASD / Arrow keys**: Steer and accelerate the ferry
- **Space/J**: Rescue nearby survivors / dock to deliver passengers
- **K/L**: Sonar ping (reveals hidden survivors through fog)
- **R**: Restart

## How to Play

- Navigate through fog that obscures visibility; use sonar pings to locate survivor groups
- Approach survivors to rescue them onto the ferry (limited passenger capacity)
- Deliver passengers to docks to score and refuel
- Avoid floating debris that damages hull
- Manage fuel (depletes while moving) and hull integrity
- Docks decay over time and may become inactive
- Rescue as many groups as possible before fuel or hull runs out
