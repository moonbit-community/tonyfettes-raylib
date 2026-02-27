# raylib_volcano_airlift_2026

A helicopter rescue game across 3 sectors of erupting volcano terrain. Fly a helicopter to pick up stranded survivors and deliver them to base before rising lava and ash clouds destroy everything.

## Build and Run

```bash
cd examples && moon build --target native raylib_volcano_airlift_2026/
cd examples && ./_build/native/debug/build/raylib_volcano_airlift_2026/raylib_volcano_airlift_2026.exe
```

## Controls

- **A/D or Left/Right**: Steer helicopter
- **W or Up**: Lift (consumes fuel)
- **S or Down**: Descend
- **Space/J**: Pick up or drop off survivor
- **R**: Restart from sector 1
- Touch controls available via on-screen buttons

## How to Play

- Fly to survivors on the terrain and press action to pick them up one at a time
- Deliver survivors to the BASE pad to score rescue points
- Lava rises from below, consuming survivors it reaches
- Ash clouds damage your hull on contact; avoid hard landings
- Meet the rescue quota for each sector to advance; clear all 3 sectors to win
- Stars are awarded based on how few survivors are lost per sector
