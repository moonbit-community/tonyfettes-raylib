#!/bin/bash
set -euo pipefail

echo "Cleaning generated raylib files..."

# Remove raylib source files copied to internal/raylib/
rm -f internal/raylib/rcore.c internal/raylib/utils.c internal/raylib/rshapes.c internal/raylib/rtextures.c internal/raylib/rtext.c internal/raylib/rmodels.c internal/raylib/raudio.c

# Remove downloaded raylib source tree
rm -rf external/

echo "Clean complete!"
