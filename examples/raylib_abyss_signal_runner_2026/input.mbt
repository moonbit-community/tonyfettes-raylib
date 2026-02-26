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
  game.input_y = 0.0
  game.input_dash_press = false
  game.input_sonar_press = false
  game.input_restart_press = false
}

///|
fn title_start_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(410)
  let h = Float::from_int(88)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.62,
    w,
    h,
  )
}

///|
fn restart_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(180)
  let h = Float::from_int(56)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.72,
    w,
    h,
  )
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

  game.touch_mode = touch_count > 0

  let start_btn = title_start_rect()
  let start_hover = pointer_on_rect(
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
  let touch_start = start_hover && not(game.touch_restart_prev)

  game.input_restart_press = key_start || mouse_start || touch_start
  game.touch_restart_prev = start_hover
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

  game.touch_mode = touch_count > 0

  let left_btn = btn_left_rect()
  let right_btn = btn_right_rect()
  let up_btn = btn_up_rect()
  let down_btn = btn_down_rect()
  let dash_btn = btn_dash_rect()
  let sonar_btn = btn_sonar_rect()

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
  let t_up = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    up_btn.0,
    up_btn.1,
    up_btn.2,
    up_btn.3,
  )
  let t_down = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    down_btn.0,
    down_btn.1,
    down_btn.2,
    down_btn.3,
  )
  let t_dash = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    dash_btn.0,
    dash_btn.1,
    dash_btn.2,
    dash_btn.3,
  )
  let t_sonar = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    sonar_btn.0,
    sonar_btn.1,
    sonar_btn.2,
    sonar_btn.3,
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
    let inv : Float = Float::from_int(1) / sqrtf(len2)
    ix = ix * inv
    iy = iy * inv
  }

  game.input_x = ix
  game.input_y = iy

  let key_dash = @raylib.is_key_pressed(@raylib.KeyLeftShift) ||
    @raylib.is_key_pressed(@raylib.KeyRightShift) ||
    @raylib.is_key_pressed(@raylib.KeyK)
  let key_sonar = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyJ) ||
    @raylib.is_key_pressed(@raylib.KeyL)

  game.input_dash_press = key_dash || (t_dash && not(game.touch_dash_prev))
  game.input_sonar_press = key_sonar || (t_sonar && not(game.touch_sonar_prev))

  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  game.touch_dash_prev = t_dash
  game.touch_sonar_prev = t_sonar
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

  game.touch_mode = touch_count > 0

  let retry_btn = restart_rect()
  let retry_hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    retry_btn.0,
    retry_btn.1,
    retry_btn.2,
    retry_btn.3,
  )

  let key_retry = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeyR)
  let mouse_retry = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let touch_retry = retry_hover && not(game.touch_restart_prev)

  game.input_restart_press = key_retry || mouse_retry || touch_retry
  game.touch_restart_prev = retry_hover
}
