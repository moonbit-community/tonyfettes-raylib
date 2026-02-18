# Browser/EMCC Investigation (2026-02-18)

## Question

Can this MoonBit + raylib project be ported to the browser by compiling to C and then using `emcc`?

## Short Answer

Yes. Your proposed path works here:

1. Keep MoonBit backend as `native` (so MoonBit emits C).
2. Compile generated MoonBit C + MoonBit runtime C + raylib C with `emcc`.

This repository now includes an automated script for that flow:

- `tools/build_web_native_emcc.sh`

## What Was Verified

Commands run locally:

```bash
moon version
moon check --target native examples/raylib_tank_1990
moon build --target native examples/raylib_tank_1990
moon build -v --target native examples/raylib_tank_1990 --dry-run
moon build --target wasm examples/raylib_tank_1990
moon build --target c examples/raylib_tank_1990
brew install emscripten
emcc --version
tools/build_web_native_emcc.sh examples/raylib_tank_1990
```

Observed results:

- `moon check --target native` and `moon build --target native` succeed.
- MoonBit native flow emits C before final compile:
  - `moonc link-core ... -o ./_build/native/debug/build/examples/raylib_tank_1990/raylib_tank_1990.c`
- `moon build --target wasm` still fails (`extern "C" is unsupported in wasm backend`) for this binding package.
- `moon build --target c` is not a valid CLI target in this toolchain.
- `emcc` is installed and usable.
- `tools/build_web_native_emcc.sh` generates browser artifacts:
  - `_build/web/raylib_tank_1990/raylib_tank_1990.html`
  - `_build/web/raylib_tank_1990/raylib_tank_1990.js`
  - `_build/web/raylib_tank_1990/raylib_tank_1990.wasm`

## Repository Facts Relevant to Web Port

- `internal/raylib/moon.pkg` is native/desktop oriented.
- `build.js` sets desktop-specific flags (`-DPLATFORM_DESKTOP_GLFW` and desktop link settings).
- raylib C source already has web support:
  - `internal/raylib/rcore.c` includes `platforms/rcore_web.c` for `PLATFORM_WEB`.
- The MoonBit binding layer is C-FFI heavy (`extern "c"` across `internal/raylib/*.mbt`), which is why current MoonBit wasm backend path is not suitable.

## Notes from Implementation

- Runtime C (`$MOON_HOME/lib/runtime.c`) must be compiled separately from raylib include paths, otherwise `internal/raylib/external/dirent.h` can shadow system `dirent.h`.
- For this raylib web backend in the repo, `-sUSE_GLFW=3` is required during `emcc` link.
- Main compile defines/flags used:
  - `-DPLATFORM_WEB`
  - `-DGRAPHICS_API_OPENGL_ES2`
  - `-sUSE_GLFW=3`
  - `-sUSE_WEBGL2=1`
  - `-sALLOW_MEMORY_GROWTH=1`

## Usage

Build web bundle:

```bash
tools/build_web_native_emcc.sh examples/raylib_tank_1990
```

Serve locally:

```bash
emrun --no_browser --port 8080 _build/web/raylib_tank_1990/raylib_tank_1990.html
```
