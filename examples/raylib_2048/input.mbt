///|
fn handle_input(game : Game) -> Unit {
  match game.state {
    s if s == state_title => handle_title_input(game)
    s if s == state_play => handle_play_input(game)
    s if s == state_won => handle_won_input(game)
    s if s == state_over => handle_over_input(game)
    _ => ()
  }
}

///|
fn handle_title_input(game : Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.reset()
    return
  }
  // Check mouse click on start button
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let cx = screen_w / 2
    let bx = cx - 120
    let by = 430
    let bw = 240
    let bh = 60
    if mx >= bx && mx <= bx + bw && my >= by && my <= by + bh {
      game.reset()
    }
  }
}

///|
fn handle_play_input(game : Game) -> Unit {
  if game.animating {
    return
  }
  // Movement
  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    ignore(try_move(game, 0, -1))
  } else if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    ignore(try_move(game, 0, 1))
  } else if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    ignore(try_move(game, -1, 0))
  } else if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    ignore(try_move(game, 1, 0))
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) ||
    @raylib.is_key_pressed(@raylib.KeyU) {
    game.undo()
  }
  // Restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.reset()
  }
  // Mouse click on buttons
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let btn_y = 100
    let btn_h = 40
    let btn_w = 110
    // New Game button
    let ngx = screen_w - btn_w - board_left
    if mx >= ngx && mx <= ngx + btn_w && my >= btn_y && my <= btn_y + btn_h {
      game.reset()
    }
    // Undo button
    let ux = screen_w - btn_w * 2 - board_left - 8
    if mx >= ux && mx <= ux + btn_w && my >= btn_y && my <= btn_y + btn_h {
      game.undo()
    }
  }
}

///|
fn handle_won_input(game : Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.keep_playing = true
    game.state = state_play
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.reset()
    return
  }
  // Click Keep Going button
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let cx = board_left + board_size / 2
    let cy = board_top + board_size / 2
    let btn_text = "Keep Going"
    let bs = 24
    let bw = @raylib.measure_text(btn_text, bs) + 40
    let bh = 48
    let bx = cx - bw / 2
    let by = cy + 10
    if mx >= bx && mx <= bx + bw && my >= by && my <= by + bh {
      game.keep_playing = true
      game.state = state_play
    }
  }
}

///|
fn handle_over_input(game : Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.reset()
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyZ) ||
    @raylib.is_key_pressed(@raylib.KeyU) {
    game.undo()
  }
}
