///|
fn clear_input(game : Game) -> Unit {
  game.input.axis_x = 0
  game.input.axis_y = 0
  game.input.hit_pressed = false
  game.input.defend_pressed = false
  game.input.burst_pressed = false
  game.input.pause_pressed = false
  game.input.restart_pressed = false
  game.input.confirm_pressed = false
}

///|
fn sample_input(game : Game) -> Unit {
  clear_input(game)

  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    game.input.axis_x = game.input.axis_x - 1
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    game.input.axis_x = game.input.axis_x + 1
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    game.input.axis_y = game.input.axis_y - 1
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.input.axis_y = game.input.axis_y + 1
  }

  game.input.hit_pressed = @raylib.is_key_pressed(@raylib.KeyJ)
  game.input.defend_pressed = @raylib.is_key_pressed(@raylib.KeyK)
  game.input.burst_pressed = @raylib.is_key_pressed(@raylib.KeySpace)
  game.input.pause_pressed = @raylib.is_key_pressed(@raylib.KeyP)
  game.input.restart_pressed = @raylib.is_key_pressed(@raylib.KeyR)

  game.input.confirm_pressed = game.input.hit_pressed ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
}
