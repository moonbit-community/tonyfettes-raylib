# raylib_shaders_color_correction

Demonstrates real-time color correction using a fragment shader. Adjust contrast, saturation, and brightness on sample images through GUI slider controls.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_color_correction/
cd examples && ./_build/native/debug/build/raylib_shaders_color_correction/raylib_shaders_color_correction.exe
```

## Controls

- **1 / 2 / 3 / 4**: Switch between four sample images (parrots, cat, mandrill, fudesumi)
- **R**: Reset all adjustments to zero
- **GUI Sliders**: Drag to adjust Contrast, Saturation, and Brightness (-100 to 100)

## Key Concepts

- Loads a fragment-only color correction shader (`color_correction.fs`) applied in screen-space.
- Uses `@raygui` GUI controls (slider bars, toggle groups, buttons) for interactive parameter adjustment.
- Demonstrates passing float uniform values to shaders for real-time image processing.
- Shows the pattern of loading images, converting to textures, and rendering through a post-processing shader.
