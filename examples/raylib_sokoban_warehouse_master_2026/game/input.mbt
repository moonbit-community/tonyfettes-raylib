///|
fn detect_hold_direction(game : @types.Game) -> @types.Direction {
  let mut dir : @types.Direction = @types.Direction::None

  if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
    dir = @types.Direction::Left
  }
  if @raylib.is_key_down(@raylib.KeyRight) || @raylib.is_key_down(@raylib.KeyD) {
    dir = @types.Direction::Right
  }
  if @raylib.is_key_down(@raylib.KeyUp) || @raylib.is_key_down(@raylib.KeyW) {
    dir = @types.Direction::Up
  }
  if @raylib.is_key_down(@raylib.KeyDown) || @raylib.is_key_down(@raylib.KeyS) {
    dir = @types.Direction::Down
  }

  let cx : Int = @types.dpad_center_x()
  let cy : Int = @types.dpad_center_y()
  let s : Int = @types.dpad_size()

  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      cx - s - 18,
      cy - s / 2,
      s,
      s,
    ) {
    dir = @types.Direction::Left
  }
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      cx + 18,
      cy - s / 2,
      s,
      s,
    ) {
    dir = @types.Direction::Right
  }
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      cx - s / 2,
      cy - s - 18,
      s,
      s,
    ) {
    dir = @types.Direction::Up
  }
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      cx - s / 2,
      cy + 18,
      s,
      s,
    ) {
    dir = @types.Direction::Down
  }

  dir
}

///|
fn detect_undo_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyZ) ||
    @raylib.is_key_pressed(@raylib.KeyBackspace)

  let x : Int = @types.action_panel_x()
  let y : Int = @types.action_panel_y()
  let w : Int = @types.action_panel_w()
  let h : Int = @types.action_panel_h()

  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      x,
      y,
      w,
      h,
    ) {
    press = true
  }

  press
}

///|
fn detect_reset_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyR)

  let x : Int = @types.action_panel_x()
  let y : Int = @types.action_panel_y() + @types.action_panel_h() + 14
  let w : Int = @types.action_panel_w()
  let h : Int = @types.action_panel_h()

  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      x,
      y,
      w,
      h,
    ) {
    press = true
  }

  press
}

///|
fn detect_next_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyN)

  let (x, y, w, h) = @types.next_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      x,
      y,
      w,
      h,
    ) {
    press = true
  }

  press
}

///|
fn detect_start_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let (x, y, w, h) = @types.title_start_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      x,
      y,
      w,
      h,
    ) {
    press = true
  }

  press
}
