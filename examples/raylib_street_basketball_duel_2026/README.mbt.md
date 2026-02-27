# Street Basketball Duel 2026

A 1-on-1 street basketball game where you face off against an AI opponent. Move, jump, dash, shoot, and steal the ball to score baskets and reach the target score first.

## Build and Run

```bash
cd examples && moon build --target native raylib_street_basketball_duel_2026/
cd examples && ./_build/native/debug/build/raylib_street_basketball_duel_2026/raylib_street_basketball_duel_2026.exe
```

## Controls

- **A/D or Left/Right**: Move horizontally
- **W or Up / Space**: Jump
- **Shift**: Dash (costs energy)
- **J / Left Mouse Button**: Shoot the ball / Attempt steal
- **Mouse / Touch**: On-screen touch controls supported
- **R**: Restart

## How to Play

- First to 21 points wins the set
- Shoot from different positions for varying shot difficulty
- Energy meter regenerates over time; used for dashing
- After a score, possession alternates between players
- The AI opponent moves, shoots, and defends autonomously
- Ball physics include spin, bouncing off the rim, and gravity
- Particle effects highlight scores, steals, and key moments
