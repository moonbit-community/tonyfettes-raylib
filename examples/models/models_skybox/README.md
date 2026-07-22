# raylib_models_skybox

Loads and renders a cubemap skybox from a panoramic image using custom shaders, creating an immersive environment backdrop.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_skybox/
cd examples && ./_build/native/debug/build/raylib_models_skybox/raylib_models_skybox.exe
```

## Controls

- **Mouse**: First-person camera look
- **WASD**: Move through the scene

## Key Concepts

- Generates a unit cube mesh and applies a skybox shader (`skybox.vs`/`skybox.fs`)
- Loads a panoramic image and converts it to a cubemap texture via `load_texture_cubemap`
- Disables backface culling and depth mask so the skybox renders correctly from inside the cube
- Sets shader uniforms for environment map, gamma correction, and vertical flip
