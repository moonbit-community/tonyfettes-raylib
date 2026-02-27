# raylib_text_input_box

Demonstrates a simple text input box with mouse hover detection, character input via `get_char_pressed`, backspace handling, and a blinking cursor.

## Build and Run

```bash
cd examples && moon build --target native raylib_text_input_box/
cd examples && ./_build/native/debug/build/raylib_text_input_box/raylib_text_input_box.exe
```

## Controls

- **Mouse**: Hover over the input box to activate it
- **Type**: Enter characters (printable ASCII, max 9 characters)
- **Backspace**: Delete last character

## Key Concepts

- Uses `check_collision_point_rec` for mouse-over detection on the text box
- Reads Unicode input with `get_char_pressed` in a loop to handle multiple keys per frame
- Changes mouse cursor to I-beam (`MouseCursorIbeam`) when hovering
- Implements a blinking underscore cursor using a frame counter
- Limits input to 9 characters with a visible counter
