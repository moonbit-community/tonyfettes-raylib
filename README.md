# tonyfettes/raylib

MoonBit bindings for [raylib](https://www.raylib.com/) 5.5 — a simple and
easy-to-use library to enjoy videogames programming.

## Features

- Native target support (macOS, Linux, Windows, Android)
- Covers core, shapes, textures, text, models, shaders, and audio APIs
- Automatic resource management via GC finalizers for opaque types (Image,
  Texture, Font, Sound, Music, Model, etc.)
- 329 included examples — ports of official raylib examples plus original games
  and demos
- Platform-specific linking handled automatically via prebuild script

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

Examples live in the `examples/` directory as a separate module:

```bash
# Build a specific example
moon -C examples build --target native raylib_core_basic_window/

# Run a specific example
moon -C examples run --target native raylib_demo/

# Run the bunnymark benchmark
moon -C examples run --target native raylib_textures_bunnymark/
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

## Platform Support

| Platform | Status |
|----------|--------|
| macOS    | Supported |
| Linux    | Supported |
| Windows  | Supported |
| Android  | Supported |

Platform-specific link flags (OpenGL, Cocoa, X11, etc.) are configured
automatically by the prebuild script — no manual setup required for desktop
targets.

## License

MIT
