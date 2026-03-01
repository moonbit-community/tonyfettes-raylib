///|
fn clear_input(game : @types.Game) -> Unit {
  game.input_x = 0.0
  game.input_y = 0.0
  game.input_fire_hold = false
  game.input_dash_press = false
  game.input_emp_press = false
  game.input_restart_press = false
}

///|
fn update_title_input(game : @types.Game) -> Unit {
  clear_input(game)
  game.touch_mode = game.touch_count > 0

  let start = @types.title_start_rect()
  let hover = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    start.0,
    start.1,
    start.2,
    start.3,
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
  let up = @types.btn_up_rect()
  let down = @types.btn_down_rect()
  let fire = @types.btn_fire_rect()
  let dash = @types.btn_dash_rect()
  let emp = @types.btn_emp_rect()

  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let tc = game.touch_count

  let t_left = @types.pointer_on_rect(
    mx, my, hold, tc, left.0, left.1, left.2, left.3,
  )
  let t_right = @types.pointer_on_rect(
    mx, my, hold, tc, right.0, right.1, right.2, right.3,
  )
  let t_up = @types.pointer_on_rect(mx, my, hold, tc, up.0, up.1, up.2, up.3)
  let t_down = @types.pointer_on_rect(
    mx, my, hold, tc, down.0, down.1, down.2, down.3,
  )
  let t_fire = @types.pointer_on_rect(
    mx, my, hold, tc, fire.0, fire.1, fire.2, fire.3,
  )
  let t_dash = @types.pointer_on_rect(
    mx, my, hold, tc, dash.0, dash.1, dash.2, dash.3,
  )
  let t_emp = @types.pointer_on_rect(
    mx, my, hold, tc, emp.0, emp.1, emp.2, emp.3,
  )

  let key_left = @raylib.is_key_down(@raylib.KeyA) ||
    @raylib.is_key_down(@raylib.KeyLeft)
  let key_right = @raylib.is_key_down(@raylib.KeyD) ||
    @raylib.is_key_down(@raylib.KeyRight)
  let key_up = @raylib.is_key_down(@raylib.KeyW) ||
    @raylib.is_key_down(@raylib.KeyUp)
  let key_down = @raylib.is_key_down(@raylib.KeyS) ||
    @raylib.is_key_down(@raylib.KeyDown)

  let mut ix : Float = 0.0
  let mut iy : Float = 0.0

  if key_left || t_left {
    ix = ix - 1.0
  }
  if key_right || t_right {
    ix = ix + 1.0
  }
  if key_up || t_up {
    iy = iy - 1.0
  }
  if key_down || t_down {
    iy = iy + 1.0
  }

  let len2 = ix * ix + iy * iy
  if len2 > 1.0 {
    let inv : Float = Float::from_int(1) / @types.sqrtf(len2)
    ix = ix * inv
    iy = iy * inv
  }

  game.input_x = ix
  game.input_y = iy

  let key_fire = @raylib.is_key_down(@raylib.KeySpace) ||
    @raylib.is_key_down(@raylib.KeyJ) ||
    @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)

  game.input_fire_hold = key_fire || t_fire

  let key_dash = @raylib.is_key_pressed(@raylib.KeyLeftShift) ||
    @raylib.is_key_pressed(@raylib.KeyRightShift) ||
    @raylib.is_key_pressed(@raylib.KeyK)
  let key_emp = @raylib.is_key_pressed(@raylib.KeyL) ||
    @raylib.is_key_pressed(@raylib.KeyE)

  game.input_dash_press = key_dash || (t_dash && not(game.touch_dash_prev))
  game.input_emp_press = key_emp || (t_emp && not(game.touch_emp_prev))

  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)

  game.touch_dash_prev = t_dash
  game.touch_emp_prev = t_emp
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
