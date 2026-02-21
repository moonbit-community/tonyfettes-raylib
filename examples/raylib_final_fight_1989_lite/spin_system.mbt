///|
fn is_player_spin_pressed(index : Int) -> Bool {
  if index == 0 {
    @raylib.is_key_pressed(@raylib.KeyH) || @raylib.is_key_pressed(@raylib.KeyJ)
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
fn enemy_in_rush_lane(player : Tank, enemy : Tank) -> Bool {
  let dx = enemy.x - player.x
  let dy = enemy.y - player.y
  let dir_x = dir_vector_x(player.dir)
  let dir_y = dir_vector_y(player.dir)
  let forward = dx * dir_x + dy * dir_y
  let side = absf(dx * dir_y - dy * dir_x)
  forward >= -5.0 && forward <= 36.0 && side <= 22.0
}

///|
fn rush_hit_enemy(
  game : Game,
  player : Tank,
  enemy_index : Int,
  team : Int,
  step_index : Int,
) -> Bool {
  let enemy = game.enemies[enemy_index]
  if not(enemy.active) || enemy.invuln_timer > 0.0 {
    return false
  }
  if not(enemy_in_rush_lane(player, enemy)) {
    return false
  }

  enemy.hp -= 2 + (player.weapon_level + 1) / 2
  enemy.freeze_timer = melee_stun_time * 0.55 +
    Float::from_int(step_index) * Float::from_double(0.03)
  enemy.ai_move_timer = 0.0
  enemy.blink_timer = 1.0
  enemy.dir = player.dir

  let push = Float::from_double(9.0) +
    Float::from_int(step_index) * Float::from_double(0.8)
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

  spawn_spark_burst(game, enemy.x, enemy.y, 10 + step_index)
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
  let dir_x = dir_vector_x(player.dir)
  let dir_y = dir_vector_y(player.dir)
  let steps = 6
  let step_dist : Float = 10.0
  let mut hits = 0

  for s = 0; s < steps; s = s + 1 {
    let nx = player.x + dir_x * step_dist
    let ny = player.y + dir_y * step_dist
    if tank_hits_world(game, nx, ny) ||
      tank_hits_players(game, nx, ny, player_index) {
      break
    }
    player.x = nx
    player.y = ny

    for enemy_i = 0; enemy_i < game.enemies.length(); enemy_i = enemy_i + 1 {
      if rush_hit_enemy(game, player, enemy_i, team, s) {
        hits += 1
      }
    }
  }

  player.spin_timer = spin_attack_duration
  player.spin_cooldown_timer = spin_attack_cooldown
  player.ai_move_timer = spin_attack_duration
  player.ai_fire_timer = melee_cooldown * Float::from_double(0.52)
  spawn_spark_burst(game, player.x, player.y, 12 + hits * 2)
  push_camera_shake(
    game,
    Float::from_double(1.1) + Float::from_int(hits) * Float::from_double(0.28),
  )

  if hits > 0 {
    grant_score(game, team, hits * spin_attack_bonus)
    bump_combo(game)
  }
}
