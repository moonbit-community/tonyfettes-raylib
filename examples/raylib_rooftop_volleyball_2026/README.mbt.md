# raylib_rooftop_volleyball_2026

A 1v1 volleyball game set on a neon rooftop with a bot opponent. Features jumping, dashing, wind gusts, and a best-of-three-sets scoring system.

## Build and Run

```bash
cd examples && moon build --target native raylib_rooftop_volleyball_2026/
cd examples && ./_build/native/debug/build/raylib_rooftop_volleyball_2026/raylib_rooftop_volleyball_2026.exe
```

## Controls

- **A / D** (or **Left / Right**): Move
- **W / Up / Space**: Jump
- **J**: Hit the ball
- **K / Left Shift**: Dash (costs energy)
- **R**: Restart match

## How to Play

Win rallies by making the ball land on the opponent's side of the net. Each set is played to 11 points with a 2-point lead required. Win 2 sets to claim the championship. Jump and time your hits to spike or lob the ball. Dashing gives a speed burst for positioning. The ball has spin physics and bounces off the net and walls. Wind gusts appear periodically, pushing the ball sideways. An energy bar governs your dash and hit frequency.
