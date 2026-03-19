# tonyfettes/raylib

MoonBit bindings for [raylib](https://www.raylib.com/) 5.5 — a simple and
easy-to-use library to enjoy videogames programming.

## Features

- Native target support (macOS, Linux, Windows, Android)
- Covers core, shapes, textures, text, models, shaders, and audio APIs
- Automatic resource management via GC finalizers for opaque types (Image,
  Texture, Font, Sound, Music, Model, etc.)
- 145 included examples — ports of official raylib examples organized by category
- Platform-specific linking handled automatically via prebuild script

## Prerequisites

A C compiler is required because raylib's C sources are compiled from source as
part of the build.

| Platform | C Compiler |
|----------|------------|
| macOS    | Xcode Command Line Tools (`xcode-select --install`) |
| Linux    | GCC or Clang (e.g., `apt install build-essential`) |
| Windows  | MSVC or MinGW-w64 (GCC) — see below |
| Android  | Android NDK |

### Windows

Either of the following C compilers will work:

- **MSVC** — Install [Visual Studio](https://visualstudio.microsoft.com/) or the
  [Build Tools for Visual Studio](https://visualstudio.microsoft.com/visual-cpp-build-tools/).
  Make sure to select the **"Desktop development with C++"** workload. The `cl.exe`
  compiler should be available in your PATH (use the "Developer Command Prompt" or
  "Developer PowerShell" that Visual Studio provides).

- **MinGW-w64 (GCC)** — Install via [MSYS2](https://www.msys2.org/):
  1. Install MSYS2 and open the **MSYS2 UCRT64** terminal
  2. Run `pacman -S mingw-w64-ucrt-x86_64-gcc`
  3. Add the MinGW bin directory to your system `PATH` (default: `C:\msys64\ucrt64\bin`)
  4. Verify in a new terminal: `gcc --version`

## Quick Start

### Install

Add the dependency to your project:

```bash
moon add tonyfettes/raylib
```

### Hello Window

```moonbit
fn main {
  @raylib.init_window(800, 450, "Hello Raylib")
  @raylib.set_target_fps(60)
  while not(@raylib.window_should_close()) {
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_text("Hello, MoonBit!", 190, 200, 20, @raylib.lightgray)
    @raylib.end_drawing()
  }
  @raylib.close_window()
}
```

Build and run:

```bash
moon run --target native main/
```

## Building Examples

Examples live in the `examples/` directory as a separate module, organized by
category (`core/`, `shapes/`, `textures/`, `text/`, `models/`, `shaders/`,
`audio/`, `others/`):

```bash
# Build a specific example
moon -C examples build --target native core/core_basic_window/

# Run a specific example
moon -C examples run --target native core/core_basic_window/

# Run the bunnymark benchmark
moon -C examples run --target native textures/textures_bunnymark/
```

## API Overview

Import `tonyfettes/raylib` and use the `@raylib` namespace:

```moonbit
// Window management
@raylib.init_window(width, height, title)
@raylib.close_window()
@raylib.set_target_fps(60)

// Drawing
@raylib.begin_drawing()
@raylib.end_drawing()
@raylib.clear_background(@raylib.skyblue)

// Shapes
@raylib.draw_rectangle(x, y, width, height, @raylib.red)
@raylib.draw_circle(x, y, radius, @raylib.blue)

// Textures
let texture = @raylib.load_texture("sprite.png")
@raylib.draw_texture(texture, x, y, @raylib.white)

// Input
@raylib.is_key_pressed(@raylib.KeySpace)
@raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
@raylib.get_mouse_position()  // -> Vector2

// Audio
@raylib.init_audio_device()
let sound = @raylib.load_sound("hit.wav")
@raylib.play_sound(sound)

// 3D
@raylib.begin_mode_3d(camera)
@raylib.draw_cube(position, width, height, length, @raylib.red)
@raylib.end_mode_3d()
```

## License

MIT
