///|
fn clear_input(game : Game) -> Unit {
  game.input_x = 0.0
  game.input_y = 0.0
  game.input_interact_press = false
  game.input_focus_hold = false
  game.input_dash_press = false
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

  let btn = title_start_rect()
  let hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    btn.0,
    btn.1,
    btn.2,
    btn.3,
  )

  let key_start = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  let mouse_start = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let touch_start = hover && not(game.touch_restart_prev)

  game.input_restart_press = key_start || mouse_start || touch_start

  game.touch_restart_prev = hover
  game.touch_interact_prev = false
  game.touch_dash_prev = false
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
  let up = btn_up_rect()
  let down = btn_down_rect()
  let interact = btn_interact_rect()
  let focus = btn_focus_rect()
  let dash = btn_dash_rect()

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
  let t_up = pointer_on_rect(mx, my, hold, touch_count, up.0, up.1, up.2, up.3)
  let t_down = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    down.0,
    down.1,
    down.2,
    down.3,
  )
  let t_interact = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    interact.0,
    interact.1,
    interact.2,
    interact.3,
  )
  let t_focus = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    focus.0,
    focus.1,
    focus.2,
    focus.3,
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

  let key_left = @raylib.is_key_down(@raylib.KeyA) ||
    @raylib.is_key_down(@raylib.KeyLeft)
  let key_right = @raylib.is_key_down(@raylib.KeyD) ||
    @raylib.is_key_down(@raylib.KeyRight)
  let key_up = @raylib.is_key_down(@raylib.KeyW) ||
    @raylib.is_key_down(@raylib.KeyUp)
  let key_down = @raylib.is_key_down(@raylib.KeyS) ||
    @raylib.is_key_down(@raylib.KeyDown)

  if key_left || t_left {
    game.input_x = game.input_x - 1.0
  }
  if key_right || t_right {
    game.input_x = game.input_x + 1.0
  }
  if key_up || t_up {
    game.input_y = game.input_y - 1.0
  }
  if key_down || t_down {
    game.input_y = game.input_y + 1.0
  }

  game.input_x = clampf(game.input_x, -1.0, 1.0)
  game.input_y = clampf(game.input_y, -1.0, 1.0)

  let key_interact = @raylib.is_key_pressed(@raylib.KeyJ) ||
    @raylib.is_key_pressed(@raylib.KeyE) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  game.input_interact_press = key_interact ||
    (t_interact && not(game.touch_interact_prev))

  let key_focus = @raylib.is_key_down(@raylib.KeyK) ||
    @raylib.is_key_down(@raylib.KeyLeftShift) ||
    @raylib.is_key_down(@raylib.KeyRightShift)
  game.input_focus_hold = key_focus || t_focus

  let key_dash = @raylib.is_key_pressed(@raylib.KeyL) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight)
  game.input_dash_press = key_dash || (t_dash && not(game.touch_dash_prev))

  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeyR)

  game.touch_interact_prev = t_interact
  game.touch_dash_prev = t_dash
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
  game.touch_interact_prev = false
  game.touch_dash_prev = false
}
