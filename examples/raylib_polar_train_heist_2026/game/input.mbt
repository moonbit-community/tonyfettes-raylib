///|
fn clear_input(game : @types.Game) -> Unit {
  game.input_x = 0.0
  game.input_jump_press = false
  game.input_fire_hold = false
  game.input_dash_press = false
  game.input_hook_press = false
  game.input_restart_press = false
}

///|
fn update_title_input(game : @types.Game) -> Unit {
  clear_input(game)
  game.touch_mode = game.touch_count > 0

  let start_btn = @types.title_start_rect()
  let hover = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    start_btn.0,
    start_btn.1,
    start_btn.2,
    start_btn.3,
  )

  let key_start = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  let mouse_start = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let touch_start = hover && not(game.touch_restart_prev)

  game.input_restart_press = key_start || mouse_start || touch_start
  game.touch_restart_prev = hover
}

///|
fn update_play_input(game : @types.Game) -> Unit {
  clear_input(game)
  game.touch_mode = game.touch_count > 0

  let left = @types.btn_left_rect()
  let right = @types.btn_right_rect()
  let jump = @types.btn_jump_rect()
  let fire = @types.btn_fire_rect()
  let dash = @types.btn_dash_rect()
  let hook = @types.btn_hook_rect()

  let t_left = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    left.0,
    left.1,
    left.2,
    left.3,
  )
  let t_right = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    right.0,
    right.1,
    right.2,
    right.3,
  )
  let t_jump = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    jump.0,
    jump.1,
    jump.2,
    jump.3,
  )
  let t_fire = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    fire.0,
    fire.1,
    fire.2,
    fire.3,
  )
  let t_dash = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    dash.0,
    dash.1,
    dash.2,
    dash.3,
  )
  let t_hook = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    hook.0,
    hook.1,
    hook.2,
    hook.3,
  )

  let key_left = @raylib.is_key_down(@raylib.KeyA) ||
    @raylib.is_key_down(@raylib.KeyLeft)
  let key_right = @raylib.is_key_down(@raylib.KeyD) ||
    @raylib.is_key_down(@raylib.KeyRight)

  if key_left || t_left {
    game.input_x = game.input_x - 1.0
  }
  if key_right || t_right {
    game.input_x = game.input_x + 1.0
  }

  game.input_x = @types.clampf(game.input_x, -1.0, 1.0)

  let key_jump = @raylib.is_key_pressed(@raylib.KeyW) ||
    @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
  game.input_jump_press = key_jump || (t_jump && not(game.touch_jump_prev))

  let key_fire = @raylib.is_key_down(@raylib.KeyJ) ||
    @raylib.is_key_down(@raylib.KeyZ) ||
    @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
  game.input_fire_hold = key_fire || t_fire

  let key_dash = @raylib.is_key_pressed(@raylib.KeyLeftShift) ||
    @raylib.is_key_pressed(@raylib.KeyRightShift) ||
    @raylib.is_key_pressed(@raylib.KeyK)
  let key_hook = @raylib.is_key_pressed(@raylib.KeyL) ||
    @raylib.is_key_pressed(@raylib.KeyE)

  game.input_dash_press = key_dash || (t_dash && not(game.touch_dash_prev))
  game.input_hook_press = key_hook || (t_hook && not(game.touch_hook_prev))

  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)

  game.touch_jump_prev = t_jump
  game.touch_dash_prev = t_dash
  game.touch_hook_prev = t_hook
}

///|
fn update_result_input(game : @types.Game) -> Unit {
  clear_input(game)
  game.touch_mode = game.touch_count > 0

  let retry = @types.retry_rect()
  let hover = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    retry.0,
    retry.1,
    retry.2,
    retry.3,
  )

  let key_retry = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeyR)
  let mouse_retry = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let touch_retry = hover && not(game.touch_restart_prev)

  game.input_restart_press = key_retry || mouse_retry || touch_retry
  game.touch_restart_prev = hover
}
