///|
fn is_player_melee_pressed(index : Int) -> Bool {
  if index == 0 {
    @raylib.is_key_pressed(@raylib.KeyZ) || @raylib.is_key_pressed(@raylib.KeyC)
  } else {
    @raylib.is_key_pressed(@raylib.KeyE) || @raylib.is_key_pressed(@raylib.KeyF)
  }
}

///|
fn enemy_in_melee_lane(player : Tank, enemy : Tank) -> Bool {
  let dx = enemy.x - player.x
  let dy = enemy.y - player.y
  let dir_x = dir_vector_x(player.dir)
  let dir_y = dir_vector_y(player.dir)
  let forward = dx * dir_x + dy * dir_y
  let side = absf(dx * dir_y - dy * dir_x)
  forward >= 2.0 && forward <= melee_reach && side <= melee_width
}

///|
fn can_player_melee(game : Game, player_index : Int) -> Bool {
  let player = game.players[player_index]
  player.active && player.ai_fire_timer <= 0.0
}

///|
fn melee_hit_enemy(
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
  if not(enemy_in_melee_lane(player, enemy)) {
    return false
  }

  enemy.hp -= 2 + player.weapon_level / 2
  enemy.freeze_timer = melee_stun_time + Float::from_int(hit_order) * 0.1
  enemy.blink_timer = 1.0
  enemy.ai_move_timer = 0.0
  enemy.dir = opposite_dir(player.dir)
  spawn_spark_burst(game, enemy.x, enemy.y, 10 + hit_order * 2)

  if enemy.hp <= 0 {
    destroy_enemy(game, enemy_index, team)
  }
  true
}

///|
fn perform_player_melee(game : Game, player_index : Int) -> Unit {
  if not(can_player_melee(game, player_index)) {
    return
  }

  let player = game.players[player_index]
  let team = team_of_player(player_index)
  let mut hits = 0

  for i = 0; i < game.enemies.length(); i = i + 1 {
    if melee_hit_enemy(game, player, i, team, hits) {
      hits += 1
    }
  }

  let fx = player.x +
    dir_vector_x(player.dir) * (tank_half + melee_reach * 0.55)
  let fy = player.y +
    dir_vector_y(player.dir) * (tank_half + melee_reach * 0.55)
  if hits > 0 {
    grant_score(game, team, hits * melee_chain_bonus)
    bump_combo(game)
    spawn_spark_burst(game, fx, fy, 12 + hits * 3)
    push_camera_shake(game, 1.0 + Float::from_int(hits) * 0.4)
  } else {
    spawn_spark_burst(game, fx, fy, 6)
  }

  player.ai_fire_timer = melee_cooldown
  player.ai_move_timer = melee_anim_time
}
