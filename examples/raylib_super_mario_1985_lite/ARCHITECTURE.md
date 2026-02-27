# Super Mario 1985 Lite — Architecture

## Package layout

```
raylib_super_mario_1985_lite/
├── main.mbt            # Entry point: window, main loop, read_input()
├── moon.pkg            # Root package (is-main), imports game/render/types/raylib
├── types/
│   ├── moon.pkg        # Imports core/math, tonyfettes/raylib
│   ├── types.mbt       # Input, Player, Enemy, Coin, Particle, Game structs
│   ├── constants.mbt   # All gameplay tuning constants
│   └── utils.mbt       # Tile helpers, math utils, collision checks
├── game/
│   ├── moon.pkg        # Imports types, particles, raylib, core/math
│   ├── game_update.mbt # update_game (pub), update_playing, tick_level_timer, update_camera
│   ├── player_system.mbt  # update_player, physics resolution, flag sequence, hurt logic
│   ├── enemy_system.mbt   # update_enemies, stomp detection, enemy AI
│   ├── coin_system.mbt    # update_coins, collection detection
│   └── level.mbt       # Level geometry builder, entity spawner, reset logic
├── particles/
│   ├── moon.pkg        # Imports types, raylib, core/math
│   └── particles.mbt   # Particle allocation, update, spawn helpers (coin/stomp/hurt/block bursts)
└── render/
    ├── moon.pkg        # Imports types, raylib, core/math
    └── render.mbt      # draw_world, draw_ui (HUD, title, game-over screens)
```

## Data flow

```
main loop
  │
  ├─ read_input()          → Input struct (raylib key state snapshot)
  │
  ├─ update_game(game, input, dt)
  │     │
  │     ├─ state_title:    particles update; input.accept → reset_full_run
  │     ├─ state_playing:  update_playing(game, input, dt)
  │     │     ├─ tick_level_timer
  │     │     ├─ update_player(game, input, dt)   ← uses input for movement/jump
  │     │     ├─ update_enemies
  │     │     ├─ update_coins
  │     │     ├─ update_particles
  │     │     └─ update_camera
  │     └─ state_win/game_over: particles update; input.restart → reset_full_run
  │
  ├─ begin_drawing / clear
  ├─ draw_world(game)      → tiles, entities, particles
  ├─ draw_ui(game)         → HUD, overlay screens
  └─ end_drawing
```

## Input decoupling

Game logic does **not** call raylib input functions directly.
All input reading happens in `read_input()` (in `main.mbt`), which produces an
`Input` struct with 6 boolean fields:

| Field          | Meaning                        | Keys                        |
|----------------|--------------------------------|-----------------------------|
| `move_left`    | Horizontal movement            | A, Left                     |
| `move_right`   | Horizontal movement            | D, Right                    |
| `jump_pressed` | Jump initiation (edge trigger) | W, Up, Space                |
| `jump_held`    | Variable-height jump (held)    | W, Up, Space                |
| `accept`       | Title screen start             | Enter, Space                |
| `restart`      | Win/game-over restart          | Enter, Space, R             |

This allows `update_game` to be called from `moon test` with synthetic `Input`
values, enabling simulation tests without a raylib window.

## Key design decisions

- **Structs are mutable** (`mut` fields) — game state is updated in-place each frame.
- **Fixed-size arrays** for enemies, coins, particles — pool allocation with `active` flags.
- **Tile map** is a flat `Array[Int]` indexed by `ty * world_tiles_w + tx`.
- **Physics** uses separate X/Y resolution passes (sweep against tile grid).
- **Coyote time + jump buffering** for responsive platformer feel.
- **Invulnerability timer** after taking damage, with position-reset on pit fall.
- **Flag sequence** is a 3-phase state machine (slide down → walk to castle → win).

## Testing

Tests live alongside their packages and run with `moon test --target native`:

- `types/utils_test.mbt` — Pure unit tests for tile helpers, math, collision.
- `game/game_test.mbt` — Simulation tests: gravity, landing, jump, coin pickup,
  enemy stomp/hurt, invulnerability regression, flag trigger, timer expiry.
  These construct `Game` + `Input` manually and call `update_game` directly.
