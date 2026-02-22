///|
fn pointer_on_rect(
  x : Float,
  y : Float,
  hold : Bool,
  touch_count : Int,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  if not(hold) && touch_count <= 0 {
    return false
  }

  let fx0 : Float = Float::from_int(rx)
  let fy0 : Float = Float::from_int(ry)
  let fx1 : Float = Float::from_int(rx + rw)
  let fy1 : Float = Float::from_int(ry + rh)

  x >= fx0 && x <= fx1 && y >= fy0 && y <= fy1
}

///|
fn title_start_hover(
  mouse_x : Float,
  mouse_y : Float,
  hold : Bool,
  touch_count : Int,
) -> Bool {
  let (x, y, w, h) = title_start_button()
  pointer_on_rect(mouse_x, mouse_y, hold, touch_count, x, y, w, h)
}

///|
fn result_retry_hover(
  mouse_x : Float,
  mouse_y : Float,
  hold : Bool,
  touch_count : Int,
) -> Bool {
  let (x, y, w, h) = retry_button()
  pointer_on_rect(mouse_x, mouse_y, hold, touch_count, x, y, w, h)
}

///|
fn update_title_input(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  let key_start : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let click_start : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )

  let tap_start : Bool = game.touch_cd <= 0.0 &&
    title_start_hover(mouse_x, mouse_y, mouse_hold, touch_count)

  if key_start || click_start || tap_start {
    start_match(game)
    game.touch_cd = 0.18
  }
}

///|
fn update_result_input(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  let key_retry : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyR)

  let click_retry : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )

  let tap_retry : Bool = game.touch_cd <= 0.0 &&
    result_retry_hover(mouse_x, mouse_y, mouse_hold, touch_count)

  if key_retry || click_retry || tap_retry {
    start_match(game)
    game.touch_cd = 0.18
  }
}

///|
fn update_play_input(
  game : Game,
  dt : Float,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_match(game)
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = state_title
    game.can_throw = false
    game.charging = false
    set_message(game, "", 0.0)
    return
  }

  if not(game.can_throw) {
    return
  }

  let mut aim_delta : Float = 0.0
  let mut spin_delta : Float = 0.0

  if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
    aim_delta = aim_delta - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyRight) || @raylib.is_key_down(@raylib.KeyD) {
    aim_delta = aim_delta + 1.0
  }

  if @raylib.is_key_down(@raylib.KeyQ) {
    spin_delta = spin_delta - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyE) {
    spin_delta = spin_delta + 1.0
  }

  let (alx, aly, alw, alh) = touch_aim_left_rect()
  let (arx, ary, arw, arh) = touch_aim_right_rect()
  let (slx, sly, slw, slh) = touch_spin_left_rect()
  let (srx, sry, srw, srh) = touch_spin_right_rect()
  let (px, py, pw, ph) = touch_power_rect()

  let touch_left : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, alx, aly, alw, alh,
  )
  let touch_right : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, arx, ary, arw, arh,
  )
  let touch_spin_left : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, slx, sly, slw, slh,
  )
  let touch_spin_right : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, srx, sry, srw, srh,
  )
  let touch_power : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_hold, touch_count, px, py, pw, ph,
  )

  if touch_left {
    aim_delta = aim_delta - 1.0
  }
  if touch_right {
    aim_delta = aim_delta + 1.0
  }
  if touch_spin_left {
    spin_delta = spin_delta - 1.0
  }
  if touch_spin_right {
    spin_delta = spin_delta + 1.0
  }

  game.aim = clampf(game.aim + aim_delta * dt * 58.0, aim_min, aim_max)
  game.spin = clampf(game.spin + spin_delta * dt * 1.28, spin_min, spin_max)

  let hold_key : Bool = @raylib.is_key_down(@raylib.KeySpace) ||
    @raylib.is_key_down(@raylib.KeyEnter) ||
    @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)

  let hold_power : Bool = hold_key || touch_power

  if hold_power {
    if not(game.charging) {
      game.charging = true
      set_message(game, "Charging power... release to throw", 0.5)
    }

    game.power = game.power + dt * 1.4 * game.power_dir
    if game.power >= 1.0 {
      game.power = 1.0
      game.power_dir = -1.0
    } else if game.power <= 0.14 {
      game.power = 0.14
      game.power_dir = 1.0
    }
  } else if game.charging {
    ignore(throw_ball(game))
  }
}
