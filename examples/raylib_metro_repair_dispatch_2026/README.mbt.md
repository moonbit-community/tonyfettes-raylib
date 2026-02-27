# Metro Repair Dispatch 2026

A real-time logistics game where you pilot a maintenance drone across a metro network, repairing degrading track segments and managing station congestion to keep trains running on schedule.

## Build and Run

```bash
cd examples && moon build --target native raylib_metro_repair_dispatch_2026/
cd examples && ./_build/native/debug/build/raylib_metro_repair_dispatch_2026/raylib_metro_repair_dispatch_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Fly the maintenance drone
- **J or Space**: Repair targeted track segment
- **K**: Scan for faults (sonar-style pulse, cooldown)
- **R**: Restart mission
- **Touch controls**: On-screen buttons available

## How to Play

A metro network of stations and track segments operates autonomously with trains picking up passengers. Track segments degrade over time from wear and faults, slowing or stopping trains. Fly your drone to damaged segments and repair them before they fail completely. Stations accumulate crowd pressure when trains are delayed. Use the scan ability to detect hidden faults early. Manage drone energy and hull integrity while keeping the entire network functional.
