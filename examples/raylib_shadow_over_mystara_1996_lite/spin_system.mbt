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
fn enemy_in_rune_field(game : Game, player : Tank, enemy : Tank) -> Bool {
  let max_r = spin_attack_radius + tank_half
  distance_sq(player.x, player.y, enemy.x, enemy.y) <= max_r * max_r &&
  not(sight_blocked(game, player.x, player.y, enemy.x, enemy.y))
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
  if not(enemy_in_rune_field(game, player, enemy)) {
    return false
  }

  let range = spin_attack_radius + tank_half
  let dist_sq = distance_sq(player.x, player.y, enemy.x, enemy.y)
  let dist = dist_sq.sqrt()
  let one = Float::from_double(1.0)
  let ratio = clampf(one - dist / range, 0.0, one)
  let bonus = if ratio > Float::from_double(0.66) {
    2
  } else if ratio > Float::from_double(0.33) {
    1
  } else {
    0
  }

  enemy.hp -= 1 + bonus + player.weapon_level / 2
  enemy.freeze_timer = melee_stun_time *
    (Float::from_double(0.52) + ratio * Float::from_double(0.48))
  enemy.ai_move_timer = 0.0
  enemy.blink_timer = 1.0
  enemy.dir = opposite_dir(enemy.dir)

  let safe_dist = if dist < Float::from_double(0.01) {
    Float::from_double(0.01)
  } else {
    dist
  }
  let ux = (enemy.x - player.x) / safe_dist
  let uy = (enemy.y - player.y) / safe_dist
  let push = Float::from_double(7.0) + ratio * Float::from_double(16.0)
  let nx = enemy.x + ux * push
  let ny = enemy.y + uy * push
  if not(tank_hits_world(game, nx, ny)) &&
    not(tank_hits_players(game, nx, ny, -1)) &&
    not(tank_hits_enemies(game, nx, ny, enemy_index)) {
    enemy.x = nx
    enemy.y = ny
  }

  spawn_spark_burst(game, enemy.x, enemy.y, 9 + bonus * 4 + hit_order)

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
  player.ai_move_timer = spin_attack_duration * Float::from_double(0.92)
  player.ai_fire_timer = melee_cooldown * Float::from_double(0.45)
  spawn_spark_burst(game, player.x, player.y, 15 + hits * 2)
  push_camera_shake(
    game,
    Float::from_double(1.0) + Float::from_int(hits) * Float::from_double(0.32),
  )

  if hits > 0 {
    grant_score(game, team, hits * spin_attack_bonus)
    bump_combo(game)
  }
}
