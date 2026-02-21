# From-Scratch Game Slate (No Tank Core Reuse)

Rules for this slate:
- Each game has its own gameplay state model and update loop.
- No shared gameplay-core files copied between games.
- Shared usage is limited to raylib bindings and generic helpers.

Current retained distinct games:
- `examples/raylib_tank_1990`
- `examples/raylib_fighter_97_lite`

New from-scratch candidates:

1. `raylib_tetris_meteor_fall_2026` — Falling-block puzzle with hold/next and speed scaling (`~2k-4k` LOC)
2. `raylib_pac_dash_2026` — Maze chase with ghost state machine and fruit bonus (`~2k-4k` LOC)
3. `raylib_asteroid_salvage_2026` — Inertia shooter with asteroid fragmentation (`~2k-4k` LOC)
4. `raylib_pinball_workshop_2026` — Physics-lite pinball table (`~3k-5k` LOC)
5. `raylib_breakout_lab_2026` — Brick breaker with modifiers and boss waves (`~2k-4k` LOC)
6. `raylib_bomber_grid_2026` — Grid bombing tactics with chain explosions (`~3k-5k` LOC)
7. `raylib_rogue_dungeon_2026` — Turn-based dungeon crawler (`~4k-7k` LOC)
8. `raylib_tower_defense_frontier_2026` — Lane/path tower defense (`~4k-7k` LOC)
9. `raylib_space_trader_2026` — Trade/combat sim loop (`~4k-8k` LOC)
10. `raylib_city_builder_mini_2026` — Tile city sim with budget loop (`~5k-9k` LOC)
11. `raylib_platformer_precision_2026` — Precision platformer with checkpoints (`~3k-6k` LOC)
12. `raylib_card_duel_2026` — Deck battler with energy/turn logic (`~4k-8k` LOC)
13. `raylib_auto_chess_micro_2026` — Board auto-battle loop (`~5k-9k` LOC)
14. `raylib_topdown_survivor_2026` — Horde survival with upgrades (`~3k-6k` LOC)
15. `raylib_rts_skirmish_2026` — Small-scale RTS with harvest/build/fight (`~6k-12k` LOC)

Execution status:
- Completed: 1, 2, 3
- Planned next: 4, 5, 6
