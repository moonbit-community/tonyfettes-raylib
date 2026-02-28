///|
fn Game::reset(self : Game) -> Unit {
  self.score = 0
  self.combo = 0
  self.max_combo = 0
  self.moves_left = base_moves + (self.level - 1) * 2
  self.target_score = base_target + (self.level - 1) * 500
  self.sel_r = -1
  self.sel_c = -1
  self.swap_r1 = -1
  self.hint_r1 = -1
  self.hint_t = 0.0
  self.msg = ""
  self.msg_t = 0.0
  fill_board(self)
  // Ensure no initial matches
  let mut has_match = true
  while has_match {
    has_match = false
    for r in 0..<grid_rows {
      for c in 0..<grid_cols {
        if c + 2 < grid_cols &&
          self.board[idx(r, c)].kind == self.board[idx(r, c + 1)].kind &&
          self.board[idx(r, c)].kind == self.board[idx(r, c + 2)].kind &&
          self.board[idx(r, c)].kind >= 0 {
          self.board[idx(r, c + 2)].kind = @raylib.get_random_value(
            0,
            num_colors - 1,
          )
          has_match = true
        }
        if r + 2 < grid_rows &&
          self.board[idx(r, c)].kind == self.board[idx(r + 1, c)].kind &&
          self.board[idx(r, c)].kind == self.board[idx(r + 2, c)].kind &&
          self.board[idx(r, c)].kind >= 0 {
          self.board[idx(r + 2, c)].kind = @raylib.get_random_value(
            0,
            num_colors - 1,
          )
          has_match = true
        }
      }
    }
  }
  // Ensure at least one valid swap exists
  if not(has_valid_swap(self)) {
    self.reset() // retry
    return
  }
  snap_positions(self)
  self.state = state_play
}

///|
fn fill_board(game : Game) -> Unit {
  for i in 0..<cell_count {
    game.board[i].kind = @raylib.get_random_value(0, num_colors - 1)
    game.board[i].matched = false
    game.board[i].flash_t = 0.0
  }
}

///|
fn snap_positions(game : Game) -> Unit {
  for r in 0..<grid_rows {
    for c in 0..<grid_cols {
      let g = game.board[idx(r, c)]
      let x = cell_x(c)
      let y = cell_y(r)
      g.anim_x = x
      g.anim_y = y
      g.target_x = x
      g.target_y = y
    }
  }
}

///|
fn try_swap(game : Game, r1 : Int, c1 : Int, r2 : Int, c2 : Int) -> Unit {
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
  let i1 = idx(r1, c1)
  let i2 = idx(r2, c2)
  let tmp = game.board[i1].kind
  game.board[i1].kind = game.board[i2].kind
  game.board[i2].kind = tmp
  // Set animation targets (swap visually)
  game.board[i1].anim_x = cell_x(c2)
  game.board[i1].anim_y = cell_y(r2)
  game.board[i1].target_x = cell_x(c1)
  game.board[i1].target_y = cell_y(r1)
  game.board[i2].anim_x = cell_x(c1)
  game.board[i2].anim_y = cell_y(r1)
  game.board[i2].target_x = cell_x(c2)
  game.board[i2].target_y = cell_y(r2)
  game.combo = 0
  game.state = state_swap
}

///|
fn undo_swap(game : Game) -> Unit {
  let i1 = idx(game.swap_r1, game.swap_c1)
  let i2 = idx(game.swap_r2, game.swap_c2)
  let tmp = game.board[i1].kind
  game.board[i1].kind = game.board[i2].kind
  game.board[i2].kind = tmp
  // Animate back
  game.board[i1].anim_x = cell_x(game.swap_c2)
  game.board[i1].anim_y = cell_y(game.swap_r2)
  game.board[i1].target_x = cell_x(game.swap_c1)
  game.board[i1].target_y = cell_y(game.swap_r1)
  game.board[i2].anim_x = cell_x(game.swap_c1)
  game.board[i2].anim_y = cell_y(game.swap_r1)
  game.board[i2].target_x = cell_x(game.swap_c2)
  game.board[i2].target_y = cell_y(game.swap_r2)
}

///|
fn find_matches(game : Game) -> Int {
  let mut count = 0
  // Clear matched flags
  for i in 0..<cell_count {
    game.board[i].matched = false
  }
  // Horizontal matches
  for r in 0..<grid_rows {
    for c = 0; c < grid_cols; {
      let k = game.board[idx(r, c)].kind
      if k < 0 {
        continue c + 1
      }
      let mut end = c + 1
      while end < grid_cols && game.board[idx(r, end)].kind == k {
        end = end + 1
      }
      if end - c >= 3 {
        for j in c..<end {
          game.board[idx(r, j)].matched = true
        }
        count = count + (end - c)
      }
      continue end
    }
  }
  // Vertical matches
  for c in 0..<grid_cols {
    for r = 0; r < grid_rows; {
      let k = game.board[idx(r, c)].kind
      if k < 0 {
        continue r + 1
      }
      let mut end = r + 1
      while end < grid_rows && game.board[idx(end, c)].kind == k {
        end = end + 1
      }
      if end - r >= 3 {
        for j in r..<end {
          game.board[idx(j, c)].matched = true
        }
        count = count + (end - r)
      }
      continue end
    }
  }
  count
}

///|
fn remove_matched(game : Game) -> Int {
  let mut removed = 0
  for i in 0..<cell_count {
    if game.board[i].matched {
      game.board[i].kind = -1
      game.board[i].matched = false
      game.board[i].flash_t = flash_duration
      removed = removed + 1
    }
  }
  removed
}

///|
fn apply_gravity(game : Game) -> Bool {
  let mut fell = false
  for c in 0..<grid_cols {
    // Compact column downward
    let mut write_r = grid_rows - 1
    for r = grid_rows - 1; r >= 0; r = r - 1 {
      if game.board[idx(r, c)].kind >= 0 {
        if write_r != r {
          let wi = idx(write_r, c)
          let ri = idx(r, c)
          game.board[wi].kind = game.board[ri].kind
          game.board[ri].kind = -1
          // Animate from old position
          game.board[wi].anim_x = cell_x(c)
          game.board[wi].anim_y = cell_y(r)
          game.board[wi].target_x = cell_x(c)
          game.board[wi].target_y = cell_y(write_r)
          fell = true
        }
        write_r = write_r - 1
      }
    }
    // Fill empty cells at the top
    for r = write_r; r >= 0; r = r - 1 {
      let i = idx(r, c)
      game.board[i].kind = @raylib.get_random_value(0, num_colors - 1)
      game.board[i].matched = false
      game.board[i].flash_t = 0.0
      // Animate falling from above
      game.board[i].anim_x = cell_x(c)
      game.board[i].anim_y = cell_y(r - (write_r - r) - 1)
      game.board[i].target_x = cell_x(c)
      game.board[i].target_y = cell_y(r)
      fell = true
    }
  }
  fell
}

///|
fn has_valid_swap(game : Game) -> Bool {
  for r in 0..<grid_rows {
    for c in 0..<grid_cols {
      // Try swap right
      if c + 1 < grid_cols {
        swap_kinds(game, r, c, r, c + 1)
        let m = find_matches(game)
        swap_kinds(game, r, c, r, c + 1)
        clear_match_flags(game)
        if m > 0 {
          return true
        }
      }
      // Try swap down
      if r + 1 < grid_rows {
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
fn find_hint(game : Game) -> Unit {
  game.hint_r1 = -1
  for r in 0..<grid_rows {
    for c in 0..<grid_cols {
      if c + 1 < grid_cols {
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
      if r + 1 < grid_rows {
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
fn swap_kinds(game : Game, r1 : Int, c1 : Int, r2 : Int, c2 : Int) -> Unit {
  let i1 = idx(r1, c1)
  let i2 = idx(r2, c2)
  let tmp = game.board[i1].kind
  game.board[i1].kind = game.board[i2].kind
  game.board[i2].kind = tmp
}

///|
fn clear_match_flags(game : Game) -> Unit {
  for i in 0..<cell_count {
    game.board[i].matched = false
  }
}

///|
fn update_animations(game : Game, dt : Float) -> Bool {
  let mut all_done = true
  for i in 0..<cell_count {
    let g = game.board[i]
    let dx = g.target_x - g.anim_x
    let dy = g.target_y - g.anim_y
    let speed = if game.state == state_swap { swap_speed } else { fall_speed }
    if absf(dx) > 0.5 || absf(dy) > 0.5 {
      g.anim_x = lerpf(g.anim_x, g.target_x, clampf(speed * dt, 0.0, 1.0))
      g.anim_y = lerpf(g.anim_y, g.target_y, clampf(speed * dt, 0.0, 1.0))
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
fn update_game_logic(game : Game, dt : Float) -> Unit {
  let done = update_animations(game, dt)
  match game.state {
    s if s == state_swap => {
      if done {
        // Check if swap produced matches
        let m = find_matches(game)
        if m > 0 {
          game.moves_left = game.moves_left - 1
          game.state = state_remove
        } else {
          // Invalid swap: undo
          undo_swap(game)
          game.state = state_swap // animate the undo
          // After undo animation finishes, go back to play
          // We detect this next frame when done=true and no matches
          // Actually we need a flag to know we're in undo mode
          // Simpler: just snap and return to play
          snap_positions(game)
          game.state = state_play
          game.msg = "No match!"
          game.msg_t = 0.8
        }
      }
    }
    s if s == state_remove => {
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
      game.state = state_fall
    }
    s if s == state_fall => {
      if done {
        let m = find_matches(game)
        if m > 0 {
          game.state = state_remove // cascade
        } else {
          // Check win/lose
          if game.score >= game.target_score {
            game.state = state_clear
          } else if game.moves_left <= 0 {
            game.state = state_over
          } else {
            game.state = state_play
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
                  for r2 in 0..<grid_rows {
                    for c2 in 0..<grid_cols {
                      if c2 + 2 < grid_cols &&
                        game.board[idx(r2, c2)].kind ==
                          game.board[idx(r2, c2 + 1)].kind &&
                        game.board[idx(r2, c2)].kind ==
                          game.board[idx(r2, c2 + 2)].kind &&
                        game.board[idx(r2, c2)].kind >= 0 {
                        game.board[idx(r2, c2 + 2)].kind = @raylib.get_random_value(
                          0,
                          num_colors - 1,
                        )
                        has_match = true
                      }
                      if r2 + 2 < grid_rows &&
                        game.board[idx(r2, c2)].kind ==
                          game.board[idx(r2 + 1, c2)].kind &&
                        game.board[idx(r2, c2)].kind ==
                          game.board[idx(r2 + 2, c2)].kind &&
                        game.board[idx(r2, c2)].kind >= 0 {
                        game.board[idx(r2 + 2, c2)].kind = @raylib.get_random_value(
                          0,
                          num_colors - 1,
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
      }
    }
    _ => ()
  }
}
