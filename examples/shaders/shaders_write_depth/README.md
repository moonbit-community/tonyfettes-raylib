# raylib_shaders_write_depth

Demonstrates writing to the depth buffer from a fragment shader. The shader inverts the depth values (`gl_FragDepth = 1 - gl_FragCoord.z`), which reverses the draw order of overlapping objects.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_write_depth/
cd examples && ./_build/native/debug/build/raylib_shaders_write_depth/raylib_shaders_write_depth.exe
```

## Controls

- **Mouse**: Orbital camera rotation

## Key Concepts

- Creating a render texture with a writable depth attachment via `load_render_texture_depth_tex`
- Using a fragment shader that writes custom depth values through `gl_FragDepth`
- Rendering to an off-screen framebuffer and then drawing the result to the screen
