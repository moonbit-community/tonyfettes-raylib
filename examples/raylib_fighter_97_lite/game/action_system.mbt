///|
fn attack_is_active(fighter : @types.Fighter) -> Bool {
  if fighter.action != @types.ActionAttack {
    return false
  }
  let mv = fighter.current_move
  fighter.action_frame >= mv.startup_frames &&
  fighter.action_frame < mv.startup_frames + mv.active_frames
}

///|
fn set_idle_state(fighter : @types.Fighter) -> Unit {
  fighter.action = @types.ActionIdle
  fighter.action_frame = 0
  fighter.action_elapsed = 0.0
  fighter.current_move = @types.MoveSpec::empty()
  fighter.move_connected = false
  fighter.move_cancel_enabled = false
  if fighter.on_ground {
    fighter.crouching = false
  }
}

///|
fn start_attack(
  fighter : @types.Fighter,
  archetype : @types.CharacterArchetype,
  mv : @types.MoveSpec,
) -> Unit {
  fighter.action = @types.ActionAttack
  fighter.action_frame = 0
  fighter.action_elapsed = 0.0
  fighter.current_move = mv
  fighter.move_connected = false
  fighter.move_cancel_enabled = false

  if mv.move_kind == @types.MoveKindSuper {
    fighter.super_meter = @types.clampi(
      fighter.super_meter - @types.super_cost,
      0,
      @types.super_max,
    )
  }

  @types.add_meter(fighter, mv.meter_gain_on_use, archetype)

  let fx = @types.facing_sign(fighter.facing)
  if mv.auto_dash {
    fighter.vx = @types.dash_forward_speed * 0.62 * fx
  } else {
    fighter.vx = mv.drift_speed * fx
  }

  if mv.attack_id == @types.AttackSpecialDp {
    if fighter.on_ground {
      fighter.on_ground = false
      fighter.vy = @types.jump_initial_velocity * 0.74
    }
  }

  if mv.invuln_end > 0 {
    fighter.invuln = mv.invuln_end
  }

  fighter.input.buffered_motion = @types.MotionNone
  fighter.input.motion_timer = 0.0
  fighter.input.attack_buffer_timer = 0.0
}

///|
fn chosen_normal_move(
  input : @types.InputState,
  archetype : @types.CharacterArchetype,
) -> @types.MoveSpec {
  if input.hk_pressed {
    archetype.normal_hk
  } else if input.hp_pressed {
    archetype.normal_hp
  } else if input.lk_pressed {
    archetype.normal_lk
  } else {
    archetype.normal_lp
  }
}

///|
fn can_cancel_current_move(fighter : @types.Fighter) -> Bool {
  if fighter.action != @types.ActionAttack {
    return false
  }
  let mv = fighter.current_move
  if fighter.action_frame < mv.cancel_window_start ||
    fighter.action_frame > mv.cancel_window_end {
    return false
  }
  if mv.move_kind == @types.MoveKindNormal {
    true
  } else {
    fighter.move_cancel_enabled
  }
}

///|
fn choose_attack_from_input(
  fighter : @types.Fighter,
  archetype : @types.CharacterArchetype,
) -> @types.MoveSpec {
  let input = fighter.input
  let motion = if input.motion_timer > 0.0 {
    input.buffered_motion
  } else {
    @types.MotionNone
  }

  if motion == @types.MotionQcf &&
    fighter.super_meter >= @types.super_cost &&
    input.hp_pressed &&
    input.hk_pressed {
    return archetype.super_move
  }

  if motion == @types.MotionDp &&
    (
      input.hp_pressed ||
      input.hk_pressed ||
      input.lp_pressed ||
      input.lk_pressed
    ) {
    return archetype.special_dp
  }

  if motion == @types.MotionQcf &&
    (
      input.hp_pressed ||
      input.hk_pressed ||
      input.lp_pressed ||
      input.lk_pressed
    ) {
    return archetype.special_qcf
  }

  chosen_normal_move(input, archetype)
}

///|
fn try_start_attack(game : @types.Game, slot : Int) -> Unit {
  let fighter = game.fighters[slot]
  let archetype = @types.fighter_archetype(game, fighter)
  let input = fighter.input

  if not(input.any_attack_pressed) {
    return
  }

  // LP+LK is reserved for throw attempts and resolved in throw_system.mbt.
  if @types.throw_input_pressed(input) {
    return
  }

  if fighter.action == @types.ActionHitstun ||
    fighter.action == @types.ActionBlockstun ||
    fighter.action == @types.ActionKnockdown ||
    fighter.action == @types.ActionWakeup ||
    fighter.action == @types.ActionThrow ||
    fighter.action == @types.ActionIntro ||
    fighter.action == @types.ActionVictory {
    return
  }

  if fighter.action == @types.ActionAttack &&
    not(can_cancel_current_move(fighter)) {
    return
  }

  let mv = choose_attack_from_input(fighter, archetype)

  if mv.airborne_only && fighter.on_ground {
    return
  }
  if mv.crouch_only && not(fighter.crouching) {
    return
  }

  start_attack(fighter, archetype, mv)

  if mv.move_kind == @types.MoveKindSuper {
    game.stage_flash = 0.32
    game.announcer_text = "SUPER!"
    game.announcer_timer = 0.5
    game.dramatic_freeze = 7
    @effects.push_camera_shake(game, 5.0)
  }
}

///|
fn update_fighter_recovery_state(fighter : @types.Fighter) -> Unit {
  if fighter.invuln > 0 {
    fighter.invuln -= 1
  }
  if fighter.throw_tech_timer > 0 {
    fighter.throw_tech_timer -= 1
  }

  if fighter.combo_timer > 0 {
    fighter.combo_timer -= 1
  } else {
    fighter.combo_counter = 0
  }

  if fighter.hitstop > 0 {
    fighter.hitstop -= 1
  }

  if fighter.flash_timer > 0.0 {
    fighter.flash_timer -= @types.frame_dt
    if fighter.flash_timer < 0.0 {
      fighter.flash_timer = 0.0
    }
  }

  if fighter.shake_timer > 0.0 {
    fighter.shake_timer -= @types.frame_dt
    if fighter.shake_timer <= 0.0 {
      fighter.shake_timer = 0.0
      fighter.hurt_shake_x = 0.0
      fighter.hurt_shake_y = 0.0
    }
  }
}

///|
fn update_fighter_action_frame(fighter : @types.Fighter, dt : Float) -> Unit {
  fighter.action_elapsed += dt
  fighter.action_frame = (fighter.action_elapsed * @types.fight_fps).to_int()

  if fighter.action == @types.ActionAttack {
    if fighter.action_frame >= fighter.current_move.total_frames {
      set_idle_state(fighter)
    }
  } else if fighter.action == @types.ActionThrow {
    if fighter.action_frame >= 18 {
      set_idle_state(fighter)
    }
  } else if fighter.action == @types.ActionDashForward ||
    fighter.action == @types.ActionDashBack {
    if fighter.action_frame >= @types.dash_duration_frames {
      set_idle_state(fighter)
    }
  } else if fighter.action == @types.ActionIntro {
    if fighter.action_frame >= 20 {
      set_idle_state(fighter)
    }
  } else if fighter.action == @types.ActionWakeup {
    if fighter.action_frame >= 18 {
      set_idle_state(fighter)
    }
  }
}

///|
fn update_stun_and_knockdown(fighter : @types.Fighter) -> Unit {
  if fighter.action == @types.ActionHitstun {
    fighter.hitstun -= 1
    fighter.vx *= 0.92
    if fighter.hitstun <= 0 {
      set_idle_state(fighter)
    }
  } else if fighter.action == @types.ActionBlockstun {
    fighter.blockstun -= 1
    fighter.vx *= 0.9
    if fighter.blockstun <= 0 {
      set_idle_state(fighter)
    }
  } else if fighter.action == @types.ActionKnockdown {
    fighter.knockdown -= 1
    fighter.vx *= 0.94
    if fighter.knockdown <= 0 {
      fighter.action = @types.ActionWakeup
      fighter.action_elapsed = 0.0
      fighter.action_frame = 0
      fighter.on_ground = true
      fighter.vy = 0.0
      fighter.crouching = false
      fighter.invuln = @types.wakeup_invuln_frames
    }
  }
}

///|
fn update_walk_and_crouch_state(
  fighter : @types.Fighter,
  archetype : @types.CharacterArchetype,
) -> Unit {
  let input = fighter.input
  let fx = @types.facing_sign(fighter.facing)

  if fighter.action == @types.ActionDashForward {
    fighter.vx = @types.dash_forward_speed * fx * archetype.speed_mul
    return
  }

  if fighter.action == @types.ActionDashBack {
    fighter.vx = @types.dash_back_speed * fx * archetype.speed_mul
    return
  }

  if fighter.action == @types.ActionAttack ||
    fighter.action == @types.ActionThrow {
    return
  }

  if not(fighter.on_ground) {
    return
  }

  if input.hold_down {
    fighter.action = @types.ActionCrouch
    fighter.crouching = true
    fighter.vx = @types.approachf(
      fighter.vx,
      if input.hold_forward {
        @types.crouch_slide_speed * fx
      } else if input.hold_back {
        -@types.crouch_slide_speed * fx
      } else {
        0.0
      },
      44.0,
    )
    return
  }

  fighter.crouching = false

  if input.dash_forward_pressed {
    fighter.action = @types.ActionDashForward
    fighter.action_elapsed = 0.0
    fighter.action_frame = 0
    fighter.vx = @types.dash_forward_speed * fx * archetype.speed_mul
    return
  }

  if input.dash_back_pressed {
    fighter.action = @types.ActionDashBack
    fighter.action_elapsed = 0.0
    fighter.action_frame = 0
    fighter.vx = @types.dash_back_speed * fx * archetype.speed_mul
    return
  }

  if input.hold_forward {
    fighter.action = @types.ActionWalkForward
    fighter.vx = @types.move_speed_forward * fx * archetype.speed_mul
  } else if input.hold_back {
    fighter.action = @types.ActionWalkBack
    fighter.vx = -@types.move_speed_back * fx * archetype.speed_mul
  } else {
    if fighter.action == @types.ActionWalkForward ||
      fighter.action == @types.ActionWalkBack ||
      fighter.action == @types.ActionCrouch {
      fighter.action = @types.ActionIdle
      fighter.action_elapsed = 0.0
      fighter.action_frame = 0
    }
    fighter.vx = @types.approachf(fighter.vx, 0.0, 50.0)
  }
}

///|
fn update_jump_state(
  fighter : @types.Fighter,
  archetype : @types.CharacterArchetype,
) -> Unit {
  if fighter.action == @types.ActionHitstun ||
    fighter.action == @types.ActionBlockstun ||
    fighter.action == @types.ActionKnockdown ||
    fighter.action == @types.ActionWakeup ||
    fighter.action == @types.ActionThrow ||
    fighter.action == @types.ActionIntro ||
    fighter.action == @types.ActionVictory {
    return
  }

  let input = fighter.input
  if fighter.on_ground && input.hold_up && not(input.hold_down) {
    fighter.on_ground = false
    fighter.action = @types.ActionJump
    fighter.action_elapsed = 0.0
    fighter.action_frame = 0
    fighter.vy = @types.jump_initial_velocity * archetype.jump_mul
    if input.hold_forward {
      fighter.vx += @types.move_speed_forward *
        0.45 *
        @types.facing_sign(fighter.facing)
    } else if input.hold_back {
      fighter.vx -= @types.move_speed_back *
        0.4 *
        @types.facing_sign(fighter.facing)
    }
  }
}

///|
fn integrate_fighter_physics(
  fighter : @types.Fighter,
  archetype : @types.CharacterArchetype,
  dt : Float,
) -> Unit {
  if not(fighter.on_ground) {
    fighter.vy += @types.gravity_force * dt * archetype.jump_mul
  } else {
    fighter.vy = 0.0
  }

  fighter.x += fighter.vx * dt
  fighter.y += fighter.vy * dt

  fighter.x = @types.stage_clamp_x(fighter.x)

  if fighter.y >= @types.floor_y {
    if not(fighter.on_ground) {
      fighter.y = @types.floor_y
      fighter.on_ground = true
      fighter.vy = 0.0
      if fighter.action == @types.ActionJump {
        set_idle_state(fighter)
      }
    } else {
      fighter.y = @types.floor_y
    }
  }

  if fighter.action == @types.ActionAttack {
    if fighter.current_move.drift_speed == 0.0 {
      fighter.vx = @types.approachf(fighter.vx, 0.0, 25.0)
    }
  } else if fighter.action == @types.ActionDashForward ||
    fighter.action == @types.ActionDashBack {

  } else {
    // Dash keeps velocity while action is active.
    fighter.vx = @types.approachf(fighter.vx, 0.0, 22.0)
  }
}

///|
fn update_facing(game : @types.Game) -> Unit {
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  if p1.x < p2.x {
    if (p1.action != @types.ActionAttack && p1.action != @types.ActionThrow) ||
      p1.action_frame < p1.current_move.startup_frames {
      p1.facing = @types.facing_right
    }
    if (p2.action != @types.ActionAttack && p2.action != @types.ActionThrow) ||
      p2.action_frame < p2.current_move.startup_frames {
      p2.facing = @types.facing_left
    }
  } else {
    if (p1.action != @types.ActionAttack && p1.action != @types.ActionThrow) ||
      p1.action_frame < p1.current_move.startup_frames {
      p1.facing = @types.facing_left
    }
    if (p2.action != @types.ActionAttack && p2.action != @types.ActionThrow) ||
      p2.action_frame < p2.current_move.startup_frames {
      p2.facing = @types.facing_right
    }
  }
}

///|
fn resolve_push_collision(game : @types.Game) -> Unit {
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  let dx = p2.x - p1.x
  let dist = @types.absf(dx)
  let min_dist = @types.fighter_push_radius * 2.0
  if dist < min_dist {
    let overlap = (min_dist - dist) * 0.5
    if dx >= 0.0 {
      p1.x -= overlap
      p2.x += overlap
    } else {
      p1.x += overlap
      p2.x -= overlap
    }
    p1.x = @types.stage_clamp_x(p1.x)
    p2.x = @types.stage_clamp_x(p2.x)
  }
}

///|
fn update_fighter_core(game : @types.Game, slot : Int, dt : Float) -> Unit {
  let fighter = game.fighters[slot]
  let archetype = @types.fighter_archetype(game, fighter)

  update_fighter_recovery_state(fighter)

  if fighter.hitstop > 0 {
    return
  }

  update_stun_and_knockdown(fighter)
  if fighter.action == @types.ActionHitstun ||
    fighter.action == @types.ActionBlockstun ||
    fighter.action == @types.ActionKnockdown ||
    fighter.action == @types.ActionWakeup ||
    fighter.action == @types.ActionThrow ||
    fighter.action == @types.ActionIntro ||
    fighter.action == @types.ActionVictory {
    update_fighter_action_frame(fighter, dt)
    integrate_fighter_physics(fighter, archetype, dt)
    return
  }

  update_jump_state(fighter, archetype)

  if fighter.action != @types.ActionAttack &&
    fighter.action != @types.ActionThrow {
    update_walk_and_crouch_state(fighter, archetype)
  }

  try_start_attack(game, slot)

  update_fighter_action_frame(fighter, dt)
  integrate_fighter_physics(fighter, archetype, dt)
}
