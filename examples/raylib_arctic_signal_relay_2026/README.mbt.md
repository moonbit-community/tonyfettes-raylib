# Arctic Signal Relay 2026

A mission-based delivery game where you drive a rover across a frozen landscape, picking up power cells from a depot and delivering them to signal relay towers while battling storms and managing energy and heat.

## Build and Run

```bash
cd examples && moon build --target native raylib_arctic_signal_relay_2026/
cd examples && ./_build/native/debug/build/raylib_arctic_signal_relay_2026/raylib_arctic_signal_relay_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Drive rover
- **Space / J**: Action (pick up cells at depot, deliver to towers)
- **R**: Restart
- **Enter / Space**: Start / next stage
- Touch buttons available on-screen

## How to Play

Drive your rover from the central depot to scattered relay towers. Load power cells at the depot, then deliver them to each tower until its demand is met. Storms blow across the map, pushing your rover and draining energy. Watch your energy and heat gauges -- returning to the depot recharges both. Complete all tower deliveries before the mission timer runs out to advance to the next stage.
