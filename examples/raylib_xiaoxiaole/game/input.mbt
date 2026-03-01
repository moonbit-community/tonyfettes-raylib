///|
fn handle_input(game : @types.Game) -> Unit {
  match game.state {
    Title => handle_title_input(game)
    Play => handle_play_input(game)
    Over | Clear => handle_end_input(game)
    _ => ()
  }
}

///|
fn handle_title_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    game.level = 1
    game.best_score = 0
    reset(game)
  }
}

///|
fn handle_play_input(game : @types.Game) -> Unit {
  // Keyboard cursor
  if @raylib.is_key_pressed(@raylib.KeyH) {
    find_hint(game)
    game.hint_t = 2.5 // show immediately (hint renders when hint_t > 2.0)
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    reset(game)
    return
  }
  // Mouse/touch click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    // Check if click is on board
    let col = (mx - @types.board_left) / (@types.cell_px + @types.cell_gap)
    let row = (my - @types.board_top) / (@types.cell_px + @types.cell_gap)
    if col >= 0 && col < @types.grid_cols && row >= 0 && row < @types.grid_rows {
      // Check bounds more precisely
      let cx = @types.board_left + col * (@types.cell_px + @types.cell_gap)
      let cy = @types.board_top + row * (@types.cell_px + @types.cell_gap)
      if mx >= cx &&
        mx < cx + @types.cell_px &&
        my >= cy &&
        my < cy + @types.cell_px {
        if game.sel_r < 0 {
          // First selection
          game.sel_r = row
          game.sel_c = col
        } else if game.sel_r == row && game.sel_c == col {
          // Deselect
          game.sel_r = -1
          game.sel_c = -1
        } else {
          // Try swap
          let dr = if row > game.sel_r {
            row - game.sel_r
          } else {
            game.sel_r - row
          }
          let dc = if col > game.sel_c {
            col - game.sel_c
          } else {
            game.sel_c - col
          }
          if dr + dc == 1 {
            try_swap(game, game.sel_r, game.sel_c, row, col)
          }
          game.sel_r = -1
          game.sel_c = -1
        }
      }
    }
  }
}

///|
fn handle_end_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.state == @types.GameState::Clear {
      game.level = game.level + 1
    }
    reset(game)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.level = 1
    reset(game)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.GameState::Title
  }
}
