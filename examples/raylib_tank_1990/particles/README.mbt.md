# particles

Particle effects system for Tank 1990. Manages a fixed-size pool of
particles and provides high-level effect spawners.

## Functions

| Function | Purpose |
|----------|---------|
| `spawn_particle` | Create a single particle with given parameters |
| `spawn_spark_burst` | Burst of small sparks (bullet impacts, tile hits) |
| `spawn_explosion` | Large explosion effect (tank/base destruction) |
| `spawn_respawn_burst` | Circular respawn shimmer effect |
| `update_particles` | Tick all active particles (move, fade, deactivate) |
