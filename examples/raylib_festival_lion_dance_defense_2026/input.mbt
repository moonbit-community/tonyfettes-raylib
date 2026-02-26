///|
fn clear_input(game : Game) -> Unit {
  game.input.move_x = 0
  game.input.move_y = 0
  game.input.press_strike = false
  game.input.press_guard = false
  game.input.press_burst = false
  game.input.press_pause = false
  game.input.press_restart = false
  game.input.press_start = false
}

///|
fn update_input(game : Game) -> Unit {
  clear_input(game)

  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    game.input.move_x = game.input.move_x - 1
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
    game.input.move_x = game.input.move_x + 1
  }
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    game.input.move_y = game.input.move_y - 1
  }
  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    game.input.move_y = game.input.move_y + 1
  }

  game.input.move_x = clampi(game.input.move_x, -1, 1)
  game.input.move_y = clampi(game.input.move_y, -1, 1)

  game.input.press_strike = @raylib.is_key_pressed(@raylib.KeyJ)
  game.input.press_guard = @raylib.is_key_pressed(@raylib.KeyK)
  game.input.press_burst = @raylib.is_key_pressed(@raylib.KeySpace)
  game.input.press_pause = @raylib.is_key_pressed(@raylib.KeyP)
  game.input.press_restart = @raylib.is_key_pressed(@raylib.KeyR)

  game.input.press_start = game.input.press_strike ||
    @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
}
