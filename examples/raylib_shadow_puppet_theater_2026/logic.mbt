///|
fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn set_message(game : Game, text : String, ttl : Float) -> Unit {
  game.message = text
  game.message_t = ttl
}

///|
fn same_pose(a : Pose, b : Pose) -> Bool {
  a.ax == b.ax && a.ay == b.ay
}

///|
fn add_score(game : Game, delta : Int) -> Unit {
  game.score = maxi(0, game.score + delta)
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn reset_current_pose(game : Game) -> Unit {
  game.current_pose.ax = 0
  game.current_pose.ay = 0
}

///|
fn generate_sequence(game : Game) -> Unit {
  game.sequence.clear()

  let len = sequence_len_for_stage(game.stage)
  let mut prev_ax = 99
  let mut prev_ay = 99

  for i = 0; i < len; i = i + 1 {
    let mut ax = @raylib.get_random_value(pose_axis_min, pose_axis_max)
    let ay = @raylib.get_random_value(pose_axis_min, pose_axis_max)

    if i > 0 && ax == prev_ax && ay == prev_ay {
      if ax < pose_axis_max {
        ax = ax + 1
      } else {
        ax = ax - 1
      }
    }

    game.sequence.push(Pose::new(ax, ay))
    prev_ax = ax
    prev_ay = ay
  }

  game.history.clear()
  game.target_idx = 0
  game.cue_time_limit = cue_time_for_stage(game.stage)
  game.cue_time_left = game.cue_time_limit
}

///|
fn init_title_scene(game : Game) -> Unit {
  game.state = state_title
  game.stage = 1
  game.score = 0
  game.combo = 0
  game.excitement = 0.0
  game.spotlight = spotlight_start
  game.cue_time_left = 0.0
  game.cue_time_limit = cue_base_time
  game.target_idx = 0
  game.sequence.clear()
  game.history.clear()
  reset_current_pose(game)
  game.burst_t = 0.0
  game.burst_cd = 0.0
  game.combo_t = 0.0
  game.beat_t = 0.0
  game.scene_t = 0.0
  game.result_t = 0.0
  game.hit_count = 0
  game.miss_count = 0
  set_message(game, "Press ENTER, J, or SPACE to open the curtain.", 99.0)
}

///|
fn start_show(game : Game) -> Unit {
  game.state = state_play
  game.stage = 1
  game.score = 0
  game.combo = 0
  game.excitement = 28.0
  game.spotlight = spotlight_start
  game.burst_t = 0.0
  game.burst_cd = 0.0
  game.combo_t = 0.0
  game.result_t = 0.0
  game.hit_count = 0
  game.miss_count = 0
  reset_current_pose(game)
  generate_sequence(game)
  set_message(
    game, "Match each target silhouette before the cue clock runs out.", 3.5,
  )
}

///|
fn target_pose(game : Game) -> Pose {
  if game.target_idx < game.sequence.length() {
    game.sequence[game.target_idx]
  } else {
    Pose::new(0, 0)
  }
}

///|
fn active_slow_factor(game : Game) -> Float {
  if game.burst_t > 0.0 {
    burst_slow_factor
  } else {
    1.0
  }
}

///|
fn apply_pose_axis_input(game : Game) -> Unit {
  if game.input.axis_dx != 0 {
    game.current_pose.ax = clampi(
      game.current_pose.ax + game.input.axis_dx,
      pose_axis_min,
      pose_axis_max,
    )
  }
  if game.input.axis_dy != 0 {
    game.current_pose.ay = clampi(
      game.current_pose.ay + game.input.axis_dy,
      pose_axis_min,
      pose_axis_max,
    )
  }
}

///|
fn try_activate_burst(game : Game) -> Unit {
  if not(game.input.burst_pressed) {
    return
  }

  if game.burst_cd <= 0.0 {
    game.burst_t = burst_duration
    game.burst_cd = burst_cooldown
    game.excitement = minf(excitement_max, game.excitement + 8.0)
    set_message(game, "Spotlight burst! Time slows for a moment.", 0.9)
  } else {
    set_message(
      game,
      "Burst cooling down: " + game.burst_cd.to_int().to_string() + "s",
      0.45,
    )
  }
}

///|
fn apply_mistake(game : Game, timeout : Bool) -> Unit {
  game.miss_count = game.miss_count + 1
  game.combo = 0
  game.combo_t = 0.0

  let spot_loss = if timeout {
    timeout_spotlight_loss
  } else {
    mistake_spotlight_loss
  }
  let excite_loss = if timeout {
    mistake_excitement_loss + 5.0
  } else {
    mistake_excitement_loss
  }

  game.spotlight = maxf(0.0, game.spotlight - spot_loss)
  game.excitement = maxf(0.0, game.excitement - excite_loss)

  if timeout {
    generate_sequence(game)
    set_message(game, "Cue missed! New sequence enters.", 1.2)
  } else {
    game.cue_time_left = maxf(
      game.cue_time_limit * 0.42,
      game.cue_time_left * 0.72,
    )
    set_message(game, "Silhouette mismatch.", 0.75)
  }
}

///|
fn complete_sequence(game : Game) -> Unit {
  let bonus = 160 + game.stage * 30 + game.combo * 8
  add_score(game, bonus)

  game.stage = game.stage + 1
  game.excitement = minf(excitement_max, game.excitement + 14.0)
  game.spotlight = minf(spotlight_max, game.spotlight + 12.0)

  generate_sequence(game)
  set_message(
    game,
    "Act cleared! Scene " + game.stage.to_string() + " begins.",
    1.5,
  )
}

///|
fn lock_current_pose(game : Game) -> Unit {
  if game.sequence.length() <= 0 || game.target_idx >= game.sequence.length() {
    return
  }

  let target = game.sequence[game.target_idx]

  if same_pose(game.current_pose, target) {
    game.history.push(Pose::new(game.current_pose.ax, game.current_pose.ay))
    game.target_idx = game.target_idx + 1
    game.hit_count = game.hit_count + 1

    game.combo = clampi(game.combo + 1, 0, 99)
    game.combo_t = combo_hold_time
    if game.combo > game.best_combo {
      game.best_combo = game.combo
    }

    let score_gain = 48 + game.stage * 10 + game.combo * 5
    add_score(game, score_gain)

    game.excitement = minf(
      excitement_max,
      game.excitement +
      correct_excitement_gain +
      Float::from_int(game.combo) * 0.7,
    )
    game.spotlight = minf(
      spotlight_max,
      game.spotlight +
      correct_spotlight_gain +
      Float::from_int(game.combo) * 0.2,
    )
    game.cue_time_left = game.cue_time_limit

    if game.target_idx >= game.sequence.length() {
      complete_sequence(game)
    } else {
      set_message(game, "Great lock!", 0.55)
    }
  } else {
    apply_mistake(game, false)
  }
}

///|
fn undo_last_pose(game : Game) -> Unit {
  if game.history.length() <= 0 || game.target_idx <= 0 {
    set_message(game, "No locked pose to undo.", 0.7)
    return
  }

  let last_idx = game.history.length() - 1
  let pose = game.history[last_idx]
  ignore(game.history.remove(last_idx))

  game.target_idx = game.target_idx - 1
  game.current_pose.ax = pose.ax
  game.current_pose.ay = pose.ay
  game.combo = 0
  game.combo_t = 0.0
  game.spotlight = maxf(0.0, game.spotlight - 5.5)
  game.excitement = maxf(0.0, game.excitement - 3.0)
  game.cue_time_left = maxf(game.cue_time_left, game.cue_time_limit * 0.65)
  set_message(game, "Last locked pose undone.", 0.85)
}

///|
fn update_title_state(game : Game) -> Unit {
  game.excitement = 18.0 + (0.5 + 0.5 * sinf(game.scene_t * 0.8)) * 14.0
  game.spotlight = spotlight_start + sinf(game.scene_t * 0.6) * 8.0

  if game.input.start_pressed {
    start_show(game)
  }
}

///|
fn update_play_state(game : Game, dt : Float) -> Unit {
  if game.input.pause_pressed {
    game.state = state_paused
    set_message(game, "Show paused. Press P to resume.", 99.0)
    return
  }

  apply_pose_axis_input(game)

  if game.input.undo_pressed {
    undo_last_pose(game)
  }

  try_activate_burst(game)

  if game.input.lock_pressed {
    lock_current_pose(game)
  }

  let sim_dt = dt * active_slow_factor(game)

  game.cue_time_left = game.cue_time_left - sim_dt
  game.combo_t = maxf(0.0, game.combo_t - sim_dt)
  if game.combo > 0 && game.combo_t <= 0.0 {
    game.combo = game.combo - 1
    if game.combo > 0 {
      game.combo_t = combo_hold_time * 0.7
    }
  }

  game.excitement = maxf(0.0, game.excitement - sim_dt * excitement_drain)
  let pressure = spotlight_drain + Float::from_int(game.combo) * 0.22
  game.spotlight = maxf(0.0, game.spotlight - sim_dt * pressure)

  if game.cue_time_left <= 0.0 {
    apply_mistake(game, true)
  }

  if game.spotlight <= 0.0 {
    game.state = state_result
    game.result_t = 0.0
    set_message(game, "Spotlight faded. Press R to restart.", 99.0)
  }
}

///|
fn update_paused_state(game : Game) -> Unit {
  if game.input.pause_pressed {
    game.state = state_play
    set_message(game, "Show resumed.", 0.8)
  }
}

///|
fn update_result_state(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt

  if game.input.start_pressed {
    start_show(game)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  game.scene_t = game.scene_t + dt
  game.beat_t = game.beat_t + dt
  game.message_t = maxf(0.0, game.message_t - dt)
  game.burst_t = maxf(0.0, game.burst_t - dt)
  game.burst_cd = maxf(0.0, game.burst_cd - dt)

  if game.input.restart_pressed {
    start_show(game)
    return
  }

  if game.state == state_title {
    update_title_state(game)
  } else if game.state == state_play {
    update_play_state(game, dt)
  } else if game.state == state_paused {
    update_paused_state(game)
  } else {
    update_result_state(game, dt)
  }
}
