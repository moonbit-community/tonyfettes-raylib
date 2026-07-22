# raylib_text_rectangle_bounds

Demonstrates drawing text constrained within a resizable rectangle container, with word wrapping and proper text clipping.

## Build and Run

```bash
cd examples && moon build --target native raylib_text_rectangle_bounds/
cd examples && ./_build/native/debug/build/raylib_text_rectangle_bounds/raylib_text_rectangle_bounds.exe
```

## Controls

- **Space**: Toggle word wrap on/off
- **Mouse drag**: Resize the container by dragging the bottom-right corner handle

## Key Concepts

- Implements a custom `draw_text_boxed` function that renders text within rectangle bounds
- Supports word wrapping with a two-pass approach: measure pass to find line breaks, then draw pass
- Handles text overflow by stopping rendering when text exceeds the container height
- Interactive container resizing with mouse drag on a resize handle
- Supports text selection highlighting via `draw_text_boxed_selectable`
