# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Android Minesweeper game written in MoonBit with Raylib for graphics. The game logic, rendering, and input handling are entirely in MoonBit, compiled to C via `moon build`, then linked with Raylib and the Android NDK into a native shared library.

## Build & Run

This is an Android Gradle project. The MoonBit compiler (`moon`) must be on PATH.

```bash
# Install MoonBit dependencies (downloads tonyfettes/raylib from mooncakes.io)
cd app/src/main/moonbit && moon install

# Build debug APK (triggers MoonBit compilation + CMake native build)
./gradlew assembleDebug

# Install and run on connected device/emulator
./gradlew installDebug
adb shell am start -n com.example.raylibminesweeper/.MainActivity

# MoonBit type-check only (fast feedback loop)
cd app/src/main/moonbit && moon check --target native

# Format MoonBit code and regenerate package info
cd app/src/main/moonbit && moon fmt && moon info

# Run unit tests
./gradlew test
```

## Build Pipeline

The build has three stages orchestrated by CMake (`app/src/main/cpp/CMakeLists.txt`):

1. **MoonBit → C**: `moon build --target native` compiles `.mbt` files to a single C file (`_build/native/debug/build/raylibminesweeper.c`)
2. **Raylib static lib**: Raylib 5.5 sources (from `tonyfettes/raylib` mooncakes dependency) compiled with `PLATFORM_ANDROID` + `GRAPHICS_API_OPENGL_ES2`
3. **Shared library**: Generated C + MoonBit runtime + C stub layer + Raylib linked into `libraylibminesweeper.so`

## Architecture

```
Android (MainActivity.kt - thin NativeActivity wrapper)
  └─ Native library (libraylibminesweeper.so)
       ├─ MoonBit game code (app/src/main/moonbit/*.mbt)
       ├─ Raylib FFI bindings (mooncakes: tonyfettes/raylib)
       │    ├─ Public wrappers: type-safe API with Bytes serialization
       │    └─ internal/raylib/: extern "c" decls + C stub files
       └─ Raylib 5.5 (C sources from tonyfettes/raylib)
```

### Key files

- `app/src/main/moonbit/main.mbt` — Slim entry point (~17 lines): init window, main loop calling `update()` + `render()`
- `app/src/main/moonbit/board.mbt` — Cell struct, board helpers (`cell_index`, `is_valid_cell`), `place_mines`, `reveal_cell`, `toggle_flag`, `chord_reveal`
- `app/src/main/moonbit/game.mbt` — `GameState`/`ScreenState` structs, game/mode/difficulty constants, `init_board`, `check_win`
- `app/src/main/moonbit/camera.mbt` — `CameraState`/`LayoutState` structs, `clamp`/`float_max`, camera functions (`calculate_layout`, `init_camera`, `clamp_camera`, `make_camera`, `screen_to_board`)
- `app/src/main/moonbit/input.mbt` — `TouchState`/`PinchState`/`PanState`/`HighlightState` structs, gesture constants, `point_in_rect`, all input/update handling
- `app/src/main/moonbit/render.mbt` — Color constants, layout constants, drawing helpers (`draw_text_centered_in_rect`, `fit_font_size`, `draw_flag_icon`), all rendering
- `app/src/main/moonbit/moon.mod.json` — MoonBit module config; depends on `tonyfettes/raylib` from mooncakes.io
- `app/src/main/moonbit/moon.pkg` — Package config; imports `tonyfettes/raylib`, marked as main
- `app/src/main/cpp/CMakeLists.txt` — Orchestrates MoonBit→C compilation, Raylib build, and final linking
- `app/src/main/java/.../MainActivity.kt` — Android entry point; keeps screen on, hides system bars
- `app/src/main/moonbit/.mooncakes/tonyfettes/raylib/` — Raylib MoonBit bindings (downloaded from mooncakes.io)

### FFI pattern (Raylib bindings)

MoonBit structs (Color, Vector2, Rectangle, Camera2D) are serialized to `Bytes` via `to_bytes()`, passed to C stubs that `memcpy` into native structs, call Raylib, and serialize results back. Passthrough functions (primitives only) are re-exported directly via `pub using @raylib.{ ... }`. See `.mooncakes/tonyfettes/raylib/CLAUDE.md` for binding-specific rules.

### Game state

Mutable state is organized into module-level structs with `mut` fields: `screen` (ScreenState), `game` (GameState), `layout_` (LayoutState), `camera` (CameraState), `touch` (TouchState), `pinch` (PinchState), `pan` (PanState), `highlight` (HighlightState). Game states: `state_menu` (0), `state_playing` (1), `state_won` (2), `state_lost` (3), `state_about` (4). Difficulty presets: Easy 12×8/10, Medium 20×12/40, Hard 30×16/99.

## MoonBit Conventions

- Use the `/moonbit-agent-guide` skill when working with MoonBit code
- Target is always `native` (no WASM)
- After modifying `.mbt` files, run `moon fmt` to format and `moon info` to regenerate `pkg.generated.mbti`
- The raylib bindings package has its own FFI rules — read `.mooncakes/tonyfettes/raylib/CLAUDE.md` before modifying bindings
- Never use `self` as a parameter name in `extern "c"` declarations
- Use `#borrow(param)` annotation on extern functions taking opaque pointer types

## Git Conventions

- Use [Conventional Commits](https://www.conventionalcommits.org/) for all commit messages (e.g. `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`, `build:`)

## Releasing

Version is defined in `app/build.gradle.kts` (`versionCode` and `versionName` in `defaultConfig`).

1. Bump version in `app/build.gradle.kts`:
   - Increment `versionCode` by 1
   - Update `versionName` to the new version (e.g. `"0.2.0"`)
2. Commit: `git commit -am "chore: bump version to <version>"`
3. Build the release APK: `./gradlew assembleRelease`
   - Output: `app/build/outputs/apk/release/app-release.apk`
4. Tag the commit: `git tag v<version>`
5. Push: `git push && git push --tags`
6. Create GitHub release with APK:
   ```bash
   gh release create v<version> app/build/outputs/apk/release/app-release.apk \
     --title "v<version>" --generate-notes
   ```
