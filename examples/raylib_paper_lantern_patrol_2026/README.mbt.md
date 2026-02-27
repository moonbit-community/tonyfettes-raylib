# Paper Lantern Patrol 2026

A night festival escort game where you patrol the streets guiding paper lanterns to shrines before their flames go out. Protect lanterns from wind gusts, sparks, and thieves while chaining deliveries for combo bonuses.

## Build and Run

```bash
cd examples && moon build --target native raylib_paper_lantern_patrol_2026/
cd examples && ./_build/native/debug/build/raylib_paper_lantern_patrol_2026/raylib_paper_lantern_patrol_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move the patrol character
- **J**: Interact -- pick up/escort a nearby lantern, stabilize its flame, or deliver it at a shrine
- **K**: Release escorted lantern, or raise a guard stance that pushes thieves away
- **Space**: Deploy a calm-wind field (cooldown-based) that slows gusts, sparks, and thieves
- **P**: Pause
- **R**: Restart

## How to Play

Lanterns spawn at the gate on the left and must be delivered to one of four shrines on the right side of the field. Each lantern has a flame meter that constantly drains and is further reduced by wind gusts, sparks, and thief attacks. Escort a lantern by moving near it and pressing J, then guide it to its target shrine for delivery. Chain consecutive deliveries within the combo window to earn increasing bonus points. The run ends when too many lanterns are extinguished (7 total). Use the guard stance (K) to repel thieves and the calm-wind field (Space) to dampen environmental hazards in a radius around you.
