# Pizza Delivery Mayhem 2026

A top-down delivery game where you ride a scooter through busy city streets, picking up pizza orders from restaurants and delivering them to customers before time runs out. Dodge traffic, manage fuel and scooter health, and chain deliveries for combo bonuses.

## Build and Run

```bash
cd examples && moon build --target native raylib_pizza_delivery_mayhem_2026/
cd examples && ./_build/native/debug/build/raylib_pizza_delivery_mayhem_2026/raylib_pizza_delivery_mayhem_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Steer the scooter
- **Shift / J**: Turbo boost (consumes fuel faster)
- **Space / E**: Action -- pick up or deliver orders
- **H**: Use a hint (shows next target location)
- **Q**: Repair scooter
- **R**: Restart run
- **Escape**: Return to title
- **Mouse / Touch**: On-screen D-pad, boost, action, hint, and restart buttons

## How to Play

Orders appear at three restaurants scattered across the city. Ride to a restaurant, pick up the order with the action key, then deliver it to the customer's location before the order timer expires. Collect fuel, repair, and speed pickups that spawn on the roads. Avoid colliding with traffic (sedans, buses, vans) which damages your scooter. Chain consecutive deliveries to build combos for higher scores. The run lasts 210 seconds -- reach the score goal to win.
