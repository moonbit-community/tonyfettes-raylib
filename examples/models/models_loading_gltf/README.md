# raylib_models_loading_gltf

Loads and displays an animated glTF/GLB model with support for cycling through embedded animations using mouse buttons.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_loading_gltf/
cd examples && ./_build/native/debug/build/raylib_models_loading_gltf/raylib_models_loading_gltf.exe
```

## Controls

- **Mouse**: Orbital camera rotation
- **Left Mouse Button**: Previous animation
- **Right Mouse Button**: Next animation

## Key Concepts

- Loads a GLB model with `load_model` and its animations with `load_model_animations`
- Plays back skeletal animations using `update_model_animation`
- Cycles through multiple animation clips embedded in the glTF file
- Uses orbital camera for hands-free viewing
