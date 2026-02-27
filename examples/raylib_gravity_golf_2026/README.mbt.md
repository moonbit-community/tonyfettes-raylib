# Gravity Golf 2026

A physics-based golf game where you launch a ball through gravitational fields. Navigate around gravity wells to sink the ball into the hole across 3 progressively harder levels.

## Build and Run

```bash
cd examples && moon build --target native raylib_gravity_golf_2026/
cd examples && ./_build/native/debug/build/raylib_gravity_golf_2026/raylib_gravity_golf_2026.exe
```

## Controls

- **Mouse**: Aim the shot direction
- **W/S or Up/Down**: Adjust shot power (220-760)
- **Space**: Launch the ball
- **R**: Restart the course

## How to Play

Aim your ball with the mouse and launch it toward the green hole. Gravity wells (purple circles) pull the ball as it travels -- use their fields to curve shots around obstacles. The ball bounces off screen edges with energy loss and settles when speed drops low enough.

Each level introduces more gravity wells. You earn points for completing holes with shots to spare. Falling into a gravity well resets the ball to the tee. Run out of shots and the round ends.
