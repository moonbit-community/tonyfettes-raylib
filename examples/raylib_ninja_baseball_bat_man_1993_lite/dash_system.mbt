///|
fn is_player_dash_pressed(index : Int) -> Bool {
  if index == 0 {
    @raylib.is_key_pressed(@raylib.KeyV) || @raylib.is_key_pressed(@raylib.KeyB)
  } else {
    @raylib.is_key_pressed(@raylib.KeyR) || @raylib.is_key_pressed(@raylib.KeyT)
  }
}

///|
fn can_player_dash(game : Game, player_index : Int) -> Bool {
  let player = game.players[player_index]
  player.active &&
  player.ai_stuck_timer <= 0.0 &&
  player.ai_move_timer <= 0.0 &&
  player.guard_timer <= 0.0
}

///|
fn dash_hit_enemy(
  game : Game,
  player : Tank,
  enemy_index : Int,
  team : Int,
) -> Bool {
  let enemy = game.enemies[enemy_index]
  if not(enemy.active) || enemy.invuln_timer > 0.0 || enemy.freeze_timer > 0.35 {
    return false
  }

  let hit_r = dash_hit_radius + tank_half
  if distance_sq(player.x, player.y, enemy.x, enemy.y) > hit_r * hit_r {
    return false
  }

  enemy.hp -= 3 + player.weapon_level / 2
  enemy.freeze_timer = melee_stun_time * 0.82
  enemy.blink_timer = 1.1
  enemy.dir = opposite_dir(player.dir)
  spawn_spark_burst(game, enemy.x, enemy.y, 12)

  if enemy.hp <= 0 {
    destroy_enemy(game, enemy_index, team)
  }
  true
}

///|
fn perform_player_dash(game : Game, player_index : Int) -> Unit {
  if not(can_player_dash(game, player_index)) {
    return
  }

  let player = game.players[player_index]
  let team = team_of_player(player_index)
  let dir_x = dir_vector_x(player.dir)
  let dir_y = dir_vector_y(player.dir)
  let steps = 6
  let step_dist = dash_strike_distance / Float::from_int(steps)
  let mut hits = 0

  for _s = 0; _s < steps; _s = _s + 1 {
    let nx = player.x + dir_x * step_dist
    let ny = player.y + dir_y * step_dist
    if tank_hits_world(game, nx, ny) ||
      tank_hits_players(game, nx, ny, player_index) {
      break
    }
    player.x = nx
    player.y = ny

    for enemy_i = 0; enemy_i < game.enemies.length(); enemy_i = enemy_i + 1 {
      if dash_hit_enemy(game, player, enemy_i, team) {
        hits += 1
      }
    }
  }

  let slash_x = player.x + dir_x * (tank_half + 7.0)
  let slash_y = player.y + dir_y * (tank_half + 7.0)
  spawn_spark_burst(game, slash_x, slash_y, 11 + hits * 2)
  push_camera_shake(game, 1.2 + Float::from_int(hits) * 0.3)

  if hits > 0 {
    grant_score(game, team, hits * dash_chain_bonus)
    bump_combo(game)
  }

  player.ai_stuck_timer = dash_cooldown
  player.ai_move_timer = melee_anim_time * 1.25
}
