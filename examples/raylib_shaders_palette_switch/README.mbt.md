# raylib_shaders_palette_switch

Demonstrates GPU-based color palette switching using a fragment shader. An 8-color indexed palette is passed to the shader as `ivec3` uniforms and can be cycled between three preset palettes.

## Build and Run

```bash
cd examples && moon build --target native raylib_shaders_palette_switch/
cd examples && ./_build/native/debug/build/raylib_shaders_palette_switch/raylib_shaders_palette_switch.exe
```

## Controls

- **Left/Right arrows**: Cycle through palettes (3-BIT RGB, AMMO-8 GameBoy-like, RKBV 2-strip film)

## Key Concepts

- Passing array uniforms to shaders with `set_shader_value_v` and `ShaderUniformIvec3`
- Encoding palette indices in pixel color values that the shader remaps to the active palette
- Drawing colored horizontal strips where the RGB values serve as palette lookup indices
