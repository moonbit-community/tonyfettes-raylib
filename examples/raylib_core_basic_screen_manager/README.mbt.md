# Core Basic Screen Manager

Demonstrates a simple state machine for managing multiple game screens (Logo, Title, Gameplay, Ending) with transitions on key press or tap.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_basic_screen_manager/
cd examples && ./_build/native/debug/build/raylib_core_basic_screen_manager/raylib_core_basic_screen_manager.exe
```

## Controls

- **Enter / Tap**: Advance to the next screen
- Logo screen auto-advances after 2 seconds

## Key Concepts

- Integer-based screen state (`0`=Logo, `1`=Title, `2`=Gameplay, `3`=Ending).
- Frame counter for timed transitions (Logo screen waits 120 frames).
- `is_gesture_detected(GestureTap)` for touch input alongside keyboard.
- Pattern for organizing game flow across multiple screens using `match`.
