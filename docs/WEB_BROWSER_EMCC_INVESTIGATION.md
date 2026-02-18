# Browser/EMCC Investigation (2026-02-18)

## Question

Can this MoonBit + raylib project be ported to the browser by compiling to C and then using `emcc`?

## Short Answer

Yes, that architecture makes sense in principle.

Your suggestion is technically sound for this repo: use MoonBit `native` backend to generate C, then compile that C with `emcc` for browser instead of desktop `cc`.

In the current repository state, this path is not automated yet.

## What Was Verified

Commands run locally:

```bash
moon version
moon check --target native examples/raylib_tank_1990
moon build --target native examples/raylib_tank_1990
moon build -v --target native examples/raylib_tank_1990 --dry-run
moon build --target wasm examples/raylib_tank_1990
moon build --target c examples/raylib_tank_1990
emcc --version
```

Observed results:

- `moon check --target native` and `moon build --target native` succeed for `examples/raylib_tank_1990`.
- `moon build -v --target native --dry-run` shows this native pipeline:
  - `moonc link-core ... -o ./_build/native/debug/build/examples/raylib_tank_1990/raylib_tank_1990.c`
  - then `/usr/bin/cc` compiles that generated C to native executable.
- `moon build --target wasm` fails with many `Error: [4156] extern "C" is unsupported in wasm backend`.
- `moon build --target c` is invalid in this installed CLI (`possible values: wasm, wasm-gc, js, native, llvm, all`).
- `emcc` is not installed on this machine (`command not found: emcc`).

## Repository Facts Relevant to Web Port

- `internal/raylib/moon.pkg` defines `native-stub` and `link: { "native": ... }` only.
- `build.js` currently sets desktop-only config (`-DPLATFORM_DESKTOP_GLFW` + desktop system libs/frameworks).
- raylib C source already contains web platform support:
  - `internal/raylib/rcore.c` has `#elif defined(PLATFORM_WEB)` and includes `platforms/rcore_web.c`.
  - `internal/raylib/platforms/rcore_web.c` is present.
- The binding layer has heavy C FFI usage (`extern "c"` appears hundreds of times across `internal/raylib/*.mbt`).

## Why It Is Blocked Today

1. Build configuration is desktop-only (`PLATFORM_DESKTOP_GLFW`, desktop link flags, desktop-oriented source set).
2. There is no web build script that replaces desktop `cc` with `emcc` and injects Emscripten web flags.
3. Local machine currently lacks the emscripten toolchain.
4. The current `--target wasm` path is not usable for this binding package because of `extern "c"` restrictions.

## Viable Paths

### Path A: Native-C-to-EMCC Route (Recommended)

1. Keep MoonBit target as `native`.
2. Use generated C entry file from `moonc link-core` output (for example `.../raylib_tank_1990.c`).
3. Compile MoonBit runtime C + generated MoonBit C + raylib C with `emcc`.
4. Use web platform defines (`PLATFORM_WEB`) and Emscripten link flags to produce browser artifacts.
5. Keep existing desktop flow unchanged.

This follows your proposal and avoids the current MoonBit wasm backend FFI limitation.

### Path B: MoonBit Wasm Backend Route

This would require a major FFI design change because current wasm backend rejects `extern "c"` in this binding layer.

## Recommendation

For near-term delivery, keep native as the primary target.

For browser exploration, create a focused branch to automate Path A for one minimal sample first, then expand to Tank 1990.
