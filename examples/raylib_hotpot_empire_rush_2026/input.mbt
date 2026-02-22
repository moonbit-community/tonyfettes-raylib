///|
fn clear_input(game : Game) -> Unit {
  game.input.move_x = 0
  game.input.move_y = 0
  game.input.press_interact = false
  game.input.press_serve_cancel = false
  game.input.press_boost = false
  game.input.press_pause = false
  game.input.press_restart = false
  game.input.press_start = false
}

///|
fn update_input(game : Game) -> Unit {
  clear_input(game)

  if @raylib.is_key_pressed(@raylib.KeyA) ||
    @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.input.move_x = -1
  }
  if @raylib.is_key_pressed(@raylib.KeyD) ||
    @raylib.is_key_pressed(@raylib.KeyRight) {
    game.input.move_x = 1
  }
  if @raylib.is_key_pressed(@raylib.KeyW) ||
    @raylib.is_key_pressed(@raylib.KeyUp) {
    game.input.move_y = -1
  }
  if @raylib.is_key_pressed(@raylib.KeyS) ||
    @raylib.is_key_pressed(@raylib.KeyDown) {
    game.input.move_y = 1
  }

  game.input.press_interact = @raylib.is_key_pressed(@raylib.KeyJ)
  game.input.press_serve_cancel = @raylib.is_key_pressed(@raylib.KeyK)
  game.input.press_boost = @raylib.is_key_pressed(@raylib.KeySpace)
  game.input.press_pause = @raylib.is_key_pressed(@raylib.KeyP)
  game.input.press_restart = @raylib.is_key_pressed(@raylib.KeyR)

  game.input.press_start = game.input.press_interact ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
}
