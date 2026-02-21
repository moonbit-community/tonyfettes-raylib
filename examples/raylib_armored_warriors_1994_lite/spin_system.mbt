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
fn overdrive_hit_enemy(
  game : Game,
  player : Tank,
  enemy_index : Int,
  team : Int,
  phase : Int,
  hit_order : Int,
) -> Bool {
  let enemy = game.enemies[enemy_index]
  if not(enemy.active) || enemy.invuln_timer > 0.0 {
    return false
  }

  let hit_r = spin_attack_radius +
    tank_half +
    Float::from_int(phase) * Float::from_double(6.5)
  if distance_sq(player.x, player.y, enemy.x, enemy.y) > hit_r * hit_r {
    return false
  }

  enemy.hp -= 2 + phase + player.weapon_level / 2
  enemy.freeze_timer = melee_stun_time * Float::from_double(0.76) +
    Float::from_int(phase + hit_order) * Float::from_double(0.05)
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
  let push = Float::from_double(8.0) +
    Float::from_int(phase) * Float::from_double(2.2) +
    Float::from_int(hit_order) * Float::from_double(0.8)
  let nx = enemy.x + dx / safe_dist * push
  let ny = enemy.y + dy / safe_dist * push
  if not(tank_hits_world(game, nx, ny)) &&
    not(tank_hits_players(game, nx, ny, -1)) &&
    not(tank_hits_enemies(game, nx, ny, enemy_index)) {
    enemy.x = nx
    enemy.y = ny
  }

  spawn_spark_burst(game, enemy.x, enemy.y, 8 + phase * 2 + hit_order)
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
  for phase = 0; phase < 3; phase = phase + 1 {
    for i = 0; i < game.enemies.length(); i = i + 1 {
      if overdrive_hit_enemy(game, player, i, team, phase, hits) {
        hits += 1
      }
    }

    let reach = Float::from_int(14 + phase * 9)
    for d = 0; d < 4; d = d + 1 {
      let sx = player.x + dir_vector_x(d) * reach
      let sy = player.y + dir_vector_y(d) * reach
      spawn_spark_burst(game, sx, sy, 7 + phase * 3)
    }
  }

  player.spin_timer = spin_attack_duration
  player.spin_cooldown_timer = spin_attack_cooldown
  player.ai_move_timer = spin_attack_duration
  player.ai_fire_timer = melee_cooldown * Float::from_double(0.42)
  spawn_spark_burst(game, player.x, player.y, 16 + hits * 2)
  push_camera_shake(
    game,
    Float::from_double(1.2) + Float::from_int(hits) * Float::from_double(0.3),
  )

  if hits > 0 {
    grant_score(game, team, hits * spin_attack_bonus)
    bump_combo(game)
  }
}
