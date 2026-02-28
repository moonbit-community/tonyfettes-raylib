///|
fn cell_screen_x(col : Int) -> Float {
  Float::from_int(board_left + board_padding + col * (cell_size + cell_gap))
}

///|
fn cell_screen_y(row : Int) -> Float {
  Float::from_int(board_top + board_padding + row * (cell_size + cell_gap))
}

///|
fn Game::reset(self : Game) -> Unit {
  for i in 0..<cell_count {
    self.tiles[i].value = 0
    self.tiles[i].scale = 1.0
    self.tiles[i].is_new = false
    self.tiles[i].is_merged = false
  }
  self.score = 0
  self.can_undo = false
  self.animating = false
  self.keep_playing = false
  self.msg = ""
  self.msg_t = 0.0
  spawn_tile(self)
  spawn_tile(self)
  snap_positions(self)
  self.state = state_play
}

///|
fn snap_positions(game : Game) -> Unit {
  for r in 0..<grid_size {
    for c in 0..<grid_size {
      let idx = r * grid_size + c
      let sx = cell_screen_x(c)
      let sy = cell_screen_y(r)
      game.tiles[idx].anim_x = sx
      game.tiles[idx].anim_y = sy
      game.tiles[idx].target_x = sx
      game.tiles[idx].target_y = sy
    }
  }
}

///|
fn spawn_tile(game : Game) -> Unit {
  let empty : Array[Int] = []
  for i in 0..<cell_count {
    if game.tiles[i].value == 0 {
      empty.push(i)
    }
  }
  if empty.length() == 0 {
    return
  }
  let pick = @raylib.get_random_value(0, empty.length() - 1)
  let idx = empty[pick]
  let val = if @raylib.get_random_value(0, 9) == 0 { 4 } else { 2 }
  game.tiles[idx].value = val
  game.tiles[idx].is_new = true
  game.tiles[idx].scale = 0.0
  let r = idx / grid_size
  let c = idx % grid_size
  game.tiles[idx].anim_x = cell_screen_x(c)
  game.tiles[idx].anim_y = cell_screen_y(r)
  game.tiles[idx].target_x = cell_screen_x(c)
  game.tiles[idx].target_y = cell_screen_y(r)
}

///|
fn save_state(game : Game) -> Unit {
  for i in 0..<cell_count {
    game.prev_values[i] = game.tiles[i].value
  }
  game.prev_score = game.score
  game.can_undo = true
}

///|
fn Game::undo(self : Game) -> Unit {
  if not(self.can_undo) {
    return
  }
  for i in 0..<cell_count {
    self.tiles[i].value = self.prev_values[i]
    self.tiles[i].is_new = false
    self.tiles[i].is_merged = false
    self.tiles[i].scale = 1.0
  }
  self.score = self.prev_score
  self.can_undo = false
  snap_positions(self)
  if self.state == state_over {
    self.state = state_play
  }
  self.msg = "Undo"
  self.msg_t = 1.5
}

///|
fn try_move(game : Game, dr : Int, dc : Int) -> Bool {
  // Save old undo state in case move is a no-op
  let old_can_undo = game.can_undo
  let old_prev_score = game.prev_score
  let old_prev : Array[Int] = Array::make(cell_count, 0)
  for i in 0..<cell_count {
    old_prev[i] = game.prev_values[i]
  }
  save_state(game)
  let mut moved = false
  let mut merge_score = 0
  // Clear merge flags
  for i in 0..<cell_count {
    game.tiles[i].is_merged = false
    game.tiles[i].is_new = false
  }
  // Process lines based on direction
  if dc != 0 {
    // Horizontal move
    for r in 0..<grid_size {
      let start = if dc > 0 { grid_size - 1 } else { 0 }
      let step = if dc > 0 { -1 } else { 1 }
      for i = start; i >= 0 && i < grid_size; i = i + step {
        let idx = r * grid_size + i
        if game.tiles[idx].value == 0 {
          continue i + step
        }
        let mut target_c = i
        let mut j = i + dc
        while j >= 0 && j < grid_size {
          let jidx = r * grid_size + j
          if game.tiles[jidx].value == 0 {
            target_c = j
            j = j + dc
          } else if game.tiles[jidx].value == game.tiles[idx].value &&
            not(game.tiles[jidx].is_merged) {
            target_c = j
            break
          } else {
            break
          }
        }
        if target_c != i {
          let tidx = r * grid_size + target_c
          if game.tiles[tidx].value == game.tiles[idx].value &&
            game.tiles[tidx].value != 0 {
            // Merge
            game.tiles[tidx].value = game.tiles[tidx].value * 2
            game.tiles[tidx].is_merged = true
            merge_score = merge_score + game.tiles[tidx].value
            game.tiles[idx].value = 0
          } else {
            // Slide
            game.tiles[tidx].value = game.tiles[idx].value
            game.tiles[idx].value = 0
          }
          // Set animation: tile slides from old position to new
          game.tiles[tidx].anim_x = cell_screen_x(i)
          game.tiles[tidx].anim_y = cell_screen_y(r)
          game.tiles[tidx].target_x = cell_screen_x(target_c)
          game.tiles[tidx].target_y = cell_screen_y(r)
          moved = true
        }
      }
    }
  } else {
    // Vertical move
    for c in 0..<grid_size {
      let start = if dr > 0 { grid_size - 1 } else { 0 }
      let step = if dr > 0 { -1 } else { 1 }
      for i = start; i >= 0 && i < grid_size; i = i + step {
        let idx = i * grid_size + c
        if game.tiles[idx].value == 0 {
          continue i + step
        }
        let mut target_r = i
        let mut j = i + dr
        while j >= 0 && j < grid_size {
          let jidx = j * grid_size + c
          if game.tiles[jidx].value == 0 {
            target_r = j
            j = j + dr
          } else if game.tiles[jidx].value == game.tiles[idx].value &&
            not(game.tiles[jidx].is_merged) {
            target_r = j
            break
          } else {
            break
          }
        }
        if target_r != i {
          let tidx = target_r * grid_size + c
          if game.tiles[tidx].value == game.tiles[idx].value &&
            game.tiles[tidx].value != 0 {
            game.tiles[tidx].value = game.tiles[tidx].value * 2
            game.tiles[tidx].is_merged = true
            merge_score = merge_score + game.tiles[tidx].value
            game.tiles[idx].value = 0
          } else {
            game.tiles[tidx].value = game.tiles[idx].value
            game.tiles[idx].value = 0
          }
          game.tiles[tidx].anim_x = cell_screen_x(c)
          game.tiles[tidx].anim_y = cell_screen_y(i)
          game.tiles[tidx].target_x = cell_screen_x(c)
          game.tiles[tidx].target_y = cell_screen_y(target_r)
          moved = true
        }
      }
    }
  }
  if not(moved) {
    // Restore previous undo state — no-op shouldn't clobber undo history
    game.can_undo = old_can_undo
    game.prev_score = old_prev_score
    for i in 0..<cell_count {
      game.prev_values[i] = old_prev[i]
    }
    return false
  }
  // moved == true from here
  {
    game.score = game.score + merge_score
    if game.score > game.best_score {
      game.best_score = game.score
    }
    // Set pop animation scale for merged tiles
    for i in 0..<cell_count {
      if game.tiles[i].is_merged {
        game.tiles[i].scale = anim_pop_scale
      }
    }
    game.animating = true
    spawn_tile(game)
    // Check win
    if not(game.keep_playing) {
      for i in 0..<cell_count {
        if game.tiles[i].value >= 2048 {
          game.state = state_won
          break
        }
      }
    }
    // Check game over (don't overwrite win state)
    if not(has_moves(game)) && game.state != state_won {
      game.state = state_over
    }
  }
  true
}

///|
fn has_moves(game : Game) -> Bool {
  for i in 0..<cell_count {
    if game.tiles[i].value == 0 {
      return true
    }
  }
  for r in 0..<grid_size {
    for c in 0..<grid_size {
      let v = game.tiles[r * grid_size + c].value
      if c + 1 < grid_size && game.tiles[r * grid_size + c + 1].value == v {
        return true
      }
      if r + 1 < grid_size && game.tiles[(r + 1) * grid_size + c].value == v {
        return true
      }
    }
  }
  false
}

///|
fn update_animations(game : Game, dt : Float) -> Unit {
  let mut all_done = true
  for i in 0..<cell_count {
    let tile = game.tiles[i]
    // Slide animation
    let dx = tile.target_x - tile.anim_x
    let dy = tile.target_y - tile.anim_y
    if absf(dx) > 0.5 || absf(dy) > 0.5 {
      tile.anim_x = lerpf(
        tile.anim_x,
        tile.target_x,
        clampf(anim_slide_speed * dt, 0.0, 1.0),
      )
      tile.anim_y = lerpf(
        tile.anim_y,
        tile.target_y,
        clampf(anim_slide_speed * dt, 0.0, 1.0),
      )
      all_done = false
    } else {
      tile.anim_x = tile.target_x
      tile.anim_y = tile.target_y
    }
    // Pop/scale animation
    if tile.is_new {
      tile.scale = lerpf(tile.scale, 1.0, clampf(anim_pop_speed * dt, 0.0, 1.0))
      if absf(tile.scale - 1.0) < 0.02 {
        tile.scale = 1.0
        tile.is_new = false
      } else {
        all_done = false
      }
    }
    if tile.is_merged {
      tile.scale = lerpf(tile.scale, 1.0, clampf(anim_pop_speed * dt, 0.0, 1.0))
      if absf(tile.scale - 1.0) < 0.02 {
        tile.scale = 1.0
        tile.is_merged = false
      } else {
        all_done = false
      }
    }
  }
  game.animating = not(all_done)
  // Message timer
  if game.msg_t > 0.0 {
    game.msg_t = game.msg_t - dt
    if game.msg_t <= 0.0 {
      game.msg = ""
    }
  }
}
