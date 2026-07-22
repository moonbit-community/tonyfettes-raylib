# raylib_shaders_eratosthenes

Visualizes the Sieve of Eratosthenes prime number algorithm entirely within a fragment shader. Each pixel represents a number, and the shader colors prime numbers differently from composites.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_eratosthenes/
cd examples && ./_build/native/debug/build/raylib_shaders_eratosthenes/raylib_shaders_eratosthenes.exe
```

## Controls

No interactive controls. The visualization runs automatically.

## Key Concepts

- Loads a fragment shader (`eratosthenes.fs`) that implements the Sieve of Eratosthenes algorithm on the GPU.
- Demonstrates a minimal shader-only visualization: the MoonBit code simply draws a fullscreen rectangle with the shader applied.
- Uses `load_render_texture` for the off-screen render target, though the primary visual output comes from the shader applied to a fullscreen quad.
