# raylib_shapes_easings_box_anim

Demonstrates multiple easing functions applied to a box animation in five stages: elastic drop-in, bounce width/height change, quadratic rotation, circular height stretch, and sine fade-out.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_easings_box_anim/
cd examples && ./_build/native/debug/build/raylib_shapes_easings_box_anim/raylib_shapes_easings_box_anim.exe
```

## Controls

- **Space**: Reset and replay the animation

## Key Concepts

- Implementing five easing functions: `ease_elastic_out`, `ease_bounce_out`, `ease_quad_out`, `ease_circ_out`, `ease_sine_out`
- Drawing a rotated rectangle with `draw_rectangle_pro` using a center origin pivot
- Chaining multiple animation phases with different easing curves
- Using `fade` to animate alpha transparency
