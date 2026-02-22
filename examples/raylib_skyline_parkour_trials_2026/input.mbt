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
fn clear_frame_input(game : Game) -> Unit {
  game.input_x = 0.0
  game.input_jump_press = false
  game.input_jump_hold = false
  game.input_climb_hold = false
  game.input_next_press = false
  game.input_restart_press = false
}

///|
fn update_touch_mode(game : Game, touch_count : Int) -> Unit {
  if touch_count > 0 {
    game.touch_mode = true
  }
}

///|
fn mouse_click_on_rect(
  mx : Float,
  my : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
  point_in_rect(mx, my, rx, ry, rw, rh)
}

///|
fn update_title_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_frame_input(game)
  update_touch_mode(game, touch_count)

  let start = title_start_rect()
  let start_touch = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    start.0,
    start.1,
    start.2,
    start.3,
  )

  let key_start = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  let mouse_start = mouse_click_on_rect(
    mx,
    my,
    start.0,
    start.1,
    start.2,
    start.3,
  )
  let touch_start = start_touch && not(game.touch_next_prev)

  game.input_next_press = key_start || mouse_start || touch_start
  game.touch_next_prev = start_touch
}

///|
fn update_play_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_frame_input(game)
  update_touch_mode(game, touch_count)

  let left_rect = touch_left_rect()
  let right_rect = touch_right_rect()
  let jump_rect = touch_jump_rect()
  let climb_rect = touch_climb_rect()
  let restart_rect = touch_play_restart_rect()

  let touch_left = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    left_rect.0,
    left_rect.1,
    left_rect.2,
    left_rect.3,
  )
  let touch_right = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    right_rect.0,
    right_rect.1,
    right_rect.2,
    right_rect.3,
  )
  let touch_jump = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    jump_rect.0,
    jump_rect.1,
    jump_rect.2,
    jump_rect.3,
  )
  let touch_climb = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    climb_rect.0,
    climb_rect.1,
    climb_rect.2,
    climb_rect.3,
  )
  let touch_restart = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    restart_rect.0,
    restart_rect.1,
    restart_rect.2,
    restart_rect.3,
  )

  let key_left = @raylib.is_key_down(@raylib.KeyA) ||
    @raylib.is_key_down(@raylib.KeyLeft)
  let key_right = @raylib.is_key_down(@raylib.KeyD) ||
    @raylib.is_key_down(@raylib.KeyRight)

  let mut move_x : Float = 0.0
  if key_left || touch_left {
    move_x = move_x - 1.0
  }
  if key_right || touch_right {
    move_x = move_x + 1.0
  }

  game.input_x = clampf(move_x, -1.0, 1.0)

  let key_jump_press = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyW) ||
    @raylib.is_key_pressed(@raylib.KeyUp)
  let key_jump_hold = @raylib.is_key_down(@raylib.KeySpace) ||
    @raylib.is_key_down(@raylib.KeyW) ||
    @raylib.is_key_down(@raylib.KeyUp)

  let key_climb_hold = @raylib.is_key_down(@raylib.KeyLeftShift) ||
    @raylib.is_key_down(@raylib.KeyRightShift) ||
    @raylib.is_key_down(@raylib.KeyE)

  game.input_jump_press = key_jump_press ||
    (touch_jump && not(game.touch_jump_prev))
  game.input_jump_hold = key_jump_hold || touch_jump
  game.input_climb_hold = key_climb_hold || touch_climb
  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyR) ||
    (touch_restart && not(game.touch_restart_prev))

  game.touch_jump_prev = touch_jump
  game.touch_restart_prev = touch_restart
}

///|
fn update_stage_clear_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_frame_input(game)
  update_touch_mode(game, touch_count)

  let next_rect = panel_next_rect()
  let restart_rect = panel_restart_rect()

  let touch_next = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    next_rect.0,
    next_rect.1,
    next_rect.2,
    next_rect.3,
  )
  let touch_restart = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    restart_rect.0,
    restart_rect.1,
    restart_rect.2,
    restart_rect.3,
  )

  let key_next = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
  let key_restart = @raylib.is_key_pressed(@raylib.KeyR)

  let mouse_next = mouse_click_on_rect(
    mx,
    my,
    next_rect.0,
    next_rect.1,
    next_rect.2,
    next_rect.3,
  )
  let mouse_restart = mouse_click_on_rect(
    mx,
    my,
    restart_rect.0,
    restart_rect.1,
    restart_rect.2,
    restart_rect.3,
  )

  game.input_next_press = key_next ||
    mouse_next ||
    (touch_next && not(game.touch_next_prev))
  game.input_restart_press = key_restart ||
    mouse_restart ||
    (touch_restart && not(game.touch_restart_prev))

  game.touch_next_prev = touch_next
  game.touch_restart_prev = touch_restart
}

///|
fn update_game_over_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_frame_input(game)
  update_touch_mode(game, touch_count)

  let retry_rect = panel_next_rect()
  let reset_rect = panel_restart_rect()

  let touch_retry = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    retry_rect.0,
    retry_rect.1,
    retry_rect.2,
    retry_rect.3,
  )
  let touch_reset = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    reset_rect.0,
    reset_rect.1,
    reset_rect.2,
    reset_rect.3,
  )

  let key_retry = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  let key_reset = @raylib.is_key_pressed(@raylib.KeyR)

  let mouse_retry = mouse_click_on_rect(
    mx,
    my,
    retry_rect.0,
    retry_rect.1,
    retry_rect.2,
    retry_rect.3,
  )
  let mouse_reset = mouse_click_on_rect(
    mx,
    my,
    reset_rect.0,
    reset_rect.1,
    reset_rect.2,
    reset_rect.3,
  )

  game.input_next_press = key_retry ||
    mouse_retry ||
    (touch_retry && not(game.touch_next_prev))
  game.input_restart_press = key_reset ||
    mouse_reset ||
    (touch_reset && not(game.touch_restart_prev))

  game.touch_next_prev = touch_retry
  game.touch_restart_prev = touch_reset
}

///|
fn update_victory_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_frame_input(game)
  update_touch_mode(game, touch_count)

  let next_rect = panel_next_rect()
  let restart_rect = panel_restart_rect()

  let touch_next = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    next_rect.0,
    next_rect.1,
    next_rect.2,
    next_rect.3,
  )
  let touch_restart = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    restart_rect.0,
    restart_rect.1,
    restart_rect.2,
    restart_rect.3,
  )

  let key_next = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  let key_restart = @raylib.is_key_pressed(@raylib.KeyR)

  let mouse_next = mouse_click_on_rect(
    mx,
    my,
    next_rect.0,
    next_rect.1,
    next_rect.2,
    next_rect.3,
  )
  let mouse_restart = mouse_click_on_rect(
    mx,
    my,
    restart_rect.0,
    restart_rect.1,
    restart_rect.2,
    restart_rect.3,
  )

  game.input_next_press = key_next ||
    mouse_next ||
    (touch_next && not(game.touch_next_prev))
  game.input_restart_press = key_restart ||
    mouse_restart ||
    (touch_restart && not(game.touch_restart_prev))

  game.touch_next_prev = touch_next
  game.touch_restart_prev = touch_restart
}
