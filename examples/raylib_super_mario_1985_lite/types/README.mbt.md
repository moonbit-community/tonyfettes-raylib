# types

Core data layer for Super Mario 1985 Lite. Contains all struct definitions,
gameplay constants, and shared utility functions used across every other package.

## Structs

| Type | Purpose |
|------|---------|
| `Input` | Per-frame input snapshot: movement, jump, accept, restart |
| `Player` | Player state: position, velocity, lives, coins, score, flag sequence |
| `Enemy` | Goomba with position, velocity, squash state |
| `Coin` | Collectible with position and bob animation phase |
| `Particle` | Visual effect with velocity, lifetime, size, color |
| `Game` | Root game state: tile map, entities, timers, camera, game state |

### Input

Immutable snapshot of player input for one frame. Created by `read_input()` in
the root package and threaded through `update_game`. Fields:

- `move_left` / `move_right` -- horizontal movement (held)
- `jump_pressed` -- jump initiation (edge-triggered, one frame)
- `jump_held` -- variable-height jump (held down)
- `accept` -- start game from title screen
- `restart` -- restart after win or game over

`Input::none()` returns a zero-input struct, useful for tests and non-interactive
frames.

### Game

Central state container. Holds the tile map as a flat `Array[Int]` indexed by
`ty * world_tiles_w + tx`, plus fixed-size pools for enemies (56), coins (256),
and particles (720). Game state is one of `state_title`, `state_playing`,
`state_win`, or `state_game_over`.

## Constants

Gameplay constants are exported as `pub let` values in `constants.mbt`:

- **Screen**: `screen_width` (1280), `screen_height` (720), `hud_height` (84)
- **Tile map**: `tile_size` (32), `world_tiles_w` (236), `world_tiles_h` (22)
- **Tile types**: `tile_empty` through `tile_castle` (0--7)
- **Game states**: `state_title`, `state_playing`, `state_win`, `state_game_over`
- **Player physics**: `gravity`, `jump_speed`, `max_run_speed`, `coyote_time`, etc.
- **Enemy**: `enemy_speed` (88), `enemy_w`/`enemy_h`
- **Pool limits**: `max_enemies` (56), `max_coins` (256), `max_particles` (720)
- **Scoring**: `coin_collect_score` (200), `stomp_score` (400), `block_hit_score` (50)

## Utilities

Shared helpers in `utils.mbt` used by multiple packages:

- **Math**: `absf`, `clampf`, `clampi`, `signf`, `randf`
- **Tile ops**: `get_tile`, `set_tile`, `fill_rect_tile`, `clear_tiles`, `tile_index`
- **Coordinate conversion**: `world_to_tile_x`, `world_to_tile_y`, `tile_left`, `tile_top`, `tile_center_x`, `tile_center_y`, `world_to_screen_x`
- **Collision**: `rects_overlap`, `tile_is_solid`
- **Entity size**: `player_half_w`, `player_half_h`, `enemy_half_w`, `enemy_half_h`
- **Query**: `remaining_coins`, `active_enemy_count`

## Tests

`utils_test.mbt` contains 27 unit tests covering `tile_is_solid`, `rects_overlap`,
`clampf`, `clampi`, `world_to_tile_x`, and `world_to_tile_y`.
