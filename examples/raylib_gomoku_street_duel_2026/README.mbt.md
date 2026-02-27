# raylib_gomoku_street_duel_2026

A Gomoku (Five-in-a-Row) board game with AI opponent on a 15x15 grid. Features cursor-based movement, move history, undo support, AI hint system, and win/draw detection with particle effects.

## Build and Run

```bash
cd examples && moon build --target native raylib_gomoku_street_duel_2026/
cd examples && ./_build/native/debug/build/raylib_gomoku_street_duel_2026/raylib_gomoku_street_duel_2026.exe
```

## Controls

- **WASD / Arrow keys**: Move cursor on the board
- **J/Space/Enter**: Place stone
- **K**: Request AI hint (limited uses)
- **U**: Undo last move pair
- **R**: Restart
- **Mouse click**: Place stone directly (touch/click support)

## How to Play

- Place black stones on the 15x15 board; the AI plays white
- First to get 5 stones in a row (horizontal, vertical, or diagonal) wins
- Use the hint system (limited to 4 per game) for suggested moves
- Move history is tracked; undo removes your last move and the AI's response
- Win/loss/draw stats are tracked across games
