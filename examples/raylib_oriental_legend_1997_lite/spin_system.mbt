///|
fn is_player_spin_pressed(index : Int) -> Bool {
  if index == 0 {
    @raylib.is_key_pressed(@raylib.KeyN) || @raylib.is_key_pressed(@raylib.KeyM)
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

  let hit_r = spin_attack_radius + tank_half
  if distance_sq(player.x, player.y, enemy.x, enemy.y) > hit_r * hit_r {
    return false
  }

  enemy.hp -= 2 + player.weapon_level / 2
  enemy.freeze_timer = melee_stun_time * 0.76 +
    Float::from_int(hit_order) * 0.08
  enemy.ai_move_timer = 0.0
  enemy.blink_timer = 1.0
  enemy.dir = opposite_dir(enemy.dir)
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
  player.ai_move_timer = spin_attack_duration * 0.9
  player.ai_fire_timer = melee_cooldown * 0.6
  spawn_spark_burst(game, player.x, player.y, 10 + hits * 2)
  push_camera_shake(game, 0.8 + Float::from_int(hits) * 0.3)

  if hits > 0 {
    grant_score(game, team, hits * spin_attack_bonus)
    bump_combo(game)
  }
}
