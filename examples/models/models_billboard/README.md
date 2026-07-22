# Models Billboard

A raylib API demo showing billboard rendering in 3D space. Displays two billboards -- one static and one rotating -- that always face the camera, with proper depth-sorted draw order.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_billboard/
cd examples && ./_build/native/debug/build/raylib_models_billboard/raylib_models_billboard.exe
```

## Controls

- **Mouse**: Orbital camera rotation (automatic)

## Key Concepts

Demonstrates `draw_billboard` for basic camera-facing quads and `draw_billboard_pro` for billboards with custom rotation, source rectangle, origin, and size. A procedurally generated checked texture is used as the billboard image. Draw order is computed by comparing squared distances from the camera to each billboard position, ensuring correct transparency rendering.
