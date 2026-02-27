# Auto Chess Micro 2026

A simplified auto-chess battler where you buy and place units on a grid during a prep phase, then watch them fight automatically against an AI opponent.

## Build and Run

```bash
cd examples && moon build --target native raylib_auto_chess_micro_2026/
cd examples && ./_build/native/debug/build/raylib_auto_chess_micro_2026/raylib_auto_chess_micro_2026.exe
```

## Controls

- **1 / 2 / 3**: Buy a Tank, Archer, or Blade unit (during prep phase)
- **Enter**: Start battle
- **R**: Restart game

## How to Play

During the prep phase, spend gold to buy units (Tank, Archer, Blade) and place them on your side of the 7x5 grid. Each role has different HP, attack, and range stats. Press Enter to start the battle -- units move toward enemies and attack automatically based on their cooldowns and range. Win the round by eliminating all enemy pieces. The AI also places units each round.
