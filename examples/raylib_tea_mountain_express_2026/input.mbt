///|
fn clear_input(game : Game) -> Unit {
  game.input_steer = 0
  game.input_tilt = 0
  game.input_brake_press = false
  game.input_stabilize_hold = false
  game.input_boost_press = false
  game.input_pause_press = false
  game.input_restart_press = false
  game.input_confirm_press = false
}

///|
fn update_input(game : Game) -> Unit {
  clear_input(game)

  if @raylib.is_key_pressed(@raylib.KeyA) ||
    @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.input_steer = game.input_steer - 1
  }

  if @raylib.is_key_pressed(@raylib.KeyD) ||
    @raylib.is_key_pressed(@raylib.KeyRight) {
    game.input_steer = game.input_steer + 1
  }

  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    game.input_tilt = game.input_tilt - 1
  }

  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    game.input_tilt = game.input_tilt + 1
  }

  game.input_steer = clampi(game.input_steer, -1, 1)
  game.input_tilt = clampi(game.input_tilt, -1, 1)

  let j_press = @raylib.is_key_pressed(@raylib.KeyJ)

  game.input_brake_press = j_press
  game.input_stabilize_hold = @raylib.is_key_down(@raylib.KeyK)
  game.input_boost_press = @raylib.is_key_pressed(@raylib.KeySpace)
  game.input_pause_press = @raylib.is_key_pressed(@raylib.KeyP)
  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyR)
  game.input_confirm_press = j_press
}
