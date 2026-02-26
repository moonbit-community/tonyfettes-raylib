///|
fn set_message(game : Game, text : String, ttl : Float) -> Unit {
  game.message = text
  game.message_t = ttl
}

///|
fn clear_incidents(game : Game) -> Unit {
  for i = 0; i < game.incidents.length(); i = i + 1 {
    game.incidents[i].active = false
    game.incidents[i].x = 0
    game.incidents[i].y = 0
    game.incidents[i].culprit = 0
    game.incidents[i].timer = 0.0
    game.incidents[i].severity = 1
    game.incidents[i].pulse_t = 0.0
  }
}

///|
fn reset_case(game : Game) -> Unit {
  for i = 0; i < game.clues.length(); i = i + 1 {
    game.clues[i].discovered = false
    game.clues[i].glow_t = 0.0
  }

  for i = 0; i < game.suspects.length(); i = i + 1 {
    game.suspects[i].deduction_unlocked = false
    game.suspects[i].suspicion = 0.0
  }

  for i = 0; i < game.chain_progress.length(); i = i + 1 {
    game.chain_progress[i] = 0
  }
  for i = 0; i < game.evidence_score.length(); i = i + 1 {
    game.evidence_score[i] = 0
  }

  clear_incidents(game)

  game.state = state_playing
  game.cursor_x = city_cols / 2
  game.cursor_y = city_rows / 2
  game.marked_suspect = -1
  game.trust = trust_max
  game.score = 0
  game.case_time = time_limit_s
  game.spawn_t = 1.8
  game.focus_t = 0.0
  game.focus_cd = 0.0
  game.city_time = 0.0
  game.solved_incidents = 0
  game.failed_incidents = 0
  game.wrong_accusations = 0
  game.clue_found = 0

  set_message(game, "Case opened. Gather clues and stop incidents.", 2.2)
}

///|
fn active_incident_count(game : Game) -> Int {
  let mut count = 0
  for i = 0; i < game.incidents.length(); i = i + 1 {
    if game.incidents[i].active {
      count = count + 1
    }
  }
  count
}

///|
fn suspect_index_at_cell(game : Game, cell_x : Int, cell_y : Int) -> Int {
  for i = 0; i < game.suspects.length(); i = i + 1 {
    if game.suspects[i].home_x == cell_x && game.suspects[i].home_y == cell_y {
      return i
    }
  }
  -1
}

///|
fn clue_index_at_cell(
  game : Game,
  cell_x : Int,
  cell_y : Int,
  undiscovered_only : Bool,
) -> Int {
  for i = 0; i < game.clues.length(); i = i + 1 {
    if game.clues[i].x != cell_x || game.clues[i].y != cell_y {
      continue
    }
    if undiscovered_only && game.clues[i].discovered {
      continue
    }
    return i
  }
  -1
}

///|
fn incident_index_at_cell(game : Game, cell_x : Int, cell_y : Int) -> Int {
  for i = 0; i < game.incidents.length(); i = i + 1 {
    if game.incidents[i].active &&
      game.incidents[i].x == cell_x &&
      game.incidents[i].y == cell_y {
      return i
    }
  }
  -1
}

///|
fn completed_chains(game : Game, suspect : Int) -> Int {
  if suspect < 0 || suspect >= suspect_count {
    return 0
  }

  let mut done = 0
  for chain = 0; chain < chains_per_suspect; chain = chain + 1 {
    let slot = chain_slot(suspect, chain)
    if game.chain_progress[slot] >= clue_steps_per_chain {
      done = done + 1
    }
  }
  done
}

///|
fn suspect_confidence(game : Game, suspect : Int) -> Int {
  if suspect < 0 || suspect >= suspect_count {
    return 0
  }

  let mut value = game.evidence_score[suspect] +
    completed_chains(game, suspect) * 8
  if game.suspects[suspect].deduction_unlocked {
    value = value + 8
  }
  value
}

///|
fn update_suspect_suspicion(game : Game) -> Unit {
  for i = 0; i < game.suspects.length(); i = i + 1 {
    let conf = Float::from_int(suspect_confidence(game, i))
    game.suspects[i].suspicion = clamp01(conf / 42.0)
  }
}

///|
fn unlock_deduction_if_ready(game : Game, suspect : Int) -> Unit {
  if suspect < 0 || suspect >= suspect_count {
    return
  }
  if game.suspects[suspect].deduction_unlocked {
    return
  }

  if completed_chains(game, suspect) >= deduction_chains_to_unlock {
    game.suspects[suspect].deduction_unlocked = true
    game.score = game.score + score_deduction_unlock
    game.trust = minf(trust_max, game.trust + trust_gain_deduction)
    set_message(
      game,
      "Deduction unlocked: " + game.suspects[suspect].name + ".",
      1.8,
    )
  }
}

///|
fn discover_clue(game : Game, clue_index : Int) -> Unit {
  if clue_index < 0 || clue_index >= game.clues.length() {
    return
  }
  if game.clues[clue_index].discovered {
    return
  }

  let suspect = game.clues[clue_index].suspect
  let chain = game.clues[clue_index].chain
  let slot = chain_slot(suspect, chain)

  game.clues[clue_index].discovered = true
  game.clues[clue_index].glow_t = 1.35

  let mut evidence_gain = evidence_per_clue
  if game.focus_t > 0.0 {
    evidence_gain = evidence_gain + evidence_focus_bonus
  }

  game.evidence_score[suspect] = game.evidence_score[suspect] + evidence_gain
  if game.chain_progress[slot] < clue_steps_per_chain {
    game.chain_progress[slot] = game.chain_progress[slot] + 1
  }

  game.clue_found = game.clue_found + 1
  game.score = game.score + score_clue + evidence_gain * 2
  game.trust = minf(trust_max, game.trust + trust_gain_clue)

  if game.chain_progress[slot] == clue_steps_per_chain {
    game.score = game.score + score_chain_complete
    game.trust = minf(trust_max, game.trust + trust_gain_chain)
    set_message(
      game,
      "Chain sealed for " + game.suspects[suspect].name + ".",
      1.6,
    )
  } else {
    set_message(
      game,
      "Clue archived on " + game.suspects[suspect].name + ".",
      1.3,
    )
  }

  unlock_deduction_if_ready(game, suspect)
}

///|
fn alloc_incident_slot(game : Game) -> Int {
  for i = 0; i < game.incidents.length(); i = i + 1 {
    if not(game.incidents[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_timer = game.incidents[0].timer
  for i = 1; i < game.incidents.length(); i = i + 1 {
    if game.incidents[i].timer > best_timer {
      best = i
      best_timer = game.incidents[i].timer
    }
  }
  best
}

///|
fn spawn_incident(game : Game) -> Unit {
  let slot = alloc_incident_slot(game)
  let roll = randi(0, 99)
  let severity = if roll < 48 { 1 } else if roll < 82 { 2 } else { 3 }

  let culprit = randi(0, suspect_count - 1)

  let mut cell_x = randi(0, city_cols - 1)
  let mut cell_y = randi(0, city_rows - 1)
  let mut tries = 0
  while tries < district_count {
    if incident_index_at_cell(game, cell_x, cell_y) < 0 &&
      suspect_index_at_cell(game, cell_x, cell_y) < 0 {
      break
    }
    cell_x = (cell_x + 2 + tries) % city_cols
    cell_y = (cell_y + 1 + tries * 2) % city_rows
    tries = tries + 1
  }

  game.incidents[slot].active = true
  game.incidents[slot].x = cell_x
  game.incidents[slot].y = cell_y
  game.incidents[slot].culprit = culprit
  game.incidents[slot].severity = severity
  game.incidents[slot].timer = maxf(
    6.0,
    incident_timer_for_severity(severity) + randf(-1.4, 1.6),
  )
  game.incidents[slot].pulse_t = 0.0

  let district_id = cell_index(cell_x, cell_y)
  set_message(
    game,
    "Incident at district #" + district_id.to_string() + ".",
    1.3,
  )
}

///|
fn update_incidents(game : Game, dt : Float) -> Unit {
  let slowdown : Float = if game.focus_t > 0.0 { 0.72 } else { 1.0 }

  for i = 0; i < game.incidents.length(); i = i + 1 {
    if not(game.incidents[i].active) {
      continue
    }

    let sev_scale = Float::from_int(game.incidents[i].severity - 1)
    game.incidents[i].pulse_t = game.incidents[i].pulse_t +
      dt * (1.0 + sev_scale * 0.6)
    game.incidents[i].timer = game.incidents[i].timer -
      dt * slowdown * (1.0 + sev_scale * 0.25)

    if game.incidents[i].timer <= 0.0 {
      game.incidents[i].active = false
      game.failed_incidents = game.failed_incidents + 1
      game.score = maxi(0, game.score - 24 - game.incidents[i].severity * 10)
      game.trust = maxf(
        0.0,
        game.trust -
        trust_penalty_missed_incident -
        Float::from_int(game.incidents[i].severity) * 2.1,
      )
      set_message(game, "Incident unresolved. City trust slips.", 1.6)
    }
  }
}

///|
fn incident_pressure(game : Game) -> Float {
  let mut pressure : Float = 0.0
  for i = 0; i < game.incidents.length(); i = i + 1 {
    if game.incidents[i].active {
      pressure = pressure + Float::from_int(game.incidents[i].severity) * 0.34
    }
  }
  pressure
}

///|
fn update_district_pulses(game : Game, dt : Float) -> Unit {
  game.city_time = game.city_time + dt

  for i = 0; i < game.pulses.length(); i = i + 1 {
    let x = i % city_cols
    let y = i / city_cols

    let mut heat : Float = 0.24 +
      0.18 * sinf(game.city_time * 0.9 + game.pulses[i].drift)

    if x == game.cursor_x && y == game.cursor_y {
      heat = heat + 0.15
    }

    for j = 0; j < game.incidents.length(); j = j + 1 {
      if not(game.incidents[j].active) {
        continue
      }

      let dx0 = x - game.incidents[j].x
      let adx = if dx0 < 0 { -dx0 } else { dx0 }
      let dy0 = y - game.incidents[j].y
      let ady = if dy0 < 0 { -dy0 } else { dy0 }

      if adx == 0 && ady == 0 {
        heat = heat + 0.42 + Float::from_int(game.incidents[j].severity) * 0.09
      } else if adx + ady == 1 {
        heat = heat + 0.12
      }
    }

    if clue_index_at_cell(game, x, y, true) >= 0 {
      heat = heat + 0.1
    }

    if game.focus_t > 0.0 {
      let dx1 = x - game.cursor_x
      let adx = if dx1 < 0 { -dx1 } else { dx1 }
      let dy1 = y - game.cursor_y
      let ady = if dy1 < 0 { -dy1 } else { dy1 }
      if adx + ady <= 1 {
        heat = heat + 0.24
      }
    }

    game.pulses[i].heat = clamp01(heat)
  }
}

///|
fn move_cursor(game : Game) -> Unit {
  if game.input_dx == 0 && game.input_dy == 0 {
    return
  }

  game.cursor_x = clampi(game.cursor_x + game.input_dx, 0, city_cols - 1)
  game.cursor_y = clampi(game.cursor_y + game.input_dy, 0, city_rows - 1)
}

///|
fn handle_focus_input(game : Game) -> Unit {
  if not(game.input_focus_press) {
    return
  }

  if game.focus_cd <= 0.0 {
    game.focus_t = focus_duration
    game.focus_cd = focus_cooldown
    set_message(game, "Focus engaged.", 0.9)
  } else {
    set_message(
      game,
      "Focus cooling: " + game.focus_cd.to_int().to_string() + "s",
      0.8,
    )
  }
}

///|
fn handle_cancel_or_mark(game : Game) -> Unit {
  if not(game.input_cancel_press) {
    return
  }

  let suspect = suspect_index_at_cell(game, game.cursor_x, game.cursor_y)
  if suspect >= 0 {
    game.marked_suspect = suspect
    set_message(
      game,
      "Marked suspect: " + game.suspects[suspect].name + ".",
      1.5,
    )
  } else if game.marked_suspect >= 0 {
    game.marked_suspect = -1
    set_message(game, "Marked suspect cleared.", 1.1)
  } else {
    set_message(game, "No suspect at cursor.", 1.0)
  }
}

///|
fn attempt_incident_resolution(game : Game, incident_index : Int) -> Unit {
  if incident_index < 0 || incident_index >= game.incidents.length() {
    return
  }

  if game.marked_suspect < 0 {
    game.trust = maxf(0.0, game.trust - 1.8)
    set_message(game, "Mark a suspect with K before accusing.", 1.4)
    return
  }

  let accused = game.marked_suspect
  let culprit = game.incidents[incident_index].culprit
  let severity = game.incidents[incident_index].severity

  if accused == culprit {
    let mut effective_confidence = suspect_confidence(game, accused)
    if game.suspects[accused].deduction_unlocked {
      effective_confidence = effective_confidence + 4
    }
    if game.focus_t > 0.0 {
      effective_confidence = effective_confidence + 6
    }

    if effective_confidence >= incident_need_score(severity) {
      game.incidents[incident_index].active = false
      game.solved_incidents = game.solved_incidents + 1
      game.score = game.score +
        score_incident_resolve +
        severity * 70 +
        effective_confidence
      game.trust = minf(
        trust_max,
        game.trust + trust_gain_resolve + Float::from_int(severity),
      )
      set_message(
        game,
        "Incident resolved. Culprit: " + game.suspects[accused].name + ".",
        1.8,
      )
    } else {
      game.wrong_accusations = game.wrong_accusations + 1
      game.trust = maxf(0.0, game.trust - trust_penalty_wrong_accuse * 0.4)
      game.score = maxi(0, game.score - score_wrong_accuse_penalty / 2)
      set_message(game, "Evidence chain incomplete. Accusation blocked.", 1.7)
    }
  } else {
    game.wrong_accusations = game.wrong_accusations + 1
    game.score = maxi(
      0,
      game.score - score_wrong_accuse_penalty - severity * 35,
    )
    game.trust = maxf(
      0.0,
      game.trust - trust_penalty_wrong_accuse - Float::from_int(severity) * 2.2,
    )
    game.incidents[incident_index].timer = maxf(
      1.0,
      game.incidents[incident_index].timer - 4.0,
    )
    set_message(game, "Wrong accusation. Trust drops hard.", 1.8)
  }
}

///|
fn inspect_suspect(game : Game, suspect : Int) -> Unit {
  if suspect < 0 || suspect >= suspect_count {
    return
  }

  let chains = completed_chains(game, suspect)
  let conf = suspect_confidence(game, suspect)
  let unlock_word = if game.suspects[suspect].deduction_unlocked {
    "deduction ready"
  } else {
    "deduction locked"
  }

  set_message(
    game,
    game.suspects[suspect].name +
    ": confidence " +
    conf.to_string() +
    ", chains " +
    chains.to_string() +
    ", " +
    unlock_word +
    ".",
    1.6,
  )
}

///|
fn handle_inspect(game : Game) -> Unit {
  if not(game.input_inspect_press) {
    return
  }

  let incident = incident_index_at_cell(game, game.cursor_x, game.cursor_y)
  if incident >= 0 {
    attempt_incident_resolution(game, incident)
    return
  }

  let clue = clue_index_at_cell(game, game.cursor_x, game.cursor_y, true)
  if clue >= 0 {
    discover_clue(game, clue)
    return
  }

  let suspect = suspect_index_at_cell(game, game.cursor_x, game.cursor_y)
  if suspect >= 0 {
    inspect_suspect(game, suspect)
    return
  }

  set_message(game, "No lead in this district.", 1.0)
}

///|
fn update_clue_glow(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.clues.length(); i = i + 1 {
    if game.clues[i].glow_t > 0.0 {
      game.clues[i].glow_t = maxf(0.0, game.clues[i].glow_t - dt)
    }
  }
}

///|
fn update_spawn_timer(game : Game, dt : Float) -> Unit {
  game.spawn_t = game.spawn_t - dt
  if game.spawn_t > 0.0 {
    return
  }

  spawn_incident(game)

  let solved_scale = Float::from_int(game.solved_incidents) * 0.08
  let mut next_spawn = incident_spawn_base - solved_scale + randf(-0.6, 0.9)
  next_spawn = maxf(incident_spawn_floor, next_spawn)

  if game.focus_t > 0.0 {
    next_spawn = next_spawn + 0.6
  }

  game.spawn_t = next_spawn
}

///|
fn update_runtime_meters(game : Game, dt : Float) -> Unit {
  if game.focus_t > 0.0 {
    game.focus_t = maxf(0.0, game.focus_t - dt)
  }
  if game.focus_cd > 0.0 {
    game.focus_cd = maxf(0.0, game.focus_cd - dt)
  }

  game.case_time = maxf(0.0, game.case_time - dt)

  let focus_factor : Float = if game.focus_t > 0.0 { 0.78 } else { 1.0 }
  game.trust = maxf(
    0.0,
    game.trust -
    dt * (trust_decay_base + incident_pressure(game)) * focus_factor,
  )
}

///|
fn transition_to_game_over(game : Game, reason : String) -> Unit {
  if game.score > game.best_score {
    game.best_score = game.score
  }
  game.state = state_game_over
  set_message(game, reason + " Press J or R to restart.", 99.0)
}

///|
fn update_title_state(game : Game, dt : Float) -> Unit {
  update_district_pulses(game, dt)

  if game.input_inspect_press {
    reset_case(game)
  }
}

///|
fn update_playing_state(game : Game, dt : Float) -> Unit {
  if game.input_pause_press {
    game.state = state_paused
    set_message(game, "Investigation paused.", 99.0)
    return
  }

  move_cursor(game)
  handle_cancel_or_mark(game)
  handle_focus_input(game)
  handle_inspect(game)

  update_runtime_meters(game, dt)
  update_spawn_timer(game, dt)
  update_incidents(game, dt)
  update_clue_glow(game, dt)
  update_district_pulses(game, dt)
  update_suspect_suspicion(game)

  if game.trust <= 0.0 {
    transition_to_game_over(game, "City trust collapsed.")
  } else if game.case_time <= 0.0 {
    transition_to_game_over(game, "Case file expired.")
  }
}

///|
fn update_paused_state(game : Game, dt : Float) -> Unit {
  update_district_pulses(game, dt)

  if game.input_pause_press || game.input_cancel_press {
    game.state = state_playing
    set_message(game, "Investigation resumed.", 1.1)
  }
}

///|
fn update_game_over_state(game : Game, dt : Float) -> Unit {
  update_district_pulses(game, dt)

  if game.input_inspect_press {
    reset_case(game)
  } else if game.input_cancel_press {
    game.state = state_title
    set_message(game, "Press J to reopen the case.", 99.0)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  let step = clampf(dt, 0.0, 0.05)

  if game.input_restart_press {
    reset_case(game)
  }

  if game.message_t > 0.0 {
    game.message_t = maxf(0.0, game.message_t - step)
  }

  if game.state == state_title {
    update_title_state(game, step)
  } else if game.state == state_playing {
    update_playing_state(game, step)
  } else if game.state == state_paused {
    update_paused_state(game, step)
  } else {
    update_game_over_state(game, step)
  }
}
