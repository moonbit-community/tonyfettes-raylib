///|
fn point_in_rect(
  x : Float,
  y : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  rect_contains(x, y, rx, ry, rw, rh)
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
  game.input_jump_press = false
  game.input_jump_hold = false
  game.input_slide_hold = false
  game.input_grapple_press = false
  game.input_pause_press = false
  game.input_restart_press = false
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
  clear_frame_input(game)
  update_pointer(game, mx, my, touch_count)

  game.touch_mode = touch_count > 0
  game.touch_count = touch_count

  let key_start = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyJ)

  let mouse_start = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let touch_active = touch_count > 0 && hold
  let touch_start = touch_active && not(game.touch_restart_prev)

  game.touch_restart_prev = touch_active

  if key_start || mouse_start || touch_start {
    start_run(game)
  }
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
  update_pointer(game, mx, my, touch_count)

  game.touch_mode = touch_count > 0
  game.touch_count = touch_count

  let jump_rect = button_jump_rect()
  let slide_rect = button_slide_rect()
  let grapple_rect = button_grapple_rect()
  let restart_rect : (Float, Float, Float, Float) = (
    Float::from_int(screen_w) - Float::from_int(136),
    Float::from_int(18),
    Float::from_int(118),
    Float::from_int(46),
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
  let touch_slide = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    slide_rect.0,
    slide_rect.1,
    slide_rect.2,
    slide_rect.3,
  )
  let touch_grapple = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    grapple_rect.0,
    grapple_rect.1,
    grapple_rect.2,
    grapple_rect.3,
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

  let key_jump_hold = @raylib.is_key_down(@raylib.KeySpace) ||
    @raylib.is_key_down(@raylib.KeyW) ||
    @raylib.is_key_down(@raylib.KeyUp)
  let key_jump_press = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyW) ||
    @raylib.is_key_pressed(@raylib.KeyUp)

  let key_slide_hold = @raylib.is_key_down(@raylib.KeyS) ||
    @raylib.is_key_down(@raylib.KeyDown) ||
    @raylib.is_key_down(@raylib.KeyLeftShift)

  let key_grapple_press = @raylib.is_key_pressed(@raylib.KeyJ) ||
    @raylib.is_key_pressed(@raylib.KeyK) ||
    @raylib.is_key_pressed(@raylib.KeyL)

  let key_restart_press = @raylib.is_key_pressed(@raylib.KeyR)

  game.input_jump_hold = key_jump_hold || touch_jump
  game.input_slide_hold = key_slide_hold || touch_slide
  game.input_jump_press = key_jump_press ||
    (touch_jump && not(game.touch_jump_prev))
  game.input_grapple_press = key_grapple_press ||
    (touch_grapple && not(game.touch_grapple_prev))
  game.input_restart_press = key_restart_press ||
    (touch_restart && not(game.touch_restart_prev))
  game.input_pause_press = @raylib.is_key_pressed(@raylib.KeyEscape)

  game.touch_jump_prev = touch_jump
  game.touch_grapple_prev = touch_grapple
  game.touch_restart_prev = touch_restart

  if game.input_pause_press {
    init_title_scene(game)
  }
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
  update_pointer(game, mx, my, touch_count)

  let key_restart = @raylib.is_key_pressed(@raylib.KeyR)
  let key_start = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)

  let touch_active = touch_count > 0 && hold
  game.input_restart_press = key_restart ||
    (touch_active && not(game.touch_restart_prev))
  game.input_jump_press = key_start

  game.touch_restart_prev = touch_active
}

///|
fn update_result_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_frame_input(game)
  update_pointer(game, mx, my, touch_count)

  let key_retry = @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let touch_retry = touch_count > 0 && hold && not(game.touch_restart_prev)
  let click_retry = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)

  game.input_restart_press = key_retry || click_retry || touch_retry
  game.input_jump_press = key_retry

  game.touch_restart_prev = touch_count > 0 && hold
}
