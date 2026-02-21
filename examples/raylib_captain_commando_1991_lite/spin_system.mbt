///|
fn is_player_spin_pressed(index : Int) -> Bool {
  if index == 0 {
    @raylib.is_key_pressed(@raylib.KeyH) || @raylib.is_key_pressed(@raylib.KeyJ)
  } else {
    @raylib.is_key_pressed(@raylib.KeyO) || @raylib.is_key_pressed(@raylib.KeyP)
  }
}

///|
fn can_player_spin(game : Game, player_index : Int) -> Bool {
  let player = game.players[player_index]
  player.active &&
  player.spin_timer <= 0.0 &&
  player.spin_cooldown_timer <= 0.0 &&
  player.guard_timer <= 0.0 &&
  player.ai_move_timer <= 0.0
}

///|
fn enemy_in_burst_lane(player : Tank, enemy : Tank) -> Bool {
  let dx = enemy.x - player.x
  let dy = enemy.y - player.y
  let dir_x = dir_vector_x(player.dir)
  let dir_y = dir_vector_y(player.dir)
  let forward = dx * dir_x + dy * dir_y
  if forward < -6.0 || forward > spin_attack_radius + 12.0 {
    return false
  }
  let side = absf(dx * dir_y - dy * dir_x)
  let width = Float::from_double(18.0) +
    clampf(forward, 0.0, spin_attack_radius) * Float::from_double(0.2)
  side <= width
}

///|
fn spin_hit_enemy(
  game : Game,
  player : Tank,
  enemy_index : Int,
  team : Int,
  hit_order : Int,
) -> Bool {
  let enemy = game.enemies[enemy_index]
  if not(enemy.active) || enemy.invuln_timer > 0.0 {
    return false
  }
  if not(enemy_in_burst_lane(player, enemy)) {
    return false
  }

  enemy.hp -= 3 + player.weapon_level / 2
  enemy.freeze_timer = melee_stun_time * 0.7 + Float::from_int(hit_order) * 0.08
  enemy.ai_move_timer = 0.0
  enemy.blink_timer = 1.0
  enemy.dir = opposite_dir(player.dir)
  spawn_spark_burst(game, enemy.x, enemy.y, 10 + hit_order * 2)

  if enemy.hp <= 0 {
    destroy_enemy(game, enemy_index, team)
  }
  true
}

///|
fn perform_player_spin(game : Game, player_index : Int) -> Unit {
  if not(can_player_spin(game, player_index)) {
    return
  }

  let player = game.players[player_index]
  let team = team_of_player(player_index)
  let mut hits = 0

  for i = 0; i < game.enemies.length(); i = i + 1 {
    if spin_hit_enemy(game, player, i, team, hits) {
      hits += 1
    }
  }

  player.spin_timer = spin_attack_duration
  player.spin_cooldown_timer = spin_attack_cooldown
  player.ai_move_timer = spin_attack_duration
  player.ai_fire_timer = melee_cooldown * 0.6
  let burst_x = player.x + dir_vector_x(player.dir) * (tank_half + 16.0)
  let burst_y = player.y + dir_vector_y(player.dir) * (tank_half + 16.0)
  spawn_spark_burst(game, burst_x, burst_y, 10 + hits * 2)
  push_camera_shake(game, 0.9 + Float::from_int(hits) * 0.34)

  if hits > 0 {
    grant_score(game, team, hits * spin_attack_bonus)
    bump_combo(game)
  }
}
