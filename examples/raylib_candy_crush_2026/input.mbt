///|
fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
fn pointer_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  if mouse_press && inside_rect(mouse_x, mouse_y, x, y, w, h) {
    return true
  }

  for i = 0; i < touch_count; i = i + 1 {
    let p = @raylib.get_touch_position(i)
    if inside_rect(p.x, p.y, x, y, w, h) {
      return true
    }
  }

  false
}

///|
fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, screen_h - 170, 460, 96)
}

///|
fn hint_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 30, 280, ui_panel_w - 60, 70)
}

///|
fn shuffle_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 30, 366, ui_panel_w - 60, 70)
}

///|
fn restart_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 30, 452, ui_panel_w - 60, 70)
}

///|
fn result_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 220, screen_h - 180, 440, 92)
}

///|
fn pointer_to_cell(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> (Bool, Int, Int) {
  let bx = board_x()
  let by = board_y()
  let bw = board_pixel_w()
  let bh = board_pixel_h()

  fn to_cell(px : Float, py : Float) -> (Bool, Int, Int) {
    if not(inside_rect(px, py, bx, by, bw, bh)) {
      return (false, 0, 0)
    }

    let cx = clampi((px.to_int() - bx) / cell_px, 0, board_cols - 1)
    let cy = clampi((py.to_int() - by) / cell_px, 0, board_rows - 1)
    (true, cx, cy)
  }

  if mouse_press {
    let cell = to_cell(mouse_x, mouse_y)
    if cell.0 {
      return cell
    }
  }

  for i = 0; i < touch_count; i = i + 1 {
    let p = @raylib.get_touch_position(i)
    let cell = to_cell(p.x, p.y)
    if cell.0 {
      return cell
    }
  }

  (false, 0, 0)
}

///|
fn update_title_input(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Unit {
  if touch_count > 0 {
    game.touch_mode = true
  }

  let mut start = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let start_rect = start_button_rect()
  if pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_press,
      touch_count,
      start_rect.0,
      start_rect.1,
      start_rect.2,
      start_rect.3,
    ) {
    start = true
  }

  if start {
    restart_run(game)
  }
}

///|
fn update_play_input(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Unit {
  if touch_count > 0 {
    game.touch_mode = true
  }

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

  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    select_or_swap(game, game.cursor_x, game.cursor_y)
  }

  if @raylib.is_key_pressed(@raylib.KeyH) {
    use_hint(game)
  }

  if @raylib.is_key_pressed(@raylib.KeyJ) {
    try_manual_shuffle(game)
  }

  if @raylib.is_key_pressed(@raylib.KeyR) {
    restart_level(game)
    return
  }

  let tap = pointer_to_cell(mouse_x, mouse_y, mouse_press, touch_count)
  if tap.0 && game.touch_cd <= 0.0 {
    game.touch_cd = touch_action_cooldown
    select_or_swap(game, tap.1, tap.2)
    return
  }

  if game.touch_cd > 0.0 {
    return
  }

  let hint = hint_button_rect()
  if pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_press,
      touch_count,
      hint.0,
      hint.1,
      hint.2,
      hint.3,
    ) {
    game.touch_cd = touch_action_cooldown
    use_hint(game)
    return
  }

  let shuffle = shuffle_button_rect()
  if pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_press,
      touch_count,
      shuffle.0,
      shuffle.1,
      shuffle.2,
      shuffle.3,
    ) {
    game.touch_cd = touch_action_cooldown
    try_manual_shuffle(game)
    return
  }

  let restart = restart_button_rect()
  if pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_press,
      touch_count,
      restart.0,
      restart.1,
      restart.2,
      restart.3,
    ) {
    game.touch_cd = touch_action_cooldown
    restart_level(game)
  }
}

///|
fn update_result_input(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Unit {
  if touch_count > 0 {
    game.touch_mode = true
  }

  let mut action = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let rect = result_button_rect()
  if pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_press,
      touch_count,
      rect.0,
      rect.1,
      rect.2,
      rect.3,
    ) {
    action = true
  }

  if game.state == state_level_clear {
    if action {
      start_next_level(game)
      return
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      restart_level(game)
      return
    }
  } else if action {
    restart_run(game)
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyT) {
    game.state = state_title
    clear_selection(game)
  }
}
