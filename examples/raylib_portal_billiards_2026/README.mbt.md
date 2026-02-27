# Portal Billiards 2026

A billiards game with a twist -- four moving portals on the table teleport balls that pass through them. Clear all target balls using limited shots across three increasingly difficult levels.

## Build and Run

```bash
cd examples && moon build --target native raylib_portal_billiards_2026/
cd examples && ./_build/native/debug/build/raylib_portal_billiards_2026/raylib_portal_billiards_2026.exe
```

## Controls

- **Mouse**: Aim the cue ball (move cursor over the table)
- **W/S or Up/Down Arrow Keys**: Adjust shot power
- **Space / J**: Shoot the cue ball
- **R**: Restart from level 1
- **Mouse / Touch**: On-screen POW+/POW- buttons and SHOOT button

## How to Play

Aim and shoot the white cue ball to pocket the colored target balls into the six corner and side pockets. Two pairs of portals drift across the table -- balls entering one portal exit from its partner with slightly increased speed. Each level gives you a limited number of shots; pocketing the cue ball (scratch) costs one shot and respawns it. Clear all targets to advance. Unused shots carry bonus points. Complete all three levels to become the Table Master.
