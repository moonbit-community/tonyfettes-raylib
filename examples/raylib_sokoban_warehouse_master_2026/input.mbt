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
fn dpad_center_x() -> Int {
  160
}

///|
fn dpad_center_y() -> Int {
  screen_h - 180
}

///|
fn dpad_size() -> Int {
  76
}

///|
fn action_panel_x() -> Int {
  screen_w - 300
}

///|
fn action_panel_y() -> Int {
  screen_h - 252
}

///|
fn action_panel_w() -> Int {
  118
}

///|
fn action_panel_h() -> Int {
  74
}

///|
fn next_button_rect() -> (Int, Int, Int, Int) {
  (screen_w - 348, screen_h - 130, 310, 84)
}

///|
fn title_start_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 220, screen_h - 170, 440, 92)
}

///|
fn detect_hold_direction(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Int {
  let mut dir : Int = touch_none

  if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
    dir = touch_left
  }
  if @raylib.is_key_down(@raylib.KeyRight) || @raylib.is_key_down(@raylib.KeyD) {
    dir = touch_right
  }
  if @raylib.is_key_down(@raylib.KeyUp) || @raylib.is_key_down(@raylib.KeyW) {
    dir = touch_up
  }
  if @raylib.is_key_down(@raylib.KeyDown) || @raylib.is_key_down(@raylib.KeyS) {
    dir = touch_down
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
    dir = touch_left
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
    dir = touch_right
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
    dir = touch_up
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
    dir = touch_down
  }

  dir
}

///|
fn detect_undo_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyZ) ||
    @raylib.is_key_pressed(@raylib.KeyBackspace)

  let x : Int = action_panel_x()
  let y : Int = action_panel_y()
  let w : Int = action_panel_w()
  let h : Int = action_panel_h()

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

  let x : Int = action_panel_x()
  let y : Int = action_panel_y() + action_panel_h() + 14
  let w : Int = action_panel_w()
  let h : Int = action_panel_h()

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
fn detect_start_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let (x, y, w, h) = title_start_rect()
  if pointer_on_rect(mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h) {
    press = true
  }

  press
}
