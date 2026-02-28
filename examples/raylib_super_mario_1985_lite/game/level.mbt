///|
fn clear_dynamic_world(game : @types.Game) -> Unit {
  for i in 0..<game.enemies.length() {
    game.enemies[i] = @types.Enemy::inactive()
  }
  for i in 0..<game.coins.length() {
    game.coins[i] = @types.Coin::inactive()
  }
}

///|
fn alloc_enemy(game : @types.Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
fn alloc_coin(game : @types.Game) -> Int {
  for i in 0..<game.coins.length() {
    if not(game.coins[i].active) {
      return i
    }
  }
  -1
}

///|
fn add_enemy_spawn(
  game : @types.Game,
  tx : Int,
  stand_tile_y : Int,
  dir : Int,
) -> Unit {
  let idx = alloc_enemy(game)
  if idx < 0 {
    return
  }
  let x = @types.tile_center_x(tx)
  let y = @types.tile_top(stand_tile_y) - @types.enemy_half_h() - 0.01
  game.enemies[idx] = @types.Enemy::spawn(x, y, dir)
}

///|
fn add_coin_spawn(game : @types.Game, tx : Int, ty : Int) -> Unit {
  let idx = alloc_coin(game)
  if idx < 0 {
    return
  }
  let x = @types.tile_center_x(tx)
  let y = @types.tile_center_y(ty)
  game.coins[idx] = @types.Coin::spawn(x, y, @types.randf(0.0, 6.28))
}

///|
fn carve_gap(game : @types.Game, tx0 : Int, tx1 : Int) -> Unit {
  for x in tx0..=tx1 {
    for y in @types.ground_row..<@types.world_tiles_h {
      @types.set_tile(game, x, y, @types.tile_empty)
    }
  }
}

///|
fn add_pipe(game : @types.Game, tx : Int, height : Int) -> Unit {
  let top = @types.ground_row - height
  @types.fill_rect_tile(game, tx, top, 2, height, @types.tile_pipe)
}

///|
fn add_brick_row(game : @types.Game, tx : Int, ty : Int, len : Int) -> Unit {
  for x in tx..<(tx + len) {
    @types.set_tile(game, x, ty, @types.tile_brick)
  }
}

///|
fn add_question(game : @types.Game, tx : Int, ty : Int) -> Unit {
  @types.set_tile(game, tx, ty, @types.tile_question)
}

///|
fn fill_ground(game : @types.Game) -> Unit {
  @types.fill_rect_tile(
    game,
    0,
    @types.ground_row,
    @types.world_tiles_w,
    @types.world_tiles_h - @types.ground_row,
    @types.tile_ground,
  )
}

///|
fn build_level_geometry(game : @types.Game) -> Unit {
  @types.clear_tiles(game)
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
  @types.fill_rect_tile(
    game,
    200,
    @types.ground_row - 1,
    1,
    1,
    @types.tile_ground,
  )
  @types.fill_rect_tile(
    game,
    201,
    @types.ground_row - 2,
    1,
    2,
    @types.tile_ground,
  )
  @types.fill_rect_tile(
    game,
    202,
    @types.ground_row - 3,
    1,
    3,
    @types.tile_ground,
  )
  @types.fill_rect_tile(
    game,
    203,
    @types.ground_row - 4,
    1,
    4,
    @types.tile_ground,
  )
  @types.fill_rect_tile(
    game,
    204,
    @types.ground_row - 5,
    1,
    5,
    @types.tile_ground,
  )
  @types.fill_rect_tile(
    game,
    205,
    @types.ground_row - 6,
    1,
    6,
    @types.tile_ground,
  )

  // Flag pole and castle.
  let flag_tx = 214
  for ty in 8..<@types.ground_row {
    @types.set_tile(game, flag_tx, ty, @types.tile_flag_pole)
  }

  @types.fill_rect_tile(
    game,
    222,
    @types.ground_row - 5,
    6,
    5,
    @types.tile_castle,
  )
  @types.fill_rect_tile(
    game,
    224,
    @types.ground_row - 7,
    2,
    2,
    @types.tile_castle,
  )

  game.flag_x = @types.tile_center_x(flag_tx)
  game.flag_top_y = @types.tile_top(8)
  game.flag_bottom_y = @types.tile_top(@types.ground_row) -
    @types.player_half_h() -
    0.01
  game.castle_x = @types.tile_left(226) + @types.tile_size_f
  game.start_y = @types.tile_top(@types.ground_row) -
    @types.player_half_h() -
    0.01
}

///|
fn populate_level_entities(game : @types.Game) -> Unit {
  clear_dynamic_world(game)

  add_enemy_spawn(game, 18, @types.ground_row, -1)
  add_enemy_spawn(game, 33, @types.ground_row, -1)
  add_enemy_spawn(game, 45, @types.ground_row, -1)
  add_enemy_spawn(game, 64, @types.ground_row, -1)
  add_enemy_spawn(game, 76, @types.ground_row, -1)
  add_enemy_spawn(game, 88, @types.ground_row, -1)
  add_enemy_spawn(game, 103, @types.ground_row, -1)
  add_enemy_spawn(game, 115, @types.ground_row, -1)
  add_enemy_spawn(game, 132, @types.ground_row, -1)
  add_enemy_spawn(game, 150, @types.ground_row, -1)
  add_enemy_spawn(game, 170, @types.ground_row, -1)
  add_enemy_spawn(game, 188, @types.ground_row, -1)
  add_enemy_spawn(game, 198, @types.ground_row - 6, -1)

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
fn reset_player_pose(game : @types.Game, give_invuln : Bool) -> Unit {
  let player = game.player
  player.x = @types.player_start_x
  player.y = game.start_y
  player.vx = 0.0
  player.vy = 0.0
  player.facing = 1
  player.on_ground = false
  player.coyote_t = 0.0
  player.jump_buf_t = 0.0
  player.reached_flag = false
  player.flag_phase = 0
  player.invuln_t = if give_invuln { @types.player_invuln_time } else { 0.0 }
}

///|
fn build_level(game : @types.Game) -> Unit {
  build_level_geometry(game)
  populate_level_entities(game)
  reset_player_pose(game, false)
  game.camera_x = 0.0
  game.shake_t = 0.0
}

///|
fn reset_full_run(game : @types.Game) -> Unit {
  build_level(game)
  @particles.clear_particles(game)

  let player = game.player
  player.lives = 3
  player.coins = 0
  player.score = 0

  game.time_left = @types.start_time_seconds
  game.time_accum = 0.0
  game.elapsed = 0.0
  game.state = @types.state_playing
}
