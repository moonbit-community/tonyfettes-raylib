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

# Copy raylib source files to internal/raylib/
echo "Copying raylib source files to ${DEST_DIR}..."
cp "$RAYLIB_SRC/rcore.c" "$DEST_DIR/"
cp "$RAYLIB_SRC/utils.c" "$DEST_DIR/"
cp "$RAYLIB_SRC/rshapes.c" "$DEST_DIR/"
cp "$RAYLIB_SRC/rtextures.c" "$DEST_DIR/"
cp "$RAYLIB_SRC/rtext.c" "$DEST_DIR/"
cp "$RAYLIB_SRC/rmodels.c" "$DEST_DIR/"
cp "$RAYLIB_SRC/raudio.c" "$DEST_DIR/"

echo "Setup complete!"
