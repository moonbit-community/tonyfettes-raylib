///|
fn is_player_spin_pressed(index : Int) -> Bool {
  if index == 0 {
    @raylib.is_key_pressed(@raylib.KeyK) || @raylib.is_key_pressed(@raylib.KeyL)
  } else {
    @raylib.is_key_pressed(@raylib.KeyU) || @raylib.is_key_pressed(@raylib.KeyI)
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
fn enemy_in_slam_lane(player : Tank, enemy : Tank) -> Bool {
  let dx = enemy.x - player.x
  let dy = enemy.y - player.y
  let dir_x = dir_vector_x(player.dir)
  let dir_y = dir_vector_y(player.dir)
  let forward = dx * dir_x + dy * dir_y
  if forward < -8.0 || forward > spin_attack_radius + 10.0 {
    return false
  }
  let side = absf(dx * dir_y - dy * dir_x)
  let width = Float::from_double(16.0) +
    clampf(forward, 0.0, spin_attack_radius) * Float::from_double(0.24)
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
  if not(enemy_in_slam_lane(player, enemy)) {
    return false
  }

  enemy.hp -= 3 + (player.weapon_level + 1) / 2
  enemy.freeze_timer = melee_stun_time * 0.64 +
    Float::from_int(hit_order) * 0.07
  enemy.ai_move_timer = 0.0
  enemy.blink_timer = 1.0
  enemy.dir = player.dir

  let push = Float::from_double(
    14.0 + Float::from_int(hit_order).to_double() * 1.2,
  )
  let dir_x = dir_vector_x(player.dir)
  let dir_y = dir_vector_y(player.dir)
  let nx = enemy.x + dir_x * push
  let ny = enemy.y + dir_y * push
  if not(tank_hits_world(game, nx, ny)) &&
    not(tank_hits_players(game, nx, ny, -1)) &&
    not(tank_hits_enemies(game, nx, ny, enemy_index)) {
    enemy.x = nx
    enemy.y = ny
  }

  spawn_spark_burst(game, enemy.x, enemy.y, 12 + hit_order * 3)

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
  let slam_x = player.x + dir_vector_x(player.dir) * (tank_half + 15.0)
  let slam_y = player.y + dir_vector_y(player.dir) * (tank_half + 15.0)
  spawn_spark_burst(game, slam_x, slam_y, 14 + hits * 2)
  push_camera_shake(game, 1.1 + Float::from_int(hits) * 0.36)

  if hits > 0 {
    grant_score(game, team, hits * spin_attack_bonus)
    bump_combo(game)
  }
}
