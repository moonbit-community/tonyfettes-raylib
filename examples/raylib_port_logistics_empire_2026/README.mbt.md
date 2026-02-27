# Port Logistics Empire 2026

A logistics management simulation where you build and manage a port network. Place nodes (docks, warehouses, factories), connect them with routes, and dispatch trucks to transport raw materials and goods to meet demand across the network.

## Build and Run

```bash
cd examples && moon build --target native raylib_port_logistics_empire_2026/
cd examples && ./_build/native/debug/build/raylib_port_logistics_empire_2026/raylib_port_logistics_empire_2026.exe
```

## Controls

- **Mouse**: Click to place nodes, draw routes between nodes, and interact with UI
- **Touch**: Tap for placement and route creation
- **Keyboard**: Various hotkeys for node types and route management (shown in-game HUD)

## Key Concepts

The game features a node-and-route network where docks produce raw materials, factories convert them into goods, and warehouses store and distribute them. Routes between nodes have health and levels that affect truck throughput. Trucks automatically travel routes carrying cargo. Balance production, routing capacity, and demand fulfillment to grow your logistics score. Nodes can experience outages, and routes degrade over time, requiring maintenance.
