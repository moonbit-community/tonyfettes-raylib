#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

tools/build_web_native_emcc.sh examples/raylib_legend_of_mir_2001_lite "$@"
