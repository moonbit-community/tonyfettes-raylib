# Powerline Repair Patrol 2026

A top-down patrol game where you pilot a repair craft across a power grid, responding to faults on transmission towers before their deadlines expire. Collect wire and fuse supplies from depots, navigate wind tunnels and storm cells, and repair faults of varying severity.

## Build and Run

```bash
cd examples && moon build --target native raylib_powerline_repair_patrol_2026/
cd examples && ./_build/native/debug/build/raylib_powerline_repair_patrol_2026/raylib_powerline_repair_patrol_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Steer the patrol craft
- **Space / E / J**: Action -- repair a fault when near a damaged tower, or collect supplies at a depot/substation
- **Shift**: Boost (consumes battery faster, generates heat)
- **H**: Use a hint
- **R**: Restart
- **Escape**: Return to title
- **Mouse / Touch**: On-screen D-pad and action buttons

## How to Play

Faults appear on towers across the grid, each with a severity level, deadline timer, and resource requirements (wire and/or fuses). Fly to the depot to stock up on supplies, then navigate to damaged towers and press the action key to repair them before their deadlines expire. Wind tunnels push your craft off course, and storm cells deal hull damage and drain battery. Manage your battery, hull integrity, and supply inventory as faults escalate in difficulty over time.
