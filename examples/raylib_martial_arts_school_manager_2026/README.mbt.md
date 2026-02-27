# Martial Arts School Manager 2026

A real-time management simulation where you run a martial arts school. Assign 6 students to rooms (Rest, Train, Spar, Defense) each week, balancing skill growth, fatigue, funds, and reputation to survive as many weeks as possible.

## Build and Run

```bash
cd examples && moon build --target native raylib_martial_arts_school_manager_2026/
cd examples && ./_build/native/debug/build/raylib_martial_arts_school_manager_2026/raylib_martial_arts_school_manager_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move cursor across student/room grid
- **J or Space**: Confirm assignment
- **K**: Cancel / dismiss
- **L**: Speed burst (temporarily speeds up time, cooldown)
- **P**: Pause
- **R**: Restart
- **F11**: Toggle borderless windowed

## How to Play

Each week runs in real time. Assign students to rooms: Rest recovers fatigue, Train builds skill (costs funds), Spar earns income and reputation, and Defense provides a stipend. Students accumulate fatigue in active rooms and lose effectiveness if overworked. Random incidents occur that require students on defense duty. Manage weekly upkeep costs that increase over time. The game ends if funds or reputation hit zero. Survive as many weeks as possible.
