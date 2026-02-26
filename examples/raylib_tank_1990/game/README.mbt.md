# game

Core gameplay systems for Tank 1990. This package contains all
tightly-coupled game logic that forms the main gameplay loop.

The only public entry point is `update_game(game, dt)`, which dispatches
to the appropriate state handler (menu, stage intro, playing, paused,
stage clear, game over, campaign clear).

## Internal Systems

| File | Responsibility |
|------|---------------|
| `player_system.mbt` | Player input, movement, ice physics, firing, respawning |
| `enemy_system.mbt` | Enemy AI, spawning, targeting, destruction |
| `bullet_system.mbt` | Bullet allocation, physics, collision resolution |
| `powerups.mbt` | Powerup spawning, collection, effect application |
| `stage.mbt` | Stage loading, base ring protection, campaign flow |
| `demo_ai.mbt` | Autonomous demo-mode AI for attract screen |
| `game_update.mbt` | State machine, starfield update, tile damage |

These systems are package-private and communicate through shared `Game`
state. They were kept in one package to avoid circular dependencies
between subsystems (e.g. bullet hits trigger enemy destruction which
spawns powerups which affect players).
