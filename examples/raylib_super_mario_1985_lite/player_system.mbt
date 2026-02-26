///|
fn is_move_left_down() -> Bool {
  @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft)
}

///|
fn is_move_right_down() -> Bool {
  @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight)
}

///|
fn is_jump_pressed() -> Bool {
  @raylib.is_key_pressed(@raylib.KeyW) ||
  @raylib.is_key_pressed(@raylib.KeyUp) ||
  @raylib.is_key_pressed(@raylib.KeySpace)
}

///|
fn is_jump_down() -> Bool {
  @raylib.is_key_down(@raylib.KeyW) ||
  @raylib.is_key_down(@raylib.KeyUp) ||
  @raylib.is_key_down(@raylib.KeySpace)
}

///|
fn collect_coin(game : Game, x : Float, y : Float) -> Unit {
  let player = game.player
  player.coins += 1
  player.score += coin_collect_score
  spawn_coin_burst(game, x, y)
}

///|
fn on_player_hit_block(game : Game, tx : Int, ty : Int, tile : Int) -> Unit {
  let player = game.player
  let cx = tile_center_x(tx)
  let cy = tile_center_y(ty)

  if tile == tile_brick {
    set_tile(game, tx, ty, tile_empty)
    player.score += block_hit_score
    spawn_block_burst(game, cx, cy, @raylib.maroon)
  } else if tile == tile_question {
    set_tile(game, tx, ty, tile_used)
    collect_coin(game, cx, cy - 12.0)
    player.score += block_hit_score
    spawn_block_burst(game, cx, cy, @raylib.yellow)
  }
}

///|
fn resolve_player_x(game : Game, dt : Float) -> Unit {
  let player = game.player
  let nx = player.x + player.vx * dt
  let half_w = player_half_w()
  let half_h = player_half_h()

  if player.vx > 0.0 {
    let right = nx + half_w
    let tx = world_to_tile_x(right)
    let top_ty = world_to_tile_y(player.y - half_h + 2.0)
    let bottom_ty = world_to_tile_y(player.y + half_h - 2.0)
    let mut blocked = false
    for ty = top_ty; ty <= bottom_ty; ty = ty + 1 {
      if tile_is_solid(get_tile(game, tx, ty)) {
        blocked = true
        break
      }
    }
    if blocked {
      player.x = tile_left(tx) - half_w - 0.01
      player.vx = 0.0
    } else {
      player.x = nx
    }
  } else if player.vx < 0.0 {
    let left = nx - half_w
    let tx = world_to_tile_x(left)
    let top_ty = world_to_tile_y(player.y - half_h + 2.0)
    let bottom_ty = world_to_tile_y(player.y + half_h - 2.0)
    let mut blocked = false
    for ty = top_ty; ty <= bottom_ty; ty = ty + 1 {
      if tile_is_solid(get_tile(game, tx, ty)) {
        blocked = true
        break
      }
    }
    if blocked {
      player.x = tile_left(tx + 1) + half_w + 0.01
      player.vx = 0.0
    } else {
      player.x = nx
    }
  }
}

///|
fn resolve_player_y(game : Game, dt : Float) -> Unit {
  let player = game.player
  let ny = player.y + player.vy * dt
  let half_w = player_half_w()
  let half_h = player_half_h()

  player.on_ground = false

  if player.vy > 0.0 {
    let bottom = ny + half_h
    let ty = world_to_tile_y(bottom)
    let left_tx = world_to_tile_x(player.x - half_w + 3.0)
    let right_tx = world_to_tile_x(player.x + half_w - 3.0)
    let mut blocked = false
    for tx = left_tx; tx <= right_tx; tx = tx + 1 {
      if tile_is_solid(get_tile(game, tx, ty)) {
        blocked = true
        break
      }
    }
    if blocked {
      player.y = tile_top(ty) - half_h - 0.01
      player.vy = 0.0
      player.on_ground = true
    } else {
      player.y = ny
    }
  } else if player.vy < 0.0 {
    let top = ny - half_h
    let ty = world_to_tile_y(top)
    let left_tx = world_to_tile_x(player.x - half_w + 3.0)
    let right_tx = world_to_tile_x(player.x + half_w - 3.0)
    let mut blocked = false
    for tx = left_tx; tx <= right_tx; tx = tx + 1 {
      let tile = get_tile(game, tx, ty)
      if tile_is_solid(tile) {
        blocked = true
        on_player_hit_block(game, tx, ty, tile)
      }
    }
    if blocked {
      player.y = tile_top(ty + 1) + half_h + 0.01
      player.vy = 0.0
    } else {
      player.y = ny
    }
  }
}

///|
fn update_flag_sequence(game : Game, dt : Float) -> Unit {
  let player = game.player
  if not(player.reached_flag) {
    return
  }

  player.vx = 0.0
  player.vy = 0.0

  if player.flag_phase == 1 {
    player.x = game.flag_x - player_half_w() - 4.0
    if player.y < game.flag_bottom_y {
      player.y += flag_slide_speed * dt
      if player.y > game.flag_bottom_y {
        player.y = game.flag_bottom_y
      }
    } else {
      player.flag_phase = 2
      player.facing = 1
      player.score += 1000 + game.time_left * 5
      game.shake_t = 0.15
    }
  } else if player.flag_phase == 2 {
    player.x += castle_walk_speed * dt
    if player.x >= game.castle_x {
      player.flag_phase = 3
      game.state = state_win
    }
  }
}

///|
fn try_trigger_flag(game : Game) -> Unit {
  let player = game.player
  if player.reached_flag {
    return
  }

  if player.x + player_half_w() >= game.flag_x - 2.0 &&
    player.y + player_half_h() >= game.flag_top_y {
    player.reached_flag = true
    player.flag_phase = 1
    player.vx = 0.0
    player.vy = 0.0
  }
}

///|
fn on_player_hurt(game : Game) -> Unit {
  let player = game.player
  if player.invuln_t > 0.0 || player.reached_flag {
    return
  }

  spawn_hurt_burst(game, player.x, player.y)
  player.lives -= 1
  game.shake_t = 0.24

  if player.lives <= 0 {
    game.state = state_game_over
    return
  }

  if player.coins >= 5 {
    player.coins -= 5
  } else {
    player.coins = 0
  }
  reset_player_pose(game, true)
  game.camera_x = clampf(
    player.x - 180.0,
    0.0,
    world_width_px - Float::from_int(screen_width),
  )
}

///|
fn update_player(game : Game, dt : Float) -> Unit {
  let player = game.player

  if player.invuln_t > 0.0 {
    player.invuln_t = player.invuln_t - dt
    if player.invuln_t < 0.0 {
      player.invuln_t = 0.0
    }
  }

  if player.reached_flag {
    update_flag_sequence(game, dt)
    return
  }

  if is_jump_pressed() {
    player.jump_buf_t = jump_buffer_time
  } else if player.jump_buf_t > 0.0 {
    player.jump_buf_t = player.jump_buf_t - dt
    if player.jump_buf_t < 0.0 {
      player.jump_buf_t = 0.0
    }
  }

  let left = is_move_left_down()
  let right = is_move_right_down()
  let move_axis = if left && not(right) {
    -1
  } else if right && not(left) {
    1
  } else {
    0
  }

  if move_axis != 0 {
    let accel = if player.on_ground { run_accel_ground } else { run_accel_air }
    player.vx += Float::from_int(move_axis) * accel * dt
    player.vx = clampf(player.vx, -max_run_speed, max_run_speed)
    player.facing = move_axis
  } else if player.on_ground {
    let drag = run_friction * dt
    if absf(player.vx) <= drag {
      player.vx = 0.0
    } else {
      player.vx = player.vx - Float::from_int(signf(player.vx)) * drag
    }
  }

  if player.jump_buf_t > 0.0 && (player.on_ground || player.coyote_t > 0.0) {
    player.vy = -jump_speed
    player.on_ground = false
    player.coyote_t = 0.0
    player.jump_buf_t = 0.0
  }

  if not(is_jump_down()) && player.vy < 0.0 {
    player.vy += gravity * dt * (1.0 - jump_cut_multiplier)
  }

  player.vy += gravity * dt
  if player.vy > max_fall_speed {
    player.vy = max_fall_speed
  }

  resolve_player_x(game, dt)
  resolve_player_y(game, dt)

  if player.on_ground {
    player.coyote_t = coyote_time
  } else if player.coyote_t > 0.0 {
    player.coyote_t = player.coyote_t - dt
    if player.coyote_t < 0.0 {
      player.coyote_t = 0.0
    }
  }

  if player.x < player_half_w() {
    player.x = player_half_w()
    player.vx = 0.0
  }

  if player.y > world_height_px + 80.0 {
    on_player_hurt(game)
    return
  }

  try_trigger_flag(game)
}
