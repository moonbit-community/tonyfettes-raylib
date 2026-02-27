# raylib_raymath_vector_angle

Demonstrates 2D vector angle calculations using two modes: the angle between two vectors (Vector2Angle) and the angle formed by a line (Vector2LineAngle). A visual arc shows the computed angle in real time as you move the mouse.

## Build and Run

```bash
cd examples && moon build --target native raylib_raymath_vector_angle/
cd examples && ./_build/native/debug/build/raylib_raymath_vector_angle/raylib_raymath_vector_angle.exe
```

## Controls

- **Mouse**: Move to set the V2 endpoint
- **Right Click** (Mode 0): Reposition the V1 reference vector
- **Space**: Toggle between Mode 0 (angle between two vectors) and Mode 1 (line angle from horizontal)

## Key Concepts

- **Mode 0**: Computes the signed angle between two direction vectors originating from the screen center using `atan2` on the cross/dot products.
- **Mode 1**: Computes the angle a line from V0 to the mouse cursor makes with the horizontal axis.
- Draws a filled circle sector to visualize the angular sweep between the two directions.
