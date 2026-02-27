# raylib_core_vr_simulator

Demonstrates VR stereo rendering with lens distortion correction. Configures a virtual VR headset device, renders a 3D scene in stereo mode, and applies a distortion shader to simulate a VR display.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_vr_simulator/
cd examples && ./_build/native/debug/build/raylib_core_vr_simulator/raylib_core_vr_simulator.exe
```

## Controls

- **Mouse**: Look around (first-person camera)
- **WASD**: Move through the 3D scene

## Key Concepts

- `VrDeviceInfo` configuration with resolution, screen size, lens distortion, and chromatic aberration parameters
- `load_vr_stereo_config` / `begin_vr_stereo_mode` / `end_vr_stereo_mode` for stereo rendering
- Custom distortion fragment shader with lens and chromatic aberration correction
- Render-to-texture pipeline: scene renders to a framebuffer, then the distortion shader processes it
- Requires the `resources/distortion330.fs` shader file in the working directory
