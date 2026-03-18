# raylib_models_gpu_skinning

Demonstrates GPU-based skeletal animation (skinning) by loading a glTF model with custom vertex and fragment shaders that perform bone transformations on the GPU.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_gpu_skinning/
cd examples && ./_build/native/debug/build/raylib_models_gpu_skinning/raylib_models_gpu_skinning.exe
```

## Controls

- **Mouse**: Orbit camera around the model
- **T**: Next animation
- **G**: Previous animation

## Key Concepts

- Loads a glTF model (`greenman.glb`) with skeletal animation data
- Applies custom skinning shaders (`skinning.vs`/`skinning.fs`) for GPU-side bone transforms
- Uses `update_model_animation_bones` instead of `update_model_animation` to update only bone data without CPU mesh deformation
- Draws the mesh directly via `draw_mesh` with the model's transform matrix
- Cycles through multiple animations embedded in the glTF file
