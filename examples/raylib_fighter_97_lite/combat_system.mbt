///|
fn defender_holding_away(attacker : Fighter, defender : Fighter) -> Bool {
  let dx = attacker.x - defender.x
  if absf(dx) <= 1.0 {
    defender.input.hold_back
  } else if dx > 0.0 {
    defender.input.x < 0
  } else {
    defender.input.x > 0
  }
}

///|
fn can_defender_block(
  attacker : Fighter,
  defender : Fighter,
  mv : MoveSpec,
) -> Bool {
  if not(defender.on_ground) {
    return false
  }

  if defender.action == action_hitstun ||
    defender.action == action_blockstun ||
    defender.action == action_throw ||
    defender.action == action_knockdown ||
    defender.action == action_wakeup ||
    defender.action == action_intro ||
    defender.action == action_victory {
    return false
  }

  if not(defender_holding_away(attacker, defender)) {
    return false
  }

  if mv.low_attack {
    defender.input.hold_down
  } else if mv.overhead_attack {
    not(defender.input.hold_down)
  } else {
    true
  }
}

///|
fn attacker_remaining_recovery(attacker : Fighter, mv : MoveSpec) -> Int {
  clampi(mv.total_frames - attacker.action_frame, 0, 999)
}

///|
fn compute_damage(
  attacker : Fighter,
  defender : Fighter,
  attacker_archetype : CharacterArchetype,
  defender_archetype : CharacterArchetype,
  mv : MoveSpec,
) -> (Int, Bool) {
  let counter_hit = defender.action == action_attack &&
    defender.action_frame < defender.current_move.startup_frames

  let mut scale = f(1.0) -
    Float::from_int(defender.combo_counter) * combo_decay_step
  if scale < f(0.45) {
    scale = f(0.45)
  }

  let mut damage = Float::from_int(mv.damage)
  damage = damage * attacker_archetype.offense_mul
  damage = damage / defender_archetype.defense_mul
  damage = damage * scale
  if counter_hit {
    damage = damage * counter_hit_bonus
  }

  let d = clampi(damage.to_int(), 1, 999)
  (d, counter_hit)
}

///|
fn apply_successful_hit(
  game : Game,
  attacker_slot : Int,
  defender_slot : Int,
  hitbox_center_x : Float,
  hitbox_center_y : Float,
) -> Unit {
  let attacker = game.fighters[attacker_slot]
  let defender = game.fighters[defender_slot]
  let mv = attacker.current_move
  let attacker_archetype = fighter_archetype(game, attacker)
  let defender_archetype = fighter_archetype(game, defender)
  let (damage, counter_hit) = compute_damage(
    attacker, defender, attacker_archetype, defender_archetype, mv,
  )

  defender.health = clampi(defender.health - damage, 0, health_max)

  if mv.knockdown {
    defender.action = action_knockdown
    defender.knockdown = mv.hitstun_frames + 26
    defender.hitstun = 0
    defender.blockstun = 0
  } else {
    defender.action = action_hitstun
    let bonus = if counter_hit { 4 } else { 0 }
    defender.hitstun = mv.hitstun_frames + bonus
    defender.blockstun = 0
    defender.knockdown = 0
  }

  let fx = facing_sign(attacker.facing)
  defender.vx = mv.launch_x * 0.06 * fx
  defender.vy = mv.launch_y * 0.06

  if mv.launch_y < -60.0 || mv.knockdown {
    defender.on_ground = false
    defender.jumped = true
    defender.crouching = false
  }

  defender.flash_timer = 0.16
  defender.shake_timer = 0.12
  defender.hurt_shake_x = rand_rangef(game, -5.0, 5.0)
  defender.hurt_shake_y = rand_rangef(game, -4.0, 4.0)

  attacker.hitstop = mv.hitstop_frames
  defender.hitstop = mv.hitstop_frames

  attacker.move_connected = true
  attacker.move_was_blocked = false
  attacker.move_cancel_enabled = mv.cancel_on_hit

  defender.combo_counter += 1
  defender.combo_timer = combo_timeout_frames
  defender.combo_damage += damage
  defender.counter_hit_flag = counter_hit

  add_meter(attacker, mv.meter_gain_on_hit, attacker_archetype)
  add_meter(defender, meter_gain_hit_taken, defender_archetype)

  let spark_kind = if mv.move_kind == move_kind_super {
    spark_kind_super
  } else {
    spark_kind_hit
  }

  spawn_hit_spark(
    game,
    hitbox_center_x,
    hitbox_center_y,
    spark_kind,
    if mv.move_kind == move_kind_super {
      44
    } else {
      22
    },
  )

  if mv.move_kind == move_kind_super {
    push_camera_shake(game, 6.4)
    game.announcer_text = if counter_hit {
      "SUPER COUNTER!"
    } else {
      "SUPER HIT!"
    }
    game.announcer_timer = 0.7
  } else {
    push_camera_shake(game, if counter_hit { 4.6 } else { 3.2 })
    if counter_hit {
      game.announcer_text = "COUNTER!"
      game.announcer_timer = 0.32
    }
  }

  if mv.move_kind != move_kind_super {
    spawn_ground_skid(game, defender)
  }

  if mv.knockdown {
    set_training_note(game, "P\{attacker_slot + 1} on hit: hard knockdown")
  } else {
    let advantage = defender.hitstun - attacker_remaining_recovery(attacker, mv)
    set_training_frame_adv(game, attacker_slot, "on hit", advantage)
  }

  game.hud_flash = 0.16
}

///|
fn apply_blocked_hit(
  game : Game,
  attacker_slot : Int,
  defender_slot : Int,
  hitbox_center_x : Float,
  hitbox_center_y : Float,
) -> Unit {
  let attacker = game.fighters[attacker_slot]
  let defender = game.fighters[defender_slot]
  let mv = attacker.current_move
  let attacker_archetype = fighter_archetype(game, attacker)
  let defender_archetype = fighter_archetype(game, defender)

  let mut chip = mv.chip_damage
  if mv.move_kind == move_kind_super {
    chip = chip + 3
  }

  if chip > 0 && defender.health > 1 {
    defender.health = clampi(defender.health - chip, 1, health_max)
  }

  let guard_damage = clampi(mv.damage / 12 + 2, 2, 16)
  defender.guard_meter -= guard_damage

  if defender.guard_meter <= 0 {
    defender.guard_meter = fighter_total_guard(defender_archetype) / 2
    defender.action = action_hitstun
    defender.hitstun = mv.hitstun_frames + 12
    defender.blockstun = 0
    defender.knockdown = 0

    game.announcer_text = "GUARD BREAK"
    game.announcer_timer = 0.55
    spawn_hit_spark(
      game, hitbox_center_x, hitbox_center_y, spark_kind_super, 30,
    )
    push_camera_shake(game, 5.2)
    set_training_note(game, "P\{attacker_slot + 1} guard break")
  } else {
    defender.action = action_blockstun
    defender.blockstun = mv.blockstun_frames
    defender.hitstun = 0
    defender.knockdown = 0
    defender.vx = mv.pushback * 0.04 * facing_sign(attacker.facing)
    spawn_hit_spark(
      game, hitbox_center_x, hitbox_center_y, spark_kind_block, 18,
    )
    push_camera_shake(game, 2.2)
    let advantage = defender.blockstun -
      attacker_remaining_recovery(attacker, mv)
    set_training_frame_adv(game, attacker_slot, "on block", advantage)
  }

  attacker.hitstop = mv.hitstop_frames / 2 + 2
  defender.hitstop = mv.hitstop_frames / 2 + 2

  attacker.move_connected = true
  attacker.move_was_blocked = true
  attacker.move_cancel_enabled = false

  add_meter(
    attacker,
    meter_gain_blocked + mv.meter_gain_on_hit / 2,
    attacker_archetype,
  )
  add_meter(defender, meter_gain_blocked + 2, defender_archetype)

  game.hud_flash = 0.08
}

///|
fn process_attack_contact(
  game : Game,
  attacker_slot : Int,
  defender_slot : Int,
) -> Unit {
  let attacker = game.fighters[attacker_slot]
  let defender = game.fighters[defender_slot]

  if attacker.health <= 0 || defender.health <= 0 {
    return
  }

  if not(attack_is_active(attacker)) {
    return
  }

  if attacker.move_connected {
    return
  }

  if defender.invuln > 0 {
    return
  }

  let mv = attacker.current_move
  let hitbox = attack_hitbox_for(attacker, mv)
  let hurtbox = hurtbox_for(defender)

  if not(@raylib.check_collision_recs(hitbox, hurtbox)) {
    return
  }

  let hit_x = hitbox.x + hitbox.width * 0.5
  let hit_y = hitbox.y + hitbox.height * 0.5

  if can_defender_block(attacker, defender, mv) {
    apply_blocked_hit(game, attacker_slot, defender_slot, hit_x, hit_y)
  } else {
    apply_successful_hit(game, attacker_slot, defender_slot, hit_x, hit_y)
  }
}

///|
fn update_combat(game : Game) -> Unit {
  process_attack_contact(game, 0, 1)
  process_attack_contact(game, 1, 0)
}
