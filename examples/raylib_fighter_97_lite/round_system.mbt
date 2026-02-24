///|
fn wrap_index(value : Int, size : Int) -> Int {
  let mut v = value
  while v < 0 {
    v += size
  }
  while v >= size {
    v -= size
  }
  v
}

///|
fn reset_round_fighters(game : Game) -> Unit {
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  let a1 = fighter_archetype(game, p1)
  let a2 = fighter_archetype(game, p2)

  p1.x = center_line_x - 220.0
  p2.x = center_line_x + 220.0
  p1.y = floor_y
  p2.y = floor_y
  p1.facing = facing_right
  p2.facing = facing_left

  p1.health = health_max
  p2.health = health_max
  p1.guard_meter = fighter_total_guard(a1)
  p2.guard_meter = fighter_total_guard(a2)

  p1.is_cpu = false
  p2.is_cpu = game.mode_vs_cpu

  reset_fighter_round_state(p1)
  reset_fighter_round_state(p2)
}

///|
fn assign_selected_characters(game : Game) -> Unit {
  game.fighters[0].archetype_index = clampi(
    game.select_cursor_p1,
    0,
    roster_count - 1,
  )
  game.fighters[1].archetype_index = clampi(
    game.select_cursor_p2,
    0,
    roster_count - 1,
  )

  game.fighters[0].round_wins = 0
  game.fighters[1].round_wins = 0
  game.fighters[0].super_meter = 0
  game.fighters[1].super_meter = 0
}

///|
fn start_round_intro(game : Game) -> Unit {
  game.state = state_intro
  game.intro_timer = intro_duration
  game.round_timer = if game.mode_training { -1.0 } else { round_time_start }
  game.winner_slot = winner_none
  game.announcer_text = if game.mode_training {
    "TRAINING"
  } else {
    "ROUND \{game.round_index}"
  }
  game.announcer_timer = if game.mode_training { 0.8 } else { 1.0 }
  game.training_adv_text = ""
  game.training_adv_timer = 0.0
  game.dramatic_freeze = 0
  reset_round_fighters(game)
}

///|
fn start_match(game : Game) -> Unit {
  game.round_index = 1
  assign_selected_characters(game)
  start_round_intro(game)
}

///|
fn start_next_round(game : Game) -> Unit {
  game.round_index += 1

  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  if game.winner_slot == 0 {
    p1.super_meter = clampi(p1.super_meter + 12, 0, super_max)
    p2.super_meter = clampi(p2.super_meter + 24, 0, super_max)
  } else if game.winner_slot == 1 {
    p1.super_meter = clampi(p1.super_meter + 24, 0, super_max)
    p2.super_meter = clampi(p2.super_meter + 12, 0, super_max)
  } else {
    p1.super_meter = clampi(p1.super_meter + 18, 0, super_max)
    p2.super_meter = clampi(p2.super_meter + 18, 0, super_max)
  }

  start_round_intro(game)
}

///|
fn choose_round_winner(game : Game) -> Int {
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  if p1.health <= 0 && p2.health <= 0 {
    return winner_draw
  }
  if p1.health <= 0 {
    return 1
  }
  if p2.health <= 0 {
    return 0
  }

  if p1.health > p2.health {
    0
  } else if p2.health > p1.health {
    1
  } else {
    winner_draw
  }
}

///|
fn enter_round_over(game : Game, winner : Int) -> Unit {
  game.state = state_round_over
  game.round_over_timer = round_over_duration
  game.winner_slot = winner

  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  if winner == 0 {
    p1.round_wins += 1
    p1.action = action_victory
    p1.action_elapsed = 0.0
    p1.action_frame = 0
    p2.action = action_knockdown
    p2.knockdown = 80
    game.announcer_text = "P1 WINS THE ROUND"
    game.announcer_timer = 1.8
  } else if winner == 1 {
    p2.round_wins += 1
    p2.action = action_victory
    p2.action_elapsed = 0.0
    p2.action_frame = 0
    p1.action = action_knockdown
    p1.knockdown = 80
    game.announcer_text = "P2 WINS THE ROUND"
    game.announcer_timer = 1.8
  } else {
    game.announcer_text = "DOUBLE KO"
    game.announcer_timer = 1.8
  }
}

///|
fn enter_match_over(game : Game) -> Unit {
  game.state = state_match_over
  game.match_over_timer = match_over_duration

  if game.fighters[0].round_wins > game.fighters[1].round_wins {
    game.winner_slot = 0
    game.announcer_text = "P1 VICTORY"
  } else if game.fighters[1].round_wins > game.fighters[0].round_wins {
    game.winner_slot = 1
    game.announcer_text = "P2 VICTORY"
  } else {
    game.winner_slot = winner_draw
    game.announcer_text = "MATCH DRAW"
  }
  game.announcer_timer = 3.4
}

///|
fn update_title(game : Game, dt : Float) -> Unit {
  game.title_blink += dt * title_blink_speed
  game.bg_scroll += dt * 12.0

  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.state = state_select
    game.select_blink = 0.0
    game.p1_confirmed = false
    game.p2_confirmed = false
  }

  if @raylib.is_key_pressed(@raylib.KeyF1) {
    game.debug_overlay = not(game.debug_overlay)
  }
}

///|
fn update_select(game : Game, dt : Float) -> Unit {
  game.select_blink += dt * select_blink_speed
  game.bg_scroll += dt * 10.0

  if @raylib.is_key_pressed(@raylib.KeyT) {
    game.mode_training = not(game.mode_training)
    if game.mode_training {
      game.mode_vs_cpu = true
      game.p2_confirmed = true
    } else {
      game.p2_confirmed = false
    }
  }

  if @raylib.is_key_pressed(@raylib.KeySpace) {
    game.mode_vs_cpu = not(game.mode_vs_cpu)
    if game.mode_vs_cpu {
      game.p2_confirmed = true
    } else {
      game.p2_confirmed = false
    }
  }

  if game.mode_training {
    game.mode_vs_cpu = true
  }

  if @raylib.is_key_pressed(@raylib.KeyA) {
    game.select_cursor_p1 = wrap_index(game.select_cursor_p1 - 1, roster_count)
    game.p1_confirmed = false
  }
  if @raylib.is_key_pressed(@raylib.KeyD) {
    game.select_cursor_p1 = wrap_index(game.select_cursor_p1 + 1, roster_count)
    game.p1_confirmed = false
  }

  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.select_cursor_p2 = wrap_index(game.select_cursor_p2 - 1, roster_count)
    if not(game.mode_vs_cpu) {
      game.p2_confirmed = false
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.select_cursor_p2 = wrap_index(game.select_cursor_p2 + 1, roster_count)
    if not(game.mode_vs_cpu) {
      game.p2_confirmed = false
    }
  }

  if game.mode_vs_cpu {
    game.p2_confirmed = true
  }

  if @raylib.is_key_pressed(@raylib.KeyF) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.p1_confirmed = true
  }

  if not(game.mode_vs_cpu) {
    if @raylib.is_key_pressed(@raylib.KeyU) ||
      @raylib.is_key_pressed(@raylib.KeyEnter) {
      game.p2_confirmed = true
    }
  }

  if @raylib.is_key_pressed(@raylib.KeyBackspace) {
    game.p1_confirmed = false
    if not(game.mode_vs_cpu) {
      game.p2_confirmed = false
    }
  }

  if game.p1_confirmed && game.p2_confirmed {
    start_match(game)
  }

  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = state_title
  }
}

///|
fn update_intro(game : Game, dt : Float) -> Unit {
  game.bg_scroll += dt * 20.0
  update_camera(game, dt)
  update_particles(game, dt)

  game.intro_timer -= dt
  if game.intro_timer <= 0.0 {
    game.intro_timer = 0.0
    game.state = state_fight
    game.announcer_text = if game.mode_training { "TRAINING" } else { "FIGHT!" }
    game.announcer_timer = if game.mode_training { 0.8 } else { 0.9 }

    let p1 = game.fighters[0]
    let p2 = game.fighters[1]
    if p1.action == action_intro {
      p1.action = action_idle
      p1.action_elapsed = 0.0
      p1.action_frame = 0
    }
    if p2.action == action_intro {
      p2.action = action_idle
      p2.action_elapsed = 0.0
      p2.action_frame = 0
    }
  }
}

///|
fn recover_fighter_resources(game : Game, dt : Float) -> Unit {
  for i = 0; i < max_players; i = i + 1 {
    let fighter = game.fighters[i]
    let archetype = fighter_archetype(game, fighter)

    if fighter.action != action_blockstun && fighter.action != action_hitstun {
      add_guard(fighter, guard_recover_per_sec * dt, archetype)
    }
  }
}

///|
fn update_training_resources(game : Game, dt : Float) -> Unit {
  for i = 0; i < max_players; i = i + 1 {
    let fighter = game.fighters[i]
    let archetype = fighter_archetype(game, fighter)

    if fighter.health <= 0 {
      fighter.health = 1
    } else if fighter.health < health_max {
      fighter.health = clampi(
        fighter.health + (training_health_regen_per_sec * dt).to_int(),
        1,
        health_max,
      )
    }

    fighter.super_meter = super_max
    add_guard(fighter, guard_recover_per_sec * dt * 2.8, archetype)
  }
}

///|
fn reset_training_fight(game : Game) -> Unit {
  reset_round_fighters(game)
  for slot = 0; slot < max_players; slot = slot + 1 {
    let fighter = game.fighters[slot]
    let archetype = fighter_archetype(game, fighter)
    fighter.health = health_max
    fighter.guard_meter = fighter_total_guard(archetype)
    fighter.super_meter = super_max
    set_idle_state(fighter)
    fighter.input = InputState::new()
  }
  game.round_timer = -1.0
  game.dramatic_freeze = 0
  game.camera_shake = 0.0
  game.announcer_text = "RESET"
  game.announcer_timer = 0.32
  game.training_adv_text = ""
  game.training_adv_timer = 0.0
}

///|
fn update_fight(game : Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = state_pause
    game.pause_blink = 0.0
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = state_select
    game.p1_confirmed = false
    game.p2_confirmed = false
    return
  }

  if game.mode_training && @raylib.is_key_pressed(@raylib.KeyR) {
    reset_training_fight(game)
    return
  }

  game.bg_scroll += dt * 30.0
  update_inputs(game, dt)

  if game.dramatic_freeze > 0 {
    game.dramatic_freeze -= 1
    update_camera(game, dt)
    update_particles(game, dt)
    return
  }

  update_facing(game)

  for slot = 0; slot < max_players; slot = slot + 1 {
    update_fighter_core(game, slot, dt)
  }

  resolve_push_collision(game)
  update_facing(game)

  let threw = update_throws(game)
  if not(threw) {
    update_combat(game)
  }
  recover_fighter_resources(game, dt)
  if game.mode_training {
    update_training_resources(game, dt)
  }

  update_particles(game, dt)
  update_camera(game, dt)

  if game.mode_training {
    return
  }

  game.round_timer -= dt
  if game.round_timer < 0.0 {
    game.round_timer = 0.0
  }

  if game.fighters[0].health <= 0 ||
    game.fighters[1].health <= 0 ||
    game.round_timer <= 0.0 {
    let winner = choose_round_winner(game)
    enter_round_over(game, winner)
  }
}

///|
fn update_round_over(game : Game, dt : Float) -> Unit {
  game.bg_scroll += dt * 16.0
  update_particles(game, dt)
  update_camera(game, dt)

  for slot = 0; slot < max_players; slot = slot + 1 {
    let fighter = game.fighters[slot]
    update_fighter_recovery_state(fighter)
    update_stun_and_knockdown(fighter)
    update_fighter_action_frame(fighter, dt)
    let archetype = fighter_archetype(game, fighter)
    integrate_fighter_physics(fighter, archetype, dt)
  }

  game.round_over_timer -= dt
  if game.round_over_timer > 0.0 {
    return
  }

  if game.fighters[0].round_wins >= max_round_wins ||
    game.fighters[1].round_wins >= max_round_wins {
    enter_match_over(game)
  } else {
    start_next_round(game)
  }
}

///|
fn update_match_over(game : Game, dt : Float) -> Unit {
  game.bg_scroll += dt * 12.0
  update_particles(game, dt)
  update_camera(game, dt)

  game.match_over_timer -= dt
  if game.match_over_timer < 0.0 {
    game.match_over_timer = 0.0
  }

  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    game.match_over_timer <= 0.0 {
    game.state = state_select
    game.p1_confirmed = false
    game.p2_confirmed = false
  }
}

///|
fn update_pause(game : Game, dt : Float) -> Unit {
  game.pause_blink += dt * 4.5
  update_particles(game, dt)
  update_camera(game, dt)

  if @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = state_fight
  }

  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = state_select
    game.p1_confirmed = false
    game.p2_confirmed = false
  }
}

///|
fn update_announcer(game : Game, dt : Float) -> Unit {
  if game.announcer_timer > 0.0 {
    game.announcer_timer -= dt
    if game.announcer_timer < 0.0 {
      game.announcer_timer = 0.0
      game.announcer_text = ""
    }
  }

  if game.stage_flash > 0.0 {
    game.stage_flash -= dt
    if game.stage_flash < 0.0 {
      game.stage_flash = 0.0
    }
  }

  if game.hud_flash > 0.0 {
    game.hud_flash -= dt
    if game.hud_flash < 0.0 {
      game.hud_flash = 0.0
    }
  }

  if game.training_adv_timer > 0.0 {
    game.training_adv_timer -= dt
    if game.training_adv_timer < 0.0 {
      game.training_adv_timer = 0.0
      game.training_adv_text = ""
    }
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  game.frame_count += 1
  update_announcer(game, dt)

  if game.state == state_title {
    update_title(game, dt)
  } else if game.state == state_select {
    update_select(game, dt)
  } else if game.state == state_intro {
    update_intro(game, dt)
  } else if game.state == state_fight {
    update_fight(game, dt)
  } else if game.state == state_round_over {
    update_round_over(game, dt)
  } else if game.state == state_match_over {
    update_match_over(game, dt)
  } else if game.state == state_pause {
    update_pause(game, dt)
  }
}
