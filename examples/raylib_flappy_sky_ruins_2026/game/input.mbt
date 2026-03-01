///|
fn title_hover(game : @types.Game) -> Bool {
  let r = @types.start_button_rect()
  @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    r.0,
    r.1,
    r.2,
    r.3,
  )
}

///|
fn result_hover(game : @types.Game) -> Bool {
  let r = @types.retry_button_rect()
  @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    r.0,
    r.1,
    r.2,
    r.3,
  )
}

///|
pub fn update_title_input(game : @types.Game) -> Unit {
  let key_start : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
  let click_start : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )
  let tap_start : Bool = game.touch_cd <= 0.0 && title_hover(game)

  if key_start || click_start || tap_start {
    start_match(game)
    game.touch_cd = 0.15
  }
}

///|
pub fn update_result_input(game : @types.Game) -> Unit {
  let key_retry : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyR)
  let click_retry : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )
  let tap_retry : Bool = game.touch_cd <= 0.0 && result_hover(game)

  if key_retry || click_retry || tap_retry {
    start_match(game)
    game.touch_cd = 0.15
  }
}

///|
pub fn update_play_input(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = Title
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

  let flap_rect = @types.btn_flap_rect()
  let boost_rect = @types.btn_boost_rect()
  let restart_rect = @types.btn_restart_rect()
  let hint_rect = @types.btn_hint_rect()

  let flap_touch : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    flap_rect.0,
    flap_rect.1,
    flap_rect.2,
    flap_rect.3,
  )
  if flap_touch {
    flap(game)
  }

  let boost_touch : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    boost_rect.0,
    boost_rect.1,
    boost_rect.2,
    boost_rect.3,
  )
  game.boost_on = (game.boost_on || boost_touch) && game.boost_meter > 0.08

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      restart_rect.0,
      restart_rect.1,
      restart_rect.2,
      restart_rect.3,
    ) {
    start_match(game)
    game.touch_cd = 0.16
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      hint_rect.0,
      hint_rect.1,
      hint_rect.2,
      hint_rect.3,
    ) {
    ignore(use_hint(game))
    game.touch_cd = 0.16
  }
}
