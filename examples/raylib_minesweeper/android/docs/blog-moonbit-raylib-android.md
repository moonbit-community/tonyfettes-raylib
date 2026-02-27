# Building an Android Game with MoonBit, Raylib, and the NDK

How we built a fully native Android Minesweeper game without writing a single line of Java game logic — using MoonBit for the brain, Raylib for the eyes, and the Android NDK to glue it all together.

## 1. Introduction

This post walks through the architecture of [RaylibMinesweeper](https://github.com/nicholasgasior/RaylibMinesweeper), an Android Minesweeper game built with an unusual stack:

- **MoonBit** — a modern systems language that compiles to C (among other targets). All game logic is written in MoonBit.
- **Raylib** — a lightweight C library for graphics, input, and audio. It handles window creation, OpenGL ES rendering, and touch input.
- **Android NDK** — the Native Development Kit lets us run C/C++ code on Android, bypassing the JVM entirely for the game loop.

The key insight is that **all three converge on C as the common language**. MoonBit compiles to C. Raylib is written in C. The NDK compiles C into a shared library that Android can load. The Kotlin layer is just a thin shell — the entire game runs natively.

The result: a ~3MB APK with a 60fps game loop, touch gestures, camera zoom/pan, and zero garbage collection pauses during gameplay.

## 2. Architecture Overview

Here's how the four layers fit together (from [`docs/architecture.md`](architecture.md)):

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

The Kotlin layer does almost nothing. `MainActivity` extends `NativeActivity`, a special Android Activity that bypasses the normal View system entirely. When the activity launches, Android calls `dlopen("libraylibminesweeper.so")`, finds `ANativeActivity_onCreate` via `dlsym`, and from that point on, everything runs in native code — Raylib's event loop, the MoonBit game logic, all of it.

## 3. The Build Pipeline: 3-Step CMake

The entire native build is orchestrated by a single `CMakeLists.txt`. Here's the full file with annotations:

```cmake
cmake_minimum_required(VERSION 3.22.1)
project("raylibminesweeper" C)

# --- Paths ---
set(MOONBIT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../moonbit)
set(NATIVE_APP_GLUE_DIR ${ANDROID_NDK}/sources/android/native_app_glue)

# MOON_HOME: use env var, fallback to $HOME/.moon
if(DEFINED ENV{MOON_HOME})
    set(MOON_HOME "$ENV{MOON_HOME}")
else()
    set(MOON_HOME "$ENV{HOME}/.moon")
endif()

# Raylib + MoonBit bindings from mooncakes.io (tonyfettes/raylib)
set(RAYLIB_BINDINGS_DIR ${MOONBIT_DIR}/.mooncakes/tonyfettes/raylib/internal/raylib)
set(RAYLIB_SRC_DIR ${RAYLIB_BINDINGS_DIR})
```

### Step 1: MoonBit → C

```cmake
# --- Find moon CLI ---
find_program(MOON_EXECUTABLE moon REQUIRED)

# --- Step 1: Run moon build to generate C ---
set(MOONBIT_GENERATED_C ${MOONBIT_DIR}/_build/native/debug/build/raylibminesweeper.c)
add_custom_command(
    OUTPUT ${MOONBIT_GENERATED_C}
    COMMAND ${MOON_EXECUTABLE} build --target native
    WORKING_DIRECTORY ${MOONBIT_DIR}
    DEPENDS ${MOONBIT_DIR}/main.mbt
    COMMENT "Compiling MoonBit to C"
)
```

`moon build --target native` compiles all `.mbt` files in the project into a **single C file** (`raylibminesweeper.c`). This is the MoonBit compiler's native backend — it produces portable C99 that any C compiler can handle.

### Step 2: Build Raylib as a Static Library

```cmake
# --- Step 2: Build raylib static library (from mooncakes dependency) ---
add_library(raylib STATIC
    ${RAYLIB_SRC_DIR}/rcore.c
    ${RAYLIB_SRC_DIR}/rshapes.c
    ${RAYLIB_SRC_DIR}/rtextures.c
    ${RAYLIB_SRC_DIR}/rtext.c
    ${RAYLIB_SRC_DIR}/rmodels.c
    ${RAYLIB_SRC_DIR}/raudio.c
    ${RAYLIB_SRC_DIR}/utils.c
)
target_include_directories(raylib PUBLIC ${RAYLIB_SRC_DIR} ${RAYLIB_SRC_DIR}/external/glfw/include)
target_include_directories(raylib PRIVATE ${NATIVE_APP_GLUE_DIR})
target_compile_definitions(raylib PUBLIC PLATFORM_ANDROID GRAPHICS_API_OPENGL_ES2 _DEFAULT_SOURCE)
target_compile_options(raylib PRIVATE -std=c99 -ffunction-sections -fdata-sections -fPIC)
```

Two critical compile definitions:

- `PLATFORM_ANDROID` — tells Raylib to use `native_app_glue` for the window and EGL for the OpenGL context
- `GRAPHICS_API_OPENGL_ES2` — targets OpenGL ES 2.0, which is universally supported on Android

The Raylib source comes from the `tonyfettes/raylib` MoonBit package (installed via `mooncakes.io`), which bundles Raylib's C sources alongside the MoonBit bindings.

### Step 3: Link Everything Into a Shared Library

```cmake
# --- Step 3: Build game shared library ---
add_library(raylibminesweeper SHARED
    ${MOONBIT_GENERATED_C}                              # MoonBit game code (compiled to C)
    ${MOON_HOME}/lib/runtime.c                          # MoonBit runtime (GC, etc.)
    ${RAYLIB_BINDINGS_DIR}/stub_window.c                # FFI stubs: MoonBit <-> Raylib
    ${RAYLIB_BINDINGS_DIR}/stub_input.c
    ${RAYLIB_BINDINGS_DIR}/stub_drawing.c
    ${RAYLIB_BINDINGS_DIR}/stub_shapes.c
    ${RAYLIB_BINDINGS_DIR}/stub_text.c
    ${RAYLIB_BINDINGS_DIR}/stub_camera.c
    ${RAYLIB_BINDINGS_DIR}/stub_color.c
    ${RAYLIB_BINDINGS_DIR}/stub_utils.c
    ${NATIVE_APP_GLUE_DIR}/android_native_app_glue.c    # NDK glue layer
)

target_include_directories(raylibminesweeper PRIVATE
    ${NATIVE_APP_GLUE_DIR}
    ${MOON_HOME}/include
    ${RAYLIB_SRC_DIR}
)

target_compile_definitions(raylibminesweeper PUBLIC PLATFORM_ANDROID)
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -u ANativeActivity_onCreate")

target_link_libraries(raylibminesweeper raylib android log EGL GLESv2 OpenSLES atomic m)
```

The final `.so` links together five things:

1. The MoonBit-generated C code (your game)
2. The MoonBit runtime (`runtime.c` — garbage collector, allocator)
3. The C stub layer (`stub_*.c` — bridges MoonBit types to Raylib C structs)
4. `android_native_app_glue.c` (NDK helper that converts Android lifecycle events into a simple `android_main()` entry point)
5. Raylib itself (as a static library)

**The critical linker flag**: `-u ANativeActivity_onCreate` forces the linker to keep this symbol even though nothing in the code references it directly. Android needs to find it via `dlsym` at runtime — without this flag, the linker would strip it as "unused" and the app would crash on launch.

### Gradle Integration

The `build.gradle.kts` tells Android Studio where to find the CMake file and which ABIs to build for:

```kotlin
android {
    defaultConfig {
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
        externalNativeBuild {
            cmake {
                arguments("-DANDROID_STL=c++_shared")
            }
        }
    }
    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }
}
```

This builds the native library for three architectures: 64-bit ARM (most modern phones), 32-bit ARM (older devices), and x86_64 (emulators).

## 4. The Android Shell

### AndroidManifest.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-feature android:glEsVersion="0x00020000" android:required="true" />

    <application ...>
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:configChanges="keyboardHidden|screenSize|orientation"
            android:screenOrientation="portrait">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>

            <meta-data
                android:name="android.app.lib_name"
                android:value="raylibminesweeper" />
        </activity>
    </application>
</manifest>
```

Key points:

- `uses-feature glEsVersion="0x00020000"` — requires OpenGL ES 2.0
- `android.app.lib_name` = `"raylibminesweeper"` — tells `NativeActivity` which `.so` to load (`libraylibminesweeper.so`)
- `configChanges` prevents Android from destroying and recreating the activity on rotation/resize — the native code handles it

### MainActivity.kt

The entire Kotlin layer is 31 lines:

```kotlin
package com.example.raylibminesweeper

import android.app.NativeActivity
import android.os.Bundle
import android.view.WindowManager
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat

class MainActivity : NativeActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            hideSystemUi()
        }
    }

    private fun hideSystemUi() {
        val windowInsetsController = WindowCompat.getInsetsController(window, window.decorView)
        windowInsetsController.systemBarsBehavior =
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        windowInsetsController.hide(WindowInsetsCompat.Type.systemBars())
    }
}
```

It does exactly two things:

1. **Keep screen on** — prevents the display from sleeping during gameplay
2. **Hide system bars** — status bar and navigation bar are hidden for fullscreen, with swipe-to-reveal

Everything else is handled by `NativeActivity`'s built-in behavior: it calls `dlopen` on the library named in the manifest metadata, finds `ANativeActivity_onCreate`, and hands off control to native code.

### The Startup Sequence

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

Raylib's `rcore_android.c` defines `android_main()`, which sets up the platform state and then calls the standard C `main()`:

```c
extern int main(int argc, char *argv[]);

void android_main(struct android_app *app) {
    char arg0[] = "raylib";
    platform.app = app;
    (void)main(1, (char *[]) { arg0, NULL });
    ANativeActivity_finish(app->activity);
}
```

Since we're building a shared library (not an executable), `main()` is just an ordinary exported symbol — there's no `crt0` startup code, no entry point conflict. Raylib declares it as `extern` and calls it directly.

## 5. The FFI Bridge: MoonBit ↔ Raylib

### The Challenge

MoonBit compiles to C, and Raylib is a C library — so you might expect calling Raylib from MoonBit to be straightforward. But there's a catch: **MoonBit can't directly pass C structs by value**. When you call `ClearBackground(Color color)` in C, the `Color` struct (4 bytes: r, g, b, a) is passed on the stack. MoonBit's FFI doesn't support this — it can only pass primitive types (int, float, pointers) and `Bytes`.

### The Solution: Bytes Serialization + C Stubs

The `tonyfettes/raylib` binding package solves this with a two-layer approach:

**1. MoonBit side — serialize structs to `Bytes`:**

```moonbit
// Color is 4 bytes: r, g, b, a
pub fn Color::to_bytes(color : Color) -> Bytes {
  [color.r, color.g, color.b, color.a]
}

// Vector2 is 8 bytes: two floats
pub fn Vector2::to_bytes(v : Vector2) -> Bytes {
  let (x0, x1, x2, x3) = write_float(v.x)
  let (y0, y1, y2, y3) = write_float(v.y)
  [x0, x1, x2, x3, y0, y1, y2, y3]
}

// Camera2D is 24 bytes: offset(Vector2) + target(Vector2) + rotation(float) + zoom(float)
pub fn Camera2D::to_bytes(c : Camera2D) -> Bytes {
  // ... serialize each field to little-endian bytes
}
```

Each struct type has `to_bytes()` and `from_bytes()` methods. Floats are serialized to 4 little-endian bytes via `reinterpret_as_int()`:

```moonbit
fn write_float(value : Float) -> (Byte, Byte, Byte, Byte) {
  let bits = value.reinterpret_as_int()
  (
    (bits & 0xFF).to_byte(),
    ((bits >> 8) & 0xFF).to_byte(),
    ((bits >> 16) & 0xFF).to_byte(),
    ((bits >> 24) & 0xFF).to_byte(),
  )
}
```

**2. C side — `memcpy` from `Bytes` into the C struct:**

```c
// Passing a struct TO Raylib
void moonbit_raylib_clear_background(moonbit_bytes_t color) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  ClearBackground(c);
}

void moonbit_raylib_begin_mode_2d(moonbit_bytes_t camera) {
  Camera2D c;
  memcpy(&c, camera, sizeof(Camera2D));
  BeginMode2D(c);
}

// Getting a struct FROM Raylib
moonbit_bytes_t moonbit_raylib_get_mouse_position(void) {
  Vector2 v = GetMousePosition();
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &v, sizeof(Vector2));
  return r;
}
```

The `moonbit_bytes_t` type is a pointer to MoonBit's managed byte array. The byte layout matches the C struct layout exactly (both use little-endian, matching the ARM and x86 targets), so `memcpy` works directly.

**3. Functions that only take primitives are re-exported directly:**

For Raylib functions that take only `int`, `float`, or `void` parameters (no struct passing), the MoonBit binding can call them directly without a C stub. The binding package re-exports these:

```moonbit
// No stub needed — these only pass primitives
pub fn draw_text(text : String, x : Int, y : Int, font_size : Int, color : Bytes) -> Unit
pub fn measure_text(text : String, font_size : Int) -> Int
pub fn get_screen_width() -> Int
pub fn set_target_fps(fps : Int) -> Unit
```

### The Flow

```
MoonBit struct (Color, Vector2, Camera2D, ...)
    ↓ to_bytes() — serialize fields to Bytes
C stub function (stub_*.c)
    ↓ memcpy — copy Bytes into C struct
Raylib C function (ClearBackground, BeginMode2D, ...)
```

This adds a small overhead per call (one allocation + memcpy), but for a game running at 60fps with a few hundred draw calls per frame, it's negligible.

## 6. Writing Game Logic in MoonBit

### Project Structure

The MoonBit project lives in `app/src/main/moonbit/`:

```
moonbit/
├── moon.mod.json          # Module config — name + dependencies
├── moon.pkg               # Package config — imports + entry point
├── main.mbt               # Entry point: init → game loop → cleanup
├── game.mbt               # GameState, ScreenState, init_board
├── board.mbt              # Cell struct, place_mines, reveal_cell, BFS flood-fill
├── camera.mbt             # CameraState, layout, zoom/pan, coordinate transforms
├── input.mbt              # TouchState, gesture classification, update logic
├── render.mbt             # All rendering: menu, board, header, overlays
└── .mooncakes/            # Dependencies (installed by moon)
    └── tonyfettes/raylib/ # Raylib bindings + C sources + stubs
```

**`moon.mod.json`** — declares the module and its dependency on the Raylib bindings:

```json
{
  "name": "tonyfettes/raylibminesweeper",
  "version": "0.1.0",
  "deps": {
    "tonyfettes/raylib": "0.1.0"
  },
  "preferred-target": "native"
}
```

**`moon.pkg`** — imports the raylib package and marks this as the main (executable) package:

```
import {
  "tonyfettes/raylib",
}

options(
  "is-main": true,
)
```

### Entry Point

The entire `main.mbt` is 19 lines:

```moonbit
fn main {
  @raylib.init_window(0, 0, "Minesweeper")
  @raylib.set_target_fps(60)
  @raylib.set_exit_key(0)
  screen.width = @raylib.get_screen_width()
  screen.height = @raylib.get_screen_height()
  screen.header_height = Float::from_int(screen.height) * header_height_ratio
  screen.footer_height = Float::from_int(screen.height) * footer_height_ratio
  while not(@raylib.window_should_close()) {
    update()
    render()
  }
  @raylib.close_window()
}
```

Passing `(0, 0)` to `init_window` tells Raylib to use the full screen size (on Android, the native display resolution). `set_exit_key(0)` disables the desktop escape-key behavior. The game loop is a textbook `update() + render()` pattern.

### Game State Management

MoonBit uses **module-level mutable structs** for global state — a pattern similar to C globals but with struct organization:

```moonbit
priv struct GameState {
  mut state : Int          // state_menu, state_playing, state_won, state_lost
  mut rows : Int
  mut cols : Int
  mut total_mines : Int
  mut revealed_count : Int
  mut flag_count : Int
  mut first_click : Bool
  mut timer : Float
  mut board : Array[Cell]
  mut current_mode : Int   // mode_dig or mode_flag
}

// Module-level global instance
let game : GameState = GameState::new()
```

There are four global state objects: `game` (game logic), `screen` (display dimensions), `camera` (zoom/pan), and `touch` (gesture tracking). The `mut` keyword on each field makes it mutable — MoonBit structs are immutable by default.

### Board Logic: Cell, Mines, and Flood-Fill

The `Cell` struct represents one square on the Minesweeper board:

```moonbit
priv struct Cell {
  mut has_mine : Bool
  mut is_revealed : Bool
  mut is_flagged : Bool
  mut neighbor_mines : Int
}
```

**Mine placement** uses safe-zone exclusion — the first click and its 8 neighbors are guaranteed mine-free:

```moonbit
fn place_mines(board : Array[Cell], rows : Int, cols : Int,
               total_mines : Int, safe_row : Int, safe_col : Int) -> Unit {
  let mut placed = 0
  while placed < total_mines {
    let idx = @raylib.get_random_value(0, rows * cols - 1)
    let r = idx / cols
    let c = idx % cols
    // Skip the safe zone (3x3 around first click)
    if int_abs(r - safe_row) <= 1 && int_abs(c - safe_col) <= 1 {
      continue
    }
    if board[idx].has_mine { continue }
    board[idx].has_mine = true
    placed = placed + 1
  }
  // ... count neighbor mines for each cell
}
```

**Cell reveal** uses BFS flood-fill — when you click a cell with 0 neighbor mines, it recursively reveals all adjacent safe cells:

```moonbit
fn reveal_cell(board : Array[Cell], rows : Int, cols : Int,
               row : Int, col : Int) -> Bool {
  // ... bounds and state checks ...
  board[idx].is_revealed = true
  game.revealed_count = game.revealed_count + 1
  if board[idx].has_mine { /* reveal all mines, return true */ }
  // BFS flood fill for zero-neighbor cells
  if board[idx].neighbor_mines == 0 {
    let queue : Array[(Int, Int)] = [(row, col)]
    let mut head = 0
    while head < queue.length() {
      let (cr, cc) = queue[head]
      head = head + 1
      for dr = -1; dr <= 1; dr = dr + 1 {
        for dc = -1; dc <= 1; dc = dc + 1 {
          // ... check bounds, skip revealed/flagged/mined ...
          board[ni].is_revealed = true
          game.revealed_count = game.revealed_count + 1
          if board[ni].neighbor_mines == 0 {
            queue.push((nr, nc))
          }
        }
      }
    }
  }
  false
}
```

The BFS uses an `Array` as a queue (with a `head` index), which is a practical pattern in MoonBit — simpler than importing a proper queue data structure.

### Touch Input: Gesture Classification

Mobile Minesweeper needs to distinguish between several gestures: **tap** (reveal/flag), **long press** (flag), **pan** (scroll the board), and **pinch** (zoom). The input system uses a state machine:

```moonbit
priv struct TouchState {
  mut start_x : Float
  mut start_y : Float
  mut timer : Float
  mut long_press_triggered : Bool
  mut gesture_decided : Bool
  mut active_gesture : Int   // touch_none, tap_or_hold, gesture_pan, gesture_pinch
  mut move_dist : Float
}
```

The classification logic:

1. **Touch start** → enter `tap_or_hold` state, record start position
2. **While held**: if 2 fingers → `gesture_pinch`; if moved far enough → `gesture_pan`; if held > 0.5s → `long_press_triggered`
3. **Touch release** → if short tap with little movement → cell action; if long press → toggle flag

Pan and pinch are handled in real-time during the hold phase:

```moonbit
// Pinch zoom with midpoint stabilization
if touch.active_gesture == gesture_pinch {
  if touch_count >= 2 {
    let t0 = @raylib.get_touch_position(0)
    let t1 = @raylib.get_touch_position(1)
    let current_dist = vector2_distance(t0, t1)
    if pinch.start_dist > 1.0 {
      let mid = @raylib.Vector2::new((t0.x + t1.x) / 2.0, (t0.y + t1.y) / 2.0)
      let world_before = @raylib.get_screen_to_world_2d(mid, make_camera())
      camera.zoom = clamp(
        pinch.start_zoom * (current_dist / pinch.start_dist),
        camera.min_zoom, camera.max_zoom
      )
      let world_after = @raylib.get_screen_to_world_2d(mid, make_camera())
      // Stabilize the pinch midpoint in world space
      camera.target_x = camera.target_x + world_before.x - world_after.x
      camera.target_y = camera.target_y + world_before.y - world_after.y
    }
  }
  clamp_camera()
}
```

The pinch zoom uses midpoint stabilization: it records the world-space position at the pinch midpoint before and after the zoom change, then adjusts the camera target to keep that world point under the user's fingers.

### Rendering: Raylib Drawing via FFI

All rendering goes through the `@raylib` FFI bindings. Here's the main render dispatcher and a sample of how cells are drawn:

```moonbit
fn render() -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(color_bg)
  if game.state == state_menu {
    render_menu()
  } else if game.state == state_about {
    render_about()
  } else {
    render_playing()
  }
  @raylib.end_drawing()
}
```

Board rendering uses Raylib's `Camera2D` for zoom/pan support:

```moonbit
fn render_board() -> Unit {
  let cam = make_camera()
  @raylib.begin_mode_2d(cam)    // All coordinates now in world space
  for r = 0; r < game.rows; r = r + 1 {
    for c = 0; c < game.cols; c = c + 1 {
      let x = layout_.offset_x + Float::from_int(c) * layout_.cell_size
      let y = layout_.offset_y + Float::from_int(r) * layout_.cell_size
      let rect = @raylib.Rectangle::new(
        x + pad, y + pad,
        layout_.cell_size - pad * 2.0,
        layout_.cell_size - pad * 2.0,
      )
      // Draw cell based on state (unrevealed, flagged, mine, number...)
      @raylib.draw_rectangle_rounded(rect, cell_roundness, 8, cell_color)
    }
  }
  @raylib.end_mode_2d()
}
```

Colors are defined as module-level constants with descriptive names:

```moonbit
let color_bg : @raylib.Color = @raylib.Color::new(240, 244, 248, 255)
let color_unrevealed : @raylib.Color = @raylib.Color::new(76, 175, 147, 255)
let color_revealed : @raylib.Color = @raylib.Color::new(232, 236, 241, 255)
let color_flag : @raylib.Color = @raylib.Color::new(231, 76, 60, 255)
let color_mine_bg : @raylib.Color = @raylib.Color::new(231, 76, 60, 255)
```

Everything is drawn with Raylib primitives — rounded rectangles for cells and buttons, circles and lines for icons (mine, flag, clock, restart), triangles for the flag shape. There are no bitmap assets; the entire UI is procedurally rendered.

## 7. Key Design Decisions

### Why NativeActivity instead of regular Activity + SurfaceView?

`NativeActivity` lets the entire rendering and input pipeline run in native code. With a regular Activity + SurfaceView + JNI approach, you'd need to marshal touch events from Java to C and manage the EGL context yourself. `NativeActivity` + `native_app_glue` handles all of this automatically, and Raylib is designed to work with it out of the box.

### Why Raylib instead of SDL or raw OpenGL?

Raylib has a simpler API than SDL (no initialization boilerplate, no renderer objects) and handles the Android platform integration cleanly. It also provides high-level drawing primitives (`draw_rectangle_rounded`, `draw_triangle`, `draw_ring`) that would take hundreds of lines of raw OpenGL. For a 2D game, Raylib hits the sweet spot of simplicity and capability.

### Why MoonBit compiles to C (not WASM) for Android?

MoonBit supports multiple backends: JavaScript, WASM, and native (via C). For Android:

- **WASM** would require a runtime (browser or Wasmtime), adding complexity and overhead
- **C** integrates directly with the NDK toolchain — the generated C file is compiled by the same `clang` that builds Raylib and the stubs

The `"preferred-target": "native"` in `moon.mod.json` tells the MoonBit compiler to use the C backend.

### Why static-link Raylib instead of a separate .so?

Static linking (`add_library(raylib STATIC ...)`) bakes Raylib into `libraylibminesweeper.so`. This avoids:

- Shipping a separate `libraylib.so` and managing its loading order
- ABI compatibility issues between separately-compiled shared libraries
- The `lib_name` metadata in the manifest only specifies one library

The tradeoff is a larger `.so`, but Raylib is small (~300KB compiled) so this is negligible.

### Module-level mutable state in MoonBit

MoonBit doesn't have traditional global variables, but module-level `let` bindings with `mut` fields serve the same purpose:

```moonbit
let game : GameState = GameState::new()    // initialized once, fields mutated in-place
let screen : ScreenState = ScreenState::new(0, 0)
let camera : CameraState = CameraState::new()
let touch : TouchState = TouchState::new()
```

This is idiomatic for game development where you need fast, mutable access to shared state without the overhead of passing everything through function parameters.

## 8. Getting Started: Prerequisites & Build

### Required Tools

- **Android SDK** (API 26+) and **NDK** — install via Android Studio's SDK Manager
- **MoonBit compiler** (`moon` CLI) — install from [moonbitlang.com](https://www.moonbitlang.com/)
- **CMake 3.22.1+** — usually bundled with the Android SDK
- **Gradle** — bundled with the project (use the `./gradlew` wrapper)

### Build & Install

```bash
# Clone the project
git clone <repo-url> RaylibMinesweeper
cd RaylibMinesweeper

# Install MoonBit dependencies
cd app/src/main/moonbit
moon install
cd ../../../..

# Build debug APK and install on connected device
./gradlew installDebug
```

The Gradle build will:

1. Invoke CMake, which invokes `moon build --target native`
2. Compile Raylib and the stubs with the NDK's cross-compiler
3. Link everything into `libraylibminesweeper.so` (one per ABI)
4. Package the `.so` files + `MainActivity` into an APK
5. Install to a connected device or emulator

### Adapting for Your Own Game

To use this architecture for a different game:

1. **Replace the MoonBit game code** — edit the `.mbt` files in `app/src/main/moonbit/`. Your `main()` function should follow the same pattern: `init_window → loop { update(); render() } → close_window`.
2. **Update `moon.mod.json`** — change the module name and version.
3. **Update `CMakeLists.txt`** — the generated C filename comes from the module name (e.g., `raylibminesweeper.c`). Update the path if your module name differs.
4. **Update Gradle + Manifest** — change `android.app.lib_name`, the `applicationId`, and the CMake project name.
5. **Add any new Raylib bindings you need** — if you use Raylib functions not yet wrapped by `tonyfettes/raylib`, add new stubs following the same `Bytes → memcpy → C struct` pattern.

The Raylib bindings on mooncakes.io already cover the most common functions (window, drawing, shapes, text, input, camera). For a 2D game, you likely won't need to add any custom stubs.

---

*Built with MoonBit + Raylib. The full source code is available in the [RaylibMinesweeper repository](https://github.com/).*
