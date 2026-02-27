# raylib_textures_logo_raylib

Minimal example of loading a PNG image file and displaying it as a texture. This is the simplest texture loading and drawing demo.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_logo_raylib/
cd examples && ./_build/native/debug/build/raylib_textures_logo_raylib/raylib_textures_logo_raylib.exe
```

## Key Concepts

- Loading a texture from a PNG file with `load_texture`
- Drawing a texture centered on screen with `draw_texture`
- Textures must be loaded after window initialization (OpenGL context required)
- Proper texture cleanup with `unload_texture` before closing
