///|
fn is_player_guard_pressed(index : Int) -> Bool {
  if index == 0 {
    @raylib.is_key_pressed(@raylib.KeyG)
  } else {
    @raylib.is_key_pressed(@raylib.KeyY)
  }
}

///|
fn enemy_in_guard_counter_arc(player : Tank, enemy : Tank) -> Bool {
  let dx = enemy.x - player.x
  let dy = enemy.y - player.y
  let dir_x = dir_vector_x(player.dir)
  let dir_y = dir_vector_y(player.dir)
  let forward = dx * dir_x + dy * dir_y
  let side = absf(dx * dir_y - dy * dir_x)
  forward >= -6.0 &&
  forward <= guard_counter_range &&
  side <= guard_counter_width
}

///|
fn can_player_guard(game : Game, player_index : Int) -> Bool {
  let player = game.players[player_index]
  player.active &&
  player.guard_timer <= 0.0 &&
  player.guard_cooldown_timer <= 0.0 &&
  player.ai_move_timer <= 0.0
}

///|
fn try_activate_player_guard(game : Game, player_index : Int) -> Bool {
  if not(can_player_guard(game, player_index)) {
    return false
  }

  let player = game.players[player_index]
  player.guard_timer = guard_duration
  player.guard_cooldown_timer = guard_cooldown
  player.ai_move_timer = 0.10
  spawn_spark_burst(game, player.x, player.y, 9)

  let mut hits = 0
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let enemy = game.enemies[i]
    if not(enemy.active) {
      continue i + 1
    }
    if not(enemy_in_guard_counter_arc(player, enemy)) {
      continue i + 1
    }
    enemy.freeze_timer = guard_counter_stun
    enemy.dir = opposite_dir(player.dir)
    enemy.blink_timer = 0.8
    spawn_spark_burst(game, enemy.x, enemy.y, 6)
    hits += 1
  }

  if hits > 0 {
    push_camera_shake(game, 0.7 + Float::from_int(hits) * 0.2)
  }
  true
}
