# raylib_models_loading_m3d

Loads and displays an M3D format model with skeletal animation, featuring toggleable mesh and skeleton visualization with bind-pose and frame-pose rendering.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_loading_m3d/
cd examples && ./_build/native/debug/build/raylib_models_loading_m3d/raylib_models_loading_m3d.exe
```

## Controls

- **Mouse**: First-person camera look
- **WASD**: Move camera
- **Space** (hold): Play animation
- **N**: Step one animation frame
- **C**: Cycle through animations
- **M**: Toggle mesh drawing
- **B**: Toggle skeleton drawing

## Key Concepts

- Loads M3D model format with `load_model` and `load_model_animations`
- Visualizes the skeletal hierarchy using bone positions and parent-child lines
- Switches between bind-pose and animation frame-pose skeleton display
- Demonstrates `get_model_bind_pose_translation` and `get_model_animation_frame_pose_translation`
