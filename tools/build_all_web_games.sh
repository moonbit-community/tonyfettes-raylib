#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FILTER="${1:-}"

declare -a scripts=()
while IFS= read -r script; do
  scripts+=("$script")
done < <(find tools -maxdepth 1 -type f -name 'build_web_*.sh' ! -name 'build_web_native_emcc.sh' | sort)

if [[ "${#scripts[@]}" -eq 0 ]]; then
  echo "error: no web build scripts found in tools/" >&2
  exit 1
fi

count=0
for script in "${scripts[@]}"; do
  name="$(basename "$script")"
  if [[ -n "$FILTER" && ! "$name" =~ $FILTER ]]; then
    continue
  fi
  count=$((count + 1))
  echo
  echo "[$count/${#scripts[@]}] Running $name"
  "$script"
done

if [[ "$count" -eq 0 ]]; then
  echo "error: filter matched no scripts: $FILTER" >&2
  exit 1
fi

echo
echo "Built $count web game bundle(s)."
