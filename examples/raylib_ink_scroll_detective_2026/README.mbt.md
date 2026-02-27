# Ink Scroll Detective 2026

A deduction and investigation game set in an ink-wash city. Navigate a 10x6 grid of districts, discover clues linked to four suspects, resolve timed incidents, and build evidence chains to unmask the culprit.

## Build and Run

```bash
cd examples && moon build --target native raylib_ink_scroll_detective_2026/
cd examples && ./_build/native/debug/build/raylib_ink_scroll_detective_2026/raylib_ink_scroll_detective_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move cursor between city districts
- **J or Space**: Inspect current district (discover clues / resolve incidents)
- **K**: Cancel / mark suspect
- **L**: Focus mode (reveals hidden clues nearby, cooldown)
- **P**: Pause
- **R**: Restart case
- **F11**: Toggle borderless windowed

## How to Play

Explore city districts to find clues scattered across the map. Each clue belongs to one of four suspects and forms part of an evidence chain. Complete chains to unlock deduction milestones that raise suspicion levels. Timed incidents spawn across the city -- reach and resolve them before they expire to maintain public trust. Wrong accusations cost trust heavily. Manage the 210-second case timer and keep trust above zero to solve the case.
