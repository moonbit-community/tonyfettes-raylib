# Mine Cart Mayhem 2026

An endless runner where you ride a mine cart along 3 parallel rails. Switch lanes to dodge rocks and walls, jump over low obstacles, and collect coins as the cart accelerates.

## Build and Run

```bash
cd examples && moon build --target native raylib_mine_cart_mayhem_2026/
cd examples && ./_build/native/debug/build/raylib_mine_cart_mayhem_2026/raylib_mine_cart_mayhem_2026.exe
```

## Controls

- **W/Up**: Switch to upper rail
- **S/Down**: Switch to lower rail
- **Space or J**: Jump (clear low obstacles)
- **R**: Restart run

## How to Play

Your mine cart rolls forward at increasing speed. Hazards approach from the right on 3 lanes: low rocks (jump over them), high walls (switch lanes to avoid), and coins (collect for bonus score). Switch between the 3 rails and time your jumps to survive as long as possible. Speed gradually increases, making reactions harder. Each collision costs a life -- lose all 3 lives and the run ends. Score is based on distance traveled and coins collected.
