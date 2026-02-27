# Space Trader 2026

A text-driven space trading simulation where you buy and sell goods across 6 planets, manage fuel and hull integrity, and aim to accumulate wealth before running out of resources.

## Build and Run

```bash
cd examples && moon build --target native raylib_space_trader_2026/
cd examples && ./_build/native/debug/build/raylib_space_trader_2026/raylib_space_trader_2026.exe
```

## Controls

- **Up/Down**: Select a good (Ore, Food, Tech, Med, Fuel)
- **Left/Right**: Select a destination planet
- **B**: Buy one unit of the selected good
- **S**: Sell one unit of the selected good
- **T**: Travel to the selected planet (costs fuel)
- **N**: Wait a day (prices fluctuate)
- **F**: Refuel at current planet
- **R**: Restart the game

## How to Play

- Trade 5 goods (Ore, Food, Tech, Med, Fuel) across 6 planets with fluctuating prices
- Each planet has supply/demand biases that affect pricing
- Travel between planets costs fuel; longer jumps cost more
- Random encounters during travel: pirate attacks or courier tips
- Manage a cargo hold of 26 slots, credits, fuel, and hull HP
- Win by accumulating enough wealth; lose if hull HP reaches zero or you run out of fuel
