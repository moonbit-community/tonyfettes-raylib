///|
fn point_in_rect(
  x : Float,
  y : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)

  x >= x0 && x <= x1 && y >= y0 && y <= y1
}

///|
fn pointer_on_rect(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
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
fn title_hover(mx : Float, my : Float, hold : Bool, touch_count : Int) -> Bool {
  let b = start_button_rect()
  pointer_on_rect(mx, my, hold, touch_count, b.0, b.1, b.2, b.3)
}

///|
fn result_hover(mx : Float, my : Float, hold : Bool, touch_count : Int) -> Bool {
  let b = retry_button_rect()
  pointer_on_rect(mx, my, hold, touch_count, b.0, b.1, b.2, b.3)
}

///|
fn update_title_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  let key_start : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
  let click_start : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )
  let tap_start : Bool = game.touch_cd <= 0.0 &&
    title_hover(mx, my, hold, touch_count)

  if key_start || click_start || tap_start {
    start_run(game)
    game.touch_cd = 0.16
  }
}

///|
fn update_result_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  let key_retry : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyR)
  let click_retry : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )
  let tap_retry : Bool = game.touch_cd <= 0.0 &&
    result_hover(mx, my, hold, touch_count)

  if key_retry || click_retry || tap_retry {
    start_run(game)
    game.touch_cd = 0.16
  }
}

///|
fn update_play_input(
  game : Game,
  _dt : Float,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = state_title
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_run(game)
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyH) {
    ignore(use_hint(game))
  }

  let mut move_x : Float = 0.0
  let mut move_y : Float = 0.0

  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    move_x = move_x - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
    move_x = move_x + 1.0
  }
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    move_y = move_y - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    move_y = move_y + 1.0
  }

  let left = btn_left()
  let right = btn_right()
  let up = btn_up()
  let down = btn_down()
  let boost = btn_boost()
  let restart = btn_restart()
  let hint = btn_hint()

  let left_touch : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    left.0,
    left.1,
    left.2,
    left.3,
  )
  let right_touch : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    right.0,
    right.1,
    right.2,
    right.3,
  )
  let up_touch : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    up.0,
    up.1,
    up.2,
    up.3,
  )
  let down_touch : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    down.0,
    down.1,
    down.2,
    down.3,
  )

  if left_touch {
    move_x = move_x - 1.0
  }
  if right_touch {
    move_x = move_x + 1.0
  }
  if up_touch {
    move_y = move_y - 1.0
  }
  if down_touch {
    move_y = move_y + 1.0
  }

  game.move_x = clampf(move_x, -1.0, 1.0)
  game.move_y = clampf(move_y, -1.0, 1.0)

  let boost_key : Bool = @raylib.is_key_down(@raylib.KeyLeftShift) ||
    @raylib.is_key_down(@raylib.KeyRightShift) ||
    @raylib.is_key_down(@raylib.KeyJ)
  let boost_touch : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    boost.0,
    boost.1,
    boost.2,
    boost.3,
  )

  game.boost_on = (boost_key || boost_touch) && game.fuel > 0.6

  if game.touch_cd <= 0.0 &&
    pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      restart.0,
      restart.1,
      restart.2,
      restart.3,
    ) {
    start_run(game)
    game.touch_cd = 0.18
    return
  }

  if game.touch_cd <= 0.0 &&
    pointer_on_rect(mx, my, hold, touch_count, hint.0, hint.1, hint.2, hint.3) {
    ignore(use_hint(game))
    game.touch_cd = 0.18
  }
}
