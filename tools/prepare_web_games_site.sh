#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB_ROOT="${1:-$ROOT_DIR/_build/web}"
OUT_DIR="${2:-$ROOT_DIR/_build/web_pages_site}"

if [[ ! -d "$WEB_ROOT" ]]; then
  echo "error: web build directory not found: $WEB_ROOT" >&2
  echo "hint: run one or more tools/build_web_*.sh scripts first" >&2
  exit 1
fi

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR/games"

declare -a GAME_IDS=()
declare -a GAME_URLS=()

while IFS= read -r bundle_dir; do
  bundle="$(basename "$bundle_dir")"

  # Publish only canonical game bundles. Debug/prototype folders can remain in
  # _build/web for local experiments but should not appear in public index/site.
  if [[ "$bundle" != raylib_* ]]; then
    continue
  fi

  if [[ -f "$bundle_dir/$bundle.html" ]]; then
    entry_html="$bundle.html"
  else
    entry_html="$(find "$bundle_dir" -maxdepth 1 -type f -name '*.html' -print | sort | head -n 1 | xargs -I{} basename "{}")"
  fi

  if [[ -z "$entry_html" ]]; then
    echo "warning: skipping bundle without html entrypoint: $bundle" >&2
    continue
  fi

  game_dir="$OUT_DIR/games/$bundle"
  mkdir -p "$game_dir"

  while IFS= read -r -d '' artifact; do
    cp "$artifact" "$game_dir/"
  done < <(find "$bundle_dir" -maxdepth 1 -type f \( -name '*.html' -o -name '*.js' -o -name '*.wasm' \) -print0 | sort -z)

  GAME_IDS+=("$bundle")
  GAME_URLS+=("games/$bundle/$entry_html")
done < <(find "$WEB_ROOT" -mindepth 1 -maxdepth 1 -type d | sort)

count="${#GAME_IDS[@]}"
if [[ "$count" -eq 0 ]]; then
  echo "error: no web game bundles found under $WEB_ROOT" >&2
  exit 1
fi

{
  echo "# Raylib MoonBit Web Games"
  echo
  echo "Total games: $count"
  echo
  for i in "${!GAME_IDS[@]}"; do
    echo "- [${GAME_IDS[$i]}](${GAME_URLS[$i]})"
  done
} > "$OUT_DIR/GAME_LIST.md"

{
  cat <<'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Raylib MoonBit Web Games</title>
  <style>
    :root {
      --bg: #0b1220;
      --panel: #111b30;
      --card: #1a2640;
      --text: #e7edf7;
      --muted: #9fb1cb;
      --accent: #4da3ff;
      --border: #2c3d61;
    }

    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      background: radial-gradient(circle at top, #16264a 0%, var(--bg) 45%);
      color: var(--text);
      font-family: "Trebuchet MS", "Segoe UI", Tahoma, sans-serif;
      min-height: 100vh;
    }

    main {
      max-width: 1100px;
      margin: 0 auto;
      padding: 24px 16px 48px;
    }

    .hero {
      background: linear-gradient(135deg, #152240 0%, #1d3258 100%);
      border: 1px solid var(--border);
      border-radius: 14px;
      padding: 18px;
      margin-bottom: 18px;
    }

    h1 {
      margin: 0;
      font-size: 30px;
      letter-spacing: 0.2px;
    }

    .summary {
      margin-top: 8px;
      color: var(--muted);
      font-size: 15px;
    }

    .filters {
      margin-top: 14px;
    }

    .controls-guide {
      margin-top: 12px;
      border: 1px solid var(--border);
      border-radius: 10px;
      background: #0f1933;
      padding: 10px 12px;
    }

    .controls-guide-title {
      font-size: 14px;
      color: var(--text);
      font-weight: 700;
      margin-bottom: 8px;
    }

    .controls-guide-grid {
      display: grid;
      gap: 6px 10px;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      color: var(--muted);
      font-size: 13px;
    }

    .controls-guide-grid code {
      color: #d6e8ff;
      font-family: "Cascadia Mono", "Consolas", "Menlo", monospace;
      background: #132146;
      border-radius: 6px;
      padding: 1px 5px;
    }

    .filters input {
      width: 100%;
      background: #0f1830;
      border: 1px solid var(--border);
      border-radius: 10px;
      color: var(--text);
      padding: 11px 13px;
      font-size: 14px;
      outline: none;
    }

    .filters input:focus {
      border-color: var(--accent);
      box-shadow: 0 0 0 2px #4da3ff33;
    }

    .games {
      display: grid;
      gap: 10px;
      grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    }

    .game-card {
      display: flex;
      align-items: center;
      justify-content: space-between;
      text-decoration: none;
      color: var(--text);
      background: linear-gradient(160deg, #182746 0%, var(--card) 100%);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 12px 13px;
      transition: transform 0.15s ease, border-color 0.15s ease;
    }

    .game-card:hover {
      transform: translateY(-2px);
      border-color: #4d7ac4;
    }

    .game-id {
      font-size: 14px;
      line-height: 1.3;
      word-break: break-word;
      margin-right: 10px;
    }

    .play {
      color: var(--accent);
      font-size: 13px;
      white-space: nowrap;
    }

    footer {
      margin-top: 20px;
      color: var(--muted);
      font-size: 13px;
    }
  </style>
</head>
<body>
  <main>
    <section class="hero">
      <h1>Raylib MoonBit Web Games</h1>
      <div class="summary">
        Lightweight playable builds generated from MoonBit native C output and compiled with Emscripten.
      </div>
      <div class="filters">
        <input id="search" type="search" placeholder="Filter games (e.g. tank, kof, diablo)" />
      </div>
      <div class="controls-guide">
        <div class="controls-guide-title">Mobile Touch Mapping</div>
        <div class="controls-guide-grid">
          <div><code>D-pad</code> => <code>W/A/S/D</code> + <code>Arrow Keys</code></div>
          <div><code>A</code> => <code>J</code> + <code>Space</code></div>
          <div><code>B</code> => <code>K</code> + <code>Enter</code></div>
          <div><code>C</code> => <code>L</code> + <code>Shift</code></div>
          <div><code>II</code> => <code>Esc</code> (menu/pause)</div>
        </div>
      </div>
    </section>

    <section class="games" id="games">
EOF

  for i in "${!GAME_IDS[@]}"; do
    printf '      <a class="game-card" href="%s" data-id="%s">\n' "${GAME_URLS[$i]}" "${GAME_IDS[$i]}"
    printf '        <span class="game-id">%s</span>\n' "${GAME_IDS[$i]}"
    echo '        <span class="play">Play</span>'
    echo '      </a>'
  done

  cat <<'EOF'
    </section>

    <footer>
      Tip: bookmark any game URL to open it directly.
    </footer>
  </main>

  <script>
    const search = document.getElementById("search");
    const cards = Array.from(document.querySelectorAll(".game-card"));
    search.addEventListener("input", () => {
      const q = search.value.trim().toLowerCase();
      for (const card of cards) {
        const id = (card.dataset.id || "").toLowerCase();
        card.style.display = q === "" || id.includes(q) ? "flex" : "none";
      }
    });
  </script>
</body>
</html>
EOF
} > "$OUT_DIR/index.html"

touch "$OUT_DIR/.nojekyll"

{
  echo "# raylib-moonbit-web-games"
  echo
  echo "Generated static site for MoonBit + raylib web builds."
  echo
  echo "- Total games: $count"
  echo "- Entry page: \`index.html\`"
  echo "- Full list: \`GAME_LIST.md\`"
} > "$OUT_DIR/README.md"

echo "$count" > "$OUT_DIR/.bundle_count"
echo "Prepared web site with $count games at: $OUT_DIR"
