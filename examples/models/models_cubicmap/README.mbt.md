# Models Cubicmap

A raylib API demo showing how to generate a 3D map from a 2D image using cubicmap mesh generation. A small PNG image is loaded and converted into a textured 3D environment.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_cubicmap/
cd examples && ./_build/native/debug/build/raylib_models_cubicmap/raylib_models_cubicmap.exe
```

## Controls

- **Mouse**: Orbital camera rotation (automatic)
- **P**: Toggle camera pause

## Key Concepts

Demonstrates `gen_mesh_cubicmap` which takes a heightmap image and produces a 3D mesh where each non-black pixel becomes a cube. The mesh is loaded into a model via `load_model_from_mesh` and textured with an atlas. The cubicmap image also serves as a minimap displayed in the corner. The camera orbits automatically using `CameraOrbital` mode.
