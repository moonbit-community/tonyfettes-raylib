# Core Input Gamepad Info

Displays raw gamepad diagnostic information for up to 4 connected gamepads, including device name, axis values, and button states.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_input_gamepad_info/
cd examples && ./_build/native/debug/build/raylib_core_input_gamepad_info/raylib_core_input_gamepad_info.exe
```

## Key Concepts

- Enumerates all 4 gamepad slots with `is_gamepad_available`.
- `get_gamepad_name` for identifying connected devices.
- `get_gamepad_axis_count` / `get_gamepad_axis_movement` for axis enumeration.
- `is_gamepad_button_down` polled for all 32 possible button indices.
- Useful as a debugging/diagnostic tool for gamepad connectivity.
