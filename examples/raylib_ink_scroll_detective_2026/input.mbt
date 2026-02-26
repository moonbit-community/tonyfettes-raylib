///|
fn clear_input(game : Game) -> Unit {
  game.input_dx = 0
  game.input_dy = 0
  game.input_inspect_press = false
  game.input_cancel_press = false
  game.input_focus_press = false
  game.input_pause_press = false
  game.input_restart_press = false
}

///|
fn update_input(game : Game) -> Unit {
  clear_input(game)

  if @raylib.is_key_pressed(@raylib.KeyA) ||
    @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.input_dx = game.input_dx - 1
  }
  if @raylib.is_key_pressed(@raylib.KeyD) ||
    @raylib.is_key_pressed(@raylib.KeyRight) {
    game.input_dx = game.input_dx + 1
  }

  if @raylib.is_key_pressed(@raylib.KeyW) ||
    @raylib.is_key_pressed(@raylib.KeyUp) {
    game.input_dy = game.input_dy - 1
  }
  if @raylib.is_key_pressed(@raylib.KeyS) ||
    @raylib.is_key_pressed(@raylib.KeyDown) {
    game.input_dy = game.input_dy + 1
  }

  game.input_dx = clampi(game.input_dx, -1, 1)
  game.input_dy = clampi(game.input_dy, -1, 1)

  game.input_inspect_press = @raylib.is_key_pressed(@raylib.KeyJ) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
  game.input_cancel_press = @raylib.is_key_pressed(@raylib.KeyK) ||
    @raylib.is_key_pressed(@raylib.KeyBackspace)
  game.input_focus_press = @raylib.is_key_pressed(@raylib.KeySpace)
  game.input_pause_press = @raylib.is_key_pressed(@raylib.KeyP)
  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyR)
}
