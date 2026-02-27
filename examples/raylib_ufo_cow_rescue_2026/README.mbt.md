# raylib_ufo_cow_rescue_2026

Pilot a UFO to abduct cows from farmland while dodging farmer gunfire. Use a tractor beam to lift cows to the mothership, dash to evade, and deploy EMP pulses to stun farmers.

## Build and Run

```bash
cd examples && moon build --target native raylib_ufo_cow_rescue_2026/
cd examples && ./_build/native/debug/build/raylib_ufo_cow_rescue_2026/raylib_ufo_cow_rescue_2026.exe
```

## Controls

- **WASD/Arrows**: Move UFO
- **J** or **BEAM button**: Activate tractor beam (hold)
- **K** or **DASH button**: Dash burst (costs energy)
- **L** or **EMP button**: EMP pulse to stun nearby farmers (costs energy)
- **Enter**: Start / return to menu
- **R**: Restart mission
- Touch controls available via on-screen D-pad and action buttons

## How to Play

- Hover over cows and hold the beam to lift them; carry them to the mothership at the top
- Rescue 22 cows before the timer runs out to complete the mission
- Farmers shoot at you and can seize ground cows; use EMP to disable them
- Collect pickups (battery, repair, data cache) scattered on the ground
- Energy regenerates over time; manage it between beam, dash, and EMP usage
