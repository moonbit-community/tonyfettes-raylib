# Core Input Gamepad

Demonstrates gamepad input detection with a visual controller representation showing buttons, D-pad, analog sticks, and triggers in real time.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_input_gamepad/
cd examples && ./_build/native/debug/build/raylib_core_input_gamepad/raylib_core_input_gamepad.exe
```

## Controls

- **Left / Right Arrow Keys**: Switch between gamepads
- **Gamepad**: All buttons, sticks, and triggers are displayed visually

## Key Concepts

- `is_gamepad_available` to check gamepad connection status.
- `get_gamepad_name` for device identification.
- `is_gamepad_button_down` for button state polling.
- `get_gamepad_axis_movement` for analog stick and trigger values.
- `get_gamepad_button_pressed` for detecting the last pressed button.
- Visual gamepad rendering with drawn shapes representing each control.
