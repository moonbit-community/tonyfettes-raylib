# raylib_train_dispatch_2026

A real-time puzzle game where you toggle track switches to route colored cargo trains to their correct destination stations. Red and blue trains must reach specific lanes to score deliveries.

## Build and Run

```bash
cd examples && moon build --target native raylib_train_dispatch_2026/
cd examples && ./_build/native/debug/build/raylib_train_dispatch_2026/raylib_train_dispatch_2026.exe
```

## Controls

- **1**: Toggle switch 1 (swaps lanes 1-2)
- **2**: Toggle switch 2 (swaps lanes 2-3)
- **3**: Toggle switch 3 (swaps lanes 3-4)
- **R**: Restart

## How to Play

- Trains spawn from both sides carrying red or blue cargo across 4 lanes
- Three vertical switches can reroute trains between adjacent lanes when toggled ON
- Red cargo heading right must exit on lane 1; blue on lane 4 (reversed for left-bound)
- Correct deliveries build combos for bonus points; wrong deliveries or collisions cost lives
- Lose all 5 lives and the dispatch fails
