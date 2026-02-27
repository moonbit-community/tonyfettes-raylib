# Radio Station Manager 2026

A radio DJ simulation where you manage a 3-minute broadcast shift. Select songs from a queue to match the audience's changing mood preferences, maintain listener count and ratings, and schedule ad breaks to earn budget.

## Build and Run

```bash
cd examples && moon build --target native raylib_radio_station_manager_2026/
cd examples && ./_build/native/debug/build/raylib_radio_station_manager_2026/raylib_radio_station_manager_2026.exe
```

## Controls

- **1/2/3/4**: Play the corresponding queued track immediately
- **A**: Run an ad break (earns budget but loses listeners and rating)
- **R**: Restart the broadcast shift

## How to Play

A queue of four songs rotates continuously, each with a mood (Chill, Pop, Rock, Classic) and energy level. The audience's desired mood shifts over the course of the 180-second broadcast. Play songs that match the current desired mood and energy level to grow your listener count and rating. Mismatched songs cause listeners to tune out. Songs auto-advance when they finish, or you can manually queue any of the four tracks. Run ad breaks to earn budget, but beware -- ads drive listeners away. The shift ends when time runs out or all listeners leave.
