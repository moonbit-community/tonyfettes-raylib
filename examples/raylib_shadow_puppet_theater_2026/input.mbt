///|
fn clear_input(game : Game) -> Unit {
  game.input.axis_dx = 0
  game.input.axis_dy = 0
  game.input.lock_pressed = false
  game.input.undo_pressed = false
  game.input.burst_pressed = false
  game.input.pause_pressed = false
  game.input.restart_pressed = false
  game.input.start_pressed = false
}

///|
fn sample_input(game : Game) -> Unit {
  clear_input(game)

  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    game.input.axis_dx = game.input.axis_dx - 1
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    game.input.axis_dx = game.input.axis_dx + 1
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    game.input.axis_dy = game.input.axis_dy - 1
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.input.axis_dy = game.input.axis_dy + 1
  }

  game.input.lock_pressed = @raylib.is_key_pressed(@raylib.KeyJ)
  game.input.undo_pressed = @raylib.is_key_pressed(@raylib.KeyK)
  game.input.burst_pressed = @raylib.is_key_pressed(@raylib.KeySpace)
  game.input.pause_pressed = @raylib.is_key_pressed(@raylib.KeyP)
  game.input.restart_pressed = @raylib.is_key_pressed(@raylib.KeyR)

  game.input.start_pressed = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeyJ) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
}
