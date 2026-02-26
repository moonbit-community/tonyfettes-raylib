# score

Scoring and combo system for Tank 1990.

## Functions

| Function | Purpose |
|----------|---------|
| `grant_score` | Award points to a player (scaled by combo multiplier) |
| `bump_combo` | Increment the kill combo counter and reset its timer |
| `combo_multiplier` | Current score multiplier based on active combo |
| `update_combo` | Tick the combo timer; resets combo when it expires |
