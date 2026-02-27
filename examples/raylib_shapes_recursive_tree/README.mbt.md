# Shapes Recursive Tree

Generates and renders a fractal binary tree with configurable angle, length, decay, depth, and line thickness. Branches grow iteratively from a trunk, splitting left and right at each level.

## Build and Run

```bash
cd examples && moon build --target native raylib_shapes_recursive_tree/
cd examples && ./_build/native/debug/build/raylib_shapes_recursive_tree/raylib_shapes_recursive_tree.exe
```

## Controls

- **GUI Sliders**: Adjust angle (0-180), length (12-240), decay (0.1-0.78), depth (1-10), thickness (1-8)
- **GUI Checkbox**: Toggle Bezier curve rendering for branches

## Key Concepts

- Builds a binary tree iteratively: each branch spawns two children at +/- the branch angle
- Branch length decays by a configurable factor at each level
- Supports rendering branches as straight lines or Bezier curves
- Uses raygui sliders for real-time parameter adjustment
- Tree is regenerated every frame from the parameters (no persistent tree structure)
