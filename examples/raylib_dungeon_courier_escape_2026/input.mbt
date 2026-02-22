///|
fn clear_input(game : Game) -> Unit {
  game.input.move_x = 0.0
  game.input.move_y = 0.0
  game.input.interact_press = false
  game.input.smoke_press = false
  game.input.sprint_hold = false
  game.input.start_press = false
  game.input.retry_press = false
}

///|
fn update_input(game : Game) -> Unit {
  clear_input(game)

  let mut ix : Float = 0.0
  let mut iy : Float = 0.0

  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    ix = ix - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
    ix = ix + 1.0
  }
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    iy = iy - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    iy = iy + 1.0
  }

  let len2 = ix * ix + iy * iy
  if len2 > 1.0 {
    let inv : Float = (1.0 : Float) / sqrtf(len2)
    ix = ix * inv
    iy = iy * inv
  }

  game.input.move_x = ix
  game.input.move_y = iy

  game.input.interact_press = @raylib.is_key_pressed(@raylib.KeyJ)
  game.input.smoke_press = @raylib.is_key_pressed(@raylib.KeyK)
  game.input.sprint_hold = @raylib.is_key_down(@raylib.KeySpace)

  game.input.start_press = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyJ)

  game.input.retry_press = @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
}
