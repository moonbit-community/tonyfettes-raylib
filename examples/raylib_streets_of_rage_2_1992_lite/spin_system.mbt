///|
fn is_player_spin_pressed(index : Int) -> Bool {
  if index == 0 {
    @raylib.is_key_pressed(@raylib.KeyN) || @raylib.is_key_pressed(@raylib.KeyM)
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
fn enemy_in_uppercut_arc(player : Tank, enemy : Tank) -> Bool {
  let dx = enemy.x - player.x
  let dy = enemy.y - player.y
  let dir_x = dir_vector_x(player.dir)
  let dir_y = dir_vector_y(player.dir)
  let forward = dx * dir_x + dy * dir_y
  let side = absf(dx * dir_y - dy * dir_x)
  let radius = spin_attack_radius + tank_half
  forward >= -8.0 &&
  forward <= radius &&
  side <=
  Float::from_double(18.0) +
  clampf(forward, 0.0, radius) * Float::from_double(0.28)
}

///|
fn uppercut_hit_enemy(
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
  if not(enemy_in_uppercut_arc(player, enemy)) {
    return false
  }

  enemy.hp -= 2 + (player.weapon_level + 1) / 2
  enemy.freeze_timer = melee_stun_time * 0.8 +
    Float::from_int(hit_order) * Float::from_double(0.08)
  enemy.ai_move_timer = 0.0
  enemy.blink_timer = 1.0
  enemy.dir = opposite_dir(player.dir)

  let dir_x = dir_vector_x(player.dir)
  let dir_y = dir_vector_y(player.dir)
  let launch = Float::from_double(14.0) +
    Float::from_int(hit_order) * Float::from_double(1.6)
  let nx = enemy.x + dir_x * launch
  let ny = enemy.y + dir_y * launch
  if not(tank_hits_world(game, nx, ny)) &&
    not(tank_hits_players(game, nx, ny, -1)) &&
    not(tank_hits_enemies(game, nx, ny, enemy_index)) {
    enemy.x = nx
    enemy.y = ny
  }

  spawn_spark_burst(game, enemy.x, enemy.y, 11 + hit_order * 2)
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
    if uppercut_hit_enemy(game, player, i, team, hits) {
      hits += 1
    }
  }

  player.spin_timer = spin_attack_duration
  player.spin_cooldown_timer = spin_attack_cooldown
  player.ai_move_timer = spin_attack_duration * Float::from_double(0.9)
  player.ai_fire_timer = melee_cooldown * Float::from_double(0.55)

  let fx = player.x +
    dir_vector_x(player.dir) * (tank_half + Float::from_double(13.0))
  let fy = player.y +
    dir_vector_y(player.dir) * (tank_half + Float::from_double(13.0))
  spawn_spark_burst(game, fx, fy, 13 + hits * 2)
  push_camera_shake(
    game,
    Float::from_double(1.0) + Float::from_int(hits) * Float::from_double(0.34),
  )

  if hits > 0 {
    grant_score(game, team, hits * spin_attack_bonus)
    bump_combo(game)
  }
}
