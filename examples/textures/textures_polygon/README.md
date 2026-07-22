# raylib_textures_polygon

Demonstrates drawing a texture mapped onto an irregular polygon using low-level OpenGL-like rlgl calls. The textured polygon rotates continuously.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_polygon/
cd examples && ./_build/native/debug/build/raylib_textures_polygon/raylib_textures_polygon.exe
```

## Key Concepts

- Defining polygon vertices and UV texture coordinates manually
- Using rlgl primitives (`rl_begin`, `rl_vertex2f`, `rl_tex_coord2f`, `rl_end`) to draw textured quads
- Rotating vertex positions with `Vector2::rotate` each frame
- Binding textures with `rl_set_texture` for custom geometry rendering
