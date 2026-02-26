///|
fn wrap_dist(a : Int, b : Int, size : Int) -> Int {
  let d0 : Int = if a > b { a - b } else { b - a }
  mini(d0, size - d0)
}

///|
fn food_distance(nx : Int, ny : Int, fx : Int, fy : Int) -> Int {
  wrap_dist(nx, fx, grid_w) + wrap_dist(ny, fy, grid_h)
}

///|
fn direction_score_player(game : Game, dir : Int) -> Int {
  if opposite_dir(game.p_dir, dir) {
    return -100000
  }

  let nx : Int = wrap_x(game.p_seg_x[0] + dir_dx(dir))
  let ny : Int = wrap_y(game.p_seg_y[0] + dir_dy(dir))

  if player_segment_at(game, nx, ny, true) {
    return -90000
  }
  if rival_segment_at(game, nx, ny, -1, false) {
    return -86000
  }
  if trap_at(game, nx, ny) {
    return -83000
  }

  let mut score : Int = 3000 -
    food_distance(nx, ny, game.food_x, game.food_y) * 70

  // Prefer cells with room around to avoid dead ends.
  for d = 0; d < 4; d = d + 1 {
    let tx : Int = wrap_x(nx + dir_dx(d))
    let ty : Int = wrap_y(ny + dir_dy(d))

    if not(player_segment_at(game, tx, ty, true)) &&
      not(rival_segment_at(game, tx, ty, -1, false)) &&
      not(trap_at(game, tx, ty)) {
      score = score + 36
    }
  }

  score
}

///|
fn suggest_player_dir(game : Game) -> Int {
  let mut best_dir : Int = -1
  let mut best_score : Int = -999999

  for d = 0; d < 4; d = d + 1 {
    let s : Int = direction_score_player(game, d)
    if s > best_score {
      best_score = s
      best_dir = d
    }
  }

  best_dir
}

///|
fn direction_score_rival(game : Game, rid : Int, dir : Int) -> Int {
  let rival = game.rivals[rid]

  if opposite_dir(rival.dir, dir) {
    return -100000
  }

  let nx : Int = wrap_x(rival.seg_x[0] + dir_dx(dir))
  let ny : Int = wrap_y(rival.seg_y[0] + dir_dy(dir))

  if rival_would_collide(game, rid, nx, ny) {
    return -90000
  }

  let mut score : Int = 2800 -
    food_distance(nx, ny, game.food_x, game.food_y) * 64

  // Avoid moving too close to player head in early game.
  let pd : Int = food_distance(nx, ny, game.p_seg_x[0], game.p_seg_y[0])
  if pd <= 2 {
    score = score - 120
  }

  // Prefer having exits.
  for d = 0; d < 4; d = d + 1 {
    let tx : Int = wrap_x(nx + dir_dx(d))
    let ty : Int = wrap_y(ny + dir_dy(d))
    if not(rival_would_collide(game, rid, tx, ty)) {
      score = score + 26
    }
  }

  score + @raylib.get_random_value(-44, 44)
}

///|
fn ai_choose_dir(game : Game, rid : Int) -> Int {
  let rival = game.rivals[rid]

  let mut best_dir : Int = rival.dir
  let mut best_score : Int = -999999

  for d = 0; d < 4; d = d + 1 {
    let s : Int = direction_score_rival(game, rid, d)
    if s > best_score {
      best_score = s
      best_dir = d
    }
  }

  best_dir
}
