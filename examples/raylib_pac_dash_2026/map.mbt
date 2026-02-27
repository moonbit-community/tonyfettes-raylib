///|
fn map_index(x : Int, y : Int) -> Int {
  y * maze_cols + x
}

///|
fn in_map(x : Int, y : Int) -> Bool {
  x >= 0 && x < maze_cols && y >= 0 && y < maze_rows
}

///|
fn tunnel_wrap_x(x : Int) -> Int {
  if x < 0 {
    maze_cols - 1
  } else if x >= maze_cols {
    0
  } else {
    x
  }
}

///|
fn build_walls(game : Game) -> Unit {
  for y = 0; y < maze_rows; y = y + 1 {
    for x = 0; x < maze_cols; x = x + 1 {
      let mut wall = false
      if x == 0 || x == maze_cols - 1 || y == 0 || y == maze_rows - 1 {
        wall = true
      }
      if y == maze_rows / 2 && (x == 0 || x == maze_cols - 1) {
        wall = false
      }
      if y % 4 == 2 && x > 2 && x < maze_cols - 3 && x % 2 == 0 {
        wall = true
      }
      if x % 6 == 3 && y > 2 && y < maze_rows - 3 && y % 2 == 1 {
        wall = true
      }

      // Keep center arena and player spawn corridor open.
      if x >= maze_cols / 2 - 2 &&
        x <= maze_cols / 2 + 2 &&
        y >= maze_rows / 2 - 2 &&
        y <= maze_rows / 2 + 2 {
        wall = false
      }
      if y >= maze_rows - 5 &&
        y <= maze_rows - 3 &&
        x >= maze_cols / 2 - 3 &&
        x <= maze_cols / 2 + 3 {
        wall = false
      }

      game.walls[map_index(x, y)] = if wall { 1 } else { 0 }
    }
  }
}

///|
fn is_walkable(game : Game, x : Int, y : Int) -> Bool {
  let wrapped_x = tunnel_wrap_x(x)
  if not(in_map(wrapped_x, y)) {
    return false
  }
  game.walls[map_index(wrapped_x, y)] == 0
}

///|
fn reset_pellets(game : Game) -> Unit {
  game.pellets_left = 0
  for y = 0; y < maze_rows; y = y + 1 {
    for x = 0; x < maze_cols; x = x + 1 {
      let i = map_index(x, y)
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
    (maze_cols / 2, maze_rows - 4),
    (maze_cols / 2, maze_rows / 2),
    (maze_cols / 2 - 1, maze_rows / 2),
    (maze_cols / 2 + 1, maze_rows / 2),
    (maze_cols / 2, maze_rows / 2 - 1),
  ]
  for i = 0; i < spawn_cells.length(); i = i + 1 {
    let (x, y) = spawn_cells[i]
    let idx = map_index(x, y)
    if game.pellets[idx] != 0 {
      game.pellets[idx] = 0
      game.pellets_left = game.pellets_left - 1
    }
  }

  let power_spots : Array[(Int, Int)] = [
    (1, 1),
    (maze_cols - 2, 1),
    (1, maze_rows - 2),
    (maze_cols - 2, maze_rows - 2),
  ]
  for i = 0; i < power_spots.length(); i = i + 1 {
    let (x, y) = power_spots[i]
    if game.walls[map_index(x, y)] == 0 {
      if game.pellets[map_index(x, y)] == 0 {
        game.pellets_left = game.pellets_left + 1
      }
      game.pellets[map_index(x, y)] = 2
    }
  }
}

///|
fn reset_positions(game : Game) -> Unit {
  game.player_x = maze_cols / 2
  game.player_y = maze_rows - 4
  game.dir_x = 0
  game.dir_y = 0
  game.want_x = 0
  game.want_y = 0

  for i = 0; i < game.ghosts.length(); i = i + 1 {
    game.ghosts[i].x = game.ghosts[i].start_x
    game.ghosts[i].y = game.ghosts[i].start_y
    game.ghosts[i].dir_x = 1
    game.ghosts[i].dir_y = 0
  }
}

///|
fn init_game(game : Game) -> Unit {
  game.ghosts.clear()
  game.ghosts.push(
    Ghost::new(maze_cols / 2, maze_rows / 2 - 1, maze_cols - 2, 1, @raylib.red),
  )
  game.ghosts.push(
    Ghost::new(maze_cols / 2 - 1, maze_rows / 2, 1, 1, @raylib.pink),
  )
  game.ghosts.push(
    Ghost::new(
      maze_cols / 2 + 1,
      maze_rows / 2,
      maze_cols - 2,
      maze_rows - 2,
      @raylib.skyblue,
    ),
  )
  game.ghosts.push(
    Ghost::new(
      maze_cols / 2,
      maze_rows / 2 + 1,
      1,
      maze_rows - 2,
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
