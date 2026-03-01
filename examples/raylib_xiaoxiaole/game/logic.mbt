///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  handle_input(game)
  update_game_logic(game, dt)
}

///|
fn reset(game : @types.Game) -> Unit {
  game.score = 0
  game.combo = 0
  game.max_combo = 0
  game.moves_left = @types.base_moves + (game.level - 1) * 2
  game.target_score = @types.base_target + (game.level - 1) * 500
  game.sel_r = -1
  game.sel_c = -1
  game.swap_r1 = -1
  game.hint_r1 = -1
  game.hint_t = 0.0
  game.msg = ""
  game.msg_t = 0.0
  fill_board(game)
  // Ensure no initial matches
  let mut has_match = true
  while has_match {
    has_match = false
    for r in 0..<@types.grid_rows {
      for c in 0..<@types.grid_cols {
        if c + 2 < @types.grid_cols &&
          game.board[@types.idx(r, c)].kind ==
          game.board[@types.idx(r, c + 1)].kind &&
          game.board[@types.idx(r, c)].kind ==
          game.board[@types.idx(r, c + 2)].kind &&
          not(game.board[@types.idx(r, c)].kind.is_empty()) {
          game.board[@types.idx(r, c + 2)].kind = @types.GemKind::from_int(
            @raylib.get_random_value(0, @types.num_colors - 1),
          )
          has_match = true
        }
        if r + 2 < @types.grid_rows &&
          game.board[@types.idx(r, c)].kind ==
          game.board[@types.idx(r + 1, c)].kind &&
          game.board[@types.idx(r, c)].kind ==
          game.board[@types.idx(r + 2, c)].kind &&
          not(game.board[@types.idx(r, c)].kind.is_empty()) {
          game.board[@types.idx(r + 2, c)].kind = @types.GemKind::from_int(
            @raylib.get_random_value(0, @types.num_colors - 1),
          )
          has_match = true
        }
      }
    }
  }
  // Ensure at least one valid swap exists
  if not(has_valid_swap(game)) {
    reset(game) // retry
    return
  }
  snap_positions(game)
  game.state = @types.GameState::Play
}

///|
fn fill_board(game : @types.Game) -> Unit {
  for i in 0..<@types.cell_count {
    game.board[i].kind = @types.GemKind::from_int(
      @raylib.get_random_value(0, @types.num_colors - 1),
    )
    game.board[i].matched = false
    game.board[i].flash_t = 0.0
  }
}

///|
fn snap_positions(game : @types.Game) -> Unit {
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let g = game.board[@types.idx(r, c)]
      let x = @types.cell_x(c)
      let y = @types.cell_y(r)
      g.anim_x = x
      g.anim_y = y
      g.target_x = x
      g.target_y = y
    }
  }
}

///|
fn try_swap(game : @types.Game, r1 : Int, c1 : Int, r2 : Int, c2 : Int) -> Unit {
  // Check adjacency
  let dr = if r2 > r1 { r2 - r1 } else { r1 - r2 }
  let dc = if c2 > c1 { c2 - c1 } else { c1 - c2 }
  if dr + dc != 1 {
    return
  }
  game.swap_r1 = r1
  game.swap_c1 = c1
  game.swap_r2 = r2
  game.swap_c2 = c2
  // Swap the kinds
  let i1 = @types.idx(r1, c1)
  let i2 = @types.idx(r2, c2)
  let tmp = game.board[i1].kind
  game.board[i1].kind = game.board[i2].kind
  game.board[i2].kind = tmp
  // Set animation targets (swap visually)
  game.board[i1].anim_x = @types.cell_x(c2)
  game.board[i1].anim_y = @types.cell_y(r2)
  game.board[i1].target_x = @types.cell_x(c1)
  game.board[i1].target_y = @types.cell_y(r1)
  game.board[i2].anim_x = @types.cell_x(c1)
  game.board[i2].anim_y = @types.cell_y(r1)
  game.board[i2].target_x = @types.cell_x(c2)
  game.board[i2].target_y = @types.cell_y(r2)
  game.combo = 0
  game.state = @types.GameState::Swap
}

///|
fn undo_swap(game : @types.Game) -> Unit {
  let i1 = @types.idx(game.swap_r1, game.swap_c1)
  let i2 = @types.idx(game.swap_r2, game.swap_c2)
  let tmp = game.board[i1].kind
  game.board[i1].kind = game.board[i2].kind
  game.board[i2].kind = tmp
  // Animate back
  game.board[i1].anim_x = @types.cell_x(game.swap_c2)
  game.board[i1].anim_y = @types.cell_y(game.swap_r2)
  game.board[i1].target_x = @types.cell_x(game.swap_c1)
  game.board[i1].target_y = @types.cell_y(game.swap_r1)
  game.board[i2].anim_x = @types.cell_x(game.swap_c1)
  game.board[i2].anim_y = @types.cell_y(game.swap_r1)
  game.board[i2].target_x = @types.cell_x(game.swap_c2)
  game.board[i2].target_y = @types.cell_y(game.swap_r2)
}

///|
fn find_matches(game : @types.Game) -> Int {
  let mut count = 0
  // Clear matched flags
  for i in 0..<@types.cell_count {
    game.board[i].matched = false
  }
  // Horizontal matches
  for r in 0..<@types.grid_rows {
    for c = 0; c < @types.grid_cols; {
      let k = game.board[@types.idx(r, c)].kind
      if k.is_empty() {
        continue c + 1
      }
      let mut end = c + 1
      while end < @types.grid_cols && game.board[@types.idx(r, end)].kind == k {
        end = end + 1
      }
      if end - c >= 3 {
        for j in c..<end {
          game.board[@types.idx(r, j)].matched = true
        }
        count = count + (end - c)
      }
      continue end
    }
  }
  // Vertical matches
  for c in 0..<@types.grid_cols {
    for r = 0; r < @types.grid_rows; {
      let k = game.board[@types.idx(r, c)].kind
      if k.is_empty() {
        continue r + 1
      }
      let mut end = r + 1
      while end < @types.grid_rows && game.board[@types.idx(end, c)].kind == k {
        end = end + 1
      }
      if end - r >= 3 {
        for j in r..<end {
          game.board[@types.idx(j, c)].matched = true
        }
        count = count + (end - r)
      }
      continue end
    }
  }
  count
}

///|
fn remove_matched(game : @types.Game) -> Int {
  let mut removed = 0
  for i in 0..<@types.cell_count {
    if game.board[i].matched {
      game.board[i].kind = @types.GemKind::Empty
      game.board[i].matched = false
      game.board[i].flash_t = @types.flash_duration
      removed = removed + 1
    }
  }
  removed
}

///|
fn apply_gravity(game : @types.Game) -> Bool {
  let mut fell = false
  for c in 0..<@types.grid_cols {
    // Compact column downward
    let mut write_r = @types.grid_rows - 1
    for r = @types.grid_rows - 1; r >= 0; r = r - 1 {
      if not(game.board[@types.idx(r, c)].kind.is_empty()) {
        if write_r != r {
          let wi = @types.idx(write_r, c)
          let ri = @types.idx(r, c)
          game.board[wi].kind = game.board[ri].kind
          game.board[ri].kind = @types.GemKind::Empty
          // Animate from old position
          game.board[wi].anim_x = @types.cell_x(c)
          game.board[wi].anim_y = @types.cell_y(r)
          game.board[wi].target_x = @types.cell_x(c)
          game.board[wi].target_y = @types.cell_y(write_r)
          fell = true
        }
        write_r = write_r - 1
      }
    }
    // Fill empty cells at the top
    for r = write_r; r >= 0; r = r - 1 {
      let i = @types.idx(r, c)
      game.board[i].kind = @types.GemKind::from_int(
        @raylib.get_random_value(0, @types.num_colors - 1),
      )
      game.board[i].matched = false
      game.board[i].flash_t = 0.0
      // Animate falling from above
      game.board[i].anim_x = @types.cell_x(c)
      game.board[i].anim_y = @types.cell_y(r - (write_r - r) - 1)
      game.board[i].target_x = @types.cell_x(c)
      game.board[i].target_y = @types.cell_y(r)
      fell = true
    }
  }
  fell
}

///|
fn has_valid_swap(game : @types.Game) -> Bool {
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      // Try swap right
      if c + 1 < @types.grid_cols {
        swap_kinds(game, r, c, r, c + 1)
        let m = find_matches(game)
        swap_kinds(game, r, c, r, c + 1)
        clear_match_flags(game)
        if m > 0 {
          return true
        }
      }
      // Try swap down
      if r + 1 < @types.grid_rows {
        swap_kinds(game, r, c, r + 1, c)
        let m = find_matches(game)
        swap_kinds(game, r, c, r + 1, c)
        clear_match_flags(game)
        if m > 0 {
          return true
        }
      }
    }
  }
  false
}

///|
fn find_hint(game : @types.Game) -> Unit {
  game.hint_r1 = -1
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      if c + 1 < @types.grid_cols {
        swap_kinds(game, r, c, r, c + 1)
        let m = find_matches(game)
        swap_kinds(game, r, c, r, c + 1)
        clear_match_flags(game)
        if m > 0 {
          game.hint_r1 = r
          game.hint_c1 = c
          game.hint_r2 = r
          game.hint_c2 = c + 1
          return
        }
      }
      if r + 1 < @types.grid_rows {
        swap_kinds(game, r, c, r + 1, c)
        let m = find_matches(game)
        swap_kinds(game, r, c, r + 1, c)
        clear_match_flags(game)
        if m > 0 {
          game.hint_r1 = r
          game.hint_c1 = c
          game.hint_r2 = r + 1
          game.hint_c2 = c
          return
        }
      }
    }
  }
}

///|
fn swap_kinds(
  game : @types.Game,
  r1 : Int,
  c1 : Int,
  r2 : Int,
  c2 : Int,
) -> Unit {
  let i1 = @types.idx(r1, c1)
  let i2 = @types.idx(r2, c2)
  let tmp = game.board[i1].kind
  game.board[i1].kind = game.board[i2].kind
  game.board[i2].kind = tmp
}

///|
fn clear_match_flags(game : @types.Game) -> Unit {
  for i in 0..<@types.cell_count {
    game.board[i].matched = false
  }
}

///|
fn update_animations(game : @types.Game, dt : Float) -> Bool {
  let mut all_done = true
  for i in 0..<@types.cell_count {
    let g = game.board[i]
    let dx = g.target_x - g.anim_x
    let dy = g.target_y - g.anim_y
    let speed = if game.state == @types.GameState::Swap {
      @types.swap_speed
    } else {
      @types.fall_speed
    }
    if @types.absf(dx) > 0.5 || @types.absf(dy) > 0.5 {
      g.anim_x = @types.lerpf(
        g.anim_x,
        g.target_x,
        @types.clampf(speed * dt, 0.0, 1.0),
      )
      g.anim_y = @types.lerpf(
        g.anim_y,
        g.target_y,
        @types.clampf(speed * dt, 0.0, 1.0),
      )
      all_done = false
    } else {
      g.anim_x = g.target_x
      g.anim_y = g.target_y
    }
    // Flash timer
    if g.flash_t > 0.0 {
      g.flash_t = g.flash_t - dt
    }
  }
  // Message timer
  if game.msg_t > 0.0 {
    game.msg_t = game.msg_t - dt
    if game.msg_t <= 0.0 {
      game.msg = ""
    }
  }
  // Hint timer
  game.hint_t = game.hint_t + dt
  all_done
}

///|
fn update_game_logic(game : @types.Game, dt : Float) -> Unit {
  let done = update_animations(game, dt)
  match game.state {
    Swap =>
      if done {
        // Check if swap produced matches
        let m = find_matches(game)
        if m > 0 {
          game.moves_left = game.moves_left - 1
          game.state = @types.GameState::Remove
        } else {
          // Invalid swap: undo
          undo_swap(game)
          game.state = @types.GameState::Swap // animate the undo
          // After undo animation finishes, go back to play
          // We detect this next frame when done=true and no matches
          // Actually we need a flag to know we're in undo mode
          // Simpler: just snap and return to play
          snap_positions(game)
          game.state = @types.GameState::Play
          game.msg = "No match!"
          game.msg_t = 0.8
        }
      }
    Remove => {
      game.combo = game.combo + 1
      if game.combo > game.max_combo {
        game.max_combo = game.combo
      }
      let removed = remove_matched(game)
      let points = removed * 10 * game.combo
      game.score = game.score + points
      if game.score > game.best_score {
        game.best_score = game.score
      }
      if game.combo > 1 {
        game.msg = "Combo x\{game.combo}!"
        game.msg_t = 1.2
      }
      ignore(apply_gravity(game))
      game.state = @types.GameState::Fall
    }
    Fall =>
      if done {
        let m = find_matches(game)
        if m > 0 {
          game.state = @types.GameState::Remove // cascade
          // Check win/lose
        } else if game.score >= game.target_score {
          game.state = @types.GameState::Clear
        } else if game.moves_left <= 0 {
          game.state = @types.GameState::Over
        } else {
          game.state = @types.GameState::Play
          game.combo = 0
          // Find hint
          find_hint(game)
          game.hint_t = 0.0
          // Check if any valid swaps exist; shuffle until valid
          if not(has_valid_swap(game)) {
            let mut attempts = 0
            while attempts < 100 {
              fill_board(game)
              // Remove any initial matches
              let mut has_match = true
              while has_match {
                has_match = false
                for r2 in 0..<@types.grid_rows {
                  for c2 in 0..<@types.grid_cols {
                    if c2 + 2 < @types.grid_cols &&
                      game.board[@types.idx(r2, c2)].kind ==
                      game.board[@types.idx(r2, c2 + 1)].kind &&
                      game.board[@types.idx(r2, c2)].kind ==
                      game.board[@types.idx(r2, c2 + 2)].kind &&
                      not(game.board[@types.idx(r2, c2)].kind.is_empty()) {
                      game.board[@types.idx(r2, c2 + 2)].kind = @types.GemKind::from_int(
                        @raylib.get_random_value(0, @types.num_colors - 1),
                      )
                      has_match = true
                    }
                    if r2 + 2 < @types.grid_rows &&
                      game.board[@types.idx(r2, c2)].kind ==
                      game.board[@types.idx(r2 + 1, c2)].kind &&
                      game.board[@types.idx(r2, c2)].kind ==
                      game.board[@types.idx(r2 + 2, c2)].kind &&
                      not(game.board[@types.idx(r2, c2)].kind.is_empty()) {
                      game.board[@types.idx(r2 + 2, c2)].kind = @types.GemKind::from_int(
                        @raylib.get_random_value(0, @types.num_colors - 1),
                      )
                      has_match = true
                    }
                  }
                }
              }
              if has_valid_swap(game) {
                break
              }
              attempts = attempts + 1
            }
            snap_positions(game)
            game.msg = "Shuffled!"
            game.msg_t = 1.5
          }
        }
      }
    _ => ()
  }
}
