# raylib_models_waving_cubes

Renders a 15x15x15 grid of cubes that wave, scatter, and pulse with rainbow colors driven by time-based sine functions.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_waving_cubes/
cd examples && ./_build/native/debug/build/raylib_models_waving_cubes/raylib_models_waving_cubes.exe
```

## Key Concepts

- Draws 3375 cubes in a triple-nested loop with positions modulated by sine waves
- Uses `color_from_hsv` to assign rainbow hues based on grid position
- Cube size and spacing oscillate over time creating a fluid wave effect
- Camera orbits the scene automatically using time-based cosine/sine position updates
- No user interaction required -- purely a visual demonstration
