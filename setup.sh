#!/bin/bash
set -euo pipefail

RAYLIB_VERSION="5.5"
RAYLIB_DIR="external/raylib"
RAYLIB_SRC="$RAYLIB_DIR/src"
DEST_DIR="internal/raylib"

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

# Skip copy if already done
if [ -f "$DEST_DIR/raylib.h" ]; then
    echo "raylib sources already copied to ${DEST_DIR}"
    exit 0
fi

# Copy raylib source files to internal/raylib/
echo "Copying raylib source files to ${DEST_DIR}..."

# Source files (.c) — includes rglfw.c for rglfw.m
cp "$RAYLIB_SRC"/{rcore,utils,rshapes,rtextures,rtext,rmodels,raudio,rglfw}.c "$DEST_DIR/"

# Header files (.h)
cp "$RAYLIB_SRC"/{raylib,rlgl,raymath,config,utils,rcamera,rgestures}.h "$DEST_DIR/"

# Platform modules (rcore.c #includes platforms/rcore_desktop_glfw.c)
cp -r "$RAYLIB_SRC/platforms" "$DEST_DIR/"

# Bundled dependencies (stb_image.h, glfw/, miniaudio.h, etc.)
cp -r "$RAYLIB_SRC/external" "$DEST_DIR/"

# Symlink GLFW headers into platforms/ so rcore_desktop_glfw.c finds "GLFW/glfw3.h"
ln -sfn ../external/glfw/include/GLFW "$DEST_DIR/platforms/GLFW"

echo "Setup complete!"
