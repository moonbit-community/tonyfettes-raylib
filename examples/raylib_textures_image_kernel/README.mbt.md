# raylib_textures_image_kernel

Demonstrates image convolution with three different 3x3 kernels: Sharpen, Sobel edge detection, and Gaussian blur.

## Build and Run

```bash
cd examples && moon build --target native raylib_textures_image_kernel/
cd examples && ./_build/native/debug/build/raylib_textures_image_kernel/raylib_textures_image_kernel.exe
```

## Key Concepts

- Defines three 3x3 convolution kernels: Gaussian blur, Sobel edge detection, and Sharpen
- Normalizes kernels before applying to ensure proper intensity
- Serializes kernel floats to `Bytes` for the FFI call to `image_kernel_convolution`
- Applies Gaussian blur 6 times iteratively for a stronger effect
- Displays all four results side by side: sharpened, Sobel edges, Gaussian blur, and original
