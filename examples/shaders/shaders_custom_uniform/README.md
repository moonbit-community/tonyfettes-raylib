# raylib_shaders_custom_uniform

Demonstrates passing custom uniform values to a post-processing shader. Renders a 3D scene to a render texture, then applies a swirl distortion effect centered on the mouse cursor.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_custom_uniform/
cd examples && ./_build/native/debug/build/raylib_shaders_custom_uniform/raylib_shaders_custom_uniform.exe
```

## Controls

- **Mouse**: Move to change the swirl center position
- Camera auto-orbits the 3D scene

## Key Concepts

- Uses a two-pass rendering pipeline: first draws the 3D scene to a `RenderTexture`, then applies a shader when drawing the render texture to screen.
- Loads a custom swirl fragment shader (`swirl.fs`) with a `center` uniform updated every frame from the mouse position.
- Demonstrates `load_render_texture`, `begin_texture_mode`/`end_texture_mode`, and `draw_render_texture_rec` for off-screen rendering.
- Shows how to pass a `Vector2` uniform to a shader using `set_shader_value`.
