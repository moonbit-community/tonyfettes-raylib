///|
fn ai_set_mode_from_distance(fighter : Fighter, distance : Float) -> Unit {
  if distance > 330.0 {
    fighter.ai_mode = ai_mode_rush
  } else if distance < 120.0 {
    fighter.ai_mode = ai_mode_evade
  } else {
    fighter.ai_mode = ai_mode_zone
  }
}

///|
fn ai_reset_flags(fighter : Fighter) -> Unit {
  fighter.ai_wants_jump = false
  fighter.ai_wants_special = false
  fighter.ai_wants_super = false
  fighter.ai_wants_throw = false
}

///|
fn ai_should_block(
  game : Game,
  _fighter : Fighter,
  opponent : Fighter,
  distance : Float,
) -> Bool {
  if opponent.action != action_attack {
    return false
  }
  if distance > 170.0 {
    return false
  }
  let pressure = if opponent.current_move.move_kind == move_kind_super {
    cpu_block_chance + 0.18
  } else {
    cpu_block_chance
  }
  rand_chance(game, pressure)
}

///|
fn ai_pick_desired_axis(
  game : Game,
  fighter : Fighter,
  opponent : Fighter,
  distance : Float,
) -> (Int, Int) {
  let dx = opponent.x - fighter.x
  let toward = if dx > 0.0 { 1 } else { -1 }

  if ai_should_block(game, fighter, opponent, distance) {
    return (-toward, if rand_chance(game, 0.35) { 1 } else { 0 })
  }

  if fighter.ai_mode == ai_mode_rush {
    if distance > 120.0 {
      (toward, 0)
    } else {
      (if rand_chance(game, 0.3) { toward } else { 0 }, 0)
    }
  } else if fighter.ai_mode == ai_mode_evade {
    if distance < 200.0 {
      (-toward, 0)
    } else {
      (0, 0)
    }
  } else if distance > 240.0 {
    (toward, 0)
  } else if distance < 140.0 {
    (-toward, if rand_chance(game, 0.25) { 1 } else { 0 })
  } else {
    (if rand_chance(game, 0.5) { toward } else { 0 }, 0)
  }
}

///|
fn ai_try_jump(game : Game, fighter : Fighter, distance : Float) -> Bool {
  if not(fighter.on_ground) {
    return false
  }
  if distance < 130.0 || distance > 360.0 {
    return false
  }
  rand_chance(game, cpu_jump_chance)
}

///|
fn ai_try_attack(
  game : Game,
  fighter : Fighter,
  opponent : Fighter,
  distance : Float,
) -> Unit {
  if fighter.action == action_attack ||
    fighter.action == action_hitstun ||
    fighter.action == action_blockstun ||
    fighter.action == action_knockdown ||
    fighter.action == action_wakeup {
    return
  }

  if fighter.ai_cooldown > 0.0 {
    fighter.ai_cooldown -= frame_dt
    if fighter.ai_cooldown < 0.0 {
      fighter.ai_cooldown = 0.0
    }
    return
  }

  let opp_air = not(opponent.on_ground)

  if fighter.on_ground &&
    opponent.on_ground &&
    distance <= throw_distance * 0.9 &&
    rand_chance(game, 0.18) {
    fighter.ai_wants_throw = true
    fighter.ai_cooldown = cpu_reaction_base + rand_rangef(game, 0.04, 0.1)
    return
  }

  if fighter.super_meter >= super_cost &&
    distance > 90.0 &&
    distance < 240.0 &&
    rand_chance(game, cpu_super_chance) {
    fighter.ai_wants_super = true
    fighter.ai_cooldown = cpu_reaction_base + rand_rangef(game, 0.08, 0.18)
    return
  }

  if opp_air && distance < 140.0 && rand_chance(game, 0.42) {
    fighter.ai_wants_special = true
    fighter.input.buffered_motion = motion_dp
    fighter.input.motion_timer = 0.24
    fighter.ai_cooldown = cpu_reaction_base
    return
  }

  if distance > 120.0 &&
    distance < 250.0 &&
    rand_chance(game, cpu_special_chance) {
    fighter.ai_wants_special = true
    fighter.input.buffered_motion = motion_qcf
    fighter.input.motion_timer = 0.24
    fighter.ai_cooldown = cpu_reaction_base + rand_rangef(game, 0.06, 0.16)
    return
  }

  if distance <= 160.0 {
    let roll = rand_range(game, 0, 99)
    if roll < 28 {
      input_press_lp(fighter)
    } else if roll < 50 {
      input_press_lk(fighter)
    } else if roll < 74 {
      input_press_hp(fighter)
    } else {
      input_press_hk(fighter)
    }
    fighter.ai_cooldown = rand_rangef(game, 0.05, 0.14)
  }
}

///|
fn ai_apply_attack_flags(fighter : Fighter) -> Unit {
  if fighter.ai_wants_throw {
    input_press_lp(fighter)
    input_press_lk(fighter)
    fighter.ai_wants_throw = false
  } else if fighter.ai_wants_super {
    input_press_super(fighter)
    fighter.ai_wants_super = false
  } else if fighter.ai_wants_special {
    let choice = rand_rangef_by_seedless(fighter)
    if choice < 0.5 {
      fighter.input.buffered_motion = motion_qcf
      fighter.input.motion_timer = 0.24
      input_press_hp(fighter)
    } else {
      fighter.input.buffered_motion = motion_dp
      fighter.input.motion_timer = 0.24
      input_press_hk(fighter)
    }
    fighter.ai_wants_special = false
  }
}

///|
fn rand_rangef_by_seedless(fighter : Fighter) -> Float {
  // Uses deterministic state derived from slot and frame counters in caller.
  let t = fighter.ai_timer * 37.0 +
    Float::from_int(fighter.action_frame * 11 + fighter.slot * 17)
  let s = Float::from_double(@math.sin(t.to_double()))
  s * 0.5 + 0.5
}

///|
fn update_cpu_input(game : Game, slot : Int, dt : Float) -> Unit {
  let fighter = game.fighters[slot]
  let opponent = game.fighters[other_slot(slot)]

  if game.mode_training {
    let toward = if opponent.x > fighter.x { 1 } else { -1 }
    push_cpu_direction(fighter, -toward, 0)
    return
  }

  fighter.ai_timer -= dt
  if fighter.ai_timer <= 0.0 {
    fighter.ai_timer = cpu_think_period + rand_rangef(game, 0.02, 0.07)
    ai_reset_flags(fighter)
  }

  let distance = fighter_distance_x(fighter, opponent)
  ai_set_mode_from_distance(fighter, distance)

  let (desired_x, desired_y0) = ai_pick_desired_axis(
    game, fighter, opponent, distance,
  )
  let mut desired_y = desired_y0

  if ai_try_jump(game, fighter, distance) {
    desired_y = -1
  }

  push_cpu_direction(fighter, desired_x, desired_y)

  ai_try_attack(game, fighter, opponent, distance)
  ai_apply_attack_flags(fighter)

  if fighter.input.any_attack_pressed {
    let dir_code = encode_relative_direction(
      fighter.input.x,
      fighter.input.y,
      fighter.facing,
    )
    push_direction_history(fighter.input, dir_code)
  }
}
