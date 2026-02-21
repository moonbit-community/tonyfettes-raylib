///|
fn opposite_dir(dir : Int) -> Int {
  if dir == dir_up {
    dir_down
  } else if dir == dir_down {
    dir_up
  } else if dir == dir_left {
    dir_right
  } else {
    dir_left
  }
}

///|
fn demo_nearest_enemy(game : Game, x : Float, y : Float) -> (Int, Float) {
  let mut best_idx = -1
  let mut best_dist : Float = Float::from_int(1000000000)
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      continue i + 1
    }
    let d = distance_sq(x, y, game.enemies[i].x, game.enemies[i].y)
    if d < best_dist {
      best_dist = d
      best_idx = i
    }
  }
  (best_idx, best_dist)
}

///|
fn demo_nearest_powerup(game : Game, x : Float, y : Float) -> (Int, Float) {
  let mut best_idx = -1
  let mut best_dist : Float = Float::from_int(1000000000)
  for i = 0; i < game.powerups.length(); i = i + 1 {
    if not(game.powerups[i].active) {
      continue i + 1
    }
    let d = distance_sq(x, y, game.powerups[i].x, game.powerups[i].y)
    if d < best_dist {
      best_dist = d
      best_idx = i
    }
  }
  (best_idx, best_dist)
}

///|
fn demo_can_step(game : Game, index : Int, dir : Int, dt : Float) -> Bool {
  let player = game.players[index]
  if not(player.active) {
    return false
  }

  let step = player.move_speed * (dt * 0.9 + 0.014)
  let nx = player.x + dir_vector_x(dir) * step
  let ny = player.y + dir_vector_y(dir) * step

  if tank_hits_world(game, nx, ny) {
    return false
  }
  if tank_hits_players(game, nx, ny, index) {
    return false
  }
  if tank_hits_enemies(game, nx, ny, -1) {
    return false
  }
  true
}

///|
fn demo_priority_dir(
  game : Game,
  index : Int,
  dt : Float,
  a : Int,
  b : Int,
  c : Int,
  d : Int,
) -> Int {
  if demo_can_step(game, index, a, dt) {
    a
  } else if demo_can_step(game, index, b, dt) {
    b
  } else if demo_can_step(game, index, c, dt) {
    c
  } else if demo_can_step(game, index, d, dt) {
    d
  } else {
    -1
  }
}

///|
fn demo_choose_move_dir(
  game : Game,
  index : Int,
  dt : Float,
  target_x : Float,
  target_y : Float,
) -> Int {
  let player = game.players[index]
  let dx = target_x - player.x
  let dy = target_y - player.y

  let horiz = if dx < 0.0 { dir_left } else { dir_right }
  let vert = if dy < 0.0 { dir_up } else { dir_down }

  let mut move_dir = if absf(dx) > absf(dy) {
    demo_priority_dir(
      game,
      index,
      dt,
      horiz,
      vert,
      opposite_dir(horiz),
      opposite_dir(vert),
    )
  } else {
    demo_priority_dir(
      game,
      index,
      dt,
      vert,
      horiz,
      opposite_dir(vert),
      opposite_dir(horiz),
    )
  }

  if move_dir < 0 {
    let random_dir = rand_range(game, 0, 3)
    if demo_can_step(game, index, random_dir, dt) {
      move_dir = random_dir
    }
  }

  move_dir
}

///|
fn demo_line_shot_dir(
  player_x : Float,
  player_y : Float,
  target_x : Float,
  target_y : Float,
) -> (Int, Bool) {
  let epsilon = Float::from_int(tile_size) * 0.42
  let dx = target_x - player_x
  let dy = target_y - player_y
  if absf(dx) <= epsilon {
    (if dy < 0.0 { dir_up } else { dir_down }, true)
  } else if absf(dy) <= epsilon {
    (if dx < 0.0 { dir_left } else { dir_right }, true)
  } else {
    (dir_up, false)
  }
}

///|
fn demo_target_position(
  game : Game,
  player : Tank,
  nearest_enemy : Int,
  enemy_dist : Float,
  nearest_powerup : Int,
  powerup_dist : Float,
) -> (Float, Float) {
  if nearest_powerup >= 0 &&
    (nearest_enemy < 0 || powerup_dist < enemy_dist * 0.8) {
    (game.powerups[nearest_powerup].x, game.powerups[nearest_powerup].y)
  } else if nearest_enemy >= 0 {
    (game.enemies[nearest_enemy].x, game.enemies[nearest_enemy].y)
  } else {
    let guard_tile_x = if player.x < tile_center_x(base_tile_x) { 0 } else { 1 }
    let guard_x = tile_center_x(base_tile_x + guard_tile_x)
    let guard_y = tile_center_y(base_tile_y - 1)
    (guard_x, guard_y)
  }
}

///|
fn demo_player_command(game : Game, index : Int, dt : Float) -> (Int, Bool) {
  let player = game.players[index]
  if not(player.active) {
    return (-1, false)
  }

  let (nearest_enemy, enemy_dist) = demo_nearest_enemy(game, player.x, player.y)
  let (nearest_powerup, powerup_dist) = demo_nearest_powerup(
    game,
    player.x,
    player.y,
  )
  let (target_x, target_y) = demo_target_position(
    game, player, nearest_enemy, enemy_dist, nearest_powerup, powerup_dist,
  )

  let mut move_dir = demo_choose_move_dir(game, index, dt, target_x, target_y)
  let mut shoot = false

  if nearest_enemy >= 0 {
    let enemy = game.enemies[nearest_enemy]
    let (line_dir, aligned) = demo_line_shot_dir(
      player.x,
      player.y,
      enemy.x,
      enemy.y,
    )
    if aligned && not(sight_blocked(game, player.x, player.y, enemy.x, enemy.y)) {
      move_dir = line_dir
      shoot = true
    }
  }

  if not(shoot) {
    let base_x = tile_center_x(base_tile_x)
    let base_y = tile_center_y(base_tile_y)
    let (line_dir, aligned) = demo_line_shot_dir(
      player.x,
      player.y,
      base_x,
      base_y,
    )
    if aligned && rand_range(game, 0, 99) < 8 {
      move_dir = line_dir
      shoot = true
    }
  }

  if not(shoot) && rand_range(game, 0, 99) < 4 {
    shoot = true
  }

  (move_dir, shoot)
}
