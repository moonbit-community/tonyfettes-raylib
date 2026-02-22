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
fn retry_hover(mx : Float, my : Float, hold : Bool, touch_count : Int) -> Bool {
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
    retry_hover(mx, my, hold, touch_count)

  if key_retry || click_retry || tap_retry {
    start_run(game)
    game.touch_cd = 0.16
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
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    go_title(game)
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_run(game)
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyH) {
    cycle_hint(game)
  }

  let mut dx : Int = 0
  let mut dy : Int = 0

  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    dx = dx - 1
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
    dx = dx + 1
  }
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    dy = dy - 1
  }
  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    dy = dy + 1
  }

  let b_l = btn_left()
  let b_r = btn_right()
  let b_u = btn_up()
  let b_d = btn_down()

  if pointer_on_rect(mx, my, hold, touch_count, b_l.0, b_l.1, b_l.2, b_l.3) {
    dx = dx - 1
  }
  if pointer_on_rect(mx, my, hold, touch_count, b_r.0, b_r.1, b_r.2, b_r.3) {
    dx = dx + 1
  }
  if pointer_on_rect(mx, my, hold, touch_count, b_u.0, b_u.1, b_u.2, b_u.3) {
    dy = dy - 1
  }
  if pointer_on_rect(mx, my, hold, touch_count, b_d.0, b_d.1, b_d.2, b_d.3) {
    dy = dy + 1
  }

  dx = clampi(dx, -1, 1)
  dy = clampi(dy, -1, 1)

  if dx != 0 && dy != 0 {
    if @raylib.is_key_down(@raylib.KeyA) ||
      @raylib.is_key_down(@raylib.KeyD) ||
      @raylib.is_key_down(@raylib.KeyLeft) ||
      @raylib.is_key_down(@raylib.KeyRight) {
      dy = 0
    } else {
      dx = 0
    }
  }

  game.req_dx = dx
  game.req_dy = dy

  let a = btn_action()
  let action_key_down : Bool = @raylib.is_key_down(@raylib.KeySpace) ||
    @raylib.is_key_down(@raylib.KeyE) ||
    @raylib.is_key_down(@raylib.KeyJ)
  let action_touch_down : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    a.0,
    a.1,
    a.2,
    a.3,
  )

  let down_now : Bool = action_key_down || action_touch_down
  game.action_pressed = down_now && not(game.action_down)
  game.action_down = down_now

  let h = btn_hint()
  let r = btn_restart()
  let m = btn_menu()

  if game.touch_cd <= 0.0 &&
    pointer_on_rect(mx, my, hold, touch_count, h.0, h.1, h.2, h.3) {
    cycle_hint(game)
    game.touch_cd = 0.16
  }

  if game.touch_cd <= 0.0 &&
    pointer_on_rect(mx, my, hold, touch_count, r.0, r.1, r.2, r.3) {
    start_run(game)
    game.touch_cd = 0.16
    return
  }

  if game.touch_cd <= 0.0 &&
    pointer_on_rect(mx, my, hold, touch_count, m.0, m.1, m.2, m.3) {
    go_title(game)
    game.touch_cd = 0.16
  }
}
