///|
fn clear_frame_input(game : @types.Game) -> Unit {
  game.input_x = 0.0
  game.input_y = 0.0
  game.input_fire_hold = false
  game.input_boost_press = false
  game.input_hack_press = false
  game.input_restart_press = false
}

///|
fn update_title_input(game : @types.Game) -> Unit {
  clear_frame_input(game)

  game.touch_mode = game.touch_count > 0

  let start_btn = @types.title_start_rect()
  let hover = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
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
fn update_play_input(game : @types.Game) -> Unit {
  clear_frame_input(game)

  game.touch_mode = game.touch_count > 0

  let left_btn = @types.btn_left_rect()
  let right_btn = @types.btn_right_rect()
  let up_btn = @types.btn_up_rect()
  let down_btn = @types.btn_down_rect()
  let fire_btn = @types.btn_fire_rect()
  let boost_btn = @types.btn_boost_rect()
  let hack_btn = @types.btn_hack_rect()

  let t_left = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    left_btn.0,
    left_btn.1,
    left_btn.2,
    left_btn.3,
  )
  let t_right = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    right_btn.0,
    right_btn.1,
    right_btn.2,
    right_btn.3,
  )
  let t_up = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    up_btn.0,
    up_btn.1,
    up_btn.2,
    up_btn.3,
  )
  let t_down = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    down_btn.0,
    down_btn.1,
    down_btn.2,
    down_btn.3,
  )
  let t_fire = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    fire_btn.0,
    fire_btn.1,
    fire_btn.2,
    fire_btn.3,
  )
  let t_boost = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    boost_btn.0,
    boost_btn.1,
    boost_btn.2,
    boost_btn.3,
  )
  let t_hack = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    hack_btn.0,
    hack_btn.1,
    hack_btn.2,
    hack_btn.3,
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

  let key_boost = @raylib.is_key_pressed(@raylib.KeyLeftShift) ||
    @raylib.is_key_pressed(@raylib.KeyRightShift) ||
    @raylib.is_key_pressed(@raylib.KeyK)
  let key_hack = @raylib.is_key_pressed(@raylib.KeyL) ||
    @raylib.is_key_pressed(@raylib.KeyE)

  game.input_boost_press = key_boost || (t_boost && not(game.touch_boost_prev))
  game.input_hack_press = key_hack || (t_hack && not(game.touch_hack_prev))

  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)

  game.touch_boost_prev = t_boost
  game.touch_hack_prev = t_hack
}

///|
fn update_result_input(game : @types.Game) -> Unit {
  clear_frame_input(game)

  game.touch_mode = game.touch_count > 0

  let retry_btn = @types.result_retry_rect()
  let hover = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    retry_btn.0,
    retry_btn.1,
    retry_btn.2,
    retry_btn.3,
  )

  let key_retry = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeyR)
  let mouse_retry = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let touch_retry = hover && not(game.touch_restart_prev)

  game.input_restart_press = key_retry || mouse_retry || touch_retry
  game.touch_restart_prev = hover
}
