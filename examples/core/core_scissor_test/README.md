# raylib_core_scissor_test

Demonstrates scissor mode rendering, where only pixels inside a defined rectangular region are drawn. The scissor area follows the mouse cursor, revealing content underneath.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_scissor_test/
cd examples && ./_build/native/debug/build/raylib_core_scissor_test/raylib_core_scissor_test.exe
```

## Controls

- **Mouse**: Move the scissor rectangle around the screen
- **S**: Toggle scissor mode on/off

## Key Concepts

- `begin_scissor_mode` / `end_scissor_mode` to restrict rendering to a rectangular area
- The full-screen red rectangle and text are only visible within the 300x300 scissor region
- Demonstrates how scissor testing can be used for reveal effects or UI clipping
