# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MoonBit bindings for raylib 5.5 (`tonyfettes/raylib`). Native-only target (no WASM).

## Build Commands

> **Note:** `moon build` (without arguments) will fail with a linker error — this
> module is a library, not an executable. Always build a specific example package
> or use `moon check --target native` to type-check.

```bash
# Build an example (native only) — examples/ is a separate module
moon -C examples build --target native raylib_demo/

# Run an example — examples/ is a separate module, use -C to set working directory
moon -C examples run --target native raylib_tank_1990/

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

- **`internal/raylib/`** — Contains all `pub extern "c"` declarations operating on raw `Bytes`/primitives, plus C source files (`stub.c`, `rglfw.c`, and raylib sources). Imported by the root package (default alias `@raylib`).
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

### Resource types

All resource types use a unified **`XxxWrapper` pattern** backed by `moonbit_make_external_object` in C stubs. Users must still call `unload_*` to release raylib-internal resources (GPU textures, audio buffers, etc.), but the MoonBit-side wrapper memory is garbage-collected. The unified C-side wrapper struct is:

```c
typedef struct {
  T *data;        // pointer to actual data (inline storage or parent's memory)
  void *owner;    // NULL = owned; non-NULL = view (decref in finalizer)
  T storage[];    // flexible array member (only allocated for owned resources)
} TWrapper;
```

- **Owned resources** (Image, Sound, Music, Model, Shader, Wave, AudioStream, VrStereoConfig, Font, Texture, RenderTexture, Mesh, Material): `data` points to inline `storage[]`, `owner = NULL`. Allocated via `MakeTWrapper(val)`.
- **View resources** (Texture from RenderTexture/Font, Mesh/Material from Model, Material from MaterialsArray): `data` points into parent's memory, `owner = parent`. `moonbit_incref(parent)` on creation, `moonbit_decref(owner)` in finalizer — parent stays alive as long as any view exists. Allocated via `MakeTWrapperView(ptr, owner)`.
- **Array wrappers** (ModelAnimationsWrapper, GlyphInfoArrayWrapper, FilePathListWrapper, AutomationEventListWrapper, MaterialsArrayWrapper): Same external object pattern but with C-allocated array metadata instead of `storage[]`.

All resource types are declared as `pub type Foo` in `types.mbt` (opaque external objects). The `DEFINE_SIMPLE_WRAPPER(T, Name)` macro in `stub_internal.h` generates the wrapper struct, finalizer, and factory functions for each type.

Other notes:

- **`#borrow` annotation**: Used for any GC-managed reference-type parameters (`Bytes`, opaque types, `Ref[T]`, etc.) in `extern "c"` declarations to prevent GC collection during FFI calls.
- **`load_image_anim`**: Frame count returned via `Ref[Int]` out-parameter (labelled `frames~` with default).
- **Depth-tex/shadowmap RenderTextures**: No special constructors. Use `@rl.load_framebuffer()`, `@rl.load_texture()`, `@rl.load_texture_depth()`, `@rl.framebuffer_attach()`, then `@raylib.new_render_texture(...)` to compose custom render textures.

### Key files

- `build.js` — Prebuild script for platform-specific link flags and stub-cc-flags (macOS/Linux/Windows)
- `internal/raylib/stub_*.c` — C glue functions (`moonbit_raylib_*` wrappers), split by domain
- `internal/raylib/rglfw.c` — GLFW aggregator (compiled directly via `native-stub`)
- `internal/raylib/{core,shapes,textures,text,models,audio}.mbt` — FFI declarations
- `internal/raylib/types.mbt` — Opaque type declarations (Image, Sound, etc.)
- `internal/raylib/stub_internal.h` — `DeclareView`/`View` macros, wrapper structs for metadata types
- `vector.mbt` — Byte helpers + Vector2/Vector3/Vector4 structs
- `color.mbt` — Color struct + 25 color constants + color utility wrappers
- `rectangle.mbt` — Rectangle struct
- `camera.mbt` — Camera2D/Camera3D structs + camera constants + camera wrappers
- `ray.mbt` — Ray/BoundingBox/RayCollision structs
- `window.mbt` — Window management re-exports/wrappers + ConfigFlags + log levels
- `input.mbt` — Cursor/keyboard/mouse re-exports/wrappers + key/mouse/gesture constants
- `drawing.mbt` — Drawing lifecycle re-exports + clear_background + blend constants + Shader type
- `textures.mbt` — Texture/RenderTexture struct definitions + texture API wrappers
- `text.mbt` — Font struct definition + font/text API wrappers
- `{shapes,models,audio}.mbt` — Domain-specific API (re-exports + wrappers)

### Platform flags (prebuild script + `moon.pkg`)

Platform-specific link flags are set dynamically by `build.js` via `--moonbit-unstable-prebuild` in `moon.mod.json`. The script detects the OS and emits `link_configs` targeting `tonyfettes/raylib/internal/raylib` — these flags propagate automatically to all dependent packages at link time, so individual example packages need no link configuration.

- **`build.js`** — Prebuild script. Emits `link_configs` (platform-specific link flags) and `vars` (dynamic `stub-cc-flags`). Sets `-framework` flags on macOS, `-l` flags on Linux, `.lib` flags on Windows. On macOS, appends `-ObjC` to `stub-cc-flags` so clang compiles `rglfw.c` as Objective-C (required for GLFW's Cocoa backend).
- **`stub-cc-flags`** — Set dynamically via `${build.RAYLIB_STUB_CC_FLAGS}` in `moon.pkg`, populated by `build.js`. Always includes `-DPLATFORM_DESKTOP_GLFW`; on macOS also includes `-ObjC`. No `-I` flags needed — the `platforms/GLFW/` directory ensures `#include "GLFW/glfw3.h"` resolves via the C preprocessor's relative path search.

Use `moon -C examples build --target native raylib_demo/` to build. The `examples/` directory is a separate module, so use `-C examples` to set the working directory.

## Critical FFI Rules

- **Never use `self` as parameter name** in `extern "c"` — MoonBit interprets it as a method definition
- **Use `#borrow(param)` for any GC-managed reference-type parameters** (`Bytes`, opaque resource types, `Ref[T]`, etc.) in `extern "c"` functions when C only reads during the call and does not store a reference.
- **String passing**: encode with `@utf8.encode(str)` → `Bytes`, C side casts `moonbit_bytes_t` to `const char*`
- **Method syntax**: use `pub fn Type::method_name(...)` not `pub fn method_name(...)`

## Publishing to mooncakes.io

### Pre-publish checklist

1. **Decide version bump** — Under pre-1.0 semver (`0.x.y`):
   - **Minor** (`0.x.0`): new features, breaking changes (renamed constants, changed API surface, new sub-packages)
   - **Patch** (`0.x.y`): bug fixes only, no API changes
2. **Update `moon.mod.json`** — bump `"version"` field
3. **Verify package contents** — run `moon package --list` and confirm only library sources are included (no `examples/`, `docs/`, `tools/`, `scripts/`, dev config files)
4. **Dry-run publish** — run `moon publish --dry-run` and confirm server returns `202 Accepted`
5. **Type-check** — run `moon check --target native`

### Publish workflow

```bash
# 1. Create release branch and commit version bump
git checkout -b release/vX.Y.Z
git add moon.mod.json
git commit -m "chore: bump version to X.Y.Z and configure publish excludes"

# 2. Tag the commit
git tag vX.Y.Z

# 3. Push branch + tag and create PR
git push -u origin release/vX.Y.Z --tags
gh pr create --title "chore: release vX.Y.Z" --base main

# 4. Run checks
moon package --list          # verify no dev files included
moon publish --dry-run       # server should return 202
moon check --target native   # type-check passes

# 5. Publish (after PR is approved/merged, or from release branch)
moon publish

# 6. Post-publish smoke test — build a fresh project against the published package
cd publish/smoke_test
moon update                              # fetch the newly published version
moon build --target native cmd/main/     # must compile and link successfully
cd ../..
```

### Post-publish smoke test

A minimal project lives at `publish/smoke_test/` (gitignored). It imports `tonyfettes/raylib` from mooncakes.io and calls `init_window`/`close_window`. After every publish, run `moon update` and `moon build --target native cmd/main/` inside it to confirm the published package actually compiles and links. If this fails, the package is broken for consumers — bump a patch version and re-publish.

### Excluded from publishing

Configured via `"exclude"` in `moon.mod.json` (gitignore syntax). Currently excludes:
`/external` (anchored to repo root), `examples`, `publish`, `docs`, `tools`, `scripts`, `CLAUDE.md`, `CONTRIBUTING.md`, `WORKFLOW.md`, `setup.sh`, `clean.sh`

`CMakeLists.txt` is **included** in the published package — consumers need it for Android/emscripten builds by referencing it from `.mooncakes/`.

**Important:** Use `/external` (leading slash) to anchor to the repo root. An unanchored `external` pattern would also strip `internal/raylib/external/` (vendored raylib headers) from the package, breaking builds for consumers.

## Conventions

- Use conventional commits (e.g., `feat:`, `fix:`, `refactor:`)
- Raylib 5.5 sources are vendored in `internal/raylib/` (committed to git); `setup.sh` can be used to upgrade to a new raylib version
- `external/` directory (raylib download cache) is gitignored
