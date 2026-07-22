# raylib_core_window_letterbox

Demonstrates resolution-independent rendering with letterboxing. The game renders at a fixed 640x480 resolution onto a render texture, then scales it to fit any window size while preserving aspect ratio.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_window_letterbox/
cd examples && ./_build/native/debug/build/raylib_core_window_letterbox/raylib_core_window_letterbox.exe
```

## Controls

- **Space**: Randomize the color bars
- **Resize window**: Drag window edges to see letterbox scaling in action

## Key Concepts

- Rendering to a fixed-size `RenderTexture` for resolution independence
- Computing scale factor as `min(window_w / game_w, window_h / game_h)` for uniform scaling
- Virtual mouse coordinate mapping from screen space to game space
- Bilinear texture filtering for smooth upscaling
- Window starts with `FlagWindowResizable` and `FlagVsyncHint` enabled
