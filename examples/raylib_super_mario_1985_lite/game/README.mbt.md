# game

Core gameplay systems for Super Mario 1985 Lite. This package contains all
tightly-coupled game logic that forms the main gameplay loop.

## Public API

| Function | Purpose |
|----------|---------|
| `init_game(game)` | Build level geometry, spawn entities, set title state |
| `update_game(game, input, dt)` | Main update: dispatches to state handler (title, playing, win, game over) |

`update_game` accepts an `Input` struct rather than reading raylib keys
directly, which allows the game logic to be tested without a window.

## Internal Systems

| File | Responsibility |
|------|---------------|
| `game_update.mbt` | State machine, camera follow, level timer, top-level dispatch |
| `player_system.mbt` | Player physics, collision resolution, jump buffering, flag sequence, hurt/death |
| `enemy_system.mbt` | Enemy gravity, wall/cliff AI, stomp detection, player-enemy collision |
| `coin_system.mbt` | Coin bob animation, player-coin overlap collection |
| `level.mbt` | Hardcoded level layout (ground, gaps, pipes, platforms, flag, castle), entity spawning, reset logic |

These systems are package-private and communicate through shared `Game` state.
They are kept in one package because subsystems are tightly coupled (e.g.
enemy collision triggers player hurt which triggers particle effects).

### Player physics

Movement uses acceleration/friction with separate ground and air rates.
Jumping uses a buffer (`jump_buf_t`) so presses within 0.11 s before landing
still count, and coyote time (`coyote_t`) allows jumping within 0.09 s after
leaving a ledge. Releasing the jump key early cuts vertical velocity for
variable-height jumps. Collision resolution sweeps X then Y independently
against the tile grid.

### Enemy AI

Enemies walk in one direction, reverse when hitting a wall, and reverse before
walking off a cliff edge. Player stomps (falling onto an enemy from above with
`vy > 110`) squash the enemy and bounce the player. Side collisions hurt the
player unless invulnerable.

### Level layout

`build_level_geometry` creates the full level procedurally from hardcoded tile
operations: ground fill, five gaps, seven pipes, six brick/question-block
platforms, a staircase, a flag pole, and a castle. `populate_level_entities`
spawns 13 enemies and ~50 coins at fixed positions.

## Tests

`game_test.mbt` contains 10 simulation tests that construct `Game` state
manually, feed synthetic `Input`, and assert outcomes:

- Gravity, ground collision, jump impulse
- Coin collection, enemy stomp, enemy hurt
- Invulnerability pit-fall regression, two-enemy stomp regression
- Flag trigger, timer expiry game-over
