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

  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)

  x >= x0 && x <= x1 && y >= y0 && y <= y1
}

///|
fn title_hover(mx : Float, my : Float, hold : Bool, touch_count : Int) -> Bool {
  let r = start_button_rect()
  pointer_on_rect(mx, my, hold, touch_count, r.0, r.1, r.2, r.3)
}

///|
fn result_hover(mx : Float, my : Float, hold : Bool, touch_count : Int) -> Bool {
  let r = retry_button_rect()
  pointer_on_rect(mx, my, hold, touch_count, r.0, r.1, r.2, r.3)
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
    start_match(game)
    game.touch_cd = 0.15
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
    start_match(game)
    game.touch_cd = 0.15
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
    start_match(game)
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyH) {
    ignore(use_hint(game))
  }

  let flap_key : Bool = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)

  if flap_key {
    flap(game)
  }

  let boost_down : Bool = @raylib.is_key_down(@raylib.KeyLeftShift) ||
    @raylib.is_key_down(@raylib.KeyRightShift) ||
    @raylib.is_key_down(@raylib.KeyJ)

  game.boost_on = boost_down && game.boost_meter > 0.08

  let flap_rect = btn_flap_rect()
  let boost_rect = btn_boost_rect()
  let restart_rect = btn_restart_rect()
  let hint_rect = btn_hint_rect()

  let flap_touch : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    flap_rect.0,
    flap_rect.1,
    flap_rect.2,
    flap_rect.3,
  )
  if flap_touch {
    flap(game)
  }

  let boost_touch : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    boost_rect.0,
    boost_rect.1,
    boost_rect.2,
    boost_rect.3,
  )
  game.boost_on = (game.boost_on || boost_touch) && game.boost_meter > 0.08

  if game.touch_cd <= 0.0 &&
    pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      restart_rect.0,
      restart_rect.1,
      restart_rect.2,
      restart_rect.3,
    ) {
    start_match(game)
    game.touch_cd = 0.16
  }

  if game.touch_cd <= 0.0 &&
    pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      hint_rect.0,
      hint_rect.1,
      hint_rect.2,
      hint_rect.3,
    ) {
    ignore(use_hint(game))
    game.touch_cd = 0.16
  }
}
