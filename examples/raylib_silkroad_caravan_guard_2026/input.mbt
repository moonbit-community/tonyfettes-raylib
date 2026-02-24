///|
fn clear_input(game : Game) -> Unit {
  game.input_x = 0.0
  game.input_y = 0.0
  game.input_shoot_hold = false
  game.input_shoot_press = false
  game.input_repair_press = false
  game.input_roll_press = false
  game.input_pause_press = false
  game.input_restart_press = false
  game.input_confirm_press = false
}

///|
fn normalize_move(game : Game) -> Unit {
  let len2 = game.input_x * game.input_x + game.input_y * game.input_y
  if len2 > 1.0 {
    let inv : Float = 1.0 / sqrtf(len2)
    game.input_x = game.input_x * inv
    game.input_y = game.input_y * inv
  }
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

  normalize_move(game)

  game.input_shoot_hold = @raylib.is_key_down(@raylib.KeyJ)
  game.input_shoot_press = @raylib.is_key_pressed(@raylib.KeyJ)
  game.input_repair_press = @raylib.is_key_pressed(@raylib.KeyK)
  game.input_roll_press = @raylib.is_key_pressed(@raylib.KeySpace)
  game.input_pause_press = @raylib.is_key_pressed(@raylib.KeyP)
  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyR)

  game.input_confirm_press = game.input_shoot_press ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
}
