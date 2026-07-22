# Shapes Following Eyes

Demonstrates two cartoon-style eyes whose irises follow the mouse cursor. The irises are constrained within their sclera circles using collision detection and trigonometry.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_following_eyes/
cd examples && ./_build/native/debug/build/raylib_shapes_following_eyes/raylib_shapes_following_eyes.exe
```

## Controls

- **Mouse**: Move to direct the eyes

## Key Concepts

- Uses `check_collision_point_circle` to detect when the mouse is outside the eye boundary
- Constrains iris position using `atan2` to compute the angle and clamp to the sclera radius
- Draws layered circles for sclera (lightgray), iris (brown/darkgreen), and pupil (black)
- Each eye tracks independently with its own constraint calculations
