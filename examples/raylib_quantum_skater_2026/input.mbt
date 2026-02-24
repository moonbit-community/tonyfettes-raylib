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
  game.input_move = 0
  game.input_jump_press = false
  game.input_jump_hold = false
  game.input_phase_press = false
  game.input_restart_press = false
  game.input_pause_press = false
}

///|
fn update_pointer(
  game : Game,
  mx : Float,
  my : Float,
  touch_count : Int,
) -> Unit {
  game.pointer_x = mx
  game.pointer_y = my
  if touch_count > 0 {
    let p = @raylib.get_touch_position(0)
    game.pointer_x = p.x
    game.pointer_y = p.y
  }
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
  update_pointer(game, mx, my, touch_count)
  game.touch_mode = touch_count > 0
  game.touch_count = touch_count

  let key_start = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  let click_start = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let touch_start = touch_count > 0 && hold && not(game.touch_restart_prev)

  game.input_jump_press = key_start || click_start || touch_start
  game.input_restart_press = game.input_jump_press
  game.touch_restart_prev = touch_count > 0 && hold
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
  update_pointer(game, mx, my, touch_count)
  game.touch_mode = touch_count > 0
  game.touch_count = touch_count

  let left_rect = button_left_rect()
  let right_rect = button_right_rect()
  let jump_rect = button_jump_rect()
  let phase_rect = button_phase_rect()
  let restart_rect : (Float, Float, Float, Float) = (
    Float::from_int(screen_w) - Float::from_int(142),
    Float::from_int(18),
    Float::from_int(126),
    Float::from_int(44),
  )

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
  let touch_phase = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    phase_rect.0,
    phase_rect.1,
    phase_rect.2,
    phase_rect.3,
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

  let key_left = @raylib.is_key_pressed(@raylib.KeyA) ||
    @raylib.is_key_pressed(@raylib.KeyLeft)
  let key_right = @raylib.is_key_pressed(@raylib.KeyD) ||
    @raylib.is_key_pressed(@raylib.KeyRight)

  let mut move_dir = 0
  if key_left || (touch_left && not(game.touch_left_prev)) {
    move_dir = -1
  }
  if key_right || (touch_right && not(game.touch_right_prev)) {
    move_dir = 1
  }

  game.input_move = move_dir

  let key_jump_press = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyW) ||
    @raylib.is_key_pressed(@raylib.KeyUp)
  let key_jump_hold = @raylib.is_key_down(@raylib.KeySpace) ||
    @raylib.is_key_down(@raylib.KeyW) ||
    @raylib.is_key_down(@raylib.KeyUp)

  let key_phase_press = @raylib.is_key_pressed(@raylib.KeyE) ||
    @raylib.is_key_pressed(@raylib.KeyK) ||
    @raylib.is_key_pressed(@raylib.KeyLeftShift)

  game.input_jump_press = key_jump_press ||
    (touch_jump && not(game.touch_jump_prev))
  game.input_jump_hold = key_jump_hold || touch_jump
  game.input_phase_press = key_phase_press ||
    (touch_phase && not(game.touch_phase_prev))
  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyR) ||
    (touch_restart && not(game.touch_restart_prev))
  game.input_pause_press = @raylib.is_key_pressed(@raylib.KeyEscape)

  game.touch_left_prev = touch_left
  game.touch_right_prev = touch_right
  game.touch_jump_prev = touch_jump
  game.touch_phase_prev = touch_phase
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
  clear_input(game)
  update_pointer(game, mx, my, touch_count)

  let key_restart = @raylib.is_key_pressed(@raylib.KeyR)
  let key_start = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  let touch_restart = touch_count > 0 && hold && not(game.touch_restart_prev)

  game.input_restart_press = key_restart || touch_restart
  game.input_jump_press = key_start
  game.touch_restart_prev = touch_count > 0 && hold
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
  update_pointer(game, mx, my, touch_count)

  let key_retry = @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
  let click_retry = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let touch_retry = touch_count > 0 && hold && not(game.touch_restart_prev)

  game.input_restart_press = key_retry || click_retry || touch_retry
  game.input_jump_press = game.input_restart_press
  game.touch_restart_prev = touch_count > 0 && hold
}
