# Core Custom Frame Control

Demonstrates manual frame timing control without `set_target_fps`, using `poll_input_events`, `swap_screen_buffer`, and `wait_time` for precise frame pacing.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_custom_frame_control/
cd examples && ./_build/native/debug/build/raylib_core_custom_frame_control/raylib_core_custom_frame_control.exe
```

## Controls

- **Space**: Pause/unpause circle movement
- **Up / Down**: Increase/decrease target FPS by 20

## Key Concepts

- Manual frame loop: `poll_input_events` -> update -> draw -> `swap_screen_buffer` -> `wait_time`.
- Custom delta time calculation using `get_time`.
- Frame-rate-independent movement (200 pixels/second regardless of FPS).
- Adjustable target FPS at runtime with visual feedback of actual vs target FPS.
- Demonstrates `SUPPORT_CUSTOM_FRAME_CONTROL` pattern.
