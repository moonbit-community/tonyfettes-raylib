///|
fn try_set_player_wanted_dir(game : Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) || @raylib.is_key_pressed(@raylib.KeyW) {
    game.want_x = 0
    game.want_y = -1
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.want_x = 0
    game.want_y = 1
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    game.want_x = -1
    game.want_y = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    game.want_x = 1
    game.want_y = 0
  }
}

///|
fn maybe_consume_pellet(game : Game) -> Unit {
  let idx = map_index(game.player_x, game.player_y)
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
      for i = 0; i < game.ghosts.length(); i = i + 1 {
        game.ghosts[i].dir_x = -game.ghosts[i].dir_x
        game.ghosts[i].dir_y = -game.ghosts[i].dir_y
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
fn step_player(game : Game) -> Unit {
  try_set_player_wanted_dir(game)

  let wx = game.player_x + game.want_x
  let wy = game.player_y + game.want_y
  if (game.want_x != 0 || game.want_y != 0) && is_walkable(game, wx, wy) {
    game.dir_x = game.want_x
    game.dir_y = game.want_y
  }

  let nx = game.player_x + game.dir_x
  let ny = game.player_y + game.dir_y
  if is_walkable(game, nx, ny) {
    game.player_x = tunnel_wrap_x(nx)
    game.player_y = ny
  }

  maybe_consume_pellet(game)
}

///|
fn is_reverse(dx : Int, dy : Int, ox : Int, oy : Int) -> Bool {
  dx == -ox && dy == -oy
}

///|
fn manhattan_distance(ax : Int, ay : Int, bx : Int, by : Int) -> Int {
  let dx = (ax - bx).abs()
  let dy = (ay - by).abs()
  dx + dy
}

///|
fn choose_ghost_target(game : Game, ghost : Ghost) -> (Int, Int) {
  if game.frightened_timer > 0.0 {
    let tx = @raylib.get_random_value(1, maze_cols - 2)
    let ty = @raylib.get_random_value(1, maze_rows - 2)
    (tx, ty)
  } else if game.chase_mode {
    (game.player_x, game.player_y)
  } else {
    (ghost.scatter_x, ghost.scatter_y)
  }
}

///|
fn step_ghost(game : Game, ghost : Ghost) -> Unit {
  let (target_x, target_y) = choose_ghost_target(game, ghost)
  let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]

  let mut best_dx = ghost.dir_x
  let mut best_dy = ghost.dir_y
  let mut best_dist = 1_000_000
  let mut found = false

  for i = 0; i < dirs.length(); i = i + 1 {
    let (dx, dy) = dirs[i]
    if is_reverse(dx, dy, ghost.dir_x, ghost.dir_y) {
      continue
    }
    let nx = ghost.x + dx
    let ny = ghost.y + dy
    if not(is_walkable(game, nx, ny)) {
      continue
    }
    found = true
    let wrapped_x = tunnel_wrap_x(nx)
    let dist = manhattan_distance(wrapped_x, ny, target_x, target_y)
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
  if is_walkable(game, nx, ny) {
    ghost.x = tunnel_wrap_x(nx)
    ghost.y = ny
  }
}

///|
fn resolve_collisions(game : Game) -> Unit {
  for i = 0; i < game.ghosts.length(); i = i + 1 {
    let ghost = game.ghosts[i]
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
fn update_phase(game : Game, dt : Float) -> Unit {
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
    for i = 0; i < game.ghosts.length(); i = i + 1 {
      game.ghosts[i].dir_x = -game.ghosts[i].dir_x
      game.ghosts[i].dir_y = -game.ghosts[i].dir_y
    }
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
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

  let ghost_step : Float =
    if game.frightened_timer > 0.0 { (0.18 : Float) } else { (0.145 : Float) }
  if game.step_timer_ghost >= ghost_step {
    game.step_timer_ghost = game.step_timer_ghost - ghost_step
    for i = 0; i < game.ghosts.length(); i = i + 1 {
      step_ghost(game, game.ghosts[i])
    }
    resolve_collisions(game)
  }
}
