# raylib_shaders_texture_outline

Demonstrates applying a shader-based outline effect to a texture. A colored outline is drawn around the non-transparent pixels of a character sprite, with adjustable outline thickness via the mouse wheel.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_texture_outline/
cd examples && ./_build/native/debug/build/raylib_shaders_texture_outline/raylib_shaders_texture_outline.exe
```

## Controls

- **Mouse wheel**: Adjust outline size (minimum 1 pixel)

## Key Concepts

- Passing `outlineSize` (float), `outlineColor` (vec4), and `textureSize` (vec2) uniforms to a fragment shader
- Using the outline shader (`outline.fs`) that detects alpha edges and draws colored outlines
- Updating shader uniforms interactively based on mouse input
