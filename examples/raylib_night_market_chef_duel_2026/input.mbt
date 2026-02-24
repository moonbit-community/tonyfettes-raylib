///|
fn clear_frame_input(game : Game) -> Unit {
  game.input.move_x = 0
  game.input.move_y = 0
  game.input.press_j = false
  game.input.press_k = false
  game.input.press_space = false
  game.input.press_pause = false
  game.input.press_restart = false
  game.input.press_start = false
}

///|
fn capture_input(game : Game) -> Unit {
  clear_frame_input(game)

  let left = @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA)
  let right = @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD)
  let up = @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW)
  let down = @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS)

  if left && not(right) {
    game.input.move_x = -1
  } else if right && not(left) {
    game.input.move_x = 1
  }

  if up && not(down) {
    game.input.move_y = -1
  } else if down && not(up) {
    game.input.move_y = 1
  }

  game.input.press_j = @raylib.is_key_pressed(@raylib.KeyJ)
  game.input.press_k = @raylib.is_key_pressed(@raylib.KeyK)
  game.input.press_space = @raylib.is_key_pressed(@raylib.KeySpace)

  game.input.press_pause = @raylib.is_key_pressed(@raylib.KeyP) ||
    @raylib.is_key_pressed(@raylib.KeyEscape)
  game.input.press_restart = @raylib.is_key_pressed(@raylib.KeyR)

  game.input.press_start = game.input.press_j ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
}
