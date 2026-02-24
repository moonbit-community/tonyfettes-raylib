#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

tools/build_web_native_emcc.sh examples/raylib_hotpot_empire_rush_2026 "$@"
