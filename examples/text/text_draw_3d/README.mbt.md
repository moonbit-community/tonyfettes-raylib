# raylib_text_draw_3d

Demonstrates rendering 2D text as 3D geometry in a 3D scene, including wave animation effects, multiple text layers, and an embedded alpha-discard fragment shader.

## Build and Run

```bash
cd examples && moon build --target native raylib_text_draw_3d/
cd examples && ./_build/native/debug/build/raylib_text_draw_3d/raylib_text_draw_3d.exe
```

## Controls

- **Left/Right**: Change font size
- **Up/Down**: Change font spacing
- **PgUp/PgDown**: Change line spacing
- **Home/End**: Remove/add text layers
- **Insert/Delete**: Adjust layer distance
- **F1**: Toggle letter boundary wireframes
- **F2**: Toggle text bounding box
- **F3**: Toggle camera mode (orbital/free)
- **Tab**: Toggle multicolor mode
- **Click cube**: Randomize colors
- **Type text**: Live text input with Backspace/Enter support

## Key Concepts

- Custom `draw_text_codepoint_3d` renders font glyphs as textured quads in 3D space using low-level rlgl calls
- Wave text animation using `~~` delimiters with configurable wave parameters
- Alpha-discard GLSL 330 shader (embedded as string) handles transparent texture depth issues
- Supports multiple stacked text layers with configurable distance
