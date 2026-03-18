# raylib_core_window_flags

Interactive demonstration of raylib's window configuration flags. Toggle various window properties at runtime while a bouncing ball animates in the background.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_window_flags/
cd examples && ./_build/native/debug/build/raylib_core_window_flags/raylib_core_window_flags.exe
```

## Controls

- **F**: Toggle fullscreen mode
- **R**: Toggle window resizable
- **D**: Toggle window undecorated (no title bar)
- **H**: Hide window (auto-restores after 4 seconds)
- **N**: Minimize window (auto-restores after 4 seconds)
- **M**: Toggle window maximized
- **U**: Toggle window unfocused
- **T**: Toggle window topmost (always on top)
- **A**: Toggle window always-run (update even when unfocused)
- **V**: Toggle VSync hint

## Key Concepts

- `set_window_state` / `clear_window_state` / `is_window_state` for runtime flag management
- Distinction between flags settable after creation and pre-creation-only flags (HighDPI, Transparent, MSAA)
