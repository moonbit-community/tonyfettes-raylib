# Models Draw Cube Texture

A raylib API demo showing how to draw textured cubes using low-level vertex submission via the rlgl API. Implements custom `draw_cube_texture` and `draw_cube_texture_rec` functions that manually specify vertices, normals, and texture coordinates for each cube face.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_draw_cube_texture/
cd examples && ./_build/native/debug/build/raylib_models_draw_cube_texture/raylib_models_draw_cube_texture.exe
```

## Controls

- None (static scene)

## Key Concepts

Demonstrates the low-level rlgl API (`rl_begin`, `rl_end`, `rl_vertex3f`, `rl_tex_coord2f`, `rl_normal3f`, `rl_color4ub`, `rl_set_texture`) for manual quad-based 3D rendering. Two cubes are drawn: one with the full texture applied to all faces, and one using a sub-rectangle of the texture via `draw_cube_texture_rec`. This approach gives full control over UV mapping and is useful when higher-level mesh APIs are insufficient.
