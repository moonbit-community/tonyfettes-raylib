# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MoonBit bindings for raylib 5.5 (`tonyfettes/raylib`). Native-only target (no WASM).

## Build Commands

```bash
# First-time setup: download raylib 5.5 and copy source files to internal/raylib/
bash setup.sh

# Build (native only) — use explicit path to avoid library-as-exe link error
moon build --target native main/

# Run the demo
./_build/native/debug/build/main/main.exe

# Type-check without building
moon check --target native
```

## Architecture

### Two-package structure

```
tonyfettes/raylib/                     # Public API: re-exports + wrappers + value types
tonyfettes/raylib/internal/raylib/     # FFI layer: pub extern "c" + C code
main/                                  # Demo executable
```

- **`internal/raylib/`** — Contains all `pub extern "c"` declarations operating on raw `Bytes`/primitives, plus C source files (`stub.c`, `rglfw.m`, and raylib sources). Imported by the root package (default alias `@raylib`).
- **Root package** — Re-exports passthrough FFI functions via `pub using @raylib.{ ... }` and provides explicit wrapper functions for those needing type conversion (String→Bytes, Color→Bytes, etc.).
- **`main/`** — Executable demo, imports `tonyfettes/raylib`.

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

Small C structs (Color, Vector2, Rectangle, etc.) are serialized to `Bytes` in MoonBit, passed to C as `moonbit_bytes_t`, and deserialized via `memcpy` in `stub.c`. Each struct type has `Type::to_bytes()` and `Type::from_bytes()` methods in `types.mbt`.

### Resource types (opaque pointers with GC finalizers)

Large/owned C structs (Image, Texture, Font, Sound, Music, Model) are wrapped in `*Wrapper` structs in `stub.c` with a `freed` flag and a destructor registered via `moonbit_make_external_object`. On the MoonBit side these are opaque `pub type` declarations in `internal/raylib/types.mbt`, re-exported via `pub using @raylib.{ type Image, ... }` in root `types.mbt`.

### Key files

- `internal/raylib/stub.c` — All C glue functions (`moonbit_raylib_*` wrappers)
- `internal/raylib/rglfw.m` — GLFW aggregator (includes raylib's rglfw.c)
- `internal/raylib/{core,shapes,textures,text,models,audio}.mbt` — FFI declarations
- `internal/raylib/types.mbt` — Opaque type declarations (Image, Texture, etc.)
- `types.mbt` — Value type structs (Color, Vector2, etc.) + type re-exports
- `constants.mbt` — Color constants, key codes, config flags, mouse buttons
- `{core,shapes,textures,text,models,audio}.mbt` — Public API (re-exports + wrappers)

### Package configuration

macOS framework link flags (`-framework Cocoa`, etc.) must be in **all three** packages:
- `internal/raylib/moon.pkg` — for `moon test` linking
- Root `moon.pkg` — for `moon test` linking
- `main/moon.pkg` — for the actual build

Use `moon build --target native main/` to avoid the spurious `_main` undefined error from library packages with `cc-link-flags`.

## Critical FFI Rules

- **Never use `self` as parameter name** in `extern "c"` — MoonBit interprets it as a method definition
- **Always use `#borrow(param)`** annotation on `extern "c"` functions that take opaque pointer types (Sound, Music, Image, Texture, Font, Model, RenderTexture) or read-only Bytes
- **String passing**: encode with `@utf8.encode(str)` → `Bytes`, C side casts `moonbit_bytes_t` to `const char*`
- **Method syntax**: use `pub fn Type::method_name(...)` not `pub fn method_name(...)`

## Conventions

- Use conventional commits (e.g., `feat:`, `fix:`, `refactor:`)
- Generated C files (from `setup.sh`) are gitignored — only `stub.c` and `rglfw.m` are tracked
- `external/` directory (raylib source tree) is gitignored
