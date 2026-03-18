# raylib_shaders_lightmap

Demonstrates lightmap-based lighting on a 3D plane using a custom shader with two texture samplers and a second set of UV coordinates.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_lightmap/
cd examples && ./_build/native/debug/build/raylib_shaders_lightmap/raylib_shaders_lightmap.exe
```

## Controls

- **Mouse**: Orbital camera rotation

## Key Concepts

- Generating a plane mesh and uploading custom `texcoords2` data via `mesh_setup_texcoords2`
- Pre-baking a lightmap into a small `RenderTexture` using additive blending
- Binding two textures to a single material (albedo on `MaterialMapAlbedo`, lightmap on `MaterialMapMetalness`)
- Using a custom lightmap shader (`lightmap.vs` / `lightmap.fs`) that samples both texture channels
- Drawing a mesh directly with `draw_mesh` and `Matrix::identity()`
