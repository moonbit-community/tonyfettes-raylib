///|
fn update_title_input(game : @types.Game) -> Unit {
  if game.touch_count > 0 {
    game.touch_mode = true
  }

  let mut start = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let start_rect = @types.start_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      start_rect.0,
      start_rect.1,
      start_rect.2,
      start_rect.3,
    ) {
    start = true
  }

  if start {
    restart_run(game)
  }
}

///|
fn update_play_input(game : @types.Game) -> Unit {
  if game.touch_count > 0 {
    game.touch_mode = true
  }

  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    move_cursor(game, -1, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    move_cursor(game, 1, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    move_cursor(game, 0, -1)
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    move_cursor(game, 0, 1)
  }

  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    select_or_swap(game, game.cursor_x, game.cursor_y)
  }

  if @raylib.is_key_pressed(@raylib.KeyH) {
    use_hint(game)
  }

  if @raylib.is_key_pressed(@raylib.KeyJ) {
    try_manual_shuffle(game)
  }

  if @raylib.is_key_pressed(@raylib.KeyR) {
    restart_level(game)
    return
  }

  let tap = @types.pointer_to_cell(
    game.mouse_x,
    game.mouse_y,
    game.mouse_press,
    game.touch_count,
  )
  if tap.0 && game.touch_cd <= 0.0 {
    game.touch_cd = @types.touch_action_cooldown
    select_or_swap(game, tap.1, tap.2)
    return
  }

  if game.touch_cd > 0.0 {
    return
  }

  let hint = @types.hint_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      hint.0,
      hint.1,
      hint.2,
      hint.3,
    ) {
    game.touch_cd = @types.touch_action_cooldown
    use_hint(game)
    return
  }

  let shuffle = @types.shuffle_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      shuffle.0,
      shuffle.1,
      shuffle.2,
      shuffle.3,
    ) {
    game.touch_cd = @types.touch_action_cooldown
    try_manual_shuffle(game)
    return
  }

  let restart = @types.restart_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      restart.0,
      restart.1,
      restart.2,
      restart.3,
    ) {
    game.touch_cd = @types.touch_action_cooldown
    restart_level(game)
  }
}

///|
fn update_result_input(game : @types.Game) -> Unit {
  if game.touch_count > 0 {
    game.touch_mode = true
  }

  let mut action = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let rect = @types.result_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      rect.0,
      rect.1,
      rect.2,
      rect.3,
    ) {
    action = true
  }

  if game.state == @types.state_level_clear {
    if action {
      start_next_level(game)
      return
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      restart_level(game)
      return
    }
  } else if action {
    restart_run(game)
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyT) {
    game.state = @types.state_title
    clear_selection(game)
  }
}
