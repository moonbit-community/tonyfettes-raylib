# particles

Particle effects system for Super Mario 1985 Lite. Manages a fixed-size pool
of 720 particles and provides high-level burst spawners for game events.

## Public Functions

| Function | Purpose |
|----------|---------|
| `clear_particles(game)` | Deactivate all particles (called on level reset) |
| `update_particles(game, dt)` | Tick all active particles: apply gravity (420 px/s^2), move, fade, deactivate expired |
| `spawn_coin_burst(game, x, y)` | 10 gold particles radiating outward (coin collected) |
| `spawn_block_burst(game, x, y, color)` | 12 particles in given color (brick broken or question block hit) |
| `spawn_stomp_burst(game, x, y)` | 15 brown particles biased upward (enemy stomped) |
| `spawn_hurt_burst(game, x, y)` | 18 red particles biased upward (player hurt) |

## Design

Particles are stored in a pre-allocated `Array[Particle]` on `Game` with an
`active` flag on each slot. `alloc_particle` scans for the first inactive slot;
if the pool is full, the spawn is silently dropped. Each particle has position,
velocity, lifetime, max lifetime, size, and color. Rendering (in the `render`
package) fades alpha based on `life / max_life` and shrinks size proportionally.
