# Chef Rush 2026

A lane-based ingredient-catching game where you move between 5 kitchen lanes to catch falling ingredients and fulfill customer orders while avoiding trash.

## Build and Run

```bash
cd examples && moon build --target native raylib_chef_rush_2026/
cd examples && ./_build/native/debug/build/raylib_chef_rush_2026/raylib_chef_rush_2026.exe
```

## Controls

- **A/D or Left/Right**: Switch lanes
- **Space / Enter**: Serve completed order
- **R**: Restart

## How to Play

Ingredients (tomato, beef, fish, lettuce) fall down 5 lanes. Move your chef between lanes to catch the right ingredients for the current customer order. Each order requires a specific ingredient type and quantity. Serve the order once you have collected enough. Catching trash items or missing too many ingredients costs you. Orders get faster and more demanding as your score increases.
