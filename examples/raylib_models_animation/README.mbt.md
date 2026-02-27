# Models Animation

A raylib API demo showing how to load and play skeletal animations on a 3D model. Loads an IQM format character model with a separate animation file and plays the animation when Space is held.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_animation/
cd examples && ./_build/native/debug/build/raylib_models_animation/raylib_models_animation.exe
```

## Controls

- **Space (hold)**: Play model animation
- **Mouse**: First-person camera look

## Key Concepts

Demonstrates `load_model`, `load_model_animations`, `update_model_animation`, and `set_model_material_texture` for skeletal animation playback. The camera uses first-person mode via `update_camera`. Model and animation resources are loaded from IQM format files, and the animation frame counter advances while Space is held.
