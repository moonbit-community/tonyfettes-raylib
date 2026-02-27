# Card Duel 2026

A turn-based card combat game where you play cards from a random hand to attack, defend, and heal against an AI enemy that fights back each turn.

## Build and Run

```bash
cd examples && moon build --target native raylib_card_duel_2026/
cd examples && ./_build/native/debug/build/raylib_card_duel_2026/raylib_card_duel_2026.exe
```

## Controls

- **1 / 2 / 3**: Play the corresponding card from your hand
- **Enter**: End your turn
- **R**: Restart

## How to Play

Each turn you receive 3 random cards and energy to spend. Cards include Strike (6 damage), Guard (7 block), Burst (12 damage), Sap (break block + 4 damage), and Repair (heal 6). Play cards strategically -- block absorbs incoming damage before it hits HP. After you end your turn, the enemy takes two actions (slash, guard, or drain). Reduce the enemy's HP to zero to win. The enemy scales in strength over time.
