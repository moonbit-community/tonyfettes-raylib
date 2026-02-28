# Naval Combat 3D

A 3D naval warfare game with wind-based sailing, broadside cannon battles, and tactical ship combat across an archipelago.

## How to Play

Command your ship in broadside cannon battles. Manage wind, sails, and crew while fighting enemy fleets. Use different ammo types for different effects: round shot for hull damage, chain shot for masts, grapeshot for crew.

## Controls

| Key | Action |
|-----|--------|
| W/S | Raise/Lower sails |
| A/D | Steer left/right |
| Space | Fire broadside (port/starboard auto-selected) |
| 1-4 | Select ammo type |
| R | Repair hull |
| F | Toggle sail state |
| B | Boarding action (when adjacent) |
| Tab | Cycle targets |
| M | Toggle minimap |
| Escape | Pause / Back |

## Build & Run

```bash
moon -C examples build --target native raylib_naval_combat_3d/
moon -C examples run --target native raylib_naval_combat_3d/
```
