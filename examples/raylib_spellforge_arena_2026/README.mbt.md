# Spellforge Arena 2026

A twin-stick magic combat game where you play as a mage battling waves of enemies in a large arena. Cast fire, frost, and storm spells, dash to evade, and collect mana orbs to fuel your abilities.

## Build and Run

```bash
cd examples && moon build --target native raylib_spellforge_arena_2026/
cd examples && ./_build/native/debug/build/raylib_spellforge_arena_2026/raylib_spellforge_arena_2026.exe
```

## Controls

- **WASD**: Move the mage
- **Mouse**: Aim direction
- **Left Mouse Button**: Cast fire spell (primary attack)
- **Right Mouse Button / E**: Cast frost spell (slows enemies)
- **Q**: Cast storm spell (area damage with shock)
- **Shift / Space**: Dash for evasion

## How to Play

- Battle enemies in a 3400x2400 scrolling arena
- Enemies have status effects: burn (fire), slow (frost), shock (storm)
- Collect mana orbs dropped by defeated enemies to restore mana
- Build kill combos for score multipliers
- Manage health, mana, and spell cooldowns
- Multiple enemy types with different behaviors and attack patterns
