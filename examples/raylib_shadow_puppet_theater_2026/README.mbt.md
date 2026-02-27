# raylib_shadow_puppet_theater_2026

A rhythm-action game where you control a shadow puppet on a theater stage. Match target silhouette poses in sequence before the cue timer runs out. Build combos and keep the audience excited to prevent the spotlight from fading.

## Build and Run

```bash
cd examples && moon build --target native raylib_shadow_puppet_theater_2026/
cd examples && ./_build/native/debug/build/raylib_shadow_puppet_theater_2026/raylib_shadow_puppet_theater_2026.exe
```

## Controls

- **Arrow keys / WASD**: Adjust puppet pose axes (horizontal and vertical)
- **J**: Lock current pose (confirm match attempt)
- **K**: Undo last locked pose
- **Space**: Activate spotlight burst (slows time temporarily)
- **P**: Pause / resume
- **R**: Restart the show
- **Enter / J / Space**: Start game from title screen
- **F11**: Toggle borderless windowed mode

## How to Play

Each scene presents a sequence of target silhouettes shown as cards at the top of the screen. Use the arrow keys to adjust your puppet's pose to match the highlighted target, then press J to lock it in. Correct matches earn score, build combos, and restore spotlight energy. Mismatches and timeouts drain the spotlight and reset combos. The spotlight constantly fades -- when it reaches zero, the show is over. Use the burst ability (Space) to temporarily slow time during difficult sequences. Each cleared scene introduces longer sequences with tighter time limits.
