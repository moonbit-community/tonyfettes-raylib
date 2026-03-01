///|
fn ai_set_mode_from_distance(
  fighter : @types.Fighter,
  distance : Float,
) -> Unit {
  if distance > 330.0 {
    fighter.ai_mode = @types.AiModeRush
  } else if distance < 120.0 {
    fighter.ai_mode = @types.AiModeEvade
  } else {
    fighter.ai_mode = @types.AiModeZone
  }
}

///|
fn ai_reset_flags(fighter : @types.Fighter) -> Unit {
  fighter.ai_wants_special = false
  fighter.ai_wants_super = false
  fighter.ai_wants_throw = false
}

///|
fn ai_should_block(
  game : @types.Game,
  _fighter : @types.Fighter,
  opponent : @types.Fighter,
  distance : Float,
) -> Bool {
  if opponent.action != @types.ActionAttack {
    return false
  }
  if distance > 170.0 {
    return false
  }
  let pressure = if opponent.current_move.move_kind == @types.MoveKindSuper {
    @types.cpu_block_chance + 0.18
  } else {
    @types.cpu_block_chance
  }
  @types.rand_chance(game, pressure)
}

///|
fn ai_pick_desired_axis(
  game : @types.Game,
  fighter : @types.Fighter,
  opponent : @types.Fighter,
  distance : Float,
) -> (Int, Int) {
  let dx = opponent.x - fighter.x
  let toward = if dx > 0.0 { 1 } else { -1 }

  if ai_should_block(game, fighter, opponent, distance) {
    return (-toward, if @types.rand_chance(game, 0.35) { 1 } else { 0 })
  }

  if fighter.ai_mode == @types.AiModeRush {
    if distance > 120.0 {
      (toward, 0)
    } else {
      (if @types.rand_chance(game, 0.3) { toward } else { 0 }, 0)
    }
  } else if fighter.ai_mode == @types.AiModeEvade {
    if distance < 200.0 {
      (-toward, 0)
    } else {
      (0, 0)
    }
  } else if distance > 240.0 {
    (toward, 0)
  } else if distance < 140.0 {
    (-toward, if @types.rand_chance(game, 0.25) { 1 } else { 0 })
  } else {
    (if @types.rand_chance(game, 0.5) { toward } else { 0 }, 0)
  }
}

///|
fn ai_try_jump(
  game : @types.Game,
  fighter : @types.Fighter,
  distance : Float,
) -> Bool {
  if not(fighter.on_ground) {
    return false
  }
  if distance < 130.0 || distance > 360.0 {
    return false
  }
  @types.rand_chance(game, @types.cpu_jump_chance)
}

///|
fn ai_try_attack(
  game : @types.Game,
  fighter : @types.Fighter,
  opponent : @types.Fighter,
  distance : Float,
) -> Unit {
  if fighter.action == @types.ActionAttack ||
    fighter.action == @types.ActionHitstun ||
    fighter.action == @types.ActionBlockstun ||
    fighter.action == @types.ActionKnockdown ||
    fighter.action == @types.ActionWakeup {
    return
  }

  if fighter.ai_cooldown > 0.0 {
    fighter.ai_cooldown -= @types.frame_dt
    if fighter.ai_cooldown < 0.0 {
      fighter.ai_cooldown = 0.0
    }
    return
  }

  let opp_air = not(opponent.on_ground)

  if fighter.on_ground &&
    opponent.on_ground &&
    distance <= @types.throw_distance * 0.9 &&
    @types.rand_chance(game, 0.18) {
    fighter.ai_wants_throw = true
    fighter.ai_cooldown = @types.cpu_reaction_base +
      @types.rand_rangef(game, 0.04, 0.1)
    return
  }

  if fighter.super_meter >= @types.super_cost &&
    distance > 90.0 &&
    distance < 240.0 &&
    @types.rand_chance(game, @types.cpu_super_chance) {
    fighter.ai_wants_super = true
    fighter.ai_cooldown = @types.cpu_reaction_base +
      @types.rand_rangef(game, 0.08, 0.18)
    return
  }

  if opp_air && distance < 140.0 && @types.rand_chance(game, 0.42) {
    fighter.ai_wants_special = true
    fighter.input.buffered_motion = @types.MotionDp
    fighter.input.motion_timer = 0.24
    fighter.ai_cooldown = @types.cpu_reaction_base
    return
  }

  if distance > 120.0 &&
    distance < 250.0 &&
    @types.rand_chance(game, @types.cpu_special_chance) {
    fighter.ai_wants_special = true
    fighter.input.buffered_motion = @types.MotionQcf
    fighter.input.motion_timer = 0.24
    fighter.ai_cooldown = @types.cpu_reaction_base +
      @types.rand_rangef(game, 0.06, 0.16)
    return
  }

  if distance <= 160.0 {
    let roll = @types.rand_range(game, 0, 99)
    if roll < 28 {
      input_press_lp(fighter)
    } else if roll < 50 {
      input_press_lk(fighter)
    } else if roll < 74 {
      input_press_hp(fighter)
    } else {
      input_press_hk(fighter)
    }
    fighter.ai_cooldown = @types.rand_rangef(game, 0.05, 0.14)
  }
}

///|
fn ai_apply_attack_flags(fighter : @types.Fighter) -> Unit {
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
      fighter.input.buffered_motion = @types.MotionQcf
      fighter.input.motion_timer = 0.24
      input_press_hp(fighter)
    } else {
      fighter.input.buffered_motion = @types.MotionDp
      fighter.input.motion_timer = 0.24
      input_press_hk(fighter)
    }
    fighter.ai_wants_special = false
  }
}

///|
fn rand_rangef_by_seedless(fighter : @types.Fighter) -> Float {
  // Uses deterministic state derived from slot and frame counters in caller.
  let t = fighter.ai_timer * 37.0 +
    Float::from_int(fighter.action_frame * 11 + fighter.slot * 17)
  let s = Float::from_double(@math.sin(t.to_double()))
  s * 0.5 + 0.5
}

///|
fn update_cpu_input(game : @types.Game, slot : Int, dt : Float) -> Unit {
  let fighter = game.fighters[slot]
  let opponent = game.fighters[@types.other_slot(slot)]

  if game.mode_training {
    let toward = if opponent.x > fighter.x { 1 } else { -1 }
    push_cpu_direction(fighter, -toward, 0)
    return
  }

  fighter.ai_timer -= dt
  if fighter.ai_timer <= 0.0 {
    fighter.ai_timer = @types.cpu_think_period +
      @types.rand_rangef(game, 0.02, 0.07)
    ai_reset_flags(fighter)
  }

  let distance = @types.fighter_distance_x(fighter, opponent)
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
