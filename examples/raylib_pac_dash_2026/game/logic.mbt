///|
fn build_walls(game : @types.Game) -> Unit {
  for y in 0..<@types.maze_rows {
    for x in 0..<@types.maze_cols {
      let mut wall = false
      if x == 0 ||
        x == @types.maze_cols - 1 ||
        y == 0 ||
        y == @types.maze_rows - 1 {
        wall = true
      }
      if y == @types.maze_rows / 2 && (x == 0 || x == @types.maze_cols - 1) {
        wall = false
      }
      if y % 4 == 2 && x > 2 && x < @types.maze_cols - 3 && x % 2 == 0 {
        wall = true
      }
      if x % 6 == 3 && y > 2 && y < @types.maze_rows - 3 && y % 2 == 1 {
        wall = true
      }

      // Keep center arena and player spawn corridor open.
      if x >= @types.maze_cols / 2 - 2 &&
        x <= @types.maze_cols / 2 + 2 &&
        y >= @types.maze_rows / 2 - 2 &&
        y <= @types.maze_rows / 2 + 2 {
        wall = false
      }
      if y >= @types.maze_rows - 5 &&
        y <= @types.maze_rows - 3 &&
        x >= @types.maze_cols / 2 - 3 &&
        x <= @types.maze_cols / 2 + 3 {
        wall = false
      }

      game.walls[@types.map_index(x, y)] = if wall { 1 } else { 0 }
    }
  }
}

///|
fn reset_pellets(game : @types.Game) -> Unit {
  game.pellets_left = 0
  for y in 0..<@types.maze_rows {
    for x in 0..<@types.maze_cols {
      let i = @types.map_index(x, y)
      if game.walls[i] == 0 {
        game.pellets[i] = 1
        game.pellets_left = game.pellets_left + 1
      } else {
        game.pellets[i] = 0
      }
    }
  }

  // Spawn zones without pellets.
  let spawn_cells : Array[(Int, Int)] = [
    (@types.maze_cols / 2, @types.maze_rows - 4),
    (@types.maze_cols / 2, @types.maze_rows / 2),
    (@types.maze_cols / 2 - 1, @types.maze_rows / 2),
    (@types.maze_cols / 2 + 1, @types.maze_rows / 2),
    (@types.maze_cols / 2, @types.maze_rows / 2 - 1),
  ]
  for spawn_cell in spawn_cells {
    let (x, y) = spawn_cell
    let idx = @types.map_index(x, y)
    if game.pellets[idx] != 0 {
      game.pellets[idx] = 0
      game.pellets_left = game.pellets_left - 1
    }
  }

  let power_spots : Array[(Int, Int)] = [
    (1, 1),
    (@types.maze_cols - 2, 1),
    (1, @types.maze_rows - 2),
    (@types.maze_cols - 2, @types.maze_rows - 2),
  ]
  for power_spot in power_spots {
    let (x, y) = power_spot
    if game.walls[@types.map_index(x, y)] == 0 {
      if game.pellets[@types.map_index(x, y)] == 0 {
        game.pellets_left = game.pellets_left + 1
      }
      game.pellets[@types.map_index(x, y)] = 2
    }
  }
}

///|
fn reset_positions(game : @types.Game) -> Unit {
  game.player_x = @types.maze_cols / 2
  game.player_y = @types.maze_rows - 4
  game.dir_x = 0
  game.dir_y = 0
  game.want_x = 0
  game.want_y = 0

  for ghost in game.ghosts {
    ghost.x = ghost.start_x
    ghost.y = ghost.start_y
    ghost.dir_x = 1
    ghost.dir_y = 0
  }
}

///|
pub fn init_game(game : @types.Game) -> Unit {
  game.ghosts.clear()
  game.ghosts.push(
    @types.Ghost::new(
      @types.maze_cols / 2,
      @types.maze_rows / 2 - 1,
      @types.maze_cols - 2,
      1,
      @raylib.red,
    ),
  )
  game.ghosts.push(
    @types.Ghost::new(
      @types.maze_cols / 2 - 1,
      @types.maze_rows / 2,
      1,
      1,
      @raylib.pink,
    ),
  )
  game.ghosts.push(
    @types.Ghost::new(
      @types.maze_cols / 2 + 1,
      @types.maze_rows / 2,
      @types.maze_cols - 2,
      @types.maze_rows - 2,
      @raylib.skyblue,
    ),
  )
  game.ghosts.push(
    @types.Ghost::new(
      @types.maze_cols / 2,
      @types.maze_rows / 2 + 1,
      1,
      @types.maze_rows - 2,
      @raylib.orange,
    ),
  )

  game.score = 0
  game.lives = 3
  game.frightened_timer = 0.0
  game.phase_timer = 0.0
  game.chase_mode = true
  game.step_timer_player = 0.0
  game.step_timer_ghost = 0.0
  game.game_over = false
  game.win = false

  build_walls(game)
  reset_pellets(game)
  reset_positions(game)
}

///|
fn is_reverse(dx : Int, dy : Int, ox : Int, oy : Int) -> Bool {
  dx == -ox && dy == -oy
}

///|
fn maybe_consume_pellet(game : @types.Game) -> Unit {
  let idx = @types.map_index(game.player_x, game.player_y)
  match game.pellets[idx] {
    1 => {
      game.pellets[idx] = 0
      game.score = game.score + 10
      game.pellets_left = game.pellets_left - 1
    }
    2 => {
      game.pellets[idx] = 0
      game.score = game.score + 50
      game.pellets_left = game.pellets_left - 1
      game.frightened_timer = 8.0
      for ghost in game.ghosts {
        ghost.dir_x = -ghost.dir_x
        ghost.dir_y = -ghost.dir_y
      }
    }
    _ => ()
  }

  if game.pellets_left <= 0 {
    game.game_over = true
    game.win = true
  }
}

///|
fn step_player(game : @types.Game) -> Unit {
  try_set_player_wanted_dir(game)

  let wx = game.player_x + game.want_x
  let wy = game.player_y + game.want_y
  if (game.want_x != 0 || game.want_y != 0) && @types.is_walkable(game, wx, wy) {
    game.dir_x = game.want_x
    game.dir_y = game.want_y
  }

  let nx = game.player_x + game.dir_x
  let ny = game.player_y + game.dir_y
  if @types.is_walkable(game, nx, ny) {
    game.player_x = @types.tunnel_wrap_x(nx)
    game.player_y = ny
  }

  maybe_consume_pellet(game)
}

///|
fn choose_ghost_target(game : @types.Game, ghost : @types.Ghost) -> (Int, Int) {
  if game.frightened_timer > 0.0 {
    let tx = @raylib.get_random_value(1, @types.maze_cols - 2)
    let ty = @raylib.get_random_value(1, @types.maze_rows - 2)
    (tx, ty)
  } else if game.chase_mode {
    (game.player_x, game.player_y)
  } else {
    (ghost.scatter_x, ghost.scatter_y)
  }
}

///|
fn step_ghost(game : @types.Game, ghost : @types.Ghost) -> Unit {
  let (target_x, target_y) = choose_ghost_target(game, ghost)
  let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]

  let mut best_dx = ghost.dir_x
  let mut best_dy = ghost.dir_y
  let mut best_dist = 1_000_000
  let mut found = false

  for dir in dirs {
    let (dx, dy) = dir
    if is_reverse(dx, dy, ghost.dir_x, ghost.dir_y) {
      continue
    }
    let nx = ghost.x + dx
    let ny = ghost.y + dy
    if not(@types.is_walkable(game, nx, ny)) {
      continue
    }
    found = true
    let wrapped_x = @types.tunnel_wrap_x(nx)
    let dist = @types.manhattan_distance(wrapped_x, ny, target_x, target_y)
    if dist < best_dist {
      best_dist = dist
      best_dx = dx
      best_dy = dy
    }
  }

  if not(found) {
    // Dead-end: reverse as fallback.
    best_dx = -ghost.dir_x
    best_dy = -ghost.dir_y
  }

  ghost.dir_x = best_dx
  ghost.dir_y = best_dy
  let nx = ghost.x + ghost.dir_x
  let ny = ghost.y + ghost.dir_y
  if @types.is_walkable(game, nx, ny) {
    ghost.x = @types.tunnel_wrap_x(nx)
    ghost.y = ny
  }
}

///|
fn resolve_collisions(game : @types.Game) -> Unit {
  for ghost in game.ghosts {
    if ghost.x == game.player_x && ghost.y == game.player_y {
      if game.frightened_timer > 0.0 {
        game.score = game.score + 200
        ghost.x = ghost.start_x
        ghost.y = ghost.start_y
        ghost.dir_x = 1
        ghost.dir_y = 0
      } else {
        game.lives = game.lives - 1
        if game.lives <= 0 {
          game.game_over = true
          game.win = false
          return
        }
        reset_positions(game)
        return
      }
    }
  }
}

///|
fn update_phase(game : @types.Game, dt : Float) -> Unit {
  if game.frightened_timer > 0.0 {
    game.frightened_timer = game.frightened_timer - dt
    if game.frightened_timer < 0.0 {
      game.frightened_timer = 0.0
    }
    return
  }

  game.phase_timer = game.phase_timer + dt
  if game.phase_timer >= 7.0 {
    game.phase_timer = 0.0
    game.chase_mode = not(game.chase_mode)
    for ghost in game.ghosts {
      ghost.dir_x = -ghost.dir_x
      ghost.dir_y = -ghost.dir_y
    }
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  if game.game_over {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      init_game(game)
    }
    return
  }

  update_phase(game, dt)
  game.step_timer_player = game.step_timer_player + dt
  game.step_timer_ghost = game.step_timer_ghost + dt

  if game.step_timer_player >= 0.11 {
    game.step_timer_player = game.step_timer_player - 0.11
    step_player(game)
    resolve_collisions(game)
  }

  let ghost_step : Float = if game.frightened_timer > 0.0 {
    (0.18 : Float)
  } else {
    (0.145 : Float)
  }
  if game.step_timer_ghost >= ghost_step {
    game.step_timer_ghost = game.step_timer_ghost - ghost_step
    for ghost in game.ghosts {
      step_ghost(game, ghost)
    }
    resolve_collisions(game)
  }
}
