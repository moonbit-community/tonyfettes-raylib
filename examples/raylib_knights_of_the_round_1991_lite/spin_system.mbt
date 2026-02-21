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
fn charge_slash_hit_enemy(
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

  let hit_r = spin_attack_radius + tank_half
  if distance_sq(player.x, player.y, enemy.x, enemy.y) > hit_r * hit_r {
    return false
  }

  enemy.hp -= 3 + player.weapon_level / 2
  enemy.freeze_timer = melee_stun_time * Float::from_double(0.8) +
    Float::from_int(hit_order) * Float::from_double(0.06)
  enemy.ai_move_timer = 0.0
  enemy.blink_timer = 1.0
  enemy.dir = opposite_dir(enemy.dir)

  let dx = enemy.x - player.x
  let dy = enemy.y - player.y
  let dist = (dx * dx + dy * dy).sqrt()
  let safe_dist = if dist < Float::from_double(0.01) {
    Float::from_double(0.01)
  } else {
    dist
  }
  let push = Float::from_double(10.0) +
    Float::from_int(hit_order) * Float::from_double(1.1)
  let nx = enemy.x + dx / safe_dist * push
  let ny = enemy.y + dy / safe_dist * push
  if not(tank_hits_world(game, nx, ny)) &&
    not(tank_hits_players(game, nx, ny, -1)) &&
    not(tank_hits_enemies(game, nx, ny, enemy_index)) {
    enemy.x = nx
    enemy.y = ny
  }

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
  let dir_x = dir_vector_x(player.dir)
  let dir_y = dir_vector_y(player.dir)

  let mut moved_steps = 0
  let charge_steps = 6
  let step_dist = Float::from_double(9.0)
  for _s = 0; _s < charge_steps; _s = _s + 1 {
    let nx = player.x + dir_x * step_dist
    let ny = player.y + dir_y * step_dist
    if tank_hits_world(game, nx, ny) ||
      tank_hits_players(game, nx, ny, player_index) {
      break
    }
    player.x = nx
    player.y = ny
    moved_steps += 1
  }

  let mut hits = 0
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if charge_slash_hit_enemy(game, player, i, team, hits) {
      hits += 1
    }
  }

  let flank = Float::from_double(14.0)
  let side_x = dir_vector_x((player.dir + 1) % 4)
  let side_y = dir_vector_y((player.dir + 1) % 4)
  spawn_spark_burst(
    game,
    player.x + side_x * flank,
    player.y + side_y * flank,
    10,
  )
  spawn_spark_burst(
    game,
    player.x - side_x * flank,
    player.y - side_y * flank,
    10,
  )

  player.spin_timer = spin_attack_duration
  player.spin_cooldown_timer = spin_attack_cooldown
  player.ai_move_timer = spin_attack_duration
  player.ai_fire_timer = melee_cooldown * Float::from_double(0.45)
  spawn_spark_burst(game, player.x, player.y, 13 + hits * 2 + moved_steps)
  push_camera_shake(
    game,
    Float::from_double(1.1) + Float::from_int(hits) * Float::from_double(0.3),
  )

  if hits > 0 {
    grant_score(game, team, hits * spin_attack_bonus)
    bump_combo(game)
  }
}
