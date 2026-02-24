///|
fn bool_to_int(v : Bool) -> Int {
  if v {
    1
  } else {
    0
  }
}

///|
fn control_keys(slot : Int) -> (Int, Int, Int, Int, Int, Int, Int, Int, Int) {
  if slot == 0 {
    (
      @raylib.KeyA,
      @raylib.KeyD,
      @raylib.KeyW,
      @raylib.KeyS,
      @raylib.KeyF,
      @raylib.KeyG,
      @raylib.KeyH,
      @raylib.KeyJ,
      @raylib.KeyEnter,
    )
  } else {
    (
      @raylib.KeyLeft,
      @raylib.KeyRight,
      @raylib.KeyUp,
      @raylib.KeyDown,
      @raylib.KeyU,
      @raylib.KeyI,
      @raylib.KeyO,
      @raylib.KeyP,
      @raylib.KeyEnter,
    )
  }
}

///|
fn encode_relative_direction(x : Int, y : Int, facing : Int) -> Int {
  let rx = if facing == facing_right { x } else { -x }
  if y > 0 {
    if rx < 0 {
      dir_down_back
    } else if rx > 0 {
      dir_down_forward
    } else {
      dir_down
    }
  } else if y < 0 {
    dir_up
  } else if rx < 0 {
    dir_back
  } else if rx > 0 {
    dir_forward
  } else {
    dir_neutral
  }
}

///|
fn push_direction_history(input : InputState, dir : Int) -> Unit {
  input.dir_history[input.dir_head] = dir
  input.dir_head += 1
  if input.dir_head >= input.dir_history.length() {
    input.dir_head = 0
  }
}

///|
fn recent_direction(input : InputState, age : Int) -> Int {
  let len = input.dir_history.length()
  let mut idx = input.dir_head - 1 - age
  while idx < 0 {
    idx += len
  }
  input.dir_history[idx % len]
}

///|
fn dir_is_forward(dir : Int) -> Bool {
  dir == dir_forward || dir == dir_down_forward
}

///|
fn dir_is_down(dir : Int) -> Bool {
  dir == dir_down || dir == dir_down_back || dir == dir_down_forward
}

///|
fn detect_motion_qcf(input : InputState) -> Bool {
  let mut seen_down = false
  let mut seen_diag = false
  for i = 20; i >= 0; i = i - 1 {
    let d = recent_direction(input, i)
    if not(seen_down) {
      if dir_is_down(d) {
        seen_down = true
      }
    } else if not(seen_diag) {
      if d == dir_down_forward {
        seen_diag = true
      } else if dir_is_forward(d) {
        return true
      }
    } else if dir_is_forward(d) {
      return true
    }
  }
  false
}

///|
fn detect_motion_dp(input : InputState) -> Bool {
  let mut stage = 0
  for i = 20; i >= 0; i = i - 1 {
    let d = recent_direction(input, i)
    if stage == 0 {
      if dir_is_forward(d) {
        stage = 1
      }
    } else if stage == 1 {
      if dir_is_down(d) {
        stage = 2
      }
    } else if d == dir_down_forward {
      return true
    }
  }
  false
}

///|
fn tick_input_timers(input : InputState, dt : Float) -> Unit {
  if input.tap_forward_timer > 0.0 {
    input.tap_forward_timer -= dt
    if input.tap_forward_timer < 0.0 {
      input.tap_forward_timer = 0.0
    }
  }
  if input.tap_back_timer > 0.0 {
    input.tap_back_timer -= dt
    if input.tap_back_timer < 0.0 {
      input.tap_back_timer = 0.0
    }
  }
  if input.motion_timer > 0.0 {
    input.motion_timer -= dt
    if input.motion_timer <= 0.0 {
      input.motion_timer = 0.0
      input.buffered_motion = motion_none
    }
  }
  if input.attack_buffer_timer > 0.0 {
    input.attack_buffer_timer -= dt
    if input.attack_buffer_timer < 0.0 {
      input.attack_buffer_timer = 0.0
    }
  }
}

///|
fn set_button_state(
  input : InputState,
  down : Bool,
  prev_down : Bool,
) -> (Bool, Bool) {
  (down && not(prev_down), not(down) && prev_down)
}

///|
fn sample_human_input(fighter : Fighter, slot : Int, dt : Float) -> Unit {
  let input = fighter.input
  let (
    key_left,
    key_right,
    key_up,
    key_down,
    key_lp,
    key_hp,
    key_lk,
    key_hk,
    key_start,
  ) = control_keys(slot)

  input.prev_x = input.x
  input.prev_y = input.y

  let left_down = @raylib.is_key_down(key_left)
  let right_down = @raylib.is_key_down(key_right)
  let up_down = @raylib.is_key_down(key_up)
  let down_down = @raylib.is_key_down(key_down)

  input.x = bool_to_int(right_down) - bool_to_int(left_down)
  input.y = bool_to_int(down_down) - bool_to_int(up_down)

  input.dash_forward_pressed = false
  input.dash_back_pressed = false

  let prev_rel_x = if fighter.facing == facing_right {
    input.prev_x
  } else {
    -input.prev_x
  }
  let rel_x = if fighter.facing == facing_right { input.x } else { -input.x }

  input.hold_forward = rel_x > 0
  input.hold_back = rel_x < 0
  input.hold_up = input.y < 0
  input.hold_down = input.y > 0

  if rel_x > 0 && prev_rel_x <= 0 {
    if input.tap_forward_timer > 0.0 {
      input.dash_forward_pressed = true
    }
    input.tap_forward_timer = tap_window
  }
  if rel_x < 0 && prev_rel_x >= 0 {
    if input.tap_back_timer > 0.0 {
      input.dash_back_pressed = true
    }
    input.tap_back_timer = tap_window
  }

  let prev_lp = input.lp_down
  let prev_hp = input.hp_down
  let prev_lk = input.lk_down
  let prev_hk = input.hk_down
  let prev_start = input.start_down

  input.lp_down = @raylib.is_key_down(key_lp)
  input.hp_down = @raylib.is_key_down(key_hp)
  input.lk_down = @raylib.is_key_down(key_lk)
  input.hk_down = @raylib.is_key_down(key_hk)
  input.start_down = @raylib.is_key_down(key_start)

  let (lp_pressed, lp_released) = set_button_state(
    input,
    input.lp_down,
    prev_lp,
  )
  let (hp_pressed, hp_released) = set_button_state(
    input,
    input.hp_down,
    prev_hp,
  )
  let (lk_pressed, lk_released) = set_button_state(
    input,
    input.lk_down,
    prev_lk,
  )
  let (hk_pressed, hk_released) = set_button_state(
    input,
    input.hk_down,
    prev_hk,
  )
  let (start_pressed, _) = set_button_state(input, input.start_down, prev_start)

  input.lp_pressed = lp_pressed
  input.hp_pressed = hp_pressed
  input.lk_pressed = lk_pressed
  input.hk_pressed = hk_pressed
  input.start_pressed = start_pressed
  input.lp_released = lp_released
  input.hp_released = hp_released
  input.lk_released = lk_released
  input.hk_released = hk_released

  input.any_attack_pressed = input.lp_pressed ||
    input.hp_pressed ||
    input.lk_pressed ||
    input.hk_pressed

  let dir_code = encode_relative_direction(input.x, input.y, fighter.facing)
  push_direction_history(input, dir_code)

  tick_input_timers(input, dt)

  if input.any_attack_pressed {
    input.attack_buffer_timer = 0.16
    if detect_motion_dp(input) {
      input.buffered_motion = motion_dp
      input.motion_timer = 0.24
    } else if detect_motion_qcf(input) {
      input.buffered_motion = motion_qcf
      input.motion_timer = 0.24
    }
  }
}

///|
fn reset_input_for_cpu(fighter : Fighter, dt : Float) -> Unit {
  let input = fighter.input
  input.prev_x = input.x
  input.prev_y = input.y
  input.x = 0
  input.y = 0
  input.hold_forward = false
  input.hold_back = false
  input.hold_up = false
  input.hold_down = false
  input.lp_pressed = false
  input.hp_pressed = false
  input.lk_pressed = false
  input.hk_pressed = false
  input.start_pressed = false
  input.lp_released = false
  input.hp_released = false
  input.lk_released = false
  input.hk_released = false
  input.any_attack_pressed = false
  input.dash_forward_pressed = false
  input.dash_back_pressed = false

  let dir_code = encode_relative_direction(input.x, input.y, fighter.facing)
  push_direction_history(input, dir_code)
  tick_input_timers(input, dt)
}

///|
fn input_press_lp(fighter : Fighter) -> Unit {
  let input = fighter.input
  input.lp_pressed = true
  input.lp_down = true
  input.any_attack_pressed = true
  input.attack_buffer_timer = 0.16
}

///|
fn input_press_hp(fighter : Fighter) -> Unit {
  let input = fighter.input
  input.hp_pressed = true
  input.hp_down = true
  input.any_attack_pressed = true
  input.attack_buffer_timer = 0.16
}

///|
fn input_press_lk(fighter : Fighter) -> Unit {
  let input = fighter.input
  input.lk_pressed = true
  input.lk_down = true
  input.any_attack_pressed = true
  input.attack_buffer_timer = 0.16
}

///|
fn input_press_hk(fighter : Fighter) -> Unit {
  let input = fighter.input
  input.hk_pressed = true
  input.hk_down = true
  input.any_attack_pressed = true
  input.attack_buffer_timer = 0.16
}

///|
fn input_press_super(fighter : Fighter) -> Unit {
  let input = fighter.input
  input.hp_pressed = true
  input.hk_pressed = true
  input.hp_down = true
  input.hk_down = true
  input.any_attack_pressed = true
  input.attack_buffer_timer = 0.16
  input.buffered_motion = motion_qcf
  input.motion_timer = 0.24
}

///|
fn push_cpu_direction(
  fighter : Fighter,
  desired_x : Int,
  desired_y : Int,
) -> Unit {
  let input = fighter.input
  input.prev_x = input.x
  input.prev_y = input.y
  input.x = clampi(desired_x, -1, 1)
  input.y = clampi(desired_y, -1, 1)

  let prev_rel_x = if fighter.facing == facing_right {
    input.prev_x
  } else {
    -input.prev_x
  }
  let rel_x = if fighter.facing == facing_right { input.x } else { -input.x }

  input.hold_forward = rel_x > 0
  input.hold_back = rel_x < 0
  input.hold_up = input.y < 0
  input.hold_down = input.y > 0

  input.dash_forward_pressed = false
  input.dash_back_pressed = false
  if rel_x > 0 && prev_rel_x <= 0 {
    if input.tap_forward_timer > 0.0 {
      input.dash_forward_pressed = true
    }
    input.tap_forward_timer = tap_window
  }
  if rel_x < 0 && prev_rel_x >= 0 {
    if input.tap_back_timer > 0.0 {
      input.dash_back_pressed = true
    }
    input.tap_back_timer = tap_window
  }

  let dir_code = encode_relative_direction(input.x, input.y, fighter.facing)
  push_direction_history(input, dir_code)
}

///|
fn finalize_cpu_input(fighter : Fighter, dt : Float) -> Unit {
  let input = fighter.input
  if input.any_attack_pressed {
    if input.buffered_motion == motion_none {
      if detect_motion_dp(input) {
        input.buffered_motion = motion_dp
        input.motion_timer = 0.24
      } else if detect_motion_qcf(input) {
        input.buffered_motion = motion_qcf
        input.motion_timer = 0.24
      }
    }
  }
  tick_input_timers(input, dt)
}

///|
fn clear_input_edges(fighter : Fighter) -> Unit {
  let input = fighter.input
  input.lp_pressed = false
  input.hp_pressed = false
  input.lk_pressed = false
  input.hk_pressed = false
  input.start_pressed = false
  input.lp_released = false
  input.hp_released = false
  input.lk_released = false
  input.hk_released = false
  input.any_attack_pressed = false
}

///|
fn update_inputs(game : Game, dt : Float) -> Unit {
  for slot = 0; slot < max_players; slot = slot + 1 {
    let fighter = game.fighters[slot]
    clear_input_edges(fighter)

    if fighter.is_cpu && game.state == state_fight {
      reset_input_for_cpu(fighter, dt)
      update_cpu_input(game, slot, dt)
      finalize_cpu_input(fighter, dt)
    } else {
      sample_human_input(fighter, slot, dt)
    }
  }
}
