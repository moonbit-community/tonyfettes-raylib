# render

Rendering layer for Super Mario 1985 Lite. Reads game state and draws
everything to screen. Never mutates game logic.

## Public Functions

| Function | Purpose |
|----------|---------|
| `draw_world(game)` | Draw background, tiles, flag, coins, enemies, player, particles (with screen shake) |
| `draw_ui(game)` | Draw HUD bar and state overlays (title, win, game over) |

## Files

- `render_world.mbt` -- World-space rendering: sky gradient with parallax clouds
  and trees, tile grid (culled to visible range), flag pole with animated flag,
  spinning coins, goomba sprites (normal and squashed), Mario sprite (rectangle
  art with facing indicator, invulnerability flashing), particles with fade-out
- `render_ui.mbt` -- Screen-space UI: dark HUD bar at top showing score, coins,
  lives, timer, and remaining enemy/coin counts; centered modal panels for
  title screen (controls help), win screen (final score), and game-over screen

## Rendering details

All world objects are converted from world coordinates to screen coordinates
using `world_to_screen_x` (camera offset) and `world_to_screen_y` (HUD offset
plus shake). Screen shake generates random offsets when `game.shake_t > 0`,
applied to camera X and all Y positions.

Tile rendering uses custom rectangle art for each tile type:
- **Ground**: brown with green grass cap on exposed tops
- **Brick**: brown with mortar grid lines
- **Question**: pulsing gold/yellow with "?" text
- **Used**: flat gray (spent question block)
- **Pipe**: green with lighter top rim and dark outline
- **Castle**: gray with window details

Player and enemy sprites are composed from colored rectangles and circles
rather than loaded textures.
