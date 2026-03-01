///|
fn handle_input(game : @types.Game) -> Unit {
  match game.state {
    s if s == @types.state_title => handle_title_input(game)
    s if s == @types.state_play => handle_play_input(game)
    s if s == @types.state_won => handle_won_input(game)
    s if s == @types.state_over => handle_over_input(game)
    _ => ()
  }
}

///|
fn handle_title_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    reset(game)
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let cx = @types.screen_w / 2
    let bx = cx - 120
    let by = 430
    let bw = 240
    let bh = 60
    if mx >= bx && mx <= bx + bw && my >= by && my <= by + bh {
      reset(game)
    }
  }
}

///|
fn handle_play_input(game : @types.Game) -> Unit {
  if game.animating {
    return
  }
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
  if @raylib.is_key_pressed(@raylib.KeyZ) ||
    @raylib.is_key_pressed(@raylib.KeyU) {
    undo(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    reset(game)
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let btn_y = 100
    let btn_h = 40
    let btn_w = 110
    let ngx = @types.screen_w - btn_w - @types.board_left
    if mx >= ngx && mx <= ngx + btn_w && my >= btn_y && my <= btn_y + btn_h {
      reset(game)
    }
    let ux = @types.screen_w - btn_w * 2 - @types.board_left - 8
    if mx >= ux && mx <= ux + btn_w && my >= btn_y && my <= btn_y + btn_h {
      undo(game)
    }
  }
}

///|
fn handle_won_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.keep_playing = true
    game.state = @types.state_play
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    reset(game)
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let cx = @types.board_left + @types.board_size / 2
    let cy = @types.board_top + @types.board_size / 2
    let btn_text = "Keep Going"
    let bs = 24
    let bw = @raylib.measure_text(btn_text, bs) + 40
    let bh = 48
    let bx = cx - bw / 2
    let by = cy + 10
    if mx >= bx && mx <= bx + bw && my >= by && my <= by + bh {
      game.keep_playing = true
      game.state = @types.state_play
    }
  }
}

///|
fn handle_over_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    reset(game)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyZ) ||
    @raylib.is_key_pressed(@raylib.KeyU) {
    undo(game)
  }
}
