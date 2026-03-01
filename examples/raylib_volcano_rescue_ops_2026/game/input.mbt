///|
fn detect_start_press(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> Bool {
  let key_press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let (x, y, w, h) = @types.title_start_button_rect()
  let touch_press : Bool = @types.pointer_on_rect(
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

  let (x, y, w, h) = @types.execute_button_rect()
  let touch_press : Bool = @types.pointer_on_rect(
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

  let (x, y, w, h) = @types.clear_route_button_rect()
  let touch_press : Bool = @types.pointer_on_rect(
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

  let (x, y, w, h) = @types.coolant_button_rect()
  let touch_press : Bool = @types.pointer_on_rect(
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

  let (x, y, w, h) = @types.restart_button_rect()
  let play_touch : Bool = @types.pointer_on_rect(
    mouse_x, mouse_y, mouse_press, touch_count, x, y, w, h,
  )

  let (rx, ry, rw, rh) = @types.result_restart_button_rect()
  let result_touch : Bool = @types.pointer_on_rect(
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

  let (x, y, w, h) = @types.result_next_button_rect()
  let touch_press : Bool = @types.pointer_on_rect(
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
  let mut dir : Int = @types.dir_none

  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    dir = @types.dir_up
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    dir = @types.dir_down
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    dir = @types.dir_left
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    dir = @types.dir_right
  }

  let up = @types.dpad_up_rect()
  if @types.pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_press,
      touch_count,
      up.0,
      up.1,
      up.2,
      up.3,
    ) {
    dir = @types.dir_up
  }

  let down = @types.dpad_down_rect()
  if @types.pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_press,
      touch_count,
      down.0,
      down.1,
      down.2,
      down.3,
    ) {
    dir = @types.dir_down
  }

  let left = @types.dpad_left_rect()
  if @types.pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_press,
      touch_count,
      left.0,
      left.1,
      left.2,
      left.3,
    ) {
    dir = @types.dir_left
  }

  let right = @types.dpad_right_rect()
  if @types.pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_press,
      touch_count,
      right.0,
      right.1,
      right.2,
      right.3,
    ) {
    dir = @types.dir_right
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
  let sample = @types.sample_pointer(mouse_x, mouse_y, mouse_press, touch_count)
  if not(sample.0) {
    return (false, 0, 0)
  }

  let (mx, my, mw, mh) = @types.map_rect()
  if not(@types.inside_rect(sample.1, sample.2, mx, my, mw, mh)) {
    return (false, 0, 0)
  }

  let gx : Int = (sample.1.to_int() - mx) / @types.tile_size
  let gy : Int = (sample.2.to_int() - my) / @types.tile_size

  if gx < 0 || gx >= @types.grid_w || gy < 0 || gy >= @types.grid_h {
    return (false, 0, 0)
  }

  (true, gx, gy)
}
