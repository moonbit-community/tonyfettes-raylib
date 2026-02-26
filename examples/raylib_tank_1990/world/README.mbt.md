# world

Collision detection and world-space geometry queries for Tank 1990.

All functions are pure queries against the game state -- they read tile data
and entity positions but never mutate the game world.

## Functions

| Function | Purpose |
|----------|---------|
| `point_in_world` | Check if a world-space point is inside the playfield |
| `tank_hits_world` | Test if a tank at (x, y) collides with any solid tile |
| `tank_hits_players` | Test tank-vs-player collision, returns player index or -1 |
| `tank_hits_enemies` | Test tank-vs-enemy collision, returns enemy index or -1 |
| `sight_blocked` | Ray-cast along a direction to check for obstacles |
