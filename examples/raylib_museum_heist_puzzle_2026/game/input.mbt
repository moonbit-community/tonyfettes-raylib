///|
fn detect_move_dir(game : @types.Game) -> @types.Direction {
  let mut dir : @types.Direction = @types.DirNone

  if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
    dir = @types.Left
  }
  if @raylib.is_key_down(@raylib.KeyRight) || @raylib.is_key_down(@raylib.KeyD) {
    dir = @types.Right
  }
  if @raylib.is_key_down(@raylib.KeyUp) || @raylib.is_key_down(@raylib.KeyW) {
    dir = @types.Up
  }
  if @raylib.is_key_down(@raylib.KeyDown) || @raylib.is_key_down(@raylib.KeyS) {
    dir = @types.Down
  }

  let (lx, ly, lw, lh) = @types.dpad_left_rect()
  let (rx, ry, rw, rh) = @types.dpad_right_rect()
  let (ux, uy, uw, uh) = @types.dpad_up_rect()
  let (dx, dy, dw, dh) = @types.dpad_down_rect()

  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      lx,
      ly,
      lw,
      lh,
    ) {
    dir = @types.Left
  }
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      rx,
      ry,
      rw,
      rh,
    ) {
    dir = @types.Right
  }
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      ux,
      uy,
      uw,
      uh,
    ) {
    dir = @types.Up
  }
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      dx,
      dy,
      dw,
      dh,
    ) {
    dir = @types.Down
  }

  dir
}

///|
fn detect_start_press(game : @types.Game) -> Bool {
  let mut pressed = @raylib.is_key_pressed(@raylib.KeyEnter) ||
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
    pressed = true
  }

  pressed
}

///|
fn detect_next_press(game : @types.Game) -> Bool {
  let mut pressed = @raylib.is_key_pressed(@raylib.KeyEnter) ||
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
    pressed = true
  }

  pressed
}

///|
fn detect_retry_press(game : @types.Game) -> Bool {
  let mut pressed = @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyBackspace)

  let (x, y, w, h) = @types.retry_button_rect()
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
    pressed = true
  }

  pressed
}

///|
fn detect_restart_play_press(game : @types.Game) -> Bool {
  let mut pressed = @raylib.is_key_pressed(@raylib.KeyR)
  let (x, y, w, h) = @types.restart_button_rect()
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
    pressed = true
  }
  pressed
}

///|
fn gather_input(game : @types.Game) -> @types.FrameInput {
  let move_dir = match game.state {
    @types.Play => detect_move_dir(game)
    _ => @types.DirNone
  }

  {
    move_dir,
    start_pressed: detect_start_press(game),
    next_pressed: detect_next_press(game),
    retry_pressed: detect_retry_press(game),
    restart_pressed: detect_restart_play_press(game),
  }
}
