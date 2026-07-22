# raylib_shapes_easings_ball_anim

Demonstrates easing functions applied to a ball animation in three stages: elastic slide-in from the left, elastic expansion, and cubic fade-out with a green background reveal.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_easings_ball_anim/
cd examples && ./_build/native/debug/build/raylib_shapes_easings_ball_anim/raylib_shapes_easings_ball_anim.exe
```

## Controls

- **Enter**: Replay the animation (after completion)
- **R**: Reset the frame counter during animation

## Key Concepts

- Implementing easing functions: `ease_elastic_out`, `ease_elastic_in`, `ease_cubic_out`
- Using a frame counter to drive time-based animation through multiple stages
- State machine pattern for sequencing animation phases
