# raylib_shaders_spotlight

Demonstrates a multi-spotlight effect using a fragment shader. Three spotlights illuminate a starfield scene -- one follows the mouse while two others bounce around the screen.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_spotlight/
cd examples && ./_build/native/debug/build/raylib_shaders_spotlight/raylib_shaders_spotlight.exe
```

## Controls

- **Mouse**: Move the primary spotlight

## Key Concepts

- Passing spotlight array data to a shader (position, inner radius, outer radius per spot)
- Animating a starfield of 400 particles with velocity-based movement
- Drawing animated texture sprites (bouncing raylib logo) behind the spotlight overlay
- Using struct arrays to manage spotlight and star state
