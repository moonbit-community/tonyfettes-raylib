///|
fn detect_held_dir(game : @types.Game) -> Int {
  let mut dir : Int = @types.dir_none

  if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
    dir = @types.dir_left
  }
  if @raylib.is_key_down(@raylib.KeyRight) || @raylib.is_key_down(@raylib.KeyD) {
    dir = @types.dir_right
  }
  if @raylib.is_key_down(@raylib.KeyUp) || @raylib.is_key_down(@raylib.KeyW) {
    dir = @types.dir_up
  }
  if @raylib.is_key_down(@raylib.KeyDown) || @raylib.is_key_down(@raylib.KeyS) {
    dir = @types.dir_down
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
    dir = @types.dir_left
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
    dir = @types.dir_right
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
    dir = @types.dir_up
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
    dir = @types.dir_down
  }

  dir
}

///|
fn detect_fill_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyF)

  let (x, y, w, h) = @types.fill_button_rect()
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
fn detect_cross_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyX) ||
    @raylib.is_key_pressed(@raylib.KeyC)

  let (x, y, w, h) = @types.cross_button_rect()
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
fn detect_undo_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyZ) ||
    @raylib.is_key_pressed(@raylib.KeyBackspace)

  let (x, y, w, h) = @types.undo_button_rect()
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
fn detect_toggle_tool() -> Bool {
  @raylib.is_key_pressed(@raylib.KeyTab) || @raylib.is_key_pressed(@raylib.KeyT)
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
fn detect_board_tap(game : @types.Game) -> (Bool, Int, Int) {
  let (board_x, board_y, tile, _, _, _, _) = @types.board_metrics(game)

  let bw : Int = game.grid_w * tile
  let bh : Int = game.grid_h * tile

  fn map_point(px : Float, py : Float) -> (Bool, Int, Int) {
    if not(@types.inside_rect(px, py, board_x, board_y, bw, bh)) {
      return (false, 0, 0)
    }

    let cx : Int = @types.clampi(
      (px.to_int() - board_x) / tile,
      0,
      game.grid_w - 1,
    )
    let cy : Int = @types.clampi(
      (py.to_int() - board_y) / tile,
      0,
      game.grid_h - 1,
    )
    (true, cx, cy)
  }

  if game.mouse_press {
    let res = map_point(game.mouse_x, game.mouse_y)
    if res.0 {
      return res
    }
  }

  if game.touch_count > 0 && game.touch_action_cd <= 0.0 {
    for i in 0..<game.touch_count {
      let p = @raylib.get_touch_position(i)
      let res = map_point(p.x, p.y)
      if res.0 {
        return res
      }
    }
  }

  (false, 0, 0)
}
