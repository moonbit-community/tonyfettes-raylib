# raylib_core_window_should_close

Demonstrates how to intercept window close events and show a confirmation dialog before exiting. Disables the default ESC-to-close behavior and implements a custom close flow.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_window_should_close/
cd examples && ./_build/native/debug/build/raylib_core_window_should_close/raylib_core_window_should_close.exe
```

## Controls

- **ESC or X button**: Request to close (shows confirmation)
- **Y**: Confirm exit
- **N**: Cancel exit request

## Key Concepts

- `set_exit_key(KeyNull)` to disable the default ESC close behavior
- `window_should_close()` still detects the X button click
- Custom confirmation dialog pattern useful for saving data before exit
