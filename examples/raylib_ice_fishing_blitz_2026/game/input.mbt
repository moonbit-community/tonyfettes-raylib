///|
fn title_hover(game : @types.Game) -> Bool {
  let b = @types.start_button_rect()
  @types.pointer_on_rect(
    game.mouse_x, game.mouse_y, game.mouse_hold, game.touch_count,
    b.0, b.1, b.2, b.3,
  )
}

///|
fn result_hover(game : @types.Game) -> Bool {
  let b = @types.retry_button_rect()
  @types.pointer_on_rect(
    game.mouse_x, game.mouse_y, game.mouse_hold, game.touch_count,
    b.0, b.1, b.2, b.3,
  )
}

///|
fn update_title_input(game : @types.Game) -> Unit {
  let key_start : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
  let click_start : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )
  let tap_start : Bool = game.touch_cd <= 0.0 && title_hover(game)

  if key_start || click_start || tap_start {
    start_run(game)
    game.touch_cd = 0.16
  }
}

///|
fn update_result_input(game : @types.Game) -> Unit {
  let key_retry : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyR)
  let click_retry : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )
  let tap_retry : Bool = game.touch_cd <= 0.0 && result_hover(game)

  if key_retry || click_retry || tap_retry {
    start_run(game)
    game.touch_cd = 0.16
  }
}

///|
fn update_play_input(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_title
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

  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let tc = game.touch_count

  let left = @types.btn_left()
  let right = @types.btn_right()
  let up = @types.btn_up()
  let down = @types.btn_down()
  let hook = @types.btn_hook()
  let boost = @types.btn_boost()
  let hint = @types.btn_hint()
  let restart = @types.btn_restart()
  let repair = @types.btn_repair()

  if @types.pointer_on_rect(mx, my, hold, tc, left.0, left.1, left.2, left.3) {
    move_x = move_x - 1.0
  }
  if @types.pointer_on_rect(
      mx, my, hold, tc, right.0, right.1, right.2, right.3,
    ) {
    move_x = move_x + 1.0
  }
  if @types.pointer_on_rect(mx, my, hold, tc, up.0, up.1, up.2, up.3) {
    move_y = move_y - 1.0
  }
  if @types.pointer_on_rect(mx, my, hold, tc, down.0, down.1, down.2, down.3) {
    move_y = move_y + 1.0
  }

  game.move_x = @types.clampf(move_x, -1.0, 1.0)
  game.move_y = @types.clampf(move_y, -1.0, 1.0)

  let boost_key : Bool = @raylib.is_key_down(@raylib.KeyLeftShift) ||
    @raylib.is_key_down(@raylib.KeyRightShift) ||
    @raylib.is_key_down(@raylib.KeyJ)

  let boost_touch : Bool = @types.pointer_on_rect(
    mx, my, hold, tc, boost.0, boost.1, boost.2, boost.3,
  )

  game.boost_on = boost_key || boost_touch

  if @raylib.is_key_pressed(@raylib.KeySpace) {
    ignore(try_toggle_grab(game))
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(mx, my, hold, tc, hook.0, hook.1, hook.2, hook.3) {
    ignore(try_toggle_grab(game))
    game.touch_cd = 0.16
  }

  if @raylib.is_key_pressed(@raylib.KeyE) {
    ignore(try_repair(game))
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(
      mx, my, hold, tc, repair.0, repair.1, repair.2, repair.3,
    ) {
    ignore(try_repair(game))
    game.touch_cd = 0.16
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(mx, my, hold, tc, hint.0, hint.1, hint.2, hint.3) {
    ignore(use_hint(game))
    game.touch_cd = 0.16
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(
      mx, my, hold, tc, restart.0, restart.1, restart.2, restart.3,
    ) {
    start_run(game)
    game.touch_cd = 0.16
  }
}
