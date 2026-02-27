# raylib_dice_roguelite_arena_2026

A dice-based roguelite combat game. Roll dice each turn and assign them to attack, defend, heal, or use special abilities against increasingly difficult enemies. Collect artifact rewards between fights to power up.

## Build and Run

```bash
cd examples && moon build --target native raylib_dice_roguelite_arena_2026/
cd examples && ./_build/native/debug/build/raylib_dice_roguelite_arena_2026/raylib_dice_roguelite_arena_2026.exe
```

## Controls

- **Mouse click**: Select dice and assign to action slots
- **R**: Reroll dice (limited uses)
- **Space/Enter**: End turn / confirm
- **Keyboard shortcuts**: Displayed in-game for various actions

## How to Play

- Each turn you roll a set of dice with different face values
- Assign dice to actions: Attack, Guard, Heal, Venom, Focus, or Crush
- Enemy telegraphs their next intent (attack, shield, heal, etc.)
- Defeat enemies to earn gold and choose from reward cards (artifacts)
- Artifacts provide permanent bonuses like extra attack damage or starting shields
- Progress through increasingly tough floors with varied enemy types
