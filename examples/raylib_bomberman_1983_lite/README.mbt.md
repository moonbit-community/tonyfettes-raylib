# Bomberman 1983 Lite

A full-featured Bomberman clone with multiple enemy types, power-ups, multi-stage progression, and 2-player support, inspired by the classic 1983 arcade game.

## Build and Run

```bash
cd examples && moon build --target native raylib_bomberman_1983_lite/
cd examples && ./_build/native/debug/build/raylib_bomberman_1983_lite/raylib_bomberman_1983_lite.exe
```

## Controls

### Player 1
- **Arrow Keys**: Move
- **Right Shift / Enter**: Place bomb
- **Space**: Fire weapon

### Player 2
- **WASD**: Move
- **Shift / Enter**: Place bomb

## How to Play

Place bombs to blast through destructible walls and defeat enemies across multiple stages. Collect power-ups (speed, blast range, shields) dropped from destroyed blocks. Different enemy types have unique behaviors -- basic enemies patrol randomly while tougher variants pursue you. Complete each stage by eliminating all enemies. Features a score system, particle effects, and a demo AI mode.
