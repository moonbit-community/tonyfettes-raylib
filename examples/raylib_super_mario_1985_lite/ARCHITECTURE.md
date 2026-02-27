# Super Mario 1985 Lite

A side-scrolling platformer inspired by the original Super Mario Bros., built
with MoonBit and raylib. All graphics are drawn procedurally from rectangles,
circles, and triangles -- no texture assets required.

## How to play

### Build & run

```bash
cd examples
moon build --target native raylib_super_mario_1985_lite/
_build/native/debug/build/raylib_super_mario_1985_lite/raylib_super_mario_1985_lite.exe
```

### Controls

| Action         | Keys                          |
|----------------|-------------------------------|
| Move left      | A or Left arrow               |
| Move right     | D or Right arrow              |
| Jump           | W, Up arrow, or Space         |
| Start game     | Enter or Space (title screen) |
| Restart        | Enter, Space, or R (after win/game over) |

### Objective

Run right through World 1-1 before the 400-second timer expires. Stomp goombas
by jumping on them from above. Smash brick blocks and hit question blocks from
below to earn coins and points. Reach the flagpole at the end of the level, then
walk to the castle to clear the stage.

### Scoring

| Event              | Points |
|--------------------|--------|
| Collect a coin     | 200    |
| Stomp an enemy     | 400    |
| Hit a block        | 50     |
| Clear the stage    | 1000 + time_left * 5 |

You start with 3 lives. Taking damage costs one life and 5 coins. Falling into a
pit or running out of time also costs a life. At zero lives the game is over.

### Tips

- Tap jump briefly for short hops, hold for full-height jumps (variable jump).
- You can still jump for a split second after walking off a ledge (coyote time).
- After taking damage you get 1.3 seconds of invulnerability -- use it to run
  past enemies.
- Hit question blocks from below to get bonus coins.

## Architecture

### Package layout

```
raylib_super_mario_1985_lite/
├── main.mbt              Entry point: window, main loop, read_input()
├── moon.pkg              Root package (is-main)
├── ARCHITECTURE.md        This file
│
├── types/                Data layer
│   ├── types.mbt         Input, Player, Enemy, Coin, Particle, Game structs
│   ├── constants.mbt     51 gameplay tuning constants
│   ├── utils.mbt         Tile ops, math, collision helpers
│   └── utils_test.mbt    27 unit tests
│
├── game/                 Logic layer
│   ├── game_update.mbt   State machine, camera, timer
│   ├── player_system.mbt Player physics, collision, flag sequence
│   ├── enemy_system.mbt  Enemy AI, stomp/hurt detection
│   ├── coin_system.mbt   Coin collection
│   ├── level.mbt         Level builder, entity spawner, reset
│   └── game_test.mbt     10 simulation tests
│
├── particles/            Effects layer
│   └── particles.mbt     Pool allocator + 4 burst spawners + update loop
│
└── render/               Presentation layer
    ├── render_world.mbt  Background, tiles, entities, particles
    └── render_ui.mbt     HUD, title/win/game-over overlays
```

Each sub-package has its own `README.mbt.md` with detailed API documentation.

### Data flow

```
main loop (60 fps)
  │
  ├─ read_input()              Snapshot raylib key state → Input struct
  │
  ├─ update_game(game, input, dt)
  │     ├─ title:     update particles; input.accept → start
  │     ├─ playing:   timer → player → enemies → coins → particles → camera
  │     └─ win/over:  update particles; input.restart → reset
  │
  ├─ draw_world(game)          Tiles, entities, effects (with screen shake)
  └─ draw_ui(game)             HUD bar + state overlay panel
```

### Key design decisions

- **Input decoupling** -- Game logic receives an `Input` struct instead of
  calling raylib directly. This enables simulation tests without a window.
- **Mutable structs** -- All game state is updated in-place each frame for
  simplicity and performance.
- **Pool allocation** -- Enemies, coins, and particles use pre-allocated
  fixed-size arrays with `active` flags rather than dynamic allocation.
- **Tile-grid physics** -- Collision resolution sweeps X then Y independently
  against the tile map, checking only nearby columns/rows.
- **Responsive jumping** -- Coyote time (0.09 s after leaving ground) and jump
  buffering (0.11 s before landing) make controls feel tight.
- **Procedural art** -- All sprites and tiles are rendered from colored
  rectangles, circles, and triangles. No external assets needed.

### Testing

All tests run without a raylib window:

```bash
cd examples
moon test --target native \
  -p tonyfettes/raylib-examples/raylib_super_mario_1985_lite/types \
  -p tonyfettes/raylib-examples/raylib_super_mario_1985_lite/game
```

| Suite | File | Tests | Coverage |
|-------|------|-------|----------|
| Unit tests | `types/utils_test.mbt` | 27 | `tile_is_solid`, `rects_overlap`, `clampf`, `clampi`, coordinate conversions |
| Simulation | `game/game_test.mbt` | 10 | Gravity, landing, jump, coins, stomp, hurt, invuln regression, flag, timer |
