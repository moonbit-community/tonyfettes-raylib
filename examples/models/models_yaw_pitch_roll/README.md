# raylib_models_yaw_pitch_roll

Demonstrates yaw, pitch, and roll rotations on a 3D airplane model using Euler angles and a rotation matrix.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_yaw_pitch_roll/
cd examples && ./_build/native/debug/build/raylib_models_yaw_pitch_roll/raylib_models_yaw_pitch_roll.exe
```

## Controls

- **Up/Down Arrow**: Control pitch (nose up/down)
- **Left/Right Arrow**: Control roll (bank left/right)
- **A/S**: Control yaw (turn left/right)

## Key Concepts

- Loads an OBJ airplane model with a diffuse texture
- Converts yaw, pitch, and roll angles to a rotation matrix via `Matrix::rotate_xyz`
- Applies the rotation matrix to the model transform with `set_model_transform`
- Implements gradual return-to-neutral when keys are released for smooth control feel
