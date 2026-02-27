# raylib_tower_defense_frontier_2026

A lane-based tower defense game. Place towers in grid slots to shoot enemies marching down 5 lanes. Earn gold from kills to build more towers and survive escalating waves.

## Build and Run

```bash
cd examples && moon build --target native raylib_tower_defense_frontier_2026/
cd examples && ./_build/native/debug/build/raylib_tower_defense_frontier_2026/raylib_tower_defense_frontier_2026.exe
```

## Controls

- **Left Click**: Place a tower in a grid slot (costs 40 gold)
- **R**: Restart

## How to Play

- Enemies march from right to left along 5 lanes
- Click empty grid cells to build towers that auto-attack enemies in their lane
- Enemies that reach the left edge cost you a life (start with 20)
- Killing enemies earns gold (12 per kill) and score; wave completion gives bonus gold
- Waves grow stronger with more HP and speed; defend the frontier as long as possible
