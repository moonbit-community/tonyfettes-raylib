# raylib_models_loading

Loads and displays a 3D model from an OBJ file with texture, supporting drag-and-drop of new models and textures at runtime, plus ray-based model selection.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_loading/
cd examples && ./_build/native/debug/build/raylib_models_loading/raylib_models_loading.exe
```

## Controls

- **Mouse**: First-person camera look
- **WASD**: Move camera
- **Left Click**: Select/deselect model (ray-cast hit test)
- **Drag & Drop**: Load new model files (.obj, .gltf, .glb, .vox, .iqm, .m3d) or textures (.png)

## Key Concepts

- Loads OBJ models and PNG textures using `load_model` and `load_texture`
- Handles file drag-and-drop via `is_file_dropped` and `load_dropped_files`
- Performs ray-based selection using `get_screen_to_world_ray` and `get_ray_collision_box`
- Draws bounding box highlight when a model is selected
