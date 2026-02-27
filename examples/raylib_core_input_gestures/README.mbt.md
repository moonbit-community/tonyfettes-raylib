# Core Input Gestures

Demonstrates touch/mouse gesture detection with a log of detected gestures and a touch area visualization.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_input_gestures/
cd examples && ./_build/native/debug/build/raylib_core_input_gestures/raylib_core_input_gestures.exe
```

## Controls

- **Touch / Mouse**: Interact with the gesture test area on the right side

## Key Concepts

- `get_gesture_detected` for identifying gesture types (tap, double-tap, hold, drag, swipe, pinch).
- `get_touch_position` for touch point location.
- `check_collision_point_rec` to constrain gesture detection to a specific area.
- Gesture history log that tracks up to 20 recent gestures.
- Deduplication of consecutive identical gestures.
