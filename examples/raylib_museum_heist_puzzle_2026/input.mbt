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
  let mut hit = false
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
fn dpad_center_x() -> Int {
  162
}

///|
fn dpad_center_y() -> Int {
  screen_h - 122
}

///|
fn dpad_button_size() -> Int {
  68
}

///|
fn dpad_left_rect() -> (Int, Int, Int, Int) {
  let s = dpad_button_size()
  let cx = dpad_center_x()
  let cy = dpad_center_y()
  (cx - s - 20, cy - s / 2, s, s)
}

///|
fn dpad_right_rect() -> (Int, Int, Int, Int) {
  let s = dpad_button_size()
  let cx = dpad_center_x()
  let cy = dpad_center_y()
  (cx + 20, cy - s / 2, s, s)
}

///|
fn dpad_up_rect() -> (Int, Int, Int, Int) {
  let s = dpad_button_size()
  let cx = dpad_center_x()
  let cy = dpad_center_y()
  (cx - s / 2, cy - s - 20, s, s)
}

///|
fn dpad_down_rect() -> (Int, Int, Int, Int) {
  let s = dpad_button_size()
  let cx = dpad_center_x()
  let cy = dpad_center_y()
  (cx - s / 2, cy + 20, s, s)
}

///|
fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 190, screen_h - 250, 380, 80)
}

///|
fn next_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 190, screen_h - 154, 380, 80)
}

///|
fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 190, screen_h - 250, 380, 80)
}

///|
fn restart_button_rect() -> (Int, Int, Int, Int) {
  (panel_x + 20, screen_h - 122, panel_w - 40, 72)
}

///|
fn detect_move_dir(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Int {
  let mut dir = dir_none

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

  let (lx, ly, lw, lh) = dpad_left_rect()
  let (rx, ry, rw, rh) = dpad_right_rect()
  let (ux, uy, uw, uh) = dpad_up_rect()
  let (dx, dy, dw, dh) = dpad_down_rect()

  if pointer_on_rect(mouse_x, mouse_y, mouse_hold, touch_count, lx, ly, lw, lh) {
    dir = dir_left
  }
  if pointer_on_rect(mouse_x, mouse_y, mouse_hold, touch_count, rx, ry, rw, rh) {
    dir = dir_right
  }
  if pointer_on_rect(mouse_x, mouse_y, mouse_hold, touch_count, ux, uy, uw, uh) {
    dir = dir_up
  }
  if pointer_on_rect(mouse_x, mouse_y, mouse_hold, touch_count, dx, dy, dw, dh) {
    dir = dir_down
  }

  dir
}

///|
fn detect_start_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let mut pressed = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let (x, y, w, h) = start_button_rect()
  if pointer_on_rect(mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h) {
    pressed = true
  }

  pressed
}

///|
fn detect_next_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let mut pressed = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyN)

  let (x, y, w, h) = next_button_rect()
  if pointer_on_rect(mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h) {
    pressed = true
  }

  pressed
}

///|
fn detect_retry_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let mut pressed = @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyBackspace)

  let (x, y, w, h) = retry_button_rect()
  if pointer_on_rect(mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h) {
    pressed = true
  }

  pressed
}

///|
fn detect_restart_play_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let mut pressed = @raylib.is_key_pressed(@raylib.KeyR)
  let (x, y, w, h) = restart_button_rect()
  if pointer_on_rect(mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h) {
    pressed = true
  }
  pressed
}
