///|
fn set_message(game : Game, text : String, ttl : Float) -> Unit {
  game.message = text
  game.message_t = ttl
}

///|
fn random_unit() -> Float {
  Float::from_int(@raylib.get_random_value(0, 1000)) / 1000.0
}

///|
fn random_incident_delay(week : Int) -> Float {
  let base = incident_gap_for(week)
  let jitter = (random_unit() * 2.0 - 1.0) * incident_gap_jitter
  maxf(incident_gap_min, base + jitter)
}

///|
fn mean_skill(game : Game) -> Float {
  let mut sum : Float = 0.0

  for i = 0; i < student_count; i = i + 1 {
    sum = sum + game.students[i].skill
  }

  sum / Float::from_int(student_count)
}

///|
fn mean_fatigue(game : Game) -> Float {
  let mut sum : Float = 0.0

  for i = 0; i < student_count; i = i + 1 {
    sum = sum + game.students[i].fatigue
  }

  sum / Float::from_int(student_count)
}

///|
fn defense_power(game : Game) -> Float {
  let mut power : Float = 0.0

  for i = 0; i < student_count; i = i + 1 {
    if game.students[i].room != room_defense {
      continue
    }

    let freshness = maxf(0.1, 1.0 - game.students[i].fatigue / 130.0)
    power = power + game.students[i].skill * freshness
  }

  power
}

///|
fn reset_students(game : Game) -> Unit {
  for i = 0; i < student_count; i = i + 1 {
    game.students[i].skill = starting_skill(i)
    game.students[i].fatigue = Float::from_int(@raylib.get_random_value(8, 20))
    game.students[i].room = room_rest
  }
}

///|
fn set_game_over(game : Game, reason : String) -> Unit {
  if game.state == state_game_over {
    return
  }

  game.state = state_game_over
  game.speed_burst_t = 0.0
  game.speed_burst_cd = 0.0
  game.defeat_reason = reason
  game.weeks_survived = game.week - 1

  if game.weeks_survived > game.best_week {
    game.best_week = game.weeks_survived
  }

  set_message(game, reason + " Press J or ENTER to restart.", 99.0)
}

///|
fn check_failure(game : Game) -> Bool {
  if game.funds <= 0.0 {
    set_game_over(
      game,
      "School funds ran out in week " + game.week.to_string() + ".",
    )
    return true
  }

  if game.reputation <= 0.0 {
    set_game_over(
      game,
      "School reputation collapsed in week " + game.week.to_string() + ".",
    )
    return true
  }

  false
}

///|
fn init_title_scene(game : Game) -> Unit {
  reset_students(game)

  game.state = state_title
  game.week = 1
  game.funds = start_funds
  game.reputation = start_reputation
  game.week_duration = week_duration_for(1)
  game.week_time_left = game.week_duration
  game.cursor_row = 0
  game.cursor_col = room_rest
  game.speed_burst_t = 0.0
  game.speed_burst_cd = 0.0
  game.incident_timer = 0.0
  game.incident_count_week = 0
  game.total_incidents = 0
  game.incident_flash_t = 0.0
  game.scene_t = 0.0
  game.week_banner_t = 0.0
  game.weeks_survived = 0
  game.defeat_reason = ""
  set_message(
    game, "Run the dojo: WASD/Arrows move, J assign, K rest, SPACE burst, P pause, R restart.",
    99.0,
  )
}

///|
fn start_new_run(game : Game) -> Unit {
  reset_students(game)

  game.state = state_playing
  game.week = 1
  game.funds = start_funds
  game.reputation = start_reputation
  game.week_duration = week_duration_for(1)
  game.week_time_left = game.week_duration
  game.cursor_row = 0
  game.cursor_col = room_train
  game.speed_burst_t = 0.0
  game.speed_burst_cd = 0.0
  game.incident_timer = random_incident_delay(1)
  game.incident_count_week = 0
  game.total_incidents = 0
  game.incident_flash_t = 0.0
  game.scene_t = 0.0
  game.week_banner_t = 2.4
  game.weeks_survived = 0
  game.defeat_reason = ""
  set_message(
    game, "Week 1 starts. Build skill, keep fatigue down, survive.", 3.2,
  )
}

///|
fn move_cursor(game : Game, dx : Int, dy : Int) -> Unit {
  game.cursor_col = clampi(game.cursor_col + dx, 0, room_count - 1)
  game.cursor_row = clampi(game.cursor_row + dy, 0, student_count - 1)
}

///|
fn assign_selected_room(game : Game) -> Unit {
  let row = clampi(game.cursor_row, 0, student_count - 1)
  let room = clampi(game.cursor_col, 0, room_count - 1)

  game.students[row].room = room
  set_message(
    game,
    game.students[row].name + " assigned to " + room_name(room) + ".",
    1.1,
  )
}

///|
fn rest_selected_student(game : Game) -> Unit {
  let row = clampi(game.cursor_row, 0, student_count - 1)
  game.students[row].room = room_rest
  game.students[row].fatigue = maxf(0.0, game.students[row].fatigue - 4.5)
  set_message(game, game.students[row].name + " pulled back to Rest.", 1.0)
}

///|
fn burst_time_scale(game : Game) -> Float {
  if game.speed_burst_t > 0.0 {
    burst_time_multiplier
  } else {
    1.0
  }
}

///|
fn try_activate_burst(game : Game) -> Unit {
  if not(game.input.burst_pressed) {
    return
  }

  if game.speed_burst_cd <= 0.0 {
    game.speed_burst_t = burst_duration
    game.speed_burst_cd = burst_cooldown
    set_message(game, "Time burst activated.", 0.9)
  } else {
    let secs_left = (game.speed_burst_cd + 0.99).to_int()
    set_message(game, "Burst cooling: " + secs_left.to_string() + "s", 0.65)
  }
}

///|
fn apply_room_simulation(game : Game, sim_dt : Float) -> Unit {
  let ops_cost = (
      operation_cost_per_sec +
      Float::from_int(game.week - 1) * operation_cost_week_scale
    ) *
    sim_dt

  game.funds = game.funds - ops_cost
  game.reputation = game.reputation -
    (reputation_passive_drain_per_sec + Float::from_int(game.week - 1) * 0.006) *
    sim_dt

  for i = 0; i < student_count; i = i + 1 {
    if game.students[i].room == room_rest {
      game.students[i].fatigue = maxf(
        0.0,
        game.students[i].fatigue - rest_fatigue_recover_per_sec * sim_dt,
      )
    } else if game.students[i].room == room_train {
      game.funds = game.funds - train_cost_per_sec * sim_dt

      let focus = maxf(0.25, 1.0 - game.students[i].fatigue / 120.0)
      game.students[i].skill = minf(
        130.0,
        game.students[i].skill + train_skill_gain_per_sec * focus * sim_dt,
      )
      game.students[i].fatigue = minf(
        fatigue_max,
        game.students[i].fatigue + train_fatigue_gain_per_sec * sim_dt,
      )
    } else if game.students[i].room == room_sparring {
      let form = maxf(0.2, 1.0 - game.students[i].fatigue / 140.0)
      let skill_scale : Float = 0.6 + game.students[i].skill / 120.0

      game.funds = game.funds +
        spar_income_per_sec * form * skill_scale * sim_dt
      game.reputation = game.reputation +
        spar_rep_gain_per_sec * form * skill_scale * sim_dt
      game.students[i].fatigue = minf(
        fatigue_max,
        game.students[i].fatigue + spar_fatigue_gain_per_sec * sim_dt,
      )
    } else {
      let stipend = defense_stipend_per_sec +
        Float::from_int(game.week - 1) * defense_stipend_week_scale

      game.funds = game.funds + stipend * sim_dt
      game.students[i].fatigue = minf(
        fatigue_max,
        game.students[i].fatigue + defense_fatigue_gain_per_sec * sim_dt,
      )
    }

    if game.students[i].fatigue > 92.0 {
      let over = game.students[i].fatigue - 92.0
      game.students[i].skill = maxf(
        18.0,
        game.students[i].skill - over * 0.16 * sim_dt,
      )
    }
  }

  game.reputation = clampf(game.reputation, 0.0, 100.0)
}

///|
fn apply_fatigue_pressure(game : Game, sim_dt : Float) -> Unit {
  let avg_fatigue = mean_fatigue(game)

  if avg_fatigue > fatigue_penalty_start {
    let over = avg_fatigue - fatigue_penalty_start
    game.reputation = game.reputation -
      over * fatigue_rep_penalty_per_sec * sim_dt
  }

  if avg_fatigue > 96.0 {
    game.funds = game.funds - (avg_fatigue - 96.0) * 2.6 * sim_dt
  }

  if avg_fatigue >= burnout_threshold {
    set_game_over(
      game,
      "Students collapsed from burnout in week " + game.week.to_string() + ".",
    )
  }
}

///|
fn trigger_incident(game : Game) -> Unit {
  let severity = incident_severity_for(game.week) * (0.8 + random_unit() * 0.5)
  let guard_power = defense_power(game)
  let block_ratio = clampf(guard_power / (severity * 165.0 + 60.0), 0.0, 0.86)

  let funds_loss = severity *
    (96.0 + Float::from_int(game.week) * 14.0) *
    (1.0 - block_ratio)
  let reputation_loss = severity *
    (5.5 + Float::from_int(game.week) * 0.55) *
    (1.0 - block_ratio)
  let fatigue_bump = severity * (3.0 - block_ratio * 2.2)

  game.funds = game.funds - funds_loss
  game.reputation = game.reputation - reputation_loss

  for i = 0; i < student_count; i = i + 1 {
    if game.students[i].room == room_rest {
      game.students[i].fatigue = minf(
        fatigue_max,
        game.students[i].fatigue + fatigue_bump * 0.35,
      )
    } else {
      game.students[i].fatigue = minf(
        fatigue_max,
        game.students[i].fatigue + fatigue_bump,
      )
    }
  }

  game.incident_count_week = game.incident_count_week + 1
  game.total_incidents = game.total_incidents + 1
  game.incident_flash_t = 1.0

  let blocked_pct = (block_ratio * 100.0).to_int()
  set_message(
    game,
    "Incident! -" +
    funds_loss.to_int().to_string() +
    " funds, -" +
    reputation_loss.to_int().to_string() +
    " rep, defense " +
    blocked_pct.to_string() +
    "%.",
    2.4,
  )
}

///|
fn advance_week(game : Game) -> Unit {
  let avg_skill = mean_skill(game)
  let avg_fatigue = mean_fatigue(game)
  let mut spar_count = 0
  let mut defense_count = 0

  for i = 0; i < student_count; i = i + 1 {
    if game.students[i].room == room_sparring {
      spar_count = spar_count + 1
    }
    if game.students[i].room == room_defense {
      defense_count = defense_count + 1
    }
  }

  let upkeep = upkeep_for(game.week) +
    Float::from_int(student_count) * student_salary_weekly
  game.funds = game.funds - upkeep

  let eval_score = avg_skill * 0.11 +
    Float::from_int(spar_count) * 2.1 +
    Float::from_int(defense_count) * 1.4 -
    avg_fatigue * 0.09 -
    Float::from_int(game.incident_count_week) * 1.8

  game.reputation = clampf(game.reputation + eval_score, 0.0, 100.0)

  for i = 0; i < student_count; i = i + 1 {
    let recover = if game.students[i].room == room_rest {
      weekly_recovery_bonus + 4.0
    } else {
      weekly_recovery_bonus
    }
    game.students[i].fatigue = maxf(0.0, game.students[i].fatigue - recover)
  }

  if check_failure(game) {
    return
  }

  game.weeks_survived = game.week
  if game.weeks_survived > game.best_week {
    game.best_week = game.weeks_survived
  }

  let cleared_week = game.week
  game.week = game.week + 1
  game.week_duration = week_duration_for(game.week)
  game.week_time_left = game.week_duration
  game.incident_count_week = 0
  game.incident_timer = random_incident_delay(game.week)
  game.week_banner_t = 2.6

  set_message(
    game,
    "Week " +
    cleared_week.to_string() +
    " cleared. Week " +
    game.week.to_string() +
    " pressure rises.",
    2.6,
  )
}

///|
fn update_title_state(game : Game) -> Unit {
  if game.input.start_pressed {
    start_new_run(game)
  }
}

///|
fn update_playing_state(game : Game, dt : Float) -> Unit {
  if game.input.pause_pressed {
    game.state = state_paused
    set_message(game, "Paused. Press P to continue.", 99.0)
    return
  }

  if game.input.move_x != 0 || game.input.move_y != 0 {
    move_cursor(game, game.input.move_x, game.input.move_y)
  }

  if game.input.confirm_pressed {
    assign_selected_room(game)
  }

  if game.input.cancel_pressed {
    rest_selected_student(game)
  }

  try_activate_burst(game)

  let sim_dt = dt * burst_time_scale(game)

  apply_room_simulation(game, sim_dt)
  apply_fatigue_pressure(game, sim_dt)

  if game.state == state_game_over || check_failure(game) {
    return
  }

  game.incident_timer = game.incident_timer - sim_dt
  if game.incident_timer <= 0.0 {
    trigger_incident(game)

    if game.state == state_game_over || check_failure(game) {
      return
    }

    game.incident_timer = random_incident_delay(game.week)
  }

  game.week_time_left = game.week_time_left - sim_dt
  if game.week_time_left <= 0.0 {
    advance_week(game)
  }
}

///|
fn update_paused_state(game : Game) -> Unit {
  if game.input.pause_pressed {
    game.state = state_playing
    set_message(game, "Dojo resumed.", 1.1)
  }
}

///|
fn update_game_over_state(game : Game) -> Unit {
  if game.input.start_pressed {
    start_new_run(game)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  game.scene_t = game.scene_t + dt
  game.message_t = maxf(0.0, game.message_t - dt)
  game.speed_burst_t = maxf(0.0, game.speed_burst_t - dt)
  game.speed_burst_cd = maxf(0.0, game.speed_burst_cd - dt)
  game.incident_flash_t = maxf(0.0, game.incident_flash_t - dt * 1.8)
  game.week_banner_t = maxf(0.0, game.week_banner_t - dt)

  if game.input.restart_pressed {
    start_new_run(game)
    return
  }

  if game.state == state_title {
    update_title_state(game)
  } else if game.state == state_playing {
    update_playing_state(game, dt)
  } else if game.state == state_paused {
    update_paused_state(game)
  } else {
    update_game_over_state(game)
  }
}
