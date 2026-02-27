# raylib_fighter_97_lite

A full-featured 2D fighting game inspired by classic 90s arcade fighters. Features a roster of 6 characters with unique movesets, special moves with motion inputs (quarter-circle-forward, dragon punch), super meter, throws, combos, and an AI opponent.

## Build and Run

```bash
cd examples && moon build --target native raylib_fighter_97_lite/
cd examples && ./_build/native/debug/build/raylib_fighter_97_lite/raylib_fighter_97_lite.exe
```

## Controls

- **WASD**: Movement (A/D walk, W jump, S crouch)
- **U**: Light Punch
- **I**: Heavy Punch
- **J**: Light Kick
- **K**: Heavy Kick
- **Double-tap A/D**: Dash forward/backward
- **QCF + attack**: Special move (quarter-circle-forward: Down, Down-Forward, Forward)
- **DP + attack**: Dragon Punch (Forward, Down, Down-Forward)
- **Super**: Full meter + specific input
- **Enter**: Start / Confirm

## How to Play

- Select a character from the 6-fighter roster, each with unique stats and moves
- Win 2 rounds to take the match; rounds are timed
- Land combos by canceling normals into specials during hit windows
- Build super meter through attacks to unlock devastating super moves
- Guard meter depletes when blocking; guard break leaves you vulnerable
- Supports VS CPU, 2-player local, and training mode
