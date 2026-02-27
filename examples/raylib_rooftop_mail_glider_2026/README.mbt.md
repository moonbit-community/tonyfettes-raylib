# raylib_rooftop_mail_glider_2026

A delivery flight sim where you pilot a glider across a scrolling cityscape, picking up mail bags from a depot and delivering them to rooftop pads before deadlines expire. Manage fuel, dodge birds and wind tunnels, and collect mid-air supply crates.

## Build and Run

```bash
cd examples && moon build --target native raylib_rooftop_mail_glider_2026/
cd examples && ./_build/native/debug/build/raylib_rooftop_mail_glider_2026/raylib_rooftop_mail_glider_2026.exe
```

## Controls

- **WASD / Arrows**: Steer the glider
- **J / Space**: Boost (consumes fuel faster, adds heat)
- **K**: Fire a flare (scares away birds)
- **E**: Pick up bags at depot / deliver bags at pads
- **R**: Restart
- **F11**: Toggle fullscreen
- **Enter**: Start game

## How to Play

Fly to the depot to load mail bags, then deliver them to the correct rooftop pads before their deadlines expire. Priority deliveries pay more. Wind tunnels push you off course and birds damage your hull on collision -- use flares to scare them. Collect floating crates for fuel, repair kits, or bonus bags. The game ends when hull integrity reaches zero or all delivery slots expire. Earn stars for efficient routes.
