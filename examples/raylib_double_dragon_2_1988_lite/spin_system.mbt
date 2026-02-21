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
fn enemy_in_grab_field(player : Tank, enemy : Tank) -> Bool {
  let radius = spin_attack_radius + tank_half
  distance_sq(player.x, player.y, enemy.x, enemy.y) <= radius * radius
}

///|
fn grab_pull_enemy(
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
  if not(enemy_in_grab_field(player, enemy)) {
    return false
  }

  let dx = player.x - enemy.x
  let dy = player.y - enemy.y
  let dist_sq = dx * dx + dy * dy
  let dist = dist_sq.sqrt()
  let safe_dist = if dist < Float::from_double(0.01) {
    Float::from_double(0.01)
  } else {
    dist
  }
  let nx = dx / safe_dist
  let ny = dy / safe_dist
  let pull = Float::from_double(8.0) +
    Float::from_int(hit_order) * Float::from_double(0.6)

  let tx = enemy.x + nx * pull
  let ty = enemy.y + ny * pull
  if not(tank_hits_world(game, tx, ty)) &&
    not(tank_hits_players(game, tx, ty, -1)) &&
    not(tank_hits_enemies(game, tx, ty, enemy_index)) {
    enemy.x = tx
    enemy.y = ty
  }

  let close_bonus = if dist < Float::from_double(15.0) { 1 } else { 0 }
  enemy.hp -= 1 + close_bonus + player.weapon_level / 2
  enemy.freeze_timer = melee_stun_time * Float::from_double(0.72)
  enemy.ai_move_timer = 0.0
  enemy.blink_timer = 1.0
  enemy.dir = opposite_dir(enemy.dir)
  spawn_spark_burst(game, enemy.x, enemy.y, 8 + hit_order * 2 + close_bonus * 2)

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
    if grab_pull_enemy(game, player, i, team, hits) {
      hits += 1
    }
  }

  player.spin_timer = spin_attack_duration
  player.spin_cooldown_timer = spin_attack_cooldown
  player.ai_move_timer = spin_attack_duration * Float::from_double(0.82)
  player.ai_fire_timer = melee_cooldown * Float::from_double(0.48)
  spawn_spark_burst(game, player.x, player.y, 14 + hits * 2)
  push_camera_shake(
    game,
    Float::from_double(0.9) + Float::from_int(hits) * Float::from_double(0.3),
  )

  if hits > 0 {
    grant_score(game, team, hits * spin_attack_bonus)
    bump_combo(game)
  }
}
