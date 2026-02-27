# raylib_museum_heist_puzzle_2026

A turn-based stealth puzzle game where you navigate a thief through museum floors, avoiding guard patrols and security to collect artifacts and reach the exit.

## Build and Run

```bash
cd examples && moon build --target native raylib_museum_heist_puzzle_2026/
cd examples && ./_build/native/debug/build/raylib_museum_heist_puzzle_2026/raylib_museum_heist_puzzle_2026.exe
```

## Controls

- **Mouse / Touch**: Move player by clicking directional areas, interact with UI buttons

## How to Play

- Move your thief tile-by-tile through the museum grid
- Collect all artifacts scattered across the floor
- Avoid guard patrol routes -- guards follow predefined paths and have a view range
- Reach the exit after collecting all artifacts to complete the level
- Progress through 3 increasingly challenging levels with different layouts
- Getting spotted by a guard triggers an alarm and ends the heist
