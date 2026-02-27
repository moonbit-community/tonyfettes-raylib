# Architecture: How Kotlin, NDK, Raylib, and MoonBit Fit Together

This document explains how the four technology layers in this project integrate to produce an Android Minesweeper app.

## Overview

```
┌─────────────────────────────────────────────────┐
│  Android OS                                     │
│  ┌───────────────────────────────────────────┐  │
│  │  Kotlin: MainActivity (NativeActivity)    │  │  ← Thin Android entry point
│  │  · Keep screen on                         │  │
│  │  · Hide system bars (fullscreen)          │  │
│  │  · meta-data specifies libraylibminesweeper│ │
│  └──────────────────┬────────────────────────┘  │
│                     │ dlopen + ANativeActivity_onCreate
│  ┌──────────────────▼────────────────────────┐  │
│  │  libraylibminesweeper.so  (NDK shared lib)│  │
│  │  ┌─────────────────────────────────────┐  │  │
│  │  │  MoonBit game code (compiled to C)  │  │  │  ← All game logic
│  │  │  main() → init_window → loop {      │  │  │
│  │  │      update()  // input + state     │  │  │
│  │  │      render()  // drawing           │  │  │
│  │  │  }                                  │  │  │
│  │  ├─────────────────────────────────────┤  │  │
│  │  │  C stub layer (stub_*.c)            │  │  │  ← MoonBit <-> Raylib bridge
│  │  │  Bytes serialization → memcpy → C   │  │  │
│  │  ├─────────────────────────────────────┤  │  │
│  │  │  Raylib 5.5 (static library)        │  │  │  ← Graphics/input/audio engine
│  │  │  PLATFORM_ANDROID + OpenGL ES 2.0   │  │  │
│  │  ├─────────────────────────────────────┤  │  │
│  │  │  android_native_app_glue            │  │  │  ← NDK glue layer
│  │  └─────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

## The Four Layers

### 1. Kotlin — The Doorman

`MainActivity.kt` extends `NativeActivity`, a special Android Activity that bypasses the normal View system and hands rendering control entirely to native code. The Kotlin layer does only two things: keep the screen on and hide the status/navigation bars for fullscreen.

The critical connection is in `AndroidManifest.xml`:

```xml
<meta-data android:name="android.app.lib_name"
           android:value="raylibminesweeper" />
```

When Android sees this, it calls `dlopen("libraylibminesweeper.so")` and looks up the symbol `ANativeActivity_onCreate` via `dlsym`.

### 2. Android NDK + CMake — The Assembly Line

`CMakeLists.txt` orchestrates the entire native build in three steps:

1. **MoonBit → C**: Runs `moon build --target native`, compiling all `.mbt` files into a single C file (`raylibminesweeper.c`).
2. **Raylib static library**: Compiles vendored Raylib 5.5 C sources with `PLATFORM_ANDROID` and `GRAPHICS_API_OPENGL_ES2`.
3. **Final shared library**: Links the MoonBit-generated C + MoonBit runtime (`runtime.c`) + C stub layer (`stub_*.c`) + `native_app_glue` + Raylib into `libraylibminesweeper.so`.

The linker flag `-u ANativeActivity_onCreate` prevents the linker from stripping this symbol — it's never referenced directly in code, but Android needs to find it via `dlsym` at runtime.

### 3. Raylib — The Engine

Raylib is a cross-platform C library for graphics, input, and audio. On Android, it uses `native_app_glue` to handle the Android window, EGL/OpenGL ES context, and touch input. It is compiled as a static library and linked into the final `.so`.

Raylib's `rcore_android.c` defines `android_main()`, which sets up the platform state and then calls the standard C `main()` function:

```c
extern int main(int argc, char *argv[]);

void android_main(struct android_app *app) {
    char arg0[] = "raylib";
    platform.app = app;
    (void)main(1, (char *[]) { arg0, NULL });
    ANativeActivity_finish(app->activity);
    // ... cleanup loop ...
}
```

### 4. MoonBit — The Brain

All game logic lives in MoonBit: board generation, mine placement, input handling, camera control, and rendering. `moon build --target native` compiles MoonBit code to C, producing a `main()` function that Raylib calls.

MoonBit cannot directly call Raylib C functions that take struct parameters, so a **C stub layer** bridges the two:

```
MoonBit struct (Color, Rectangle, ...)
    ↓ to_bytes() — serialize to Bytes
C stub function (stub_*.c)
    ↓ memcpy — deserialize into C struct
Raylib C function
```

## Startup Sequence

```
1. User taps the app icon
2. Android launches MainActivity (NativeActivity)
3. NativeActivity calls dlopen("libraylibminesweeper.so")
4. Android calls ANativeActivity_onCreate()          [native_app_glue]
5.   → Registers lifecycle callbacks
6.   → Spawns a new thread running android_main()    [Raylib rcore_android.c]
7.     → Calls main()                                [MoonBit-generated C]
8.       → init_window, set_target_fps
9.       → Main loop: update() + render()
10.      → close_window on exit
11.    → ANativeActivity_finish()
```

## Why `main()` Is Just a Regular Function Here

A common question: isn't `main()` special in C?

In a normal C executable, the C runtime startup code (`crt0`) calls `main()` as the process entry point. But this project builds a **shared library** (`add_library(... SHARED ...)`), not an executable. Shared libraries:

- Do **not** link `crt0`
- Do **not** have a process entry point
- Are loaded via `dlopen()` at runtime

So `main()` in the `.so` is just an ordinary exported symbol. Raylib's `android_main` declares it as `extern` and calls it directly — no `crt0` involved, no entry point conflict.

## Alternative Approaches (Without Raylib)

If you were building a native Android app without Raylib, you have three options:

| Approach | Entry point | You implement |
|---|---|---|
| `native_app_glue` | `android_main()` | Game loop, EGL setup |
| Raw `NativeActivity` | `ANativeActivity_onCreate()` | All lifecycle callbacks directly |
| Java/Kotlin + JNI | JNI functions | `SurfaceView` + JNI calls to native code |

This project uses approach 1, with Raylib implementing `android_main` for you, so you only need to provide `main()`.
