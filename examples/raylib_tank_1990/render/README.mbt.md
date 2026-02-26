# render

Rendering layer for Tank 1990. Reads game state and draws everything to
screen. Never mutates game logic.

## Public Functions

| Function | Purpose |
|----------|---------|
| `draw_world` | Draw starfield, terrain, tanks, bullets, particles, powerups, fog |
| `draw_ui` | Draw side panel, player cards, and state overlays (menu, pause, etc.) |

## Files

- `render_world.mbt` -- World-space rendering: background, tiles, entities, effects
- `render_ui.mbt` -- Screen-space UI: enemy counter, player cards, overlays for
  menu, stage intro, pause, stage clear, game over, and campaign clear screens
