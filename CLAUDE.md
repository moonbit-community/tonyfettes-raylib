# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MoonBit bindings for raylib 5.5 (`tonyfettes/raylib`). Native-only target (no WASM).

## Build Commands

```bash
# Build (native only) — specify package path to avoid library-as-exe link error
moon build --target native examples/raylib_demo/

# Run an example
./_build/native/debug/build/examples/raylib_demo/raylib_demo.exe

# Type-check without building
moon check --target native
```

## Architecture

### Package structure

```
tonyfettes/raylib/                     # Public API: re-exports + wrappers + value types
tonyfettes/raylib/internal/raylib/     # FFI layer: pub extern "c" + C code
examples/raylib_*/                     # Example executables
```

- **`internal/raylib/`** — Contains all `pub extern "c"` declarations operating on raw `Bytes`/primitives, plus C source files (`stub.c`, `rglfw.m`, and raylib sources). Imported by the root package (default alias `@raylib`).
- **Root package** — Re-exports passthrough FFI functions via `pub using @raylib.{ ... }` and provides explicit wrapper functions for those needing type conversion (String→Bytes, Color→Bytes, etc.).
- **`examples/raylib_*/`** — Example executables, each imports `tonyfettes/raylib`.

### FFI Pattern

Passthrough functions (primitives/opaque types only) are re-exported directly:
```moonbit
pub using @raylib.{ close_window, is_key_pressed, ... }
```

Functions needing type conversion get explicit wrappers:
```moonbit
pub fn clear_background(color : Color) -> Unit {
  @raylib.clear_background(color.to_bytes())
}
```

### Struct passing via Bytes serialization

Small C structs (Color, Vector2, Rectangle, etc.) are serialized to `Bytes` in MoonBit, passed to C as `moonbit_bytes_t`, and deserialized via `memcpy` in `stub.c`. Each struct type has `Type::to_bytes()` and `Type::from_bytes()` methods in its domain file.

### Resource types (opaque pointers with GC finalizers)

Large/owned C structs (Image, Texture, Font, Sound, Music, Model) are wrapped in `*Wrapper` structs in `stub.c` with a `freed` flag and a destructor registered via `moonbit_make_external_object`. On the MoonBit side these are opaque `pub type` declarations in `internal/raylib/types.mbt`, re-exported via `pub using @raylib.{ type Image, ... }` in the corresponding domain files (`textures.mbt`, `text.mbt`, `models.mbt`, `audio.mbt`, `drawing.mbt`).

### Key files

- `build.js` — Prebuild script for platform-specific link flags (macOS/Linux/Windows)
- `internal/raylib/stub.c` — All C glue functions (`moonbit_raylib_*` wrappers)
- `internal/raylib/rglfw.m` — GLFW aggregator (includes raylib's rglfw.c)
- `internal/raylib/{core,shapes,textures,text,models,audio}.mbt` — FFI declarations
- `internal/raylib/types.mbt` — Opaque type declarations (Image, Texture, etc.)
- `vector.mbt` — Byte helpers + Vector2/Vector3/Vector4 structs
- `color.mbt` — Color struct + 25 color constants + color utility wrappers
- `rectangle.mbt` — Rectangle struct
- `camera.mbt` — Camera2D/Camera3D structs + camera constants + camera wrappers
- `ray.mbt` — Ray/BoundingBox/RayCollision structs
- `window.mbt` — Window management re-exports/wrappers + ConfigFlags + log levels
- `input.mbt` — Cursor/keyboard/mouse re-exports/wrappers + key/mouse/gesture constants
- `drawing.mbt` — Drawing lifecycle re-exports + clear_background + blend constants + Shader/RenderTexture types
- `{shapes,textures,text,models,audio}.mbt` — Domain-specific API (re-exports + wrappers)
### Platform flags (prebuild script + `moon.pkg`)

Platform-specific link flags are set dynamically by `build.js` via `--moonbit-unstable-prebuild` in `moon.mod.json`. The script detects the OS and emits `link_configs` targeting `tonyfettes/raylib/internal/raylib` — these flags propagate automatically to all dependent packages at link time, so individual example packages need no link configuration.

- **`build.js`** — Prebuild script. Sets `-framework` flags on macOS, `-l` flags on Linux, `.lib` flags on Windows.
- **`stub-cc-flags`** — Stub compilation flags. Only `internal/raylib/moon.pkg` needs these (`-DPLATFORM_DESKTOP_GLFW`), hardcoded since they apply on all platforms. No `-I` flags needed — a symlink (`platforms/GLFW → ../external/glfw/include/GLFW`) ensures `#include "GLFW/glfw3.h"` resolves via the C preprocessor's relative path search.

Use `moon build --target native examples/raylib_demo/` to build. Specify a package path to avoid the spurious `_main` undefined error from library packages.

## Critical FFI Rules

- **Never use `self` as parameter name** in `extern "c"` — MoonBit interprets it as a method definition
- **Always use `#borrow(param)`** annotation on `extern "c"` functions that take opaque pointer types (Sound, Music, Image, Texture, Font, Model, RenderTexture) or read-only Bytes
- **String passing**: encode with `@utf8.encode(str)` → `Bytes`, C side casts `moonbit_bytes_t` to `const char*`
- **Method syntax**: use `pub fn Type::method_name(...)` not `pub fn method_name(...)`

## Conventions

- Use conventional commits (e.g., `feat:`, `fix:`, `refactor:`)
- Raylib 5.5 sources are vendored in `internal/raylib/` (committed to git); `setup.sh` can be used to upgrade to a new raylib version
- `external/` directory (raylib download cache) is gitignored
