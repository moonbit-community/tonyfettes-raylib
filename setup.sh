#!/bin/bash
set -euo pipefail

RAYLIB_VERSION="5.5"
RAYLIB_DIR="external/raylib"
RAYLIB_SRC="$RAYLIB_DIR/src"
GLFW_SRC="$RAYLIB_SRC/external/glfw/src"

# Download and extract raylib if not present
if [ ! -d "$RAYLIB_DIR" ]; then
    echo "Downloading raylib ${RAYLIB_VERSION}..."
    mkdir -p external
    curl -L "https://github.com/raysan5/raylib/archive/refs/tags/${RAYLIB_VERSION}.tar.gz" -o external/raylib.tar.gz
    tar xzf external/raylib.tar.gz -C external
    mv "external/raylib-${RAYLIB_VERSION}" "$RAYLIB_DIR"
    rm external/raylib.tar.gz
    echo "raylib ${RAYLIB_VERSION} downloaded to ${RAYLIB_DIR}"
else
    echo "raylib already present at ${RAYLIB_DIR}"
fi

# Copy raylib source files to project root
echo "Copying raylib source files..."
cp "$RAYLIB_SRC/rcore.c" .
cp "$RAYLIB_SRC/utils.c" .
cp "$RAYLIB_SRC/rshapes.c" .
cp "$RAYLIB_SRC/rtextures.c" .
cp "$RAYLIB_SRC/rtext.c" .
cp "$RAYLIB_SRC/rmodels.c" .
cp "$RAYLIB_SRC/raudio.c" .

# Copy GLFW source files with glfw_ prefix
echo "Copying GLFW source files..."

# Platform-independent C files
cp "$GLFW_SRC/init.c"         glfw_init.c
cp "$GLFW_SRC/platform.c"     glfw_platform.c
cp "$GLFW_SRC/context.c"      glfw_context.c
cp "$GLFW_SRC/monitor.c"      glfw_monitor.c
cp "$GLFW_SRC/window.c"       glfw_window.c
cp "$GLFW_SRC/input.c"        glfw_input.c
cp "$GLFW_SRC/vulkan.c"       glfw_vulkan.c

# POSIX files
cp "$GLFW_SRC/posix_module.c" glfw_posix_module.c
cp "$GLFW_SRC/posix_thread.c" glfw_posix_thread.c
cp "$GLFW_SRC/posix_poll.c"   glfw_posix_poll.c

# Cocoa/macOS files (.m for Objective-C)
cp "$GLFW_SRC/cocoa_init.m"      glfw_cocoa_init.m
cp "$GLFW_SRC/cocoa_joystick.m"  glfw_cocoa_joystick.m
cp "$GLFW_SRC/cocoa_monitor.m"   glfw_cocoa_monitor.m
cp "$GLFW_SRC/cocoa_window.m"    glfw_cocoa_window.m
cp "$GLFW_SRC/cocoa_time.c"      glfw_cocoa_time.c
cp "$GLFW_SRC/nsgl_context.m"    glfw_nsgl_context.m

# EGL and OSMesa (needed even if unused - GLFW references them)
cp "$GLFW_SRC/egl_context.c"     glfw_egl_context.c
cp "$GLFW_SRC/osmesa_context.c"  glfw_osmesa_context.c

echo "Setup complete!"
