# Core Clipboard Text

Demonstrates system clipboard read/write operations with a GUI-based text editor using raygui controls for cut, copy, paste, and clear.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_clipboard_text/
cd examples && ./_build/native/debug/build/raylib_core_clipboard_text/raylib_core_clipboard_text.exe
```

## Controls

- **Ctrl+X**: Cut text to clipboard
- **Ctrl+C**: Copy text to clipboard
- **Ctrl+V**: Paste text from clipboard
- **GUI Buttons**: CUT, COPY, PASTE, CLEAR, and Random text

## Key Concepts

- `set_clipboard_text` / `get_clipboard_text` for system clipboard interaction.
- raygui integration: `gui_text_box`, `gui_button`, `gui_label`.
- Keyboard shortcut handling with `is_key_down` for modifier keys.
- Cross-application clipboard interoperability.
