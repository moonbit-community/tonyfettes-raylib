# Lunar Lander Ops 2026

A classic lunar lander physics game where you pilot a spacecraft through gravity to land softly on designated pads across procedural terrain, while coping with wind and meteor hazards.

## Build and Run

```bash
cd examples && moon build --target native raylib_lunar_lander_ops_2026/
cd examples && ./_build/native/debug/build/raylib_lunar_lander_ops_2026/raylib_lunar_lander_ops_2026.exe
```

## Controls

- **A/D or Left/Right**: Rotate the lander
- **W or Up**: Fire main thruster (costs fuel)
- **R**: Restart from level 1

## How to Play

Guide your lander down to the highlighted landing pad on the lunar surface. Gravity pulls you down constantly -- use thrust to slow your descent, but fuel is limited. Wind pushes the craft sideways and shifts over time. Meteors rain from above in later levels. You must touch down on the pad with low enough velocity to land safely. Each of the 4 levels features different terrain, pad placement, and wind conditions. Crashing costs a life; run out of lives and the mission ends.
