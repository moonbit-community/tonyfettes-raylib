# Core 2D Camera Mouse Zoom

Demonstrates mouse-driven 2D camera panning and zooming with two selectable zoom modes: mouse wheel and mouse drag.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_2d_camera_mouse_zoom/
cd examples && ./_build/native/debug/build/raylib_core_2d_camera_mouse_zoom/raylib_core_2d_camera_mouse_zoom.exe
```

## Controls

- **1**: Select mouse wheel zoom mode
- **2**: Select mouse move zoom mode
- **Left Mouse Drag**: Pan the camera
- **Mouse Wheel** (mode 1): Zoom in/out centered on cursor
- **Right Mouse Drag** (mode 2): Zoom in/out by dragging horizontally

## Key Concepts

- `get_screen_to_world_2d` for zoom-at-cursor-point behavior.
- Camera offset and target adjustment to keep zoom centered on the mouse position.
- Two zoom interaction patterns: scroll wheel and drag-based zooming.
- A reference grid drawn in world space to visualize the camera transform.
