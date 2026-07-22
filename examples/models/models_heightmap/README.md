# raylib_models_heightmap

Generates and renders a 3D terrain mesh from a grayscale heightmap image, with an orbital camera for viewing the landscape.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_heightmap/
cd examples && ./_build/native/debug/build/raylib_models_heightmap/raylib_models_heightmap.exe
```

## Controls

- **Mouse**: Orbit camera around the terrain

## Key Concepts

- Loads a grayscale PNG image and generates a heightmap mesh using `gen_mesh_heightmap`
- Applies the heightmap image as the diffuse texture on the terrain model
- Uses `CameraOrbital` mode for automatic camera rotation around the scene
- Demonstrates image-to-mesh conversion with configurable world-space dimensions
