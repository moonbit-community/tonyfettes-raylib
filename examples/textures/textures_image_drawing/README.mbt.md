# raylib_textures_image_drawing

Demonstrates CPU-side image manipulation: cropping, flipping, resizing, compositing, and drawing primitives and text onto images before uploading to GPU.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_image_drawing/
cd examples && ./_build/native/debug/build/raylib_textures_image_drawing/raylib_textures_image_drawing.exe
```

## Key Concepts

- Loads two images (cat and parrots), then performs CPU-side operations: `image_crop`, `image_flip_horizontal`, `image_resize`
- Composites the cat image onto the parrots image at 1.5x scale using `image_draw`
- Draws primitives directly on the image: `image_draw_pixel`, `image_draw_circle_lines`, `image_draw_rectangle`
- Renders text onto the image using a custom font with `image_draw_text_ex`
- Converts the final composited image to a single GPU texture for display
