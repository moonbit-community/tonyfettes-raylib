# Models Bone Socket

A raylib API demo showing how to attach equipment models to animated character bone sockets. A GLTF character model has named bone sockets (hat, right hand, left hand) where equipment meshes are dynamically positioned and rotated to follow the animation.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_bone_socket/
cd examples && ./_build/native/debug/build/raylib_models_bone_socket/raylib_models_bone_socket.exe
```

## Controls

- **T/G**: Cycle through animations forward/backward
- **F/H**: Rotate character left/right
- **1/2/3**: Toggle visibility of hat, sword, and shield
- **Mouse**: Third-person camera control

## Key Concepts

Demonstrates bone socket attachment by searching for named bones (`socket_hat`, `socket_hand_R`, `socket_hand_L`), then computing equipment transforms from animation frame pose data. Uses `get_model_animation_frame_pose_translation`, `get_model_animation_frame_pose_rotation`, and `get_model_bind_pose_rotation` with quaternion math to correctly position and orient equipment meshes on animated skeletons.
