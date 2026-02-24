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
  game.input_turn = 0.0
  game.input_ring_move = 0
  game.input_fire_hold = false
  game.input_beam_press = false
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
fn restart_rect() -> (Float, Float, Float, Float) {
  (
    Float::from_int(screen_w) - Float::from_int(144),
    Float::from_int(14),
    Float::from_int(130),
    Float::from_int(44),
  )
}

///|
fn beam_rect() -> (Float, Float, Float, Float) {
  let fire = button_fire_rect()
  (fire.0, fire.1 - Float::from_int(66), fire.2, Float::from_int(56))
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

  let key_start = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  let mouse_start = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let touch_start = touch_count > 0 && hold && not(game.touch_restart_prev)

  game.input_fire_hold = key_start || mouse_start || touch_start
  game.input_restart_press = game.input_fire_hold

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
  clear_frame_input(game)
  update_pointer(game, mx, my, touch_count)

  game.touch_mode = touch_count > 0
  game.touch_count = touch_count

  let left_btn = button_left_rect()
  let right_btn = button_right_rect()
  let in_btn = button_in_rect()
  let out_btn = button_out_rect()
  let fire_btn = button_fire_rect()
  let beam_btn = beam_rect()
  let restart_btn = restart_rect()

  let t_left = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    left_btn.0,
    left_btn.1,
    left_btn.2,
    left_btn.3,
  )
  let t_right = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    right_btn.0,
    right_btn.1,
    right_btn.2,
    right_btn.3,
  )
  let t_in = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    in_btn.0,
    in_btn.1,
    in_btn.2,
    in_btn.3,
  )
  let t_out = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    out_btn.0,
    out_btn.1,
    out_btn.2,
    out_btn.3,
  )
  let t_fire = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    fire_btn.0,
    fire_btn.1,
    fire_btn.2,
    fire_btn.3,
  )
  let t_beam = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    beam_btn.0,
    beam_btn.1,
    beam_btn.2,
    beam_btn.3,
  )
  let t_restart = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    restart_btn.0,
    restart_btn.1,
    restart_btn.2,
    restart_btn.3,
  )

  let key_left = @raylib.is_key_down(@raylib.KeyA) ||
    @raylib.is_key_down(@raylib.KeyLeft)
  let key_right = @raylib.is_key_down(@raylib.KeyD) ||
    @raylib.is_key_down(@raylib.KeyRight)

  if key_left || t_left {
    game.input_turn = game.input_turn - 1.0
  }
  if key_right || t_right {
    game.input_turn = game.input_turn + 1.0
  }

  let key_in_press = @raylib.is_key_pressed(@raylib.KeyW) ||
    @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyQ)
  let key_out_press = @raylib.is_key_pressed(@raylib.KeyS) ||
    @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyE)

  if key_in_press || (t_in && not(game.touch_in_prev)) {
    game.input_ring_move = -1
  }
  if key_out_press || (t_out && not(game.touch_out_prev)) {
    game.input_ring_move = 1
  }

  let key_fire = @raylib.is_key_down(@raylib.KeySpace) ||
    @raylib.is_key_down(@raylib.KeyJ) ||
    @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
  game.input_fire_hold = key_fire || t_fire

  let key_beam = @raylib.is_key_pressed(@raylib.KeyK) ||
    @raylib.is_key_pressed(@raylib.KeyL) ||
    @raylib.is_key_pressed(@raylib.KeyLeftShift)
  game.input_beam_press = key_beam || (t_beam && not(game.touch_beam_prev))

  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyR) ||
    (t_restart && not(game.touch_restart_prev))
  game.input_pause_press = @raylib.is_key_pressed(@raylib.KeyEscape)

  game.touch_in_prev = t_in
  game.touch_out_prev = t_out
  game.touch_beam_prev = t_beam
  game.touch_restart_prev = t_restart
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
  let touch_restart = touch_count > 0 && hold && not(game.touch_restart_prev)

  game.input_restart_press = key_restart || touch_restart
  game.input_fire_hold = key_start
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
  clear_frame_input(game)
  update_pointer(game, mx, my, touch_count)

  let key_retry = @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
  let click_retry = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let touch_retry = touch_count > 0 && hold && not(game.touch_restart_prev)

  game.input_restart_press = key_retry || click_retry || touch_retry
  game.input_fire_hold = game.input_restart_press
  game.touch_restart_prev = touch_count > 0 && hold
}
