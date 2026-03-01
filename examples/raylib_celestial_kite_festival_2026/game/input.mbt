///|
fn clear_input(game : @types.Game) -> Unit {
  game.input_x = 0.0
  game.input_y = 0.0
  game.input_burst_press = false
  game.input_reel_hold = false
  game.input_restart_press = false
}

///|
fn update_title_input(game : @types.Game) -> Unit {
  clear_input(game)
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  game.touch_mode = touch_count > 0

  let btn = @types.title_start_rect()
  let hover = @types.pointer_on_rect(
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
  game.touch_burst_prev = false
}

///|
fn update_play_input(game : @types.Game) -> Unit {
  clear_input(game)
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  game.touch_mode = touch_count > 0

  let left = @types.btn_left_rect()
  let right = @types.btn_right_rect()
  let up = @types.btn_up_rect()
  let down = @types.btn_down_rect()
  let burst = @types.btn_burst_rect()
  let reel = @types.btn_reel_rect()

  let t_left = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    left.0,
    left.1,
    left.2,
    left.3,
  )
  let t_right = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    right.0,
    right.1,
    right.2,
    right.3,
  )
  let t_up = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    up.0,
    up.1,
    up.2,
    up.3,
  )
  let t_down = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    down.0,
    down.1,
    down.2,
    down.3,
  )
  let t_burst = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    burst.0,
    burst.1,
    burst.2,
    burst.3,
  )
  let t_reel = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    reel.0,
    reel.1,
    reel.2,
    reel.3,
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

  game.input_x = @types.clampf(game.input_x, -1.0, 1.0)
  game.input_y = @types.clampf(game.input_y, -1.0, 1.0)

  let key_burst = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyK)
  game.input_burst_press = key_burst || (t_burst && not(game.touch_burst_prev))

  let key_reel = @raylib.is_key_down(@raylib.KeyJ) ||
    @raylib.is_key_down(@raylib.KeyLeftShift) ||
    @raylib.is_key_down(@raylib.KeyRightShift) ||
    @raylib.is_mouse_button_down(@raylib.MouseButtonRight)
  game.input_reel_hold = key_reel || t_reel

  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeyR)

  game.touch_burst_prev = t_burst
}

///|
fn update_result_input(game : @types.Game) -> Unit {
  clear_input(game)
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  game.touch_mode = touch_count > 0

  let retry = @types.retry_rect()
  let hover = @types.pointer_on_rect(
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
  game.touch_burst_prev = false
}
