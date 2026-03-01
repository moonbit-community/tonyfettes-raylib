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
  let (x, y, w, h) = @types.result_retry_button()
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
fn board_hover_cell(
  game : @types.Game,
  mx : Float,
  my : Float,
) -> (Bool, Int, Int) {
  click_to_cell(game, mx, my)
}

///|
fn do_action_on_cell(game : @types.Game, x : Int, y : Int) -> Bool {
  match game.mode {
    @types.Reveal => reveal_cell(game, x, y)
    @types.Flag => toggle_flag(game, x, y)
  }
}

///|
fn move_cursor(game : @types.Game, dx : Int, dy : Int) -> Unit {
  game.cursor_x = @types.clampi(game.cursor_x + dx, 0, @types.board_w - 1)
  game.cursor_y = @types.clampi(game.cursor_y + dy, 0, @types.board_h - 1)
}

///|
fn handle_keyboard(game : @types.Game) -> Unit {
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
    game.mode = match game.mode {
      @types.Reveal => @types.Flag
      @types.Flag => @types.Reveal
    }
    @types.set_msg(
      game,
      match game.mode {
        @types.Reveal => "Reveal mode"
        @types.Flag => "Flag mode"
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
fn handle_touch_buttons(game : @types.Game) -> Bool {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  let (mx0, my0, mw0, mh0) = @types.touch_mode_button()
  let (hx0, hy0, hw0, hh0) = @types.touch_hint_button()
  let (rx0, ry0, rw0, rh0) = @types.touch_reset_button()
  let (ax0, ay0, aw0, ah0) = @types.touch_reveal_button()

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(mx, my, hold, touch_count, mx0, my0, mw0, mh0) {
    game.mode = match game.mode {
      @types.Reveal => @types.Flag
      @types.Flag => @types.Reveal
    }
    @types.set_msg(
      game,
      match game.mode {
        @types.Reveal => "Reveal mode"
        @types.Flag => "Flag mode"
      },
      0.8,
    )
    game.touch_cd = 0.18
    return true
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(mx, my, hold, touch_count, hx0, hy0, hw0, hh0) {
    ignore(use_hint(game))
    game.touch_cd = 0.18
    return true
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(mx, my, hold, touch_count, rx0, ry0, rw0, rh0) {
    start_match(game)
    game.touch_cd = 0.18
    return true
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(mx, my, hold, touch_count, ax0, ay0, aw0, ah0) {
    ignore(do_action_on_cell(game, game.cursor_x, game.cursor_y))
    game.touch_cd = 0.16
    return true
  }

  false
}

///|
fn update_play_input(game : @types.Game, _dt : Float) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y

  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.Title
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

  if handle_touch_buttons(game) {
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

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.mouse_x = Float::from_int(@raylib.get_mouse_x())
  game.mouse_y = Float::from_int(@raylib.get_mouse_y())
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0

  match game.state {
    @types.Title => update_title_input(game)
    @types.Play => {
      update_play_input(game, dt)
      update_play(game, dt)
    }
    @types.Result => {
      update_result_input(game)
      update_play(game, dt)
    }
  }
}
