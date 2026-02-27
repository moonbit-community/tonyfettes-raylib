# Platformer Precision 2026

A side-scrolling precision platformer with checkpoints and spike hazards. Navigate a long obstacle course of floating platforms while avoiding spikes and pits to reach the finish line.

## Build and Run

```bash
cd examples && moon build --target native raylib_platformer_precision_2026/
cd examples && ./_build/native/debug/build/raylib_platformer_precision_2026/raylib_platformer_precision_2026.exe
```

## Controls

- **A/D or Left/Right Arrow Keys**: Move left/right
- **Space / W / Up Arrow**: Jump (when grounded)
- **R**: Restart the entire course

## How to Play

Run and jump across a scrolling course of platforms, avoiding red spike traps on the ground and bottomless pits. The course spans over 3800 pixels with 12 platforms at increasing heights. Four checkpoints save your progress -- dying to spikes or falling off screen respawns you at the last checkpoint reached. The death counter tracks how many attempts it takes. Reach the yellow goal marker at the far right to clear the course.
