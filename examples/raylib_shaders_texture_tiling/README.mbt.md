# raylib_shaders_texture_tiling

Demonstrates texture tiling on a 3D cube model using a custom fragment shader. The tiling factor is controlled via a shader uniform, causing the texture to repeat multiple times across each face.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_texture_tiling/
cd examples && ./_build/native/debug/build/raylib_shaders_texture_tiling/raylib_shaders_texture_tiling.exe
```

## Controls

- **Mouse + WASD**: Free camera movement
- **Z**: Reset camera target to origin

## Key Concepts

- Using a `tiling.fs` shader to multiply UV coordinates for texture repetition
- Passing a `tiling` vec2 uniform to control horizontal and vertical repeat count
- Assigning both a texture and a custom shader to a model's material
