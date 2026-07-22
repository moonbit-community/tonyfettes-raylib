# raylib_core_smooth_pixelperfect

Demonstrates smooth pixel-perfect camera movement by rendering to a low-resolution render texture (160x90) and upscaling it to the window (800x450). Uses two cameras to split integer and fractional positioning.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_smooth_pixelperfect/
cd examples && ./_build/native/debug/build/raylib_core_smooth_pixelperfect/raylib_core_smooth_pixelperfect.exe
```

## Key Concepts

- **Dual-camera technique**: A world-space camera handles integer pixel positions, while a screen-space camera handles the fractional sub-pixel offset
- Rendering to a small `RenderTexture` then drawing it scaled to the full window
- The camera orbits automatically using sin/cos to demonstrate smooth motion without pixel jitter
- Source rectangle has negative height to flip the OpenGL-inverted render texture
