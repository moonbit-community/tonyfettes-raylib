# raylib_models_first_person_maze

First-person maze navigation demo that generates a 3D maze from a cubicmap image, with wall collision detection and a minimap overlay.

## Build and Run

```bash
cd examples && moon build --target native raylib_models_first_person_maze/
cd examples && ./_build/native/debug/build/raylib_models_first_person_maze/raylib_models_first_person_maze.exe
```

## Controls

- **Mouse**: Look around
- **WASD**: Move through the maze

## Key Concepts

- Generates a 3D mesh from a 2D cubicmap image using `gen_mesh_cubicmap`
- Applies a texture atlas to the generated maze model
- Implements 2D circle-vs-rectangle collision to prevent walking through walls
- Renders a minimap in the corner showing the maze layout and player position
- Uses first-person camera mode with cursor disabled for immersive navigation
