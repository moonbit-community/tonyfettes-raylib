///|
fn enemy_resolve_x(game : Game, enemy : Enemy, dt : Float) -> Unit {
  let nx = enemy.x + enemy.vx * dt
  let half_w = enemy_half_w()
  let half_h = enemy_half_h()

  if enemy.vx > 0.0 {
    let right = nx + half_w
    let tx = world_to_tile_x(right)
    let top_ty = world_to_tile_y(enemy.y - half_h + 2.0)
    let bottom_ty = world_to_tile_y(enemy.y + half_h - 2.0)
    let mut blocked = false
    for ty = top_ty; ty <= bottom_ty; ty = ty + 1 {
      if tile_is_solid(get_tile(game, tx, ty)) {
        blocked = true
        break
      }
    }
    if blocked {
      enemy.x = tile_left(tx) - half_w - 0.01
      enemy.vx = -enemy_speed
      enemy.dir = -1
    } else {
      enemy.x = nx
    }
  } else {
    let left = nx - half_w
    let tx = world_to_tile_x(left)
    let top_ty = world_to_tile_y(enemy.y - half_h + 2.0)
    let bottom_ty = world_to_tile_y(enemy.y + half_h - 2.0)
    let mut blocked = false
    for ty = top_ty; ty <= bottom_ty; ty = ty + 1 {
      if tile_is_solid(get_tile(game, tx, ty)) {
        blocked = true
        break
      }
    }
    if blocked {
      enemy.x = tile_left(tx + 1) + half_w + 0.01
      enemy.vx = enemy_speed
      enemy.dir = 1
    } else {
      enemy.x = nx
    }
  }
}

///|
fn enemy_resolve_y(game : Game, enemy : Enemy, dt : Float) -> Unit {
  let ny = enemy.y + enemy.vy * dt
  let half_w = enemy_half_w()
  let half_h = enemy_half_h()

  if enemy.vy > 0.0 {
    let bottom = ny + half_h
    let ty = world_to_tile_y(bottom)
    let left_tx = world_to_tile_x(enemy.x - half_w + 2.0)
    let right_tx = world_to_tile_x(enemy.x + half_w - 2.0)
    let mut blocked = false
    for tx = left_tx; tx <= right_tx; tx = tx + 1 {
      if tile_is_solid(get_tile(game, tx, ty)) {
        blocked = true
        break
      }
    }
    if blocked {
      enemy.y = tile_top(ty) - half_h - 0.01
      enemy.vy = 0.0
    } else {
      enemy.y = ny
    }
  } else if enemy.vy < 0.0 {
    let top = ny - half_h
    let ty = world_to_tile_y(top)
    let left_tx = world_to_tile_x(enemy.x - half_w + 2.0)
    let right_tx = world_to_tile_x(enemy.x + half_w - 2.0)
    let mut blocked = false
    for tx = left_tx; tx <= right_tx; tx = tx + 1 {
      if tile_is_solid(get_tile(game, tx, ty)) {
        blocked = true
        break
      }
    }
    if blocked {
      enemy.y = tile_top(ty + 1) + half_h + 0.01
      enemy.vy = 0.0
    } else {
      enemy.y = ny
    }
  }
}

///|
fn enemy_ground_ahead(game : Game, enemy : Enemy) -> Bool {
  let probe_x = enemy.x + Float::from_int(enemy.dir) * (enemy_half_w() + 2.0)
  let probe_y = enemy.y + enemy_half_h() + 6.0
  let tx = world_to_tile_x(probe_x)
  let ty = world_to_tile_y(probe_y)
  tile_is_solid(get_tile(game, tx, ty))
}

///|
fn stomp_enemy(game : Game, enemy : Enemy) -> Unit {
  if enemy.squashed {
    return
  }
  enemy.squashed = true
  enemy.squash_t = 0.42
  enemy.vx = 0.0
  enemy.vy = 0.0
  let player = game.player
  player.vy = -stomp_bounce_speed
  player.on_ground = false
  player.score += stomp_score
  spawn_stomp_burst(game, enemy.x, enemy.y)
}

///|
fn update_enemies(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let enemy = game.enemies[i]
    if not(enemy.active) {
      continue i + 1
    }

    if enemy.squashed {
      enemy.squash_t = enemy.squash_t - dt
      if enemy.squash_t <= 0.0 {
        enemy.active = false
      }
      continue i + 1
    }

    enemy.vy = enemy.vy + gravity * dt
    if enemy.vy > max_fall_speed {
      enemy.vy = max_fall_speed
    }

    enemy_resolve_x(game, enemy, dt)
    enemy_resolve_y(game, enemy, dt)

    if not(enemy_ground_ahead(game, enemy)) {
      enemy.vx = -enemy.vx
      enemy.dir = -enemy.dir
    }

    if enemy.y > world_height_px + 20.0 {
      enemy.active = false
      continue i + 1
    }

    if game.player.reached_flag {
      continue i + 1
    }

    let player = game.player
    let px0 = player.x - player_half_w()
    let py0 = player.y - player_half_h()
    let px1 = player.x + player_half_w()
    let py1 = player.y + player_half_h()

    let ex0 = enemy.x - enemy_half_w()
    let ey0 = enemy.y - enemy_half_h()
    let ex1 = enemy.x + enemy_half_w()
    let ey1 = enemy.y + enemy_half_h()

    if rects_overlap(px0, py0, px1, py1, ex0, ey0, ex1, ey1) {
      if player.vy > 110.0 && player.y < enemy.y - 4.0 {
        stomp_enemy(game, enemy)
      } else {
        on_player_hurt(game)
      }
    }
  }
}
