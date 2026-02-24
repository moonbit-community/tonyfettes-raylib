///|
fn point_in_rect(
  x : Float,
  y : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  x >= rx && x <= rx + rw && y >= ry && y <= ry + rh
}

///|
fn pointer_on_rect(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  if hold && point_in_rect(mx, my, rx, ry, rw, rh) {
    return true
  }

  for i = 0; i < touch_count; i = i + 1 {
    let p = @raylib.get_touch_position(i)
    if point_in_rect(p.x, p.y, rx, ry, rw, rh) {
      return true
    }
  }

  false
}

///|
fn clear_input(game : Game) -> Unit {
  game.input_x = 0.0
  game.input_jump_press = false
  game.input_fire_hold = false
  game.input_dash_press = false
  game.input_hook_press = false
  game.input_restart_press = false
}

///|
fn update_title_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_input(game)
  game.touch_mode = touch_count > 0

  let start_btn = title_start_rect()
  let hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
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
fn update_play_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_input(game)
  game.touch_mode = touch_count > 0

  let left = btn_left_rect()
  let right = btn_right_rect()
  let jump = btn_jump_rect()
  let fire = btn_fire_rect()
  let dash = btn_dash_rect()
  let hook = btn_hook_rect()

  let t_left = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    left.0,
    left.1,
    left.2,
    left.3,
  )
  let t_right = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    right.0,
    right.1,
    right.2,
    right.3,
  )
  let t_jump = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    jump.0,
    jump.1,
    jump.2,
    jump.3,
  )
  let t_fire = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    fire.0,
    fire.1,
    fire.2,
    fire.3,
  )
  let t_dash = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    dash.0,
    dash.1,
    dash.2,
    dash.3,
  )
  let t_hook = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
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

  game.input_x = clampf(game.input_x, -1.0, 1.0)

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
fn update_result_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_input(game)
  game.touch_mode = touch_count > 0

  let retry = retry_rect()
  let hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
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
