# raylib_drone_delivery_2026

A time-limited delivery game where you pilot a drone to pick up packages and deliver them to drop-off points while avoiding shock orbs bouncing around the screen.

## Build and Run

```bash
cd examples && moon build --target native raylib_drone_delivery_2026/
cd examples && ./_build/native/debug/build/raylib_drone_delivery_2026/raylib_drone_delivery_2026.exe
```

## Controls

- **WASD / Arrow keys**: Move drone
- **R**: Restart

## How to Play

- Fly to the pickup point (P) to grab a package, then deliver it to the drop-off point (D)
- Avoid shock orbs that bounce around and deplete battery and increase heat on contact
- Battery and heat are your resource constraints
- Build delivery combos for bonus score
- Complete as many deliveries as possible before the 90-second timer expires
