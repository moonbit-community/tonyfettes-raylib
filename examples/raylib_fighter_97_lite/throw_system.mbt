///|
fn fighter_can_attempt_throw(fighter : Fighter) -> Bool {
  fighter.on_ground &&
  fighter.action != action_attack &&
  fighter.action != action_throw &&
  fighter.action != action_hitstun &&
  fighter.action != action_blockstun &&
  fighter.action != action_knockdown &&
  fighter.action != action_wakeup &&
  fighter.action != action_intro &&
  fighter.action != action_victory
}

///|
fn throw_in_range(attacker : Fighter, defender : Fighter) -> Bool {
  absf(attacker.x - defender.x) <= throw_distance &&
  absf(attacker.y - defender.y) <= throw_vertical_tolerance
}

///|
fn apply_throw_hit(
  game : Game,
  attacker_slot : Int,
  defender_slot : Int,
) -> Unit {
  let attacker = game.fighters[attacker_slot]
  let defender = game.fighters[defender_slot]

  let attacker_archetype = fighter_archetype(game, attacker)
  let defender_archetype = fighter_archetype(game, defender)

  attacker.action = action_throw
  attacker.action_elapsed = 0.0
  attacker.action_frame = 0
  attacker.current_move = MoveSpec::empty()
  attacker.vx = 0.0
  attacker.vy = 0.0
  attacker.move_connected = true
  attacker.move_was_blocked = false
  attacker.move_cancel_enabled = false

  defender.health = clampi(defender.health - throw_damage, 0, health_max)
  defender.action = action_knockdown
  defender.hitstun = 0
  defender.blockstun = 0
  defender.knockdown = throw_knockdown_frames
  defender.invuln = 0

  let fx = facing_sign(attacker.facing)
  defender.vx = throw_push_x * 0.06 * fx
  defender.vy = throw_launch_y * 0.06
  defender.on_ground = false
  defender.jumped = true
  defender.crouching = false

  defender.combo_counter += 1
  defender.combo_damage += throw_damage
  defender.combo_timer = combo_timeout_frames

  let hit_x = (attacker.x + defender.x) * 0.5
  let hit_y = defender.y - 70.0
  spawn_hit_spark(game, hit_x, hit_y, spark_kind_hit, 24)
  spawn_ground_skid(game, defender)

  add_meter(attacker, 10, attacker_archetype)
  add_meter(defender, 6, defender_archetype)

  game.announcer_text = "THROW!"
  game.announcer_timer = 0.36
  game.hud_flash = 0.11
  push_camera_shake(game, 3.0)
}

///|
fn try_throw(game : Game, attacker_slot : Int, defender_slot : Int) -> Bool {
  let attacker = game.fighters[attacker_slot]
  let defender = game.fighters[defender_slot]

  if attacker.health <= 0 || defender.health <= 0 {
    return false
  }

  if not(fighter_can_attempt_throw(attacker)) {
    return false
  }
  if not(fighter_is_throw_vulnerable(defender)) {
    return false
  }

  if not(throw_input_pressed(attacker.input)) {
    return false
  }

  if not(throw_in_range(attacker, defender)) {
    return false
  }

  apply_throw_hit(game, attacker_slot, defender_slot)
  true
}

///|
fn update_throws(game : Game) -> Bool {
  let first = if game.frame_count % 2 == 0 { 0 } else { 1 }
  let second = other_slot(first)

  if try_throw(game, first, second) {
    return true
  }

  if try_throw(game, second, first) {
    return true
  }

  false
}
