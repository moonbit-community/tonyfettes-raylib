# Shapes Logo Raylib Anim

Animates the construction of the raylib logo through a multi-state sequence: blinking cursor, growing border bars, letter-by-letter text reveal, and fade-out.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_logo_raylib_anim/
cd examples && ./_build/native/debug/build/raylib_shapes_logo_raylib_anim/raylib_shapes_logo_raylib_anim.exe
```

## Controls

- **R**: Replay the animation after it completes

## Key Concepts

- Implements a 5-state animation state machine:
  - State 0: Blinking small square
  - State 1: Top and left bars grow outward
  - State 2: Bottom and right bars grow outward
  - State 3: Letters appear one by one, then everything fades out
  - State 4: Waiting for replay
- Uses `fade` to apply alpha transparency during the fade-out phase
- Frame counter drives the timing of each animation stage
