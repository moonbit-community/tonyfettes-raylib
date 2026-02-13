# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MoonBit bindings for raylib 5.5 (`tonyfettes/raylib`). Native-only target (no WASM).

## Build Commands

```bash
# First-time setup: download raylib 5.5 and copy source files to project root
bash setup.sh

# Build (native only)
moon build --target native

# Run the demo
./_build/native/debug/build/main/main.exe

# Type-check without building
moon check --target native
```

## Architecture

### FFI Pattern (two layers)

Every raylib binding follows this pattern:

1. **Private FFI declaration** — `extern "c"` function with `_ffi` suffix, operating on raw `Bytes`/primitives
2. **Public wrapper** — converts MoonBit types to/from Bytes and calls the FFI function

```moonbit
#borrow(color)
extern "c" fn clear_background_ffi(color : Bytes) = "moonbit_raylib_clear_background"

pub fn clear_background(color : Color) -> Unit {
  clear_background_ffi(color.to_bytes())
}
```

### Struct passing via Bytes serialization

Small C structs (Color, Vector2, Rectangle, etc.) are serialized to `Bytes` in MoonBit, passed to C as `moonbit_bytes_t`, and deserialized via `memcpy` in `stub.c`. Each struct type has `Type::to_bytes()` and `Type::from_bytes()` methods in `types.mbt`.

### Resource types (opaque pointers with GC finalizers)

Large/owned C structs (Image, Texture, Font, Sound, Music, Model) are wrapped in `*Wrapper` structs in `stub.c` with a `freed` flag and a destructor registered via `moonbit_make_external_object`. On the MoonBit side these are opaque `pub type` declarations.

### Key files

- `stub.c` — All C glue functions (`moonbit_raylib_*` wrappers). Functions that take only primitives call raylib directly (no wrapper needed).
- `types.mbt` — Struct definitions + Bytes serialization helpers
- `constants.mbt` — Color constants, key codes, config flags, mouse buttons
- `core.mbt` — Window, drawing, timing, input, camera
- `shapes.mbt` — 2D shape drawing + collision detection
- `textures.mbt` — Image/texture loading and drawing
- `text.mbt` — Font loading and text drawing
- `models.mbt` — 3D shapes, model loading, ray collision
- `audio.mbt` — Sound and music playback

### Package structure

- Root package (`tonyfettes/raylib`) — the library, lists all C sources in `native-stub`
- `main/` — executable demo, imports `tonyfettes/raylib`

macOS framework link flags (`-framework Cocoa`, etc.) are in `main/moon.pkg.json` only — the root library package must NOT have `cc-link-flags`.

## Critical FFI Rules

- **Never use `self` as parameter name** in `extern "c"` — MoonBit interprets it as a method definition
- **Always use `#borrow(param)`** annotation on `extern "c"` functions that take opaque pointer types (Sound, Music, Image, Texture, Font, Model, RenderTexture) or read-only Bytes
- **String passing**: encode with `@utf8.encode(str)` → `Bytes`, C side casts `moonbit_bytes_t` to `const char*`
- **Method syntax**: use `pub fn Type::method_name(...)` not `pub fn method_name(...)`

## Conventions

- Use conventional commits (e.g., `feat:`, `fix:`, `refactor:`)
- Generated C/M files (from `setup.sh`) are gitignored — only `stub.c` is tracked
- `external/` directory (raylib source tree) is gitignored
