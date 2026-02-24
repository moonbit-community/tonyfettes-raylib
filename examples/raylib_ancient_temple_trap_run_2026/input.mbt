///|
fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
fn pointer_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  if mouse_hold && inside_rect(mouse_x, mouse_y, x, y, w, h) {
    return true
  }

  for i = 0; i < touch_count; i = i + 1 {
    let p = @raylib.get_touch_position(i)
    if inside_rect(p.x, p.y, x, y, w, h) {
      return true
    }
  }

  false
}

///|
fn mouse_click_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
  inside_rect(mouse_x, mouse_y, x, y, w, h)
}

///|
fn clear_frame_input(game : Game) -> Unit {
  game.input_x = 0.0
  game.input_y = 0.0
  game.input_dash_hold = false
  game.input_start_press = false
  game.input_restart_press = false
  game.input_next_press = false
}

///|
fn update_touch_mode(game : Game, touch_count : Int) -> Unit {
  if touch_count > 0 {
    game.touch_mode = true
  }
}

///|
fn update_title_input(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_frame_input(game)
  update_touch_mode(game, touch_count)

  let (x, y, w, h) = title_start_rect()
  let touch_hover = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, x, y, w, h,
  )

  let key_press = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  let mouse_press = mouse_click_on_rect(mouse_x, mouse_y, x, y, w, h)
  let touch_press = touch_hover && not(game.touch_start_prev)

  game.input_start_press = key_press || mouse_press || touch_press
  game.touch_start_prev = touch_hover
}

///|
fn update_play_input(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_frame_input(game)
  update_touch_mode(game, touch_count)

  let (lx, ly, lw, lh) = touch_left_rect()
  let (rx, ry, rw, rh) = touch_right_rect()
  let (ux, uy, uw, uh) = touch_up_rect()
  let (dx, dy, dw, dh) = touch_down_rect()
  let (dash_x, dash_y, dash_w, dash_h) = touch_dash_rect()
  let (rst_x, rst_y, rst_w, rst_h) = play_restart_rect()

  let touch_left = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, lx, ly, lw, lh,
  )
  let touch_right = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, rx, ry, rw, rh,
  )
  let touch_up = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, ux, uy, uw, uh,
  )
  let touch_down = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, dx, dy, dw, dh,
  )
  let touch_dash = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, dash_x, dash_y, dash_w, dash_h,
  )

  let key_left = @raylib.is_key_down(@raylib.KeyA) ||
    @raylib.is_key_down(@raylib.KeyLeft)
  let key_right = @raylib.is_key_down(@raylib.KeyD) ||
    @raylib.is_key_down(@raylib.KeyRight)
  let key_up = @raylib.is_key_down(@raylib.KeyW) ||
    @raylib.is_key_down(@raylib.KeyUp)
  let key_down = @raylib.is_key_down(@raylib.KeyS) ||
    @raylib.is_key_down(@raylib.KeyDown)

  if key_left || touch_left {
    game.input_x = game.input_x - 1.0
  }
  if key_right || touch_right {
    game.input_x = game.input_x + 1.0
  }
  if key_up || touch_up {
    game.input_y = game.input_y - 1.0
  }
  if key_down || touch_down {
    game.input_y = game.input_y + 1.0
  }

  game.input_x = clampf(game.input_x, -1.0, 1.0)
  game.input_y = clampf(game.input_y, -1.0, 1.0)

  let key_dash = @raylib.is_key_down(@raylib.KeyLeftShift) ||
    @raylib.is_key_down(@raylib.KeyRightShift) ||
    @raylib.is_key_down(@raylib.KeyK)
  game.input_dash_hold = key_dash || touch_dash

  let restart_hover = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, rst_x, rst_y, rst_w, rst_h,
  )
  let key_restart = @raylib.is_key_pressed(@raylib.KeyR)
  let mouse_restart = mouse_click_on_rect(
    mouse_x, mouse_y, rst_x, rst_y, rst_w, rst_h,
  )
  let touch_restart = restart_hover && not(game.touch_restart_prev)

  game.input_restart_press = key_restart || mouse_restart || touch_restart
  game.touch_restart_prev = restart_hover
}

///|
fn update_stage_clear_input(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_frame_input(game)
  update_touch_mode(game, touch_count)

  let (next_x, next_y, next_w, next_h) = panel_next_rect()
  let (rst_x, rst_y, rst_w, rst_h) = panel_restart_rect()

  let touch_next_hover = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, next_x, next_y, next_w, next_h,
  )
  let touch_restart_hover = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, rst_x, rst_y, rst_w, rst_h,
  )

  let key_next = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  let key_restart = @raylib.is_key_pressed(@raylib.KeyR)

  let mouse_next = mouse_click_on_rect(
    mouse_x, mouse_y, next_x, next_y, next_w, next_h,
  )
  let mouse_restart = mouse_click_on_rect(
    mouse_x, mouse_y, rst_x, rst_y, rst_w, rst_h,
  )

  let touch_next = touch_next_hover && not(game.touch_next_prev)
  let touch_restart = touch_restart_hover && not(game.touch_restart_prev)

  game.input_next_press = key_next || mouse_next || touch_next
  game.input_restart_press = key_restart || mouse_restart || touch_restart

  game.touch_next_prev = touch_next_hover
  game.touch_restart_prev = touch_restart_hover
}

///|
fn update_failed_input(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_frame_input(game)
  update_touch_mode(game, touch_count)

  let (title_x, title_y, title_w, title_h) = panel_next_rect()
  let (retry_x, retry_y, retry_w, retry_h) = panel_restart_rect()

  let touch_title_hover = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, title_x, title_y, title_w, title_h,
  )
  let touch_retry_hover = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, retry_x, retry_y, retry_w, retry_h,
  )

  let key_retry = @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  let key_title = @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyT)

  let mouse_title = mouse_click_on_rect(
    mouse_x, mouse_y, title_x, title_y, title_w, title_h,
  )
  let mouse_retry = mouse_click_on_rect(
    mouse_x, mouse_y, retry_x, retry_y, retry_w, retry_h,
  )

  let touch_title = touch_title_hover && not(game.touch_next_prev)
  let touch_retry = touch_retry_hover && not(game.touch_restart_prev)

  game.input_next_press = key_title || mouse_title || touch_title
  game.input_restart_press = key_retry || mouse_retry || touch_retry

  game.touch_next_prev = touch_title_hover
  game.touch_restart_prev = touch_retry_hover
}

///|
fn update_victory_input(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_frame_input(game)
  update_touch_mode(game, touch_count)

  let (again_x, again_y, again_w, again_h) = panel_next_rect()
  let (title_x, title_y, title_w, title_h) = panel_restart_rect()

  let touch_again_hover = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, again_x, again_y, again_w, again_h,
  )
  let touch_title_hover = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, title_x, title_y, title_w, title_h,
  )

  let key_again = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  let key_title = @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyT)

  let mouse_again = mouse_click_on_rect(
    mouse_x, mouse_y, again_x, again_y, again_w, again_h,
  )
  let mouse_title = mouse_click_on_rect(
    mouse_x, mouse_y, title_x, title_y, title_w, title_h,
  )

  let touch_again = touch_again_hover && not(game.touch_next_prev)
  let touch_title = touch_title_hover && not(game.touch_restart_prev)

  game.input_next_press = key_again || mouse_again || touch_again
  game.input_restart_press = key_title || mouse_title || touch_title

  game.touch_next_prev = touch_again_hover
  game.touch_restart_prev = touch_title_hover
}
