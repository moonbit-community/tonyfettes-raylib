# Skyline Fire Rescue 2026

A city fire-fighting simulation where you pilot a helicopter to extinguish burning buildings, rescue trapped civilians, and deliver them to the hospital while managing your water supply.

## Build and Run

```bash
cd examples && moon build --target native raylib_skyline_fire_rescue_2026/
cd examples && ./_build/native/debug/build/raylib_skyline_fire_rescue_2026/raylib_skyline_fire_rescue_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move the helicopter
- **Space / Left Mouse Button**: Drop water on fires
- **E**: Pick up/drop off passengers at designated zones

## How to Play

- Up to 28 buildings can catch fire and spread flames to neighbors
- Fly over the reservoir to refill your water tank
- Drop water on burning buildings to reduce their fire level
- Rescue civilians from buildings before they collapse (integrity reaches zero)
- Deliver rescued passengers to the hospital for points
- Buildings have structural integrity that decreases as they burn
- Fires spread between nearby buildings if not controlled
