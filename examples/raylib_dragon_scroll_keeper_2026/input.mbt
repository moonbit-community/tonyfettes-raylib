///|
fn clear_input(game : Game) -> Unit {
  game.input_x = 0.0
  game.input_y = 0.0
  game.input_action_press = false
  game.input_cancel_press = false
  game.input_shield_press = false
  game.input_pause_press = false
  game.input_restart_press = false
}

///|
fn update_input(game : Game) -> Unit {
  clear_input(game)

  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    game.input_x = game.input_x - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
    game.input_x = game.input_x + 1.0
  }
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    game.input_y = game.input_y - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    game.input_y = game.input_y + 1.0
  }

  game.input_x = clampf(game.input_x, -1.0, 1.0)
  game.input_y = clampf(game.input_y, -1.0, 1.0)

  game.input_action_press = @raylib.is_key_pressed(@raylib.KeyJ)
  game.input_cancel_press = @raylib.is_key_pressed(@raylib.KeyK)
  game.input_shield_press = @raylib.is_key_pressed(@raylib.KeySpace)
  game.input_pause_press = @raylib.is_key_pressed(@raylib.KeyP)
  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyR)
}
