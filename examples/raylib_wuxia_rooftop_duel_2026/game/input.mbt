///|
fn axis(negative : Bool, positive : Bool) -> Float {
  if negative && not(positive) {
    -1.0
  } else if positive && not(negative) {
    1.0
  } else {
    0.0
  }
}

///|
fn should_start_duel() -> Bool {
  @raylib.is_key_pressed(@raylib.KeyEnter) ||
  @raylib.is_key_pressed(@raylib.KeyJ) ||
  @raylib.is_key_pressed(@raylib.KeyK) ||
  @raylib.is_key_pressed(@raylib.KeySpace)
}

///|
fn update_input(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_new_run(game)
    return
  }

  if game.state == @types.state_title {
    if should_start_duel() {
      start_new_run(game)
    }
    return
  }

  if game.state == @types.state_game_over {
    if should_start_duel() {
      start_new_run(game)
    }
    return
  }

  if game.state == @types.state_paused {
    if @raylib.is_key_pressed(@raylib.KeyP) {
      game.state = @types.state_playing
      @types.set_message(game, "Duel resumed.", 0.8)
    }
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.state_paused
    @types.set_message(game, "Paused.", 10.0)
    return
  }

  let left : Bool = @raylib.is_key_down(@raylib.KeyA) ||
    @raylib.is_key_down(@raylib.KeyLeft)
  let right : Bool = @raylib.is_key_down(@raylib.KeyD) ||
    @raylib.is_key_down(@raylib.KeyRight)
  let up : Bool = @raylib.is_key_down(@raylib.KeyW) ||
    @raylib.is_key_down(@raylib.KeyUp)
  let down : Bool = @raylib.is_key_down(@raylib.KeyS) ||
    @raylib.is_key_down(@raylib.KeyDown)

  game.move_x = axis(left, right)
  game.move_y = axis(up, down)

  if @types.absf(game.move_x) + @types.absf(game.move_y) > 0.01 {
    let facing = @types.normalize(game.move_x, game.move_y)
    game.facing_x = facing.0
    game.facing_y = facing.1
  }

  if @raylib.is_key_pressed(@raylib.KeyJ) {
    ignore(try_player_attack(game, @types.attack_light))
  }

  if @raylib.is_key_pressed(@raylib.KeyK) {
    ignore(try_player_attack(game, @types.attack_heavy))
  }

  if @raylib.is_key_pressed(@raylib.KeyL) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    ignore(trigger_parry_dash(game))
  }
}
