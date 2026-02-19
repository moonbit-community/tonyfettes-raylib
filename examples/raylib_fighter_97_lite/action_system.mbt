///|
fn attack_is_active(fighter : Fighter) -> Bool {
  if fighter.action != action_attack {
    return false
  }
  let mv = fighter.current_move
  fighter.action_frame >= mv.startup_frames &&
  fighter.action_frame < mv.startup_frames + mv.active_frames
}

///|
fn attack_is_recovery(fighter : Fighter) -> Bool {
  if fighter.action != action_attack {
    return false
  }
  let mv = fighter.current_move
  fighter.action_frame >= mv.startup_frames + mv.active_frames
}

///|
fn set_idle_state(fighter : Fighter) -> Unit {
  fighter.action = action_idle
  fighter.action_frame = 0
  fighter.action_elapsed = 0.0
  fighter.current_move = MoveSpec::empty()
  fighter.move_connected = false
  fighter.move_was_blocked = false
  fighter.move_cancel_enabled = false
  if fighter.on_ground {
    fighter.crouching = false
  }
}

///|
fn start_attack(
  fighter : Fighter,
  archetype : CharacterArchetype,
  mv : MoveSpec,
) -> Unit {
  fighter.action = action_attack
  fighter.action_frame = 0
  fighter.action_elapsed = 0.0
  fighter.current_move = mv
  fighter.move_connected = false
  fighter.move_was_blocked = false
  fighter.move_cancel_enabled = false

  if mv.move_kind == move_kind_super {
    fighter.super_meter = clampi(fighter.super_meter - super_cost, 0, super_max)
  }

  add_meter(fighter, mv.meter_gain_on_use, archetype)

  let fx = facing_sign(fighter.facing)
  if mv.auto_dash {
    fighter.vx = dash_forward_speed * 0.62 * fx
  } else {
    fighter.vx = mv.drift_speed * fx
  }

  if mv.attack_id == attack_special_dp {
    if fighter.on_ground {
      fighter.on_ground = false
      fighter.jumped = true
      fighter.vy = jump_initial_velocity * 0.74
    }
  }

  if mv.invuln_end > 0 {
    fighter.invuln = mv.invuln_end
  }

  fighter.input.buffered_motion = motion_none
  fighter.input.motion_timer = 0.0
  fighter.input.attack_buffer_timer = 0.0
}

///|
fn chosen_normal_move(
  input : InputState,
  archetype : CharacterArchetype,
) -> MoveSpec {
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
fn can_cancel_current_move(fighter : Fighter) -> Bool {
  if fighter.action != action_attack {
    return false
  }
  let mv = fighter.current_move
  if fighter.action_frame < mv.cancel_window_start ||
    fighter.action_frame > mv.cancel_window_end {
    return false
  }
  if mv.move_kind == move_kind_normal {
    true
  } else {
    fighter.move_cancel_enabled
  }
}

///|
fn choose_attack_from_input(
  fighter : Fighter,
  archetype : CharacterArchetype,
) -> MoveSpec {
  let input = fighter.input
  let motion = if input.motion_timer > 0.0 {
    input.buffered_motion
  } else {
    motion_none
  }

  if motion == motion_qcf &&
    fighter.super_meter >= super_cost &&
    input.hp_pressed &&
    input.hk_pressed {
    return archetype.super_move
  }

  if motion == motion_dp &&
    (
      input.hp_pressed ||
      input.hk_pressed ||
      input.lp_pressed ||
      input.lk_pressed
    ) {
    return archetype.special_dp
  }

  if motion == motion_qcf &&
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
fn try_start_attack(game : Game, slot : Int) -> Unit {
  let fighter = game.fighters[slot]
  let archetype = fighter_archetype(game, fighter)
  let input = fighter.input

  if not(input.any_attack_pressed) {
    return
  }

  // LP+LK is reserved for throw attempts and resolved in throw_system.mbt.
  if throw_input_pressed(input) {
    return
  }

  if fighter.action == action_hitstun ||
    fighter.action == action_blockstun ||
    fighter.action == action_knockdown ||
    fighter.action == action_wakeup ||
    fighter.action == action_throw ||
    fighter.action == action_intro ||
    fighter.action == action_victory {
    return
  }

  if fighter.action == action_attack && not(can_cancel_current_move(fighter)) {
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

  if mv.move_kind == move_kind_super {
    game.stage_flash = 0.32
    game.announcer_text = "SUPER!"
    game.announcer_timer = 0.5
    game.dramatic_freeze = 7
    push_camera_shake(game, 5.0)
  }
}

///|
fn update_fighter_recovery_state(fighter : Fighter) -> Unit {
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
    fighter.combo_damage = 0
  }

  if fighter.hitstop > 0 {
    fighter.hitstop -= 1
  }

  if fighter.flash_timer > 0.0 {
    fighter.flash_timer -= frame_dt
    if fighter.flash_timer < 0.0 {
      fighter.flash_timer = 0.0
    }
  }

  if fighter.shake_timer > 0.0 {
    fighter.shake_timer -= frame_dt
    if fighter.shake_timer <= 0.0 {
      fighter.shake_timer = 0.0
      fighter.hurt_shake_x = 0.0
      fighter.hurt_shake_y = 0.0
    }
  }
}

///|
fn update_fighter_action_frame(fighter : Fighter, dt : Float) -> Unit {
  fighter.action_elapsed += dt
  fighter.action_frame = (fighter.action_elapsed * fight_fps).to_int()

  if fighter.action == action_attack {
    if fighter.action_frame >= fighter.current_move.total_frames {
      set_idle_state(fighter)
    }
  } else if fighter.action == action_throw {
    if fighter.action_frame >= 18 {
      set_idle_state(fighter)
    }
  } else if fighter.action == action_dash_forward ||
    fighter.action == action_dash_back {
    if fighter.action_frame >= dash_duration_frames {
      set_idle_state(fighter)
    }
  } else if fighter.action == action_intro {
    if fighter.action_frame >= 20 {
      set_idle_state(fighter)
    }
  } else if fighter.action == action_wakeup {
    if fighter.action_frame >= 18 {
      set_idle_state(fighter)
    }
  }
}

///|
fn update_stun_and_knockdown(fighter : Fighter) -> Unit {
  if fighter.action == action_hitstun {
    fighter.hitstun -= 1
    fighter.vx *= 0.92
    if fighter.hitstun <= 0 {
      set_idle_state(fighter)
    }
  } else if fighter.action == action_blockstun {
    fighter.blockstun -= 1
    fighter.vx *= 0.9
    if fighter.blockstun <= 0 {
      set_idle_state(fighter)
    }
  } else if fighter.action == action_knockdown {
    fighter.knockdown -= 1
    fighter.vx *= 0.94
    if fighter.knockdown <= 0 {
      fighter.action = action_wakeup
      fighter.action_elapsed = 0.0
      fighter.action_frame = 0
      fighter.on_ground = true
      fighter.vy = 0.0
      fighter.crouching = false
      fighter.invuln = wakeup_invuln_frames
    }
  }
}

///|
fn update_walk_and_crouch_state(
  fighter : Fighter,
  archetype : CharacterArchetype,
) -> Unit {
  let input = fighter.input
  let fx = facing_sign(fighter.facing)

  if fighter.action == action_dash_forward {
    fighter.vx = dash_forward_speed * fx * archetype.speed_mul
    return
  }

  if fighter.action == action_dash_back {
    fighter.vx = dash_back_speed * fx * archetype.speed_mul
    return
  }

  if fighter.action == action_attack || fighter.action == action_throw {
    return
  }

  if not(fighter.on_ground) {
    return
  }

  if input.hold_down {
    fighter.action = action_crouch
    fighter.crouching = true
    fighter.vx = approachf(
      fighter.vx,
      if input.hold_forward {
        crouch_slide_speed * fx
      } else if input.hold_back {
        -crouch_slide_speed * fx
      } else {
        0.0
      },
      44.0,
    )
    return
  }

  fighter.crouching = false

  if input.dash_forward_pressed {
    fighter.action = action_dash_forward
    fighter.action_elapsed = 0.0
    fighter.action_frame = 0
    fighter.vx = dash_forward_speed * fx * archetype.speed_mul
    return
  }

  if input.dash_back_pressed {
    fighter.action = action_dash_back
    fighter.action_elapsed = 0.0
    fighter.action_frame = 0
    fighter.vx = dash_back_speed * fx * archetype.speed_mul
    return
  }

  if input.hold_forward {
    fighter.action = action_walk_forward
    fighter.vx = move_speed_forward * fx * archetype.speed_mul
  } else if input.hold_back {
    fighter.action = action_walk_back
    fighter.vx = -move_speed_back * fx * archetype.speed_mul
  } else {
    if fighter.action == action_walk_forward ||
      fighter.action == action_walk_back ||
      fighter.action == action_crouch {
      fighter.action = action_idle
      fighter.action_elapsed = 0.0
      fighter.action_frame = 0
    }
    fighter.vx = approachf(fighter.vx, 0.0, 50.0)
  }
}

///|
fn update_jump_state(fighter : Fighter, archetype : CharacterArchetype) -> Unit {
  if fighter.action == action_hitstun ||
    fighter.action == action_blockstun ||
    fighter.action == action_knockdown ||
    fighter.action == action_wakeup ||
    fighter.action == action_throw ||
    fighter.action == action_intro ||
    fighter.action == action_victory {
    return
  }

  let input = fighter.input
  if fighter.on_ground && input.hold_up && not(input.hold_down) {
    fighter.on_ground = false
    fighter.jumped = true
    fighter.action = action_jump
    fighter.action_elapsed = 0.0
    fighter.action_frame = 0
    fighter.vy = jump_initial_velocity * archetype.jump_mul
    if input.hold_forward {
      fighter.vx += move_speed_forward * 0.45 * facing_sign(fighter.facing)
    } else if input.hold_back {
      fighter.vx -= move_speed_back * 0.4 * facing_sign(fighter.facing)
    }
  }
}

///|
fn integrate_fighter_physics(
  fighter : Fighter,
  archetype : CharacterArchetype,
  dt : Float,
) -> Unit {
  if not(fighter.on_ground) {
    fighter.vy += gravity_force * dt * archetype.jump_mul
  } else {
    fighter.vy = 0.0
  }

  fighter.x += fighter.vx * dt
  fighter.y += fighter.vy * dt

  fighter.x = stage_clamp_x(fighter.x)

  if fighter.y >= floor_y {
    if not(fighter.on_ground) {
      fighter.y = floor_y
      fighter.on_ground = true
      fighter.jumped = false
      fighter.vy = 0.0
      if fighter.action == action_jump {
        set_idle_state(fighter)
      }
    } else {
      fighter.y = floor_y
    }
  }

  if fighter.action == action_attack {
    if fighter.current_move.drift_speed == 0.0 {
      fighter.vx = approachf(fighter.vx, 0.0, 25.0)
    }
  } else if fighter.action == action_dash_forward ||
    fighter.action == action_dash_back {
    // Dash keeps velocity while action is active.
  } else {
    fighter.vx = approachf(fighter.vx, 0.0, 22.0)
  }
}

///|
fn update_facing(game : Game) -> Unit {
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  if p1.x < p2.x {
    if (p1.action != action_attack && p1.action != action_throw) ||
      p1.action_frame < p1.current_move.startup_frames {
      p1.facing = facing_right
    }
    if (p2.action != action_attack && p2.action != action_throw) ||
      p2.action_frame < p2.current_move.startup_frames {
      p2.facing = facing_left
    }
  } else {
    if (p1.action != action_attack && p1.action != action_throw) ||
      p1.action_frame < p1.current_move.startup_frames {
      p1.facing = facing_left
    }
    if (p2.action != action_attack && p2.action != action_throw) ||
      p2.action_frame < p2.current_move.startup_frames {
      p2.facing = facing_right
    }
  }
}

///|
fn resolve_push_collision(game : Game) -> Unit {
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  let dx = p2.x - p1.x
  let dist = absf(dx)
  let min_dist = fighter_push_radius * 2.0
  if dist < min_dist {
    let overlap = (min_dist - dist) * 0.5
    if dx >= 0.0 {
      p1.x -= overlap
      p2.x += overlap
    } else {
      p1.x += overlap
      p2.x -= overlap
    }
    p1.x = stage_clamp_x(p1.x)
    p2.x = stage_clamp_x(p2.x)
  }
}

///|
fn update_fighter_core(game : Game, slot : Int, dt : Float) -> Unit {
  let fighter = game.fighters[slot]
  let archetype = fighter_archetype(game, fighter)

  update_fighter_recovery_state(fighter)

  if fighter.hitstop > 0 {
    return
  }

  update_stun_and_knockdown(fighter)
  if fighter.action == action_hitstun ||
    fighter.action == action_blockstun ||
    fighter.action == action_knockdown ||
    fighter.action == action_wakeup ||
    fighter.action == action_throw ||
    fighter.action == action_intro ||
    fighter.action == action_victory {
    update_fighter_action_frame(fighter, dt)
    integrate_fighter_physics(fighter, archetype, dt)
    return
  }

  update_jump_state(fighter, archetype)

  if fighter.action != action_attack && fighter.action != action_throw {
    update_walk_and_crouch_state(fighter, archetype)
  }

  try_start_attack(game, slot)

  update_fighter_action_frame(fighter, dt)
  integrate_fighter_physics(fighter, archetype, dt)
}
