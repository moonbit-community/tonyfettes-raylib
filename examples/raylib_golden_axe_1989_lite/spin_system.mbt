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
fn roar_hit_enemy(
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
  let dist_sq = distance_sq(player.x, player.y, enemy.x, enemy.y)
  if dist_sq > hit_r * hit_r {
    return false
  }

  enemy.hp -= 2 + player.weapon_level / 2
  enemy.freeze_timer = melee_stun_time * Float::from_double(0.74) +
    Float::from_int(hit_order) * Float::from_double(0.04)
  enemy.ai_move_timer = 0.0
  enemy.blink_timer = 1.0
  enemy.dir = opposite_dir(enemy.dir)

  let dx = enemy.x - player.x
  let dy = enemy.y - player.y
  let dist = dist_sq.sqrt()
  let safe_dist = if dist < Float::from_double(0.01) {
    Float::from_double(0.01)
  } else {
    dist
  }
  let push = Float::from_double(9.0) +
    Float::from_int(hit_order) * Float::from_double(0.8)
  let nx = enemy.x + dx / safe_dist * push
  let ny = enemy.y + dy / safe_dist * push
  if not(tank_hits_world(game, nx, ny)) &&
    not(tank_hits_players(game, nx, ny, -1)) &&
    not(tank_hits_enemies(game, nx, ny, enemy_index)) {
    enemy.x = nx
    enemy.y = ny
  }

  spawn_spark_burst(game, enemy.x, enemy.y, 9 + hit_order * 2)
  if enemy.hp <= 0 {
    destroy_enemy(game, enemy_index, team)
  }
  true
}

///|
fn shatter_enemy_bullets(game : Game, player : Tank, team : Int) -> Int {
  let mut cleared = 0
  let clear_r = spin_attack_radius + Float::from_double(8.0)
  for i = 0; i < game.bullets.length(); i = i + 1 {
    let bullet = game.bullets[i]
    if not(bullet.active) || bullet.owner_team != team_enemy {
      continue i + 1
    }
    if distance_sq(player.x, player.y, bullet.x, bullet.y) <= clear_r * clear_r {
      bullet.active = false
      spawn_spark_burst(game, bullet.x, bullet.y, 4)
      cleared += 1
    }
  }
  if cleared > 0 {
    grant_score(game, team, cleared * 6)
  }
  cleared
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
    if roar_hit_enemy(game, player, i, team, hits) {
      hits += 1
    }
  }
  let cleared = shatter_enemy_bullets(game, player, team)

  player.spin_timer = spin_attack_duration
  player.spin_cooldown_timer = spin_attack_cooldown
  player.ai_move_timer = spin_attack_duration
  player.ai_fire_timer = melee_cooldown * Float::from_double(0.45)
  player.shield_timer = if player.shield_timer < Float::from_double(0.42) {
    Float::from_double(0.42)
  } else {
    player.shield_timer
  }

  spawn_spark_burst(game, player.x, player.y, 15 + hits * 2 + cleared)
  push_camera_shake(
    game,
    Float::from_double(1.0) +
    Float::from_int(hits) * Float::from_double(0.32) +
    Float::from_int(cleared) * Float::from_double(0.08),
  )

  if hits > 0 {
    grant_score(game, team, hits * spin_attack_bonus)
    bump_combo(game)
  }
}
