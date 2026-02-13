#!/bin/bash
set -euo pipefail

RAYLIB_VERSION="5.5"
RAYLIB_DIR="external/raylib"
RAYLIB_SRC="$RAYLIB_DIR/src"

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

echo "Setup complete!"
