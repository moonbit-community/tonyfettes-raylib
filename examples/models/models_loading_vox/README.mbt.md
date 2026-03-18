# raylib_models_loading_vox

Loads and renders MagicaVoxel (.vox) models with a custom voxel lighting shader, featuring point lights and model cycling.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_loading_vox/
cd examples && ./_build/native/debug/build/raylib_models_loading_vox/raylib_models_loading_vox.exe
```

## Controls

- **Left Click**: Cycle to next VOX model
- **Middle Mouse**: Rotate/zoom camera
- **WASD / Arrow Keys**: Move camera
- **Mouse Wheel**: Zoom in/out

## Key Concepts

- Loads multiple MagicaVoxel .vox files and centers them using bounding box calculations
- Implements a custom lighting system with 4 point lights using shader uniforms
- Applies a voxel-specific lighting shader (`voxel_lighting.vs`/`voxel_lighting.fs`)
- Passes camera position and light parameters to shaders via `set_shader_value`
- Uses `update_camera_pro` for manual camera control with rotation and zoom
