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
  mouse_flag : Bool,
  touch_count : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  let mut hit : Bool = false

  if mouse_flag && inside_rect(mouse_x, mouse_y, x, y, w, h) {
    hit = true
  }

  if not(hit) {
    for i = 0; i < touch_count; i = i + 1 {
      let p = @raylib.get_touch_position(i)
      if inside_rect(p.x, p.y, x, y, w, h) {
        hit = true
      }
    }
  }

  hit
}

///|
fn panel_x() -> Int {
  screen_w - 420
}

///|
fn dpad_center_x() -> Int {
  162
}

///|
fn dpad_center_y() -> Int {
  screen_h - 184
}

///|
fn dpad_size() -> Int {
  78
}

///|
fn place_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 256, 170, 72)
}

///|
fn hint_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 214, screen_h - 256, 170, 72)
}

///|
fn undo_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 172, 170, 72)
}

///|
fn clear_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 214, screen_h - 172, 170, 72)
}

///|
fn reset_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 88, 170, 72)
}

///|
fn next_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 88, 360, 72)
}

///|
fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, screen_h - 158, 460, 96)
}

///|
fn detect_held_dir(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Int {
  let mut dir : Int = dir_none

  if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
    dir = dir_left
  }
  if @raylib.is_key_down(@raylib.KeyRight) || @raylib.is_key_down(@raylib.KeyD) {
    dir = dir_right
  }
  if @raylib.is_key_down(@raylib.KeyUp) || @raylib.is_key_down(@raylib.KeyW) {
    dir = dir_up
  }
  if @raylib.is_key_down(@raylib.KeyDown) || @raylib.is_key_down(@raylib.KeyS) {
    dir = dir_down
  }

  let cx : Int = dpad_center_x()
  let cy : Int = dpad_center_y()
  let s : Int = dpad_size()

  if pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_hold,
      touch_count,
      cx - s - 18,
      cy - s / 2,
      s,
      s,
    ) {
    dir = dir_left
  }
  if pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_hold,
      touch_count,
      cx + 18,
      cy - s / 2,
      s,
      s,
    ) {
    dir = dir_right
  }
  if pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_hold,
      touch_count,
      cx - s / 2,
      cy - s - 18,
      s,
      s,
    ) {
    dir = dir_up
  }
  if pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_hold,
      touch_count,
      cx - s / 2,
      cy + 18,
      s,
      s,
    ) {
    dir = dir_down
  }

  dir
}

///|
fn detect_place_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let (x, y, w, h) = place_button_rect()
  if pointer_on_rect(mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h) {
    press = true
  }

  press
}

///|
fn detect_hint_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyH)

  let (x, y, w, h) = hint_button_rect()
  if pointer_on_rect(mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h) {
    press = true
  }

  press
}

///|
fn detect_undo_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyU) ||
    @raylib.is_key_pressed(@raylib.KeyZ)

  let (x, y, w, h) = undo_button_rect()
  if pointer_on_rect(mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h) {
    press = true
  }

  press
}

///|
fn detect_clear_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyC) ||
    @raylib.is_key_pressed(@raylib.KeyBackspace)

  let (x, y, w, h) = clear_button_rect()
  if pointer_on_rect(mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h) {
    press = true
  }

  press
}

///|
fn detect_reset_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyR)

  let (x, y, w, h) = reset_button_rect()
  if pointer_on_rect(mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h) {
    press = true
  }

  press
}

///|
fn detect_start_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let (x, y, w, h) = start_button_rect()
  if pointer_on_rect(mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h) {
    press = true
  }

  press
}

///|
fn detect_next_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyN)

  let (x, y, w, h) = next_button_rect()
  if pointer_on_rect(mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h) {
    press = true
  }

  press
}

///|
fn detect_board_tap(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> (Bool, Int, Int) {
  let (board_x, board_y, tile) = board_metrics(game)
  let bw : Int = board_n * tile
  let bh : Int = board_n * tile

  fn map(px : Float, py : Float) -> (Bool, Int, Int) {
    if not(inside_rect(px, py, board_x, board_y, bw, bh)) {
      return (false, 0, 0)
    }

    let cx : Int = clampi((px.to_int() - board_x) / tile, 0, board_n - 1)
    let cy : Int = clampi((py.to_int() - board_y) / tile, 0, board_n - 1)
    (true, cx, cy)
  }

  if mouse_press {
    let r = map(mouse_x, mouse_y)
    if r.0 {
      return r
    }
  }

  if touch_count > 0 && game.touch_action_cd <= 0.0 {
    for i = 0; i < touch_count; i = i + 1 {
      let p = @raylib.get_touch_position(i)
      let r = map(p.x, p.y)
      if r.0 {
        return r
      }
    }
  }

  (false, 0, 0)
}
