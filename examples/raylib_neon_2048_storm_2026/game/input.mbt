///|
fn title_hover(game : @types.Game) -> Bool {
  let (x, y, w, h) = @types.title_start_button()
  @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    x,
    y,
    w,
    h,
  )
}

///|
fn result_hover(game : @types.Game) -> Bool {
  let (x, y, w, h) = @types.retry_button()
  @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    x,
    y,
    w,
    h,
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
    start_match(game)
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
    start_match(game)
    game.touch_cd = 0.16
  }
}

///|
fn btn_pressed(game : @types.Game, rect : (Int, Int, Int, Int)) -> Bool {
  if game.touch_cd > 0.0 {
    return false
  }

  @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    rect.0,
    rect.1,
    rect.2,
    rect.3,
  )
}

///|
fn handle_buttons(game : @types.Game) -> Bool {
  if btn_pressed(game, @types.btn_left()) {
    ignore(try_move(game, @types.DirLeft))
    game.touch_cd = 0.14
    return true
  }
  if btn_pressed(game, @types.btn_right()) {
    ignore(try_move(game, @types.DirRight))
    game.touch_cd = 0.14
    return true
  }
  if btn_pressed(game, @types.btn_up()) {
    ignore(try_move(game, @types.DirUp))
    game.touch_cd = 0.14
    return true
  }
  if btn_pressed(game, @types.btn_down()) {
    ignore(try_move(game, @types.DirDown))
    game.touch_cd = 0.14
    return true
  }
  if btn_pressed(game, @types.btn_zap()) {
    ignore(use_zap(game, game.cursor_x, game.cursor_y))
    game.touch_cd = 0.16
    return true
  }
  if btn_pressed(game, @types.btn_undo()) {
    ignore(restore_undo(game))
    game.touch_cd = 0.16
    return true
  }
  if btn_pressed(game, @types.btn_restart()) {
    start_match(game)
    game.touch_cd = 0.16
    return true
  }

  false
}

///|
fn update_play_input(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.Title
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_match(game)
    return
  }

  let hover = @types.pointer_cell(game, game.mouse_x, game.mouse_y)
  if hover.0 {
    game.cursor_x = hover.1
    game.cursor_y = hover.2
  }

  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    ignore(try_move(game, @types.DirLeft))
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    ignore(try_move(game, @types.DirRight))
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    ignore(try_move(game, @types.DirUp))
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    ignore(try_move(game, @types.DirDown))
  }

  if @raylib.is_key_pressed(@raylib.KeyZ) ||
    @raylib.is_key_pressed(@raylib.KeyU) {
    ignore(restore_undo(game))
  }

  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    ignore(use_zap(game, game.cursor_x, game.cursor_y))
  }

  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    if hover.0 {
      ignore(use_zap(game, hover.1, hover.2))
    }
  }

  if handle_buttons(game) {
    return
  }
}
