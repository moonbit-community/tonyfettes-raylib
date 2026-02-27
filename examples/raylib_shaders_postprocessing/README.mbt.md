# raylib_shaders_postprocessing

Demonstrates full-screen post-processing shader effects applied to a 3D scene. The scene is rendered to an off-screen `RenderTexture`, then drawn to the screen through one of several selectable shaders.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_postprocessing/
cd examples && ./_build/native/debug/build/raylib_shaders_postprocessing/raylib_shaders_postprocessing.exe
```

## Controls

- **Left/Right arrows**: Cycle through post-processing shaders (Grayscale, Blur, Cross-hatching)
- **Mouse**: Orbital camera rotation

## Key Concepts

- Render-to-texture workflow: draw 3D scene into a `RenderTexture`, then apply a shader when drawing to screen
- Y-flipping the render texture to correct for OpenGL's bottom-left coordinate origin
- Loading and switching between multiple fragment shaders at runtime
