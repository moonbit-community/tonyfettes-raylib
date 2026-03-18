# raylib_shaders_julia_set

Renders an interactive Julia set fractal using a fragment shader. The user can select from six predefined points of interest, zoom in/out, pan, and animate the fractal's `c` parameter.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_julia_set/
cd examples && ./_build/native/debug/build/raylib_shaders_julia_set/raylib_shaders_julia_set.exe
```

## Controls

- **1-6**: Select a predefined point of interest
- **Left mouse button**: Zoom in and pan toward cursor
- **Right mouse button**: Zoom out and pan toward cursor
- **Left/Right arrows**: Decrease/increase animation speed of the `c` parameter
- **Space**: Stop animation
- **R**: Reset zoom and offset
- **F1**: Toggle control hints

## Key Concepts

- Real-time fractal rendering via a GPU fragment shader (`julia_set.fs`)
- Passing `c`, `zoom`, and `offset` uniforms to control the fractal view
- Using a `RenderTexture` as an off-screen target for shader-based drawing
