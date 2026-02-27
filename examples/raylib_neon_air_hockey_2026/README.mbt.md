# raylib_neon_air_hockey_2026

A neon-styled air hockey game for two players sharing one keyboard, with spark effects on puck collisions and goal scoring.

## Build and Run

```bash
cd examples && moon build --target native raylib_neon_air_hockey_2026/
cd examples && ./_build/native/debug/build/raylib_neon_air_hockey_2026/raylib_neon_air_hockey_2026.exe
```

## Controls

- **WASD**: Move left paddle (Player 1)
- **Space / J / K**: Strike puck (Player 1)
- **R**: Restart match

## How to Play

- Each player controls a paddle on their side of the table
- Hit the puck into the opponent's goal to score points
- The puck bounces off table walls and paddles with physics-based collisions
- Spark particles burst on contact for visual feedback
- First player to reach the score limit wins the match
