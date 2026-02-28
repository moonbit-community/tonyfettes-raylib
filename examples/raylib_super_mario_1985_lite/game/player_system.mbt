///|
fn collect_coin(game : @types.Game, x : Float, y : Float) -> Unit {
  let player = game.player
  player.coins += 1
  player.score += @types.coin_collect_score
  @particles.spawn_coin_burst(game, x, y)
}

///|
fn on_player_hit_block(
  game : @types.Game,
  tx : Int,
  ty : Int,
  tile : Int,
) -> Unit {
  let player = game.player
  let cx = @types.tile_center_x(tx)
  let cy = @types.tile_center_y(ty)

  if tile == @types.tile_brick {
    @types.set_tile(game, tx, ty, @types.tile_empty)
    player.score += @types.block_hit_score
    @particles.spawn_block_burst(game, cx, cy, @raylib.maroon)
  } else if tile == @types.tile_question {
    @types.set_tile(game, tx, ty, @types.tile_used)
    collect_coin(game, cx, cy - 12.0)
    player.score += @types.block_hit_score
    @particles.spawn_block_burst(game, cx, cy, @raylib.yellow)
  }
}

///|
fn resolve_player_x(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  let nx = player.x + player.vx * dt
  let half_w = @types.player_half_w()
  let half_h = @types.player_half_h()

  if player.vx > 0.0 {
    let right = nx + half_w
    let tx = @types.world_to_tile_x(right)
    let top_ty = @types.world_to_tile_y(player.y - half_h + 2.0)
    let bottom_ty = @types.world_to_tile_y(player.y + half_h - 2.0)
    let mut blocked = false
    for ty in top_ty..<=bottom_ty {
      if @types.tile_is_solid(@types.get_tile(game, tx, ty)) {
        blocked = true
        break
      }
    }
    if blocked {
      player.x = @types.tile_left(tx) - half_w - 0.01
      player.vx = 0.0
    } else {
      player.x = nx
    }
  } else if player.vx < 0.0 {
    let left = nx - half_w
    let tx = @types.world_to_tile_x(left)
    let top_ty = @types.world_to_tile_y(player.y - half_h + 2.0)
    let bottom_ty = @types.world_to_tile_y(player.y + half_h - 2.0)
    let mut blocked = false
    for ty in top_ty..<=bottom_ty {
      if @types.tile_is_solid(@types.get_tile(game, tx, ty)) {
        blocked = true
        break
      }
    }
    if blocked {
      player.x = @types.tile_left(tx + 1) + half_w + 0.01
      player.vx = 0.0
    } else {
      player.x = nx
    }
  }
}

///|
fn resolve_player_y(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  let ny = player.y + player.vy * dt
  let half_w = @types.player_half_w()
  let half_h = @types.player_half_h()

  player.on_ground = false

  if player.vy > 0.0 {
    let bottom = ny + half_h
    let ty = @types.world_to_tile_y(bottom)
    let left_tx = @types.world_to_tile_x(player.x - half_w + 3.0)
    let right_tx = @types.world_to_tile_x(player.x + half_w - 3.0)
    let mut blocked = false
    for tx in left_tx..<=right_tx {
      if @types.tile_is_solid(@types.get_tile(game, tx, ty)) {
        blocked = true
        break
      }
    }
    if blocked {
      player.y = @types.tile_top(ty) - half_h - 0.01
      player.vy = 0.0
      player.on_ground = true
    } else {
      player.y = ny
    }
  } else if player.vy < 0.0 {
    let top = ny - half_h
    let ty = @types.world_to_tile_y(top)
    let left_tx = @types.world_to_tile_x(player.x - half_w + 3.0)
    let right_tx = @types.world_to_tile_x(player.x + half_w - 3.0)
    let mut blocked = false
    for tx in left_tx..<=right_tx {
      let tile = @types.get_tile(game, tx, ty)
      if @types.tile_is_solid(tile) {
        blocked = true
        on_player_hit_block(game, tx, ty, tile)
      }
    }
    if blocked {
      player.y = @types.tile_top(ty + 1) + half_h + 0.01
      player.vy = 0.0
    } else {
      player.y = ny
    }
  }
}

///|
fn update_flag_sequence(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  if not(player.reached_flag) {
    return
  }

  player.vx = 0.0
  player.vy = 0.0

  if player.flag_phase == 1 {
    player.x = game.flag_x - @types.player_half_w() - 4.0
    if player.y < game.flag_bottom_y {
      player.y += @types.flag_slide_speed * dt
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
    player.x += @types.castle_walk_speed * dt
    if player.x >= game.castle_x {
      player.flag_phase = 3
      game.state = @types.state_win
    }
  }
}

///|
fn try_trigger_flag(game : @types.Game) -> Unit {
  let player = game.player
  if player.reached_flag {
    return
  }

  if player.x + @types.player_half_w() >= game.flag_x - 2.0 &&
    player.y + @types.player_half_h() >= game.flag_top_y {
    player.reached_flag = true
    player.flag_phase = 1
    player.vx = 0.0
    player.vy = 0.0
  }
}

///|
fn on_player_hurt(game : @types.Game) -> Unit {
  let player = game.player
  if player.invuln_t > 0.0 || player.reached_flag {
    return
  }

  @particles.spawn_hurt_burst(game, player.x, player.y)
  player.lives -= 1
  game.shake_t = 0.24

  if player.lives <= 0 {
    game.state = @types.state_game_over
    return
  }

  if player.coins >= 5 {
    player.coins -= 5
  } else {
    player.coins = 0
  }
  reset_player_pose(game, true)
  game.camera_x = @types.clampf(
    player.x - 180.0,
    0.0,
    @types.world_width_px - Float::from_int(@types.screen_width),
  )
}

///|
fn update_player(game : @types.Game, input : @types.Input, dt : Float) -> Unit {
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

  if input.jump_pressed {
    player.jump_buf_t = @types.jump_buffer_time
  } else if player.jump_buf_t > 0.0 {
    player.jump_buf_t = player.jump_buf_t - dt
    if player.jump_buf_t < 0.0 {
      player.jump_buf_t = 0.0
    }
  }

  let left = input.move_left
  let right = input.move_right
  let move_axis = if left && not(right) {
    -1
  } else if right && not(left) {
    1
  } else {
    0
  }

  if move_axis != 0 {
    let accel = if player.on_ground {
      @types.run_accel_ground
    } else {
      @types.run_accel_air
    }
    player.vx += Float::from_int(move_axis) * accel * dt
    player.vx = @types.clampf(
      player.vx,
      -@types.max_run_speed,
      @types.max_run_speed,
    )
    player.facing = move_axis
  } else if player.on_ground {
    let drag = @types.run_friction * dt
    if @types.absf(player.vx) <= drag {
      player.vx = 0.0
    } else {
      player.vx = player.vx - Float::from_int(@types.signf(player.vx)) * drag
    }
  }

  if player.jump_buf_t > 0.0 && (player.on_ground || player.coyote_t > 0.0) {
    player.vy = -@types.jump_speed
    player.on_ground = false
    player.coyote_t = 0.0
    player.jump_buf_t = 0.0
  }

  if not(input.jump_held) && player.vy < 0.0 {
    player.vy += @types.gravity * dt * (1.0 - @types.jump_cut_multiplier)
  }

  player.vy += @types.gravity * dt
  if player.vy > @types.max_fall_speed {
    player.vy = @types.max_fall_speed
  }

  resolve_player_x(game, dt)
  resolve_player_y(game, dt)

  if player.on_ground {
    player.coyote_t = @types.coyote_time
  } else if player.coyote_t > 0.0 {
    player.coyote_t = player.coyote_t - dt
    if player.coyote_t < 0.0 {
      player.coyote_t = 0.0
    }
  }

  if player.x < @types.player_half_w() {
    player.x = @types.player_half_w()
    player.vx = 0.0
  }

  if player.y > @types.world_height_px + 80.0 {
    if player.invuln_t > 0.0 {
      reset_player_pose(game, true)
    } else {
      on_player_hurt(game)
    }
    return
  }

  try_trigger_flag(game)
}
