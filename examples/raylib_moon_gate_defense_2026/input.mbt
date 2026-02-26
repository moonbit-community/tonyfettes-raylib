///|
fn clear_input(game : Game) -> Unit {
  game.input_move_x = 0
  game.input_move_y = 0
  game.input_place_press = false
  game.input_cancel_press = false
  game.input_barrier_press = false
  game.input_pause_press = false
  game.input_restart_press = false
}

///|
fn update_input(game : Game) -> Unit {
  clear_input(game)

  if @raylib.is_key_pressed(@raylib.KeyA) ||
    @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.input_move_x = game.input_move_x - 1
  }
  if @raylib.is_key_pressed(@raylib.KeyD) ||
    @raylib.is_key_pressed(@raylib.KeyRight) {
    game.input_move_x = game.input_move_x + 1
  }
  if @raylib.is_key_pressed(@raylib.KeyW) ||
    @raylib.is_key_pressed(@raylib.KeyUp) {
    game.input_move_y = game.input_move_y - 1
  }
  if @raylib.is_key_pressed(@raylib.KeyS) ||
    @raylib.is_key_pressed(@raylib.KeyDown) {
    game.input_move_y = game.input_move_y + 1
  }

  game.input_place_press = @raylib.is_key_pressed(@raylib.KeyJ)
  game.input_cancel_press = @raylib.is_key_pressed(@raylib.KeyK)
  game.input_barrier_press = @raylib.is_key_pressed(@raylib.KeySpace)
  game.input_pause_press = @raylib.is_key_pressed(@raylib.KeyP)
  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyR)
}
