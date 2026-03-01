///|
fn opposite_dir(dir : @types.Dir) -> @types.Dir {
  match dir {
    Up => @types.Down
    Down => @types.Up
    Left => @types.Right
    Right => @types.Left
  }
}

///|
fn demo_nearest_enemy(game : @types.Game, x : Float, y : Float) -> (Int, Float) {
  let mut best_idx = -1
  let mut best_dist : Float = Float::from_int(1000000000)
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }
    let d = @types.distance_sq(x, y, game.enemies[i].x, game.enemies[i].y)
    if d < best_dist {
      best_dist = d
      best_idx = i
    }
  }
  (best_idx, best_dist)
}

///|
fn demo_nearest_powerup(
  game : @types.Game,
  x : Float,
  y : Float,
) -> (Int, Float) {
  let mut best_idx = -1
  let mut best_dist : Float = Float::from_int(1000000000)
  for i in 0..<game.powerups.length() {
    if not(game.powerups[i].active) {
      continue
    }
    let d = @types.distance_sq(x, y, game.powerups[i].x, game.powerups[i].y)
    if d < best_dist {
      best_dist = d
      best_idx = i
    }
  }
  (best_idx, best_dist)
}

///|
fn demo_can_step(
  game : @types.Game,
  index : Int,
  dir : @types.Dir,
  dt : Float,
) -> Bool {
  let player = game.players[index]
  if not(player.active) {
    return false
  }

  let step = player.move_speed * (dt * 0.9 + 0.014)
  let nx = player.x + @types.dir_vector_x(dir) * step
  let ny = player.y + @types.dir_vector_y(dir) * step

  if @world.tank_hits_world(game, nx, ny) {
    return false
  }
  if @world.tank_hits_players(game, nx, ny, index) {
    return false
  }
  if @world.tank_hits_enemies(game, nx, ny, -1) {
    return false
  }
  true
}

///|
fn demo_priority_dir(
  game : @types.Game,
  index : Int,
  dt : Float,
  a : @types.Dir,
  b : @types.Dir,
  c : @types.Dir,
  d : @types.Dir,
) -> @types.Dir? {
  if demo_can_step(game, index, a, dt) {
    Some(a)
  } else if demo_can_step(game, index, b, dt) {
    Some(b)
  } else if demo_can_step(game, index, c, dt) {
    Some(c)
  } else if demo_can_step(game, index, d, dt) {
    Some(d)
  } else {
    None
  }
}

///|
fn demo_choose_move_dir(
  game : @types.Game,
  index : Int,
  dt : Float,
  target_x : Float,
  target_y : Float,
) -> @types.Dir? {
  let player = game.players[index]
  let dx = target_x - player.x
  let dy = target_y - player.y

  let horiz : @types.Dir = if dx < 0.0 { @types.Left } else { @types.Right }
  let vert : @types.Dir = if dy < 0.0 { @types.Up } else { @types.Down }

  let mut move_dir : @types.Dir? = if @types.absf(dx) > @types.absf(dy) {
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

  match move_dir {
    None => {
      let random_dir = @types.rand_dir(game)
      if demo_can_step(game, index, random_dir, dt) {
        move_dir = Some(random_dir)
      }
    }
    _ => ()
  }

  move_dir
}

///|
fn demo_line_shot_dir(
  player_x : Float,
  player_y : Float,
  target_x : Float,
  target_y : Float,
) -> (@types.Dir, Bool) {
  let epsilon = Float::from_int(@types.tile_size) * 0.42
  let dx = target_x - player_x
  let dy = target_y - player_y
  if @types.absf(dx) <= epsilon {
    (if dy < 0.0 { @types.Up } else { @types.Down }, true)
  } else if @types.absf(dy) <= epsilon {
    (if dx < 0.0 { @types.Left } else { @types.Right }, true)
  } else {
    (@types.Up, false)
  }
}

///|
fn demo_target_position(
  game : @types.Game,
  player : @types.Tank,
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
    let guard_tile_x = if player.x < @types.tile_center_x(@types.base_tile_x) {
      0
    } else {
      1
    }
    let guard_x = @types.tile_center_x(@types.base_tile_x + guard_tile_x)
    let guard_y = @types.tile_center_y(@types.base_tile_y - 1)
    (guard_x, guard_y)
  }
}

///|
fn demo_player_command(
  game : @types.Game,
  index : Int,
  dt : Float,
) -> (@types.Dir?, Bool) {
  let player = game.players[index]
  if not(player.active) {
    return (None, false)
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

  let mut move_dir : @types.Dir? = demo_choose_move_dir(
    game, index, dt, target_x, target_y,
  )
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
      move_dir = Some(line_dir)
      shoot = true
    }
  }

  if not(shoot) {
    let base_x = @types.tile_center_x(@types.base_tile_x)
    let base_y = @types.tile_center_y(@types.base_tile_y)
    let (line_dir, aligned) = demo_line_shot_dir(
      player.x,
      player.y,
      base_x,
      base_y,
    )
    if aligned && @types.rand_range(game, 0, 99) < 8 {
      move_dir = Some(line_dir)
      shoot = true
    }
  }

  if not(shoot) && @types.rand_range(game, 0, 99) < 4 {
    shoot = true
  }

  (move_dir, shoot)
}

///|
fn sight_blocked(
  game : @types.Game,
  ax : Float,
  ay : Float,
  bx : Float,
  by : Float,
) -> Bool {
  let dx = bx - ax
  let dy = by - ay
  let distance = (dx * dx + dy * dy).sqrt()
  if distance <= 1.0 {
    return false
  }
  let step = Float::from_int(@types.tile_size / 2)
  let n = @types.clampi((distance / step).to_int(), 1, 80)
  for i in 1..<n {
    let t = Float::from_int(i) / Float::from_int(n)
    let px = ax + dx * t
    let py = ay + dy * t
    let tile = @types.get_tile(
      game,
      @types.world_x_to_tile(px),
      @types.world_y_to_tile(py),
    )
    if tile == @types.Brick || tile == @types.Steel || tile == @types.Base {
      return true
    }
  }
  false
}
