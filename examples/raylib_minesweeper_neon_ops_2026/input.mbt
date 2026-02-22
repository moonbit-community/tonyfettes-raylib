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
  let (x, y, w, h) = result_retry_button()
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
fn board_hover_cell(game : Game, mx : Float, my : Float) -> (Bool, Int, Int) {
  click_to_cell(game, mx, my)
}

///|
fn do_action_on_cell(game : Game, x : Int, y : Int) -> Bool {
  if game.mode == mode_reveal {
    reveal_cell(game, x, y)
  } else {
    toggle_flag(game, x, y)
  }
}

///|
fn move_cursor(game : Game, dx : Int, dy : Int) -> Unit {
  game.cursor_x = clampi(game.cursor_x + dx, 0, board_w - 1)
  game.cursor_y = clampi(game.cursor_y + dy, 0, board_h - 1)
}

///|
fn handle_keyboard(game : Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    move_cursor(game, -1, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    move_cursor(game, 1, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    move_cursor(game, 0, -1)
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    move_cursor(game, 0, 1)
  }

  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.mode = if game.mode == mode_reveal { mode_flag } else { mode_reveal }
    set_msg(
      game,
      if game.mode == mode_reveal {
        "Reveal mode"
      } else {
        "Flag mode"
      },
      0.8,
    )
  }

  if @raylib.is_key_pressed(@raylib.KeyF) {
    ignore(toggle_flag(game, game.cursor_x, game.cursor_y))
  }

  if @raylib.is_key_pressed(@raylib.KeyH) {
    ignore(use_hint(game))
  }

  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    ignore(do_action_on_cell(game, game.cursor_x, game.cursor_y))
  }
}

///|
fn handle_touch_buttons(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Bool {
  let (mx0, my0, mw0, mh0) = touch_mode_button()
  let (hx0, hy0, hw0, hh0) = touch_hint_button()
  let (rx0, ry0, rw0, rh0) = touch_reset_button()
  let (ax0, ay0, aw0, ah0) = touch_reveal_button()

  if game.touch_cd <= 0.0 &&
    pointer_on_rect(mx, my, hold, touch_count, mx0, my0, mw0, mh0) {
    game.mode = if game.mode == mode_reveal { mode_flag } else { mode_reveal }
    set_msg(
      game,
      if game.mode == mode_reveal {
        "Reveal mode"
      } else {
        "Flag mode"
      },
      0.8,
    )
    game.touch_cd = 0.18
    return true
  }

  if game.touch_cd <= 0.0 &&
    pointer_on_rect(mx, my, hold, touch_count, hx0, hy0, hw0, hh0) {
    ignore(use_hint(game))
    game.touch_cd = 0.18
    return true
  }

  if game.touch_cd <= 0.0 &&
    pointer_on_rect(mx, my, hold, touch_count, rx0, ry0, rw0, rh0) {
    start_match(game)
    game.touch_cd = 0.18
    return true
  }

  if game.touch_cd <= 0.0 &&
    pointer_on_rect(mx, my, hold, touch_count, ax0, ay0, aw0, ah0) {
    ignore(do_action_on_cell(game, game.cursor_x, game.cursor_y))
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

  handle_keyboard(game)

  let hover = board_hover_cell(game, mx, my)
  if hover.0 {
    game.cursor_x = hover.1
    game.cursor_y = hover.2
  }

  if handle_touch_buttons(game, mx, my, hold, touch_count) {
    return
  }

  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if hover.0 {
      ignore(do_action_on_cell(game, hover.1, hover.2))
    }
  }

  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    if hover.0 {
      ignore(toggle_flag(game, hover.1, hover.2))
    }
  }
}
