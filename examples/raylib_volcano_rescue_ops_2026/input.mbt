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
  if mouse_flag && inside_rect(mouse_x, mouse_y, x, y, w, h) {
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
fn sample_pointer(
  mouse_x : Float,
  mouse_y : Float,
  mouse_flag : Bool,
  touch_count : Int,
) -> (Bool, Float, Float) {
  if mouse_flag {
    return (true, mouse_x, mouse_y)
  }

  if touch_count > 0 {
    let p = @raylib.get_touch_position(0)
    return (true, p.x, p.y)
  }

  (false, 0.0, 0.0)
}

///|
fn map_rect() -> (Int, Int, Int, Int) {
  (map_x, map_y, grid_w * tile_size, grid_h * tile_size)
}

///|
fn execute_button_rect() -> (Int, Int, Int, Int) {
  (panel_x + 250, screen_h - 238, panel_w - 274, 68)
}

///|
fn clear_route_button_rect() -> (Int, Int, Int, Int) {
  (panel_x + 250, screen_h - 158, panel_w - 274, 62)
}

///|
fn coolant_button_rect() -> (Int, Int, Int, Int) {
  (panel_x + 250, screen_h - 84, panel_w - 274, 56)
}

///|
fn restart_button_rect() -> (Int, Int, Int, Int) {
  (panel_x + 24, 184, panel_w - 48, 52)
}

///|
fn title_start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 240, screen_h - 182, 480, 98)
}

///|
fn result_restart_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 290, screen_h - 198, 250, 94)
}

///|
fn result_next_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 + 40, screen_h - 198, 250, 94)
}

///|
fn dpad_center_x() -> Int {
  panel_x + 118
}

///|
fn dpad_center_y() -> Int {
  screen_h - 142
}

///|
fn dpad_size() -> Int {
  78
}

///|
fn dpad_left_rect() -> (Int, Int, Int, Int) {
  let s : Int = dpad_size()
  (dpad_center_x() - s - 24, dpad_center_y() - s / 2, s, s)
}

///|
fn dpad_right_rect() -> (Int, Int, Int, Int) {
  let s : Int = dpad_size()
  (dpad_center_x() + 24, dpad_center_y() - s / 2, s, s)
}

///|
fn dpad_up_rect() -> (Int, Int, Int, Int) {
  let s : Int = dpad_size()
  (dpad_center_x() - s / 2, dpad_center_y() - s - 24, s, s)
}

///|
fn dpad_down_rect() -> (Int, Int, Int, Int) {
  let s : Int = dpad_size()
  (dpad_center_x() - s / 2, dpad_center_y() + 24, s, s)
}

///|
fn detect_start_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let key_press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let (x, y, w, h) = title_start_button_rect()
  let touch_press : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h,
  )

  key_press || touch_press
}

///|
fn detect_execute_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let key_press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyE)

  let (x, y, w, h) = execute_button_rect()
  let touch_press : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h,
  )

  key_press || touch_press
}

///|
fn detect_clear_route_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let key_press : Bool = @raylib.is_key_pressed(@raylib.KeyBackspace) ||
    @raylib.is_key_pressed(@raylib.KeyDelete) ||
    @raylib.is_key_pressed(@raylib.KeyX)

  let (x, y, w, h) = clear_route_button_rect()
  let touch_press : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h,
  )

  key_press || touch_press
}

///|
fn detect_coolant_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let key_press : Bool = @raylib.is_key_pressed(@raylib.KeyC)

  let (x, y, w, h) = coolant_button_rect()
  let touch_press : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h,
  )

  key_press || touch_press
}

///|
fn detect_restart_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let key_press : Bool = @raylib.is_key_pressed(@raylib.KeyR)

  let (x, y, w, h) = restart_button_rect()
  let play_touch : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h,
  )

  let (rx, ry, rw, rh) = result_restart_button_rect()
  let result_touch : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_press, touch_count, rx, ry, rw, rh,
  )

  key_press || play_touch || result_touch
}

///|
fn detect_next_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let key_press : Bool = @raylib.is_key_pressed(@raylib.KeyN) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)

  let (x, y, w, h) = result_next_button_rect()
  let touch_press : Bool = pointer_on_rect(
    mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h,
  )

  key_press || touch_press
}

///|
fn detect_dir_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Int {
  let mut dir : Int = dir_none

  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    dir = dir_up
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    dir = dir_down
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    dir = dir_left
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    dir = dir_right
  }

  let up = dpad_up_rect()
  if pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_press,
      touch_count,
      up.0,
      up.1,
      up.2,
      up.3,
    ) {
    dir = dir_up
  }

  let down = dpad_down_rect()
  if pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_press,
      touch_count,
      down.0,
      down.1,
      down.2,
      down.3,
    ) {
    dir = dir_down
  }

  let left = dpad_left_rect()
  if pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_press,
      touch_count,
      left.0,
      left.1,
      left.2,
      left.3,
    ) {
    dir = dir_left
  }

  let right = dpad_right_rect()
  if pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_press,
      touch_count,
      right.0,
      right.1,
      right.2,
      right.3,
    ) {
    dir = dir_right
  }

  dir
}

///|
fn detect_map_target(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> (Bool, Int, Int) {
  let sample = sample_pointer(mouse_x, mouse_y, mouse_press, touch_count)
  if not(sample.0) {
    return (false, 0, 0)
  }

  let (mx, my, mw, mh) = map_rect()
  if not(inside_rect(sample.1, sample.2, mx, my, mw, mh)) {
    return (false, 0, 0)
  }

  let gx : Int = (sample.1.to_int() - mx) / tile_size
  let gy : Int = (sample.2.to_int() - my) / tile_size

  if gx < 0 || gx >= grid_w || gy < 0 || gy >= grid_h {
    return (false, 0, 0)
  }

  (true, gx, gy)
}
