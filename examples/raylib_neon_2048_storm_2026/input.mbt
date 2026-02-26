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
  let (x, y, w, h) = title_start_button()
  pointer_on_rect(mx, my, hold, touch_count, x, y, w, h)
}

///|
fn result_hover(mx : Float, my : Float, hold : Bool, touch_count : Int) -> Bool {
  let (x, y, w, h) = retry_button()
  pointer_on_rect(mx, my, hold, touch_count, x, y, w, h)
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
    start_match(game)
    game.touch_cd = 0.16
  }
}

///|
fn btn_pressed(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rect : (Int, Int, Int, Int),
) -> Bool {
  if game.touch_cd > 0.0 {
    return false
  }

  pointer_on_rect(mx, my, hold, touch_count, rect.0, rect.1, rect.2, rect.3)
}

///|
fn handle_buttons(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Bool {
  if btn_pressed(game, mx, my, hold, touch_count, btn_left()) {
    ignore(try_move(game, dir_left))
    game.touch_cd = 0.14
    return true
  }
  if btn_pressed(game, mx, my, hold, touch_count, btn_right()) {
    ignore(try_move(game, dir_right))
    game.touch_cd = 0.14
    return true
  }
  if btn_pressed(game, mx, my, hold, touch_count, btn_up()) {
    ignore(try_move(game, dir_up))
    game.touch_cd = 0.14
    return true
  }
  if btn_pressed(game, mx, my, hold, touch_count, btn_down()) {
    ignore(try_move(game, dir_down))
    game.touch_cd = 0.14
    return true
  }
  if btn_pressed(game, mx, my, hold, touch_count, btn_zap()) {
    ignore(use_zap(game, game.cursor_x, game.cursor_y))
    game.touch_cd = 0.16
    return true
  }
  if btn_pressed(game, mx, my, hold, touch_count, btn_undo()) {
    ignore(restore_undo(game))
    game.touch_cd = 0.16
    return true
  }
  if btn_pressed(game, mx, my, hold, touch_count, btn_restart()) {
    start_match(game)
    game.touch_cd = 0.16
    return true
  }

  false
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

  let hover = pointer_cell(game, mx, my)
  if hover.0 {
    game.cursor_x = hover.1
    game.cursor_y = hover.2
  }

  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    ignore(try_move(game, dir_left))
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    ignore(try_move(game, dir_right))
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    ignore(try_move(game, dir_up))
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    ignore(try_move(game, dir_down))
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

  if handle_buttons(game, mx, my, hold, touch_count) {
    return
  }
}
