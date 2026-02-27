# raylib_glacier_rescue_2026

A helicopter rescue game set in a vast glacier wilderness. Fly a helicopter across a large scrolling world, locate stranded survivors, pick them up, and return them to base while managing fuel, hull, and cold exposure. Features avalanches, hazards, and flare drops.

## Build and Run

```bash
cd examples && moon build --target native raylib_glacier_rescue_2026/
cd examples && ./_build/native/debug/build/raylib_glacier_rescue_2026/raylib_glacier_rescue_2026.exe
```

## Controls

- **WASD / Arrow keys**: Fly helicopter
- **Space/J**: Boost (temporary speed increase)
- **K/L**: Drop flare (reveals nearby survivors)
- **R**: Restart

## How to Play

- Fly over the glacier world (4200x2800) to find survivors shown with beacon flashes
- Land near survivors to pick them up (limited capacity)
- Return to base to deliver rescued survivors and refuel
- Avoid ice hazards and falling debris; avalanches sweep across zones
- Manage fuel (depletes while flying), hull integrity, and cold exposure
- Drop flares to light up dark areas and spot hidden survivors
- Rescue as many survivors as possible; lost survivors count against you
