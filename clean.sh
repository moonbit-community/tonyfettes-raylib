#!/bin/bash
set -euo pipefail

echo "Cleaning generated raylib files..."

# Remove raylib source files copied to root
rm -f rcore.c utils.c rshapes.c rtextures.c rtext.c rmodels.c raudio.c

# Remove downloaded raylib source tree
rm -rf external/

echo "Clean complete!"
