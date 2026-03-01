///|
fn fighter_can_attempt_throw(fighter : @types.Fighter) -> Bool {
  fighter.on_ground &&
  fighter.action != @types.ActionAttack &&
  fighter.action != @types.ActionThrow &&
  fighter.action != @types.ActionHitstun &&
  fighter.action != @types.ActionBlockstun &&
  fighter.action != @types.ActionKnockdown &&
  fighter.action != @types.ActionWakeup &&
  fighter.action != @types.ActionIntro &&
  fighter.action != @types.ActionVictory
}

///|
fn throw_in_range(attacker : @types.Fighter, defender : @types.Fighter) -> Bool {
  @types.absf(attacker.x - defender.x) <= @types.throw_distance &&
  @types.absf(attacker.y - defender.y) <= @types.throw_vertical_tolerance
}

///|
fn fighter_throw_intent(
  attacker : @types.Fighter,
  defender : @types.Fighter,
) -> Bool {
  fighter_can_attempt_throw(attacker) &&
  @types.throw_input_pressed(attacker.input) &&
  throw_in_range(attacker, defender)
}

///|
fn throw_horizontal_velocity(
  attacker : @types.Fighter,
  defender : @types.Fighter,
) -> Float {
  let toward = @types.throw_push_x * 0.06 * @types.facing_sign(attacker.facing)
  let toward_corner_space = if toward > 0.0 {
    @types.stage_right_x - defender.x
  } else {
    defender.x - @types.stage_left_x
  }

  if toward_corner_space < @types.throw_corner_space_min {
    -toward * @types.throw_corner_escape_ratio
  } else {
    toward
  }
}

///|
fn apply_throw_tech(
  game : @types.Game,
  first_slot : Int,
  second_slot : Int,
) -> Unit {
  let first = game.fighters[first_slot]
  let second = game.fighters[second_slot]
  let first_archetype = @types.fighter_archetype(game, first)
  let second_archetype = @types.fighter_archetype(game, second)

  set_idle_state(first)
  set_idle_state(second)
  first.throw_tech_timer = 0
  second.throw_tech_timer = 0
  first.invuln = @types.throw_tech_invuln_frames
  second.invuln = @types.throw_tech_invuln_frames

  let push = @types.throw_tech_push_x * 0.06
  if first.x <= second.x {
    first.vx = -push
    second.vx = push
  } else {
    first.vx = push
    second.vx = -push
  }

  let hit_x = (first.x + second.x) * 0.5
  let hit_y = (first.y + second.y) * 0.5 - 70.0
  @effects.spawn_hit_spark(game, hit_x, hit_y, @types.SparkKindBlock, 24)

  @types.add_meter(first, 5, first_archetype)
  @types.add_meter(second, 5, second_archetype)

  game.announcer_text = "THROW TECH"
  game.announcer_timer = 0.34
  game.hud_flash = 0.08
  @effects.push_camera_shake(game, 2.0)
  @types.set_training_note(game, "Throw tech")
}

///|
fn apply_throw_hit(
  game : @types.Game,
  attacker_slot : Int,
  defender_slot : Int,
) -> Unit {
  let attacker = game.fighters[attacker_slot]
  let defender = game.fighters[defender_slot]

  let attacker_archetype = @types.fighter_archetype(game, attacker)
  let defender_archetype = @types.fighter_archetype(game, defender)

  attacker.action = @types.ActionThrow
  attacker.action_elapsed = 0.0
  attacker.action_frame = 0
  attacker.current_move = @types.MoveSpec::empty()
  attacker.vx = 0.0
  attacker.vy = 0.0
  attacker.move_connected = true
  attacker.move_cancel_enabled = false
  attacker.throw_tech_timer = 0

  defender.health = @types.clampi(
    defender.health - @types.throw_damage,
    0,
    @types.health_max,
  )
  defender.action = @types.ActionKnockdown
  defender.hitstun = 0
  defender.blockstun = 0
  defender.knockdown = @types.throw_knockdown_frames
  defender.invuln = 0
  defender.throw_tech_timer = 0

  defender.vx = throw_horizontal_velocity(attacker, defender)
  defender.vy = @types.throw_launch_y * 0.06
  defender.on_ground = false
  defender.crouching = false

  defender.combo_counter += 1
  defender.combo_timer = @types.combo_timeout_frames

  let hit_x = (attacker.x + defender.x) * 0.5
  let hit_y = defender.y - 70.0
  @effects.spawn_hit_spark(game, hit_x, hit_y, @types.SparkKindHit, 24)
  @effects.spawn_ground_skid(game, defender)

  @types.add_meter(attacker, 10, attacker_archetype)
  @types.add_meter(defender, 6, defender_archetype)

  game.announcer_text = "THROW!"
  game.announcer_timer = 0.36
  game.hud_flash = 0.11
  @effects.push_camera_shake(game, 3.0)
  @types.set_training_note(game, "P\{attacker_slot + 1} throw: hard knockdown")
}

///|
fn try_throw(
  game : @types.Game,
  attacker_slot : Int,
  defender_slot : Int,
  attacker_intent : Bool,
) -> Bool {
  if not(attacker_intent) {
    return false
  }

  let attacker = game.fighters[attacker_slot]
  let defender = game.fighters[defender_slot]

  if attacker.health <= 0 || defender.health <= 0 {
    return false
  }

  if not(fighter_can_attempt_throw(attacker)) {
    return false
  }
  if not(@types.fighter_is_throw_vulnerable(defender)) {
    return false
  }

  if not(throw_in_range(attacker, defender)) {
    return false
  }

  if defender.throw_tech_timer > 0 {
    apply_throw_tech(game, attacker_slot, defender_slot)
    return true
  }

  apply_throw_hit(game, attacker_slot, defender_slot)
  true
}

///|
fn update_throws(game : @types.Game) -> Bool {
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]
  let p1_intent = fighter_throw_intent(p1, p2)
  let p2_intent = fighter_throw_intent(p2, p1)

  if p1_intent {
    p1.throw_tech_timer = @types.throw_tech_window_frames
  }
  if p2_intent {
    p2.throw_tech_timer = @types.throw_tech_window_frames
  }

  if p1_intent &&
    p2_intent &&
    @types.fighter_is_throw_vulnerable(p1) &&
    @types.fighter_is_throw_vulnerable(p2) {
    apply_throw_tech(game, 0, 1)
    return true
  }

  let first = if game.frame_count % 2 == 0 { 0 } else { 1 }
  let second = @types.other_slot(first)

  if try_throw(
      game,
      first,
      second,
      if first == 0 {
        p1_intent
      } else {
        p2_intent
      },
    ) {
    return true
  }

  if try_throw(
      game,
      second,
      first,
      if second == 0 {
        p1_intent
      } else {
        p2_intent
      },
    ) {
    return true
  }

  false
}
