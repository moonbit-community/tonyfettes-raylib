# Core Input Multitouch

Demonstrates multitouch input by displaying circles at up to 10 simultaneous touch points, each labeled with its index.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_input_multitouch/
cd examples && ./_build/native/debug/build/raylib_core_input_multitouch/raylib_core_input_multitouch.exe
```

## Controls

- **Touch Screen**: Touch at multiple points simultaneously

## Key Concepts

- `get_touch_point_count` for detecting the number of active touch points.
- `get_touch_position` for reading individual touch point positions.
- Filtering out zero-position touch points (no active touch).
- Rendering indexed touch indicators with `draw_circle_v`.
