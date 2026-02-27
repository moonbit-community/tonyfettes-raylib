# raylib_rhythm_street_beats_2026

A 4-lane rhythm game with procedurally generated note charts. Hit notes as they cross the judgment line, hold long notes, build combo chains, and activate Fever mode for bonus multipliers.

## Build and Run

```bash
cd examples && moon build --target native raylib_rhythm_street_beats_2026/
cd examples && ./_build/native/debug/build/raylib_rhythm_street_beats_2026/raylib_rhythm_street_beats_2026.exe
```

## Controls

- **D / F / J / K** (or **Arrow Keys**): Hit notes in lanes 1-4
- **Space**: Activate Fever mode (when meter is full)
- **Enter**: Start game / return to menu
- **R**: Replay from results screen
- **F11**: Toggle fullscreen

## How to Play

Notes scroll down four lanes toward a yellow judgment line. Press the matching lane key when a note reaches the line. Timing determines the grade: Perfect, Great, or Good. Hold notes require keeping the key pressed until the note ends. Build a combo to increase your score multiplier. Fill the Fever meter to 100% and press Space for a temporary score boost. The life bar drains on misses -- if it empties, the track fails. Final grades range from C to SS based on accuracy.
