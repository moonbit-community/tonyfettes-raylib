///|
fn active_slow_factor(game : @types.Game) -> Float {
  if game.burst_t > 0.0 {
    @types.burst_slow_factor
  } else {
    1.0
  }
}

///|
fn cadence_for_elapsed(elapsed : Float) -> Float {
  let raw = @types.beat_start_interval - elapsed * @types.beat_accel_per_sec
  if raw < @types.beat_min_interval {
    @types.beat_min_interval
  } else {
    raw
  }
}

///|
fn init_title_state(game : @types.Game) -> Unit {
  game.state = @types.state_title
  game.lane_x = 0
  game.lane_y = 0
  game.stance = @types.stance_spear
  game.health = @types.health_max
  game.harmony = @types.harmony_max
  game.acclaim = 0
  game.combo = 0
  game.hits = 0
  game.misses = 0
  game.duel_time_left = @types.duel_duration
  game.elapsed = 0.0
  game.beat_interval = @types.beat_start_interval
  game.next_prompt_t = 0.7
  game.prompt_active = false
  game.prompt = @types.Prompt::new(0, 0, @types.stance_spear, 0.0)
  game.prompt_serial = 0
  game.burst_t = 0.0
  game.burst_cd = 0.0
  game.guard_flash_t = 0.0
  game.game_over_reason = ""
  @types.set_message(game, "Press J or ENTER to raise the curtain.", 99.0)
}

///|
fn start_duel(game : @types.Game) -> Unit {
  game.state = @types.state_playing
  game.lane_x = 0
  game.lane_y = 0
  game.stance = @types.stance_spear
  game.health = @types.health_max
  game.harmony = @types.harmony_max
  game.acclaim = 0
  game.combo = 0
  game.hits = 0
  game.misses = 0
  game.duel_time_left = @types.duel_duration
  game.elapsed = 0.0
  game.beat_interval = @types.beat_start_interval
  game.next_prompt_t = 0.9
  game.prompt_active = false
  game.prompt = @types.Prompt::new(0, 0, @types.stance_spear, 0.0)
  game.prompt_serial = 0
  game.burst_t = 0.0
  game.burst_cd = 0.0
  game.guard_flash_t = 0.0
  game.game_over_reason = ""
  @types.set_message(
    game,
    "Match lane and stance with the drum beat. K can deflect near impact.",
    2.5,
  )
}

///|
fn finish_duel(game : @types.Game, reason : String) -> Unit {
  game.state = @types.state_game_over
  game.prompt_active = false
  game.game_over_reason = reason
  @types.set_message(game, "Press R to restart, J to return to title.", 99.0)
}

///|
fn apply_axis_focus_and_stance(game : @types.Game) -> Unit {
  if game.input.axis_x != 0 {
    game.lane_x = @types.clampi(
      game.lane_x + game.input.axis_x,
      @types.lane_axis_min,
      @types.lane_axis_max,
    )
  }
  if game.input.axis_y != 0 {
    game.lane_y = @types.clampi(
      game.lane_y + game.input.axis_y,
      @types.lane_axis_min,
      @types.lane_axis_max,
    )
  }

  if game.input.axis_y < 0 {
    game.stance = @types.stance_spear
  } else if game.input.axis_x > 0 {
    game.stance = @types.stance_fan
  } else if game.input.axis_y > 0 {
    game.stance = @types.stance_guard
  } else if game.input.axis_x < 0 {
    game.stance = @types.stance_sleeve
  }
}

///|
fn spawn_prompt(game : @types.Game) -> Unit {
  let prev_lane_x = game.prompt.lane_x
  let prev_lane_y = game.prompt.lane_y
  let prev_stance = game.prompt.stance

  let mut lane_x = @raylib.get_random_value(@types.lane_axis_min, @types.lane_axis_max)
  let lane_y = @raylib.get_random_value(@types.lane_axis_min, @types.lane_axis_max)
  let mut stance = @raylib.get_random_value(0, @types.stance_count - 1)

  if game.prompt_serial > 0 &&
    lane_x == prev_lane_x &&
    lane_y == prev_lane_y &&
    stance == prev_stance {
    stance = (stance + 1) % @types.stance_count
    if lane_x == 0 && lane_y == 0 {
      lane_x = 1
    }
  }

  game.prompt = @types.Prompt::new(lane_x, lane_y, stance, @types.prompt_lead_time)
  game.prompt_active = true
  game.prompt_serial = game.prompt_serial + 1
}

///|
fn apply_hit_success(game : @types.Game, perfect : Bool) -> Unit {
  game.hits = game.hits + 1
  game.combo = game.combo + 1
  if game.combo > game.best_combo {
    game.best_combo = game.combo
  }

  let base_gain = if perfect {
    @types.perfect_acclaim_gain
  } else {
    @types.good_acclaim_gain
  }
  let combo_gain = game.combo * @types.combo_acclaim_step
  game.acclaim = game.acclaim + base_gain + combo_gain

  let health_gain = if perfect {
    @types.hit_health_recover + 0.7
  } else {
    @types.hit_health_recover
  }
  game.health = @types.minf(@types.health_max, game.health + health_gain)
  game.harmony = @types.minf(
    @types.harmony_max,
    game.harmony + @types.hit_harmony_recover + Float::from_int(game.combo) * 0.18,
  )

  if perfect {
    @types.set_message(game, "Perfect beat! Crowd acclaim surges.", 0.75)
  } else {
    @types.set_message(game, "Clean beat.", 0.55)
  }

  game.prompt_active = false
}

///|
fn apply_miss(
  game : @types.Game,
  reason : String,
  extra_harmony_penalty : Float,
) -> Unit {
  game.misses = game.misses + 1
  game.combo = 0
  game.prompt_active = false

  game.health = @types.maxf(0.0, game.health - @types.miss_health_penalty)
  game.harmony = @types.maxf(
    0.0,
    game.harmony - @types.miss_harmony_penalty - extra_harmony_penalty,
  )
  game.acclaim = @types.maxi(0, game.acclaim - 24)

  @types.set_message(game, reason, 0.95)

  if game.health <= 0.0 || game.harmony <= 0.0 {
    finish_duel(game, "Stage harmony collapsed under missed beats.")
  }
}

///|
fn apply_offbeat_penalty(game : @types.Game) -> Unit {
  game.combo = 0
  game.harmony = @types.maxf(0.0, game.harmony - @types.offbeat_harmony_penalty)
  game.acclaim = @types.maxi(0, game.acclaim - 8)
  @types.set_message(game, "Off-beat strike.", 0.45)

  if game.harmony <= 0.0 {
    finish_duel(game, "Stage harmony shattered by off-beat strikes.")
  }
}

///|
fn try_hit_prompt(game : @types.Game) -> Unit {
  if not(game.prompt_active) {
    apply_offbeat_penalty(game)
    return
  }

  let timing = @types.absf(game.prompt.time_left)
  let lane_ok = game.lane_x == game.prompt.lane_x &&
    game.lane_y == game.prompt.lane_y
  let stance_ok = game.stance == game.prompt.stance

  if timing > @types.timing_miss {
    apply_offbeat_penalty(game)
    return
  }

  if not(lane_ok) || not(stance_ok) {
    apply_miss(
      game,
      "Mismatch: lane focus or stance was wrong.",
      @types.mismatch_harmony_extra,
    )
    return
  }

  if timing <= @types.timing_perfect {
    apply_hit_success(game, true)
  } else if timing <= @types.timing_good {
    apply_hit_success(game, false)
  } else {
    apply_miss(game, "Timing slipped beyond the beat window.", 0.0)
  }
}

///|
fn try_deflect(game : @types.Game) -> Unit {
  if game.prompt_active {
    let timing = @types.absf(game.prompt.time_left)
    if timing <= @types.timing_deflect {
      game.prompt_active = false
      game.combo = @types.maxi(0, game.combo - 1)
      game.harmony = @types.maxf(
        0.0,
        game.harmony - @types.deflect_harmony_penalty,
      )
      game.acclaim = game.acclaim + @types.deflect_acclaim_gain
      game.stance = game.prompt.stance
      game.guard_flash_t = 0.36
      @types.set_message(
        game,
        "Deflect transition! Prompt canceled safely.",
        0.7,
      )

      if game.harmony <= 0.0 {
        finish_duel(game, "Harmony broke during defensive transitions.")
      }
      return
    }
  }

  game.stance = @types.stance_guard
  game.guard_flash_t = 0.22
  game.harmony = @types.maxf(0.0, game.harmony - 1.0)
  @types.set_message(game, "Guard transition.", 0.5)

  if game.harmony <= 0.0 {
    finish_duel(game, "Harmony broke while holding guard.")
  }
}

///|
fn try_activate_burst(game : @types.Game) -> Unit {
  if not(game.input.burst_pressed) {
    return
  }

  if game.burst_cd <= 0.0 {
    game.burst_t = @types.burst_duration
    game.burst_cd = @types.burst_cooldown
    game.harmony = @types.minf(@types.harmony_max, game.harmony + 8.0)
    @types.set_message(game, "Focus burst: tempo slows briefly.", 0.9)
  } else {
    let wait_s = game.burst_cd.to_int() + 1
    @types.set_message(
      game,
      "Focus burst cooling down: " + wait_s.to_string() + "s",
      0.5,
    )
  }
}

///|
fn update_title_state(game : @types.Game) -> Unit {
  let wave : Float = 0.5 + 0.5 * @types.sinf(game.crowd_wave_t * 0.9)
  game.health = 80.0 + wave * 14.0
  game.harmony = 76.0 + (1.0 - wave) * 18.0

  if game.input.confirm_pressed || game.input.restart_pressed {
    start_duel(game)
  }
}

///|
fn update_paused_state(game : @types.Game) -> Unit {
  if game.input.restart_pressed {
    start_duel(game)
    return
  }

  if game.input.pause_pressed || game.input.confirm_pressed {
    game.state = @types.state_playing
    @types.set_message(game, "Performance resumed.", 0.8)
  }
}

///|
fn update_game_over_state(game : @types.Game) -> Unit {
  if game.input.restart_pressed {
    start_duel(game)
    return
  }

  if game.input.confirm_pressed {
    init_title_state(game)
  }
}

///|
fn update_playing_state(game : @types.Game, dt : Float) -> Unit {
  if game.input.pause_pressed {
    game.state = @types.state_paused
    @types.set_message(game, "Paused. Press P or J to resume.", 99.0)
    return
  }

  if game.input.restart_pressed {
    start_duel(game)
    return
  }

  apply_axis_focus_and_stance(game)

  if game.input.defend_pressed {
    try_deflect(game)
  }

  if game.state != @types.state_playing {
    return
  }

  if game.input.hit_pressed {
    try_hit_prompt(game)
  }

  if game.state != @types.state_playing {
    return
  }

  try_activate_burst(game)

  let sim_dt = dt * active_slow_factor(game)
  game.elapsed = game.elapsed + sim_dt
  game.duel_time_left = @types.maxf(0.0, game.duel_time_left - sim_dt)
  game.beat_interval = cadence_for_elapsed(game.elapsed)
  game.next_prompt_t = game.next_prompt_t - sim_dt

  game.health = @types.maxf(
    0.0,
    game.health - sim_dt * @types.health_drain_per_sec,
  )
  let pressure = @types.harmony_drain_per_sec +
    Float::from_int(game.misses) * 0.02
  game.harmony = @types.maxf(0.0, game.harmony - sim_dt * pressure)

  if game.prompt_active {
    game.prompt.time_left = game.prompt.time_left - sim_dt
    if game.prompt.time_left < -@types.timing_miss {
      apply_miss(game, "Missed cue from the rival troupe.", 0.0)
    }
  }

  if game.state != @types.state_playing {
    return
  }

  if not(game.prompt_active) && game.next_prompt_t <= 0.0 {
    spawn_prompt(game)
    game.next_prompt_t = game.beat_interval
  }

  if game.health <= 0.0 || game.harmony <= 0.0 {
    finish_duel(game, "Your troupe lost vitality before the final drum.")
    return
  }

  if game.duel_time_left <= 0.0 {
    let result = if game.acclaim >= 1200 {
      "Victory: the audience chants for an encore."
    } else if game.acclaim >= 800 {
      "Draw: both troupes share the applause."
    } else {
      "Defeat: the rival troupe takes the curtain call."
    }
    finish_duel(
      game,
      result + " Grade: " + @types.grade_for_acclaim(game.acclaim),
    )
  }
}

///|
pub fn init_game(game : @types.Game) -> Unit {
  init_title_state(game)
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  sample_input(game)

  game.crowd_wave_t = game.crowd_wave_t + dt
  game.message_t = @types.maxf(0.0, game.message_t - dt)

  if game.state != @types.state_paused {
    game.burst_t = @types.maxf(0.0, game.burst_t - dt)
    game.burst_cd = @types.maxf(0.0, game.burst_cd - dt)
    game.guard_flash_t = @types.maxf(0.0, game.guard_flash_t - dt)
  }

  if game.state == @types.state_title {
    update_title_state(game)
  } else if game.state == @types.state_playing {
    update_playing_state(game, dt)
  } else if game.state == @types.state_paused {
    update_paused_state(game)
  } else {
    update_game_over_state(game)
  }
}
