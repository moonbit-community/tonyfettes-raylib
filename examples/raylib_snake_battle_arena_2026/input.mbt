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
  let b = start_button_rect()
  pointer_on_rect(mx, my, hold, touch_count, b.0, b.1, b.2, b.3)
}

///|
fn result_hover(mx : Float, my : Float, hold : Bool, touch_count : Int) -> Bool {
  let b = retry_button_rect()
  pointer_on_rect(mx, my, hold, touch_count, b.0, b.1, b.2, b.3)
}

///|
fn board_cell_from_pointer(
  game : Game,
  mx : Float,
  my : Float,
) -> (Bool, Int, Int) {
  let (bx, by, tile) = board_metrics(game)

  let x : Int = (mx.to_int() - bx) / tile
  let y : Int = (my.to_int() - by) / tile

  if x >= 0 && x < grid_w && y >= 0 && y < grid_h {
    (true, x, y)
  } else {
    (false, 0, 0)
  }
}

///|
fn direction_to_cell(game : Game, tx : Int, ty : Int) -> Int {
  let hx : Int = game.p_seg_x[0]
  let hy : Int = game.p_seg_y[0]

  let mut dx : Int = tx - hx
  let mut dy : Int = ty - hy

  if absf(Float::from_int(dx)) > Float::from_int(grid_w / 2) {
    dx = if dx > 0 { dx - grid_w } else { dx + grid_w }
  }
  if absf(Float::from_int(dy)) > Float::from_int(grid_h / 2) {
    dy = if dy > 0 { dy - grid_h } else { dy + grid_h }
  }

  if absf(Float::from_int(dx)) > absf(Float::from_int(dy)) {
    if dx < 0 {
      dir_left
    } else {
      dir_right
    }
  } else if dy < 0 {
    dir_up
  } else {
    dir_down
  }
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
fn handle_touch_buttons(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Bool {
  if game.touch_cd > 0.0 {
    return false
  }

  let left = btn_left()
  let right = btn_right()
  let up = btn_up()
  let down = btn_down()
  let boost = btn_boost()
  let restart = btn_restart()
  let hint = btn_hint()

  if pointer_on_rect(mx, my, hold, touch_count, left.0, left.1, left.2, left.3) {
    game.p_next_dir = dir_left
    game.touch_cd = 0.12
    return true
  }
  if pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      right.0,
      right.1,
      right.2,
      right.3,
    ) {
    game.p_next_dir = dir_right
    game.touch_cd = 0.12
    return true
  }
  if pointer_on_rect(mx, my, hold, touch_count, up.0, up.1, up.2, up.3) {
    game.p_next_dir = dir_up
    game.touch_cd = 0.12
    return true
  }
  if pointer_on_rect(mx, my, hold, touch_count, down.0, down.1, down.2, down.3) {
    game.p_next_dir = dir_down
    game.touch_cd = 0.12
    return true
  }

  if pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      restart.0,
      restart.1,
      restart.2,
      restart.3,
    ) {
    start_match(game)
    game.touch_cd = 0.16
    return true
  }

  if pointer_on_rect(mx, my, hold, touch_count, hint.0, hint.1, hint.2, hint.3) {
    ignore(use_hint(game))
    game.touch_cd = 0.16
    return true
  }

  if pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      boost.0,
      boost.1,
      boost.2,
      boost.3,
    ) {
    game.boost_on = game.boost_meter > 0.08
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

  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    game.p_next_dir = dir_left
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    game.p_next_dir = dir_right
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    game.p_next_dir = dir_up
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.p_next_dir = dir_down
  }

  if @raylib.is_key_pressed(@raylib.KeyH) {
    ignore(use_hint(game))
  }

  let boost_key : Bool = @raylib.is_key_down(@raylib.KeyLeftShift) ||
    @raylib.is_key_down(@raylib.KeyRightShift) ||
    @raylib.is_key_down(@raylib.KeyJ)

  game.boost_on = boost_key && game.boost_meter > 0.08

  let cell = board_cell_from_pointer(game, mx, my)
  if cell.0 {
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      game.p_next_dir = direction_to_cell(game, cell.1, cell.2)
    }
  }

  ignore(handle_touch_buttons(game, mx, my, hold, touch_count))
}
