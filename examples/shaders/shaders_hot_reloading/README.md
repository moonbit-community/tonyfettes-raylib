# raylib_shaders_hot_reloading

Demonstrates hot-reloading a fragment shader at runtime. The shader is re-read from disk when its file modification time changes, allowing live editing of the visual effect without restarting the application.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_hot_reloading/
cd examples && ./_build/native/debug/build/raylib_shaders_hot_reloading/raylib_shaders_hot_reloading.exe
```

## Controls

- **A**: Toggle automatic shader reloading on/off
- **Left mouse button**: Manually trigger shader reload (when auto-reload is off)

## Key Concepts

- Detecting file changes with `get_file_mod_time` and reloading shaders at runtime
- Passing `resolution`, `mouse`, and `time` uniforms to a full-screen fragment shader
- Validating reloaded shaders with `is_shader_valid` before swapping
- Drawing a full-screen rectangle through `begin_shader_mode` / `end_shader_mode`
