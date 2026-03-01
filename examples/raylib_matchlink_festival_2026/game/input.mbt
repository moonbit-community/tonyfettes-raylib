///|
fn detect_held_dir(game : @types.Game) -> @types.Direction {
  let mut dir : @types.Direction = DirNone

  if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
    dir = Left
  }
  if @raylib.is_key_down(@raylib.KeyRight) || @raylib.is_key_down(@raylib.KeyD) {
    dir = Right
  }
  if @raylib.is_key_down(@raylib.KeyUp) || @raylib.is_key_down(@raylib.KeyW) {
    dir = Up
  }
  if @raylib.is_key_down(@raylib.KeyDown) || @raylib.is_key_down(@raylib.KeyS) {
    dir = Down
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
    dir = Left
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
    dir = Right
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
    dir = Up
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
    dir = Down
  }

  dir
}

///|
fn detect_select_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let (x, y, w, h) = @types.select_button_rect()
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
fn detect_hint_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyH)

  let (x, y, w, h) = @types.hint_button_rect()
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
fn detect_shuffle_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyJ)

  let (x, y, w, h) = @types.shuffle_button_rect()
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
fn detect_clear_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyC) ||
    @raylib.is_key_pressed(@raylib.KeyBackspace)

  let (x, y, w, h) = @types.clear_button_rect()
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

  let (x, y, w, h) = @types.reset_button_rect()
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

  let (x, y, w, h) = @types.start_button_rect()
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
fn detect_board_tap(game : @types.Game) -> (Bool, Int, Int) {
  let (board_x, board_y, tile) = @types.board_metrics(game)

  let bw : Int = game.board_w * tile
  let bh : Int = game.board_h * tile

  fn map_to_cell(px : Float, py : Float) -> (Bool, Int, Int) {
    if not(@types.inside_rect(px, py, board_x, board_y, bw, bh)) {
      return (false, 0, 0)
    }

    let cx : Int = @types.clampi(
      (px.to_int() - board_x) / tile + 1,
      1,
      game.board_w,
    )
    let cy : Int = @types.clampi(
      (py.to_int() - board_y) / tile + 1,
      1,
      game.board_h,
    )
    (true, cx, cy)
  }

  if game.mouse_press {
    let r = map_to_cell(game.mouse_x, game.mouse_y)
    if r.0 {
      return r
    }
  }

  if game.touch_count > 0 && game.touch_action_cd <= 0.0 {
    for i in 0..<game.touch_count {
      let p = @raylib.get_touch_position(i)
      let r = map_to_cell(p.x, p.y)
      if r.0 {
        return r
      }
    }
  }

  (false, 0, 0)
}
