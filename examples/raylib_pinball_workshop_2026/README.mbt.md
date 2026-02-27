# Pinball Workshop 2026

A classic pinball game with flippers, bumpers, and physics-based ball movement. Keep the ball in play using left and right flippers, hit bumpers to score points, and try to avoid draining.

## Build and Run

```bash
cd examples && moon build --target native raylib_pinball_workshop_2026/
cd examples && ./_build/native/debug/build/raylib_pinball_workshop_2026/raylib_pinball_workshop_2026.exe
```

## Controls

- **Space**: Launch the ball
- **A**: Activate left flipper
- **D**: Activate right flipper
- **R**: Restart the game

## How to Play

Press Space to launch the ball onto the table. Use the A and D keys to swing the left and right flippers upward and keep the ball from falling through the drain at the bottom. Three circular bumpers are placed on the table -- hitting them awards 150-200 points each, while flipper contact gives 25 points. You start with 3 lives; each drain costs one life. The game ends when all lives are lost.
