# levels

Pure data package containing 48 level map patterns and 96 stage profiles
for Tank 1990. This package has no game logic -- only data definitions that
are loaded by the `game` package when a stage begins.

## Level Patterns

`level_pattern(index)` returns an `Array[String]` encoding the tile layout
for the given stage index (0-47, wrapping). Each character maps to a tile
type (brick, steel, water, bush, ice, or empty).

## Stage Profiles

`get_stage_profile(index)` returns a `StageProfile` with per-stage theming
and difficulty modifiers: title, subtitle, enemy bonus count, spawn rate
scaling, powerup drop bonus, sky gradient colors, fog alpha, and UI accent
color.
