# types

Core data layer for Tank 1990. Contains all struct definitions, gameplay
constants, and shared utility functions used across every other package.

## Structs

| Type | Purpose |
|------|---------|
| `Game` | Root game state: map, entities, timers, scores |
| `Tank` | Player or enemy tank with position, HP, AI timers |
| `Bullet` | Projectile with velocity, TTL, damage |
| `Particle` | Visual effect (sparks, explosions) |
| `Powerup` | Collectible item with kind, position, TTL |
| `Star` | Background star for parallax starfield |
| `StageProfile` | Per-stage theming: title, colors, difficulty modifiers |

## Constants

Gameplay constants are exported as `pub let` values covering screen
dimensions, tile types, directions, entity limits, spawn positions,
speeds, and timing values.

## Utilities

Shared helpers used by multiple packages:

- **Math**: `absf`, `clampf`, `clampi`
- **RNG**: `rand_next`, `rand_range`, `rand_rangef`
- **Tile ops**: `get_tile`, `set_tile`, `tile_index`, coordinate conversions
- **Collision**: `rects_overlap`, `tank_rect`, `is_tile_solid_for_tank`
- **Rendering**: `draw_centered_text`, `draw_shadow_text`, `pulse_color`
- **Lookup tables**: `enemy_score`, `enemy_color`, `powerup_color`, etc.
