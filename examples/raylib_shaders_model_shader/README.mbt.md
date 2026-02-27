# raylib_shaders_model_shader

Demonstrates applying a custom fragment shader (grayscale) to a 3D model. Loads an OBJ watermill model with its diffuse texture and renders it through a grayscale post-process shader.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_model_shader/
cd examples && ./_build/native/debug/build/raylib_shaders_model_shader/raylib_shaders_model_shader.exe
```

## Controls

- **Mouse + WASD**: Free camera movement
- **Esc**: Exit

## Key Concepts

- Loading an OBJ model with `load_model` and binding a diffuse texture
- Assigning a custom shader to a model's material with `set_model_material_shader`
- Using a grayscale fragment shader to transform model rendering in real time
