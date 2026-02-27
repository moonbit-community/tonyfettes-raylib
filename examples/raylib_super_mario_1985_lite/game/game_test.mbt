///|
fn setup_game() -> @types.Game {
  let game = @types.Game::new()
  @types.fill_rect_tile(
    game,
    0,
    @types.ground_row,
    @types.world_tiles_w,
    @types.world_tiles_h - @types.ground_row,
    @types.tile_ground,
  )
  let ground_y = @types.tile_top(@types.ground_row) -
    @types.player_half_h() -
    0.01
  game.player.x = @types.player_start_x
  game.player.y = ground_y
  game.player.on_ground = true
  game.player.lives = 3
  game.player.coins = 0
  game.player.score = 0
  game.state = @types.state_playing
  game.start_y = ground_y
  game.flag_x = @types.tile_center_x(214)
  game.flag_top_y = @types.tile_top(8)
  game.flag_bottom_y = @types.tile_top(@types.ground_row) -
    @types.player_half_h() -
    0.01
  game.castle_x = @types.tile_left(226) + @types.tile_size_f
  game
}

///|
let no_input : @types.Input = {
  move_left: false,
  move_right: false,
  jump_pressed: false,
  jump_held: false,
  accept: false,
  restart: false,
}

///|
let dt : Float = 1.0 / 60.0

///|
test "gravity: player in air falls" {
  let game = setup_game()
  game.player.y = @types.tile_top(@types.ground_row) - 200.0
  game.player.on_ground = false
  let y_before = game.player.y
  for i = 0; i < 10; i = i + 1 {
    update_game(game, no_input, dt)
  }
  assert_true(game.player.y > y_before)
}

///|
test "ground collision: player lands on tile" {
  let game = setup_game()
  game.player.y = @types.tile_top(@types.ground_row) -
    @types.player_half_h() -
    5.0
  game.player.vy = 200.0
  game.player.on_ground = false
  for i = 0; i < 5; i = i + 1 {
    update_game(game, no_input, dt)
  }
  assert_true(game.player.on_ground)
}

///|
test "jump: player vy goes negative on ground with jump_pressed" {
  let game = setup_game()
  game.player.on_ground = true
  let jump_input : @types.Input = {
    move_left: false,
    move_right: false,
    jump_pressed: true,
    jump_held: true,
    accept: false,
    restart: false,
  }
  update_game(game, jump_input, dt)
  assert_true(game.player.vy < 0.0)
}

///|
test "coin collection: player overlaps coin increments coins" {
  let game = setup_game()
  let player = game.player
  game.coins[0] = @types.Coin::spawn(player.x, player.y, 0.0)
  let coins_before = player.coins
  update_game(game, no_input, dt)
  assert_true(player.coins > coins_before)
  assert_false(game.coins[0].active)
}

///|
test "enemy stomp: player above enemy with high vy squashes enemy" {
  let game = setup_game()
  let player = game.player
  let enemy_x = player.x + 5.0
  let enemy_y = @types.tile_top(@types.ground_row) -
    @types.enemy_half_h() -
    0.01
  game.enemies[0] = @types.Enemy::spawn(enemy_x, enemy_y, -1)
  player.x = enemy_x
  player.y = enemy_y - @types.player_half_h() - @types.enemy_half_h() + 5.0
  player.vy = 500.0
  player.on_ground = false
  update_game(game, no_input, dt)
  assert_true(game.enemies[0].squashed)
}

///|
test "enemy hurt: side collision decrements lives" {
  let game = setup_game()
  let player = game.player
  let lives_before = player.lives
  let enemy_x = player.x + @types.player_half_w() + @types.enemy_half_w() - 5.0
  let enemy_y = player.y
  game.enemies[0] = @types.Enemy::spawn(enemy_x, enemy_y, -1)
  player.vy = 0.0
  update_game(game, no_input, dt)
  assert_true(player.lives < lives_before)
}

///|
test "invulnerable player falls off world: position reset, no extra life lost" {
  let game = setup_game()
  let player = game.player
  player.invuln_t = 1.0
  player.y = @types.world_height_px + 100.0
  player.on_ground = false
  let lives_before = player.lives
  update_game(game, no_input, dt)
  assert_eq(player.lives, lives_before)
  assert_true(player.y < @types.world_height_px)
}

///|
test "two adjacent enemies: stomp one, no hurt from second" {
  let game = setup_game()
  let player = game.player
  let enemy_y = @types.tile_top(@types.ground_row) -
    @types.enemy_half_h() -
    0.01
  game.enemies[0] = @types.Enemy::spawn(player.x, enemy_y, -1)
  game.enemies[1] = @types.Enemy::spawn(
    player.x + @types.enemy_half_w() * 2.0 + 2.0,
    enemy_y,
    -1,
  )
  player.x = game.enemies[0].x
  player.y = enemy_y - @types.player_half_h() - @types.enemy_half_h() + 5.0
  player.vy = 500.0
  player.on_ground = false
  let lives_before = player.lives
  update_game(game, no_input, dt)
  assert_true(game.enemies[0].squashed)
  assert_eq(player.lives, lives_before)
}

///|
test "flag trigger: player reaches flag x sets reached_flag" {
  let game = setup_game()
  let player = game.player
  player.x = game.flag_x - @types.player_half_w()
  player.y = game.flag_bottom_y
  player.on_ground = true
  let right_input : @types.Input = {
    move_left: false,
    move_right: true,
    jump_pressed: false,
    jump_held: false,
    accept: false,
    restart: false,
  }
  for i = 0; i < 30; i = i + 1 {
    update_game(game, right_input, dt)
    if player.reached_flag {
      break
    }
  }
  assert_true(player.reached_flag)
}

///|
test "timer expiry: time runs out triggers game over" {
  let game = setup_game()
  game.time_left = 1
  game.time_accum = 0.0
  for i = 0; i < 120; i = i + 1 {
    if game.state != @types.state_playing {
      break
    }
    update_game(game, no_input, dt)
  }
  assert_eq(game.state, @types.state_game_over)
}
