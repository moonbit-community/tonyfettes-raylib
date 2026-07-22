# Core Automation Events

Demonstrates raylib's automation event system for recording and replaying input events in a simple platformer scene.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_automation_events/
cd examples && ./_build/native/debug/build/raylib_core_automation_events/raylib_core_automation_events.exe
```

## Controls

- **Left / Right**: Move player
- **Space**: Jump
- **R**: Reset game state
- **S**: Start/stop recording input events (exports to `automation.rae`)
- **A**: Replay the last recorded events
- **Mouse Wheel**: Zoom camera
- **Drop .rae file**: Load and replay an automation event file

## Key Concepts

- `load_automation_event_list` / `export_automation_event_list` for file I/O.
- `start_automation_event_recording` / `stop_automation_event_recording` to capture input.
- `play_automation_event` to replay recorded events frame by frame.
- Useful for automated testing, demos, and replay systems.
