///|
fn clear_dynamic_world(game : Game) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    game.enemies[i] = Enemy::inactive()
  }
  for i = 0; i < game.coins.length(); i = i + 1 {
    game.coins[i] = Coin::inactive()
  }
}

///|
fn alloc_enemy(game : Game) -> Int {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
fn alloc_coin(game : Game) -> Int {
  for i = 0; i < game.coins.length(); i = i + 1 {
    if not(game.coins[i].active) {
      return i
    }
  }
  -1
}

///|
fn add_enemy_spawn(
  game : Game,
  tx : Int,
  stand_tile_y : Int,
  dir : Int,
) -> Unit {
  let idx = alloc_enemy(game)
  if idx < 0 {
    return
  }
  let x = tile_center_x(tx)
  let y = tile_top(stand_tile_y) - enemy_half_h() - 0.01
  game.enemies[idx] = Enemy::spawn(x, y, dir)
}

///|
fn add_coin_spawn(game : Game, tx : Int, ty : Int) -> Unit {
  let idx = alloc_coin(game)
  if idx < 0 {
    return
  }
  let x = tile_center_x(tx)
  let y = tile_center_y(ty)
  game.coins[idx] = Coin::spawn(x, y, randf(0.0, 6.28))
}

///|
fn carve_gap(game : Game, tx0 : Int, tx1 : Int) -> Unit {
  for x = tx0; x <= tx1; x = x + 1 {
    for y = ground_row; y < world_tiles_h; y = y + 1 {
      set_tile(game, x, y, tile_empty)
    }
  }
}

///|
fn add_pipe(game : Game, tx : Int, height : Int) -> Unit {
  let top = ground_row - height
  fill_rect_tile(game, tx, top, 2, height, tile_pipe)
}

///|
fn add_brick_row(game : Game, tx : Int, ty : Int, len : Int) -> Unit {
  for x = tx; x < tx + len; x = x + 1 {
    set_tile(game, x, ty, tile_brick)
  }
}

///|
fn add_question(game : Game, tx : Int, ty : Int) -> Unit {
  set_tile(game, tx, ty, tile_question)
}

///|
fn fill_ground(game : Game) -> Unit {
  fill_rect_tile(
    game,
    0,
    ground_row,
    world_tiles_w,
    world_tiles_h - ground_row,
    tile_ground,
  )
}

///|
fn build_level_geometry(game : Game) -> Unit {
  clear_tiles(game)
  fill_ground(game)

  carve_gap(game, 48, 51)
  carve_gap(game, 92, 95)
  carve_gap(game, 138, 142)
  carve_gap(game, 174, 176)
  carve_gap(game, 209, 212)

  add_pipe(game, 28, 3)
  add_pipe(game, 40, 4)
  add_pipe(game, 70, 3)
  add_pipe(game, 106, 5)
  add_pipe(game, 146, 4)
  add_pipe(game, 164, 6)
  add_pipe(game, 192, 4)

  add_brick_row(game, 22, 12, 5)
  add_question(game, 23, 12)
  add_question(game, 25, 12)

  add_brick_row(game, 58, 11, 6)
  add_question(game, 61, 11)

  add_brick_row(game, 82, 12, 5)
  add_question(game, 84, 12)

  add_brick_row(game, 118, 10, 4)
  add_question(game, 119, 10)
  add_question(game, 121, 10)

  add_brick_row(game, 152, 12, 8)
  add_question(game, 155, 12)
  add_question(game, 157, 12)

  add_brick_row(game, 181, 11, 7)
  add_question(game, 184, 11)

  // Stair near the end.
  fill_rect_tile(game, 200, ground_row - 1, 1, 1, tile_ground)
  fill_rect_tile(game, 201, ground_row - 2, 1, 2, tile_ground)
  fill_rect_tile(game, 202, ground_row - 3, 1, 3, tile_ground)
  fill_rect_tile(game, 203, ground_row - 4, 1, 4, tile_ground)
  fill_rect_tile(game, 204, ground_row - 5, 1, 5, tile_ground)
  fill_rect_tile(game, 205, ground_row - 6, 1, 6, tile_ground)

  // Flag pole and castle.
  let flag_tx = 214
  for ty = 8; ty < ground_row; ty = ty + 1 {
    set_tile(game, flag_tx, ty, tile_flag_pole)
  }

  fill_rect_tile(game, 222, ground_row - 5, 6, 5, tile_castle)
  fill_rect_tile(game, 224, ground_row - 7, 2, 2, tile_castle)

  game.flag_x = tile_center_x(flag_tx)
  game.flag_top_y = tile_top(8)
  game.flag_bottom_y = tile_top(ground_row) - player_half_h() - 0.01
  game.castle_x = tile_left(226) + tile_size_f
  game.start_y = tile_top(ground_row) - player_half_h() - 0.01
}

///|
fn populate_level_entities(game : Game) -> Unit {
  clear_dynamic_world(game)

  add_enemy_spawn(game, 18, ground_row, -1)
  add_enemy_spawn(game, 33, ground_row, -1)
  add_enemy_spawn(game, 45, ground_row, -1)
  add_enemy_spawn(game, 64, ground_row, -1)
  add_enemy_spawn(game, 76, ground_row, -1)
  add_enemy_spawn(game, 88, ground_row, -1)
  add_enemy_spawn(game, 103, ground_row, -1)
  add_enemy_spawn(game, 115, ground_row, -1)
  add_enemy_spawn(game, 132, ground_row, -1)
  add_enemy_spawn(game, 150, ground_row, -1)
  add_enemy_spawn(game, 170, ground_row, -1)
  add_enemy_spawn(game, 188, ground_row, -1)
  add_enemy_spawn(game, 198, ground_row - 6, -1)

  for x = 8; x < 36; x = x + 3 {
    add_coin_spawn(game, x, 13)
  }
  for x = 54; x < 88; x = x + 4 {
    add_coin_spawn(game, x, 10)
  }
  for x = 100; x < 133; x = x + 3 {
    add_coin_spawn(game, x, 9)
  }
  for x = 146; x < 180; x = x + 3 {
    add_coin_spawn(game, x, 11)
  }
  for x = 184; x < 212; x = x + 2 {
    add_coin_spawn(game, x, 8)
  }
}

///|
fn reset_player_pose(game : Game, give_invuln : Bool) -> Unit {
  let player = game.player
  player.x = player_start_x
  player.y = game.start_y
  player.vx = 0.0
  player.vy = 0.0
  player.facing = 1
  player.on_ground = false
  player.coyote_t = 0.0
  player.jump_buf_t = 0.0
  player.reached_flag = false
  player.flag_phase = 0
  player.invuln_t = if give_invuln { player_invuln_time } else { 0.0 }
}

///|
fn build_level(game : Game) -> Unit {
  build_level_geometry(game)
  populate_level_entities(game)
  reset_player_pose(game, false)
  game.camera_x = 0.0
  game.shake_t = 0.0
}

///|
fn reset_full_run(game : Game) -> Unit {
  build_level(game)
  clear_particles(game)

  let player = game.player
  player.lives = 3
  player.coins = 0
  player.score = 0

  game.time_left = start_time_seconds
  game.time_accum = 0.0
  game.elapsed = 0.0
  game.state = state_playing
}
