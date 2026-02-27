# raylib_zombie_safehouse_siege_2026

A zombie horde defense game. Protect your safehouse while fighting off waves of zombies. Scavenge scrap from fallen enemies to upgrade your safehouse, manage ammo with reloading, and use dash to escape danger.

## Build and Run

```bash
cd examples && moon build --target native raylib_zombie_safehouse_siege_2026/
cd examples && ./_build/native/debug/build/raylib_zombie_safehouse_siege_2026/raylib_zombie_safehouse_siege_2026.exe
```

## Controls

- **WASD/Arrows**: Move survivor
- **Mouse**: Aim
- **Left Click / J**: Shoot (auto-aims at nearest zombie)
- **K**: Dash (brief invulnerable burst)
- **Space**: Harvest scrap from nearby fallen zombies
- **R**: Restart

## How to Play

- Zombies spawn in waves and converge on your safehouse at the center
- Shoot zombies before they reach the safehouse; they damage it on contact
- Collect scrap dropped by defeated zombies to upgrade safehouse HP, shields, and turrets
- Manage your ammo and reload timing; the safehouse turret provides supplementary fire
- If the safehouse or your survivor is destroyed, the siege is lost
