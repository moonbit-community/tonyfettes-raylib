# Web Games GitHub Pages Automation

This repository can publish generated web game bundles to:

- Target static site repo: `bobzhang/raylib-moonbit-web-games`
- Hosted URL: `https://bobzhang.github.io/raylib-moonbit-web-games/`

## What Is Automated

On every push (and manual dispatch), workflow:

1. Installs MoonBit and Emscripten.
2. Builds all web games via `tools/build_all_web_games.sh`.
3. Packages web output into a navigable static site via `tools/prepare_web_games_site.sh`.
4. Pushes refreshed static files to `bobzhang/raylib-moonbit-web-games`.

Workflow file:

- `.github/workflows/publish-web-games-pages.yml`

## Required Secret

Set this secret in this source repository:

- `WEB_GAMES_PUBLISH_TOKEN`: GitHub token with write access to `bobzhang/raylib-moonbit-web-games`.

Example (using authenticated `gh` CLI):

```bash
gh auth token | gh secret set WEB_GAMES_PUBLISH_TOKEN --repo moonbit-community/tonyfettes-raylib
```

## Local Manual Run

```bash
tools/build_all_web_games.sh
tools/prepare_web_games_site.sh _build/web _build/web_pages_site
```

Generated outputs:

- `_build/web_pages_site/index.html`
- `_build/web_pages_site/GAME_LIST.md`
- `_build/web_pages_site/games/<game_id>/<game_id>.html`
