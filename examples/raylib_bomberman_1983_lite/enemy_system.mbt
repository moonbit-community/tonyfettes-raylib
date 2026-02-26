///|
fn enemy_spawn_x(slot : Int) -> Float {
  if slot == 0 {
    enemy_spawn_x0
  } else if slot == 1 {
    enemy_spawn_x1
  } else {
    enemy_spawn_x2
  }
}

///|
fn alloc_enemy_slot(game : Game) -> Int {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_enemy(game : Game) -> Bool {
  if game.enemies_spawned >= game.enemies_to_spawn {
    return false
  }
  if game.enemies_alive >= enemy_on_field_limit {
    return false
  }

  let slot = alloc_enemy_slot(game)
  if slot < 0 {
    return false
  }

  let spawn_lane = rand_range(game, 0, 2)
  let sx = enemy_spawn_x(spawn_lane)
  let sy = enemy_spawn_y

  if tank_hits_world(game, sx, sy) ||
    tank_hits_players(game, sx, sy, -1) ||
    tank_hits_enemies(game, sx, sy, -1) {
    return false
  }

  let kind = stage_enemy_kind(game, game.stage_index, game.enemies_spawned)
  game.enemies[slot] = Tank::new_enemy(kind, sx, sy)
  game.enemies_spawned += 1
  game.enemies_alive += 1
  spawn_respawn_burst(game, sx, sy)
  true
}

///|
fn choose_enemy_target_player(game : Game, enemy : Tank) -> Int {
  let mut best_idx = -1
  let mut best_dist : Float = Float::from_int(1000000000)
  for i = 0; i < max_players; i = i + 1 {
    let player = game.players[i]
    if player.active {
      let d = distance_sq(enemy.x, enemy.y, player.x, player.y)
      if d < best_dist {
        best_dist = d
        best_idx = i
      }
    }
  }
  best_idx
}

///|
fn enemy_desired_dir(game : Game, enemy : Tank) -> Int {
  let target_player = choose_enemy_target_player(game, enemy)
  let mut target_x = tile_center_x(base_tile_x)
  let mut target_y = tile_center_y(base_tile_y)

  if target_player >= 0 {
    let player = game.players[target_player]
    if rand_range(game, 0, 99) < 62 {
      target_x = player.x
      target_y = player.y
    }
  }

  let dx = target_x - enemy.x
  let dy = target_y - enemy.y
  let horiz = if dx < 0.0 { dir_left } else { dir_right }
  let vert = if dy < 0.0 { dir_up } else { dir_down }

  let r = rand_range(game, 0, 99)
  if absf(dx) > absf(dy) {
    if r < 72 {
      horiz
    } else if r < 92 {
      vert
    } else {
      rand_range(game, 0, 3)
    }
  } else if r < 72 {
    vert
  } else if r < 92 {
    horiz
  } else {
    rand_range(game, 0, 3)
  }
}

///|
fn try_move_enemy(
  game : Game,
  enemy_index : Int,
  dir : Int,
  dt : Float,
) -> Bool {
  let enemy = game.enemies[enemy_index]
  let step = enemy.move_speed * dt
  let nx = enemy.x + dir_vector_x(dir) * step
  let ny = enemy.y + dir_vector_y(dir) * step

  if tank_hits_world(game, nx, ny) {
    return false
  }
  if tank_hits_enemies(game, nx, ny, enemy_index) {
    return false
  }

  enemy.x = nx
  enemy.y = ny
  true
}

///|
fn enemy_shoot_if_ready(_game : Game, _enemy_index : Int) -> Unit {
  ()
}

///|
fn update_enemy_spawn(game : Game, dt : Float) -> Unit {
  if game.enemies_spawned >= game.enemies_to_spawn {
    return
  }
  game.spawn_timer -= dt
  if game.spawn_timer <= 0.0 {
    if spawn_enemy(game) {
      game.spawn_timer = enemy_spawn_period * game.profile.spawn_scale
    } else {
      game.spawn_timer = 0.25 * game.profile.spawn_scale
    }
  }
}

///|
fn update_enemies(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      continue i + 1
    }

    let enemy = game.enemies[i]
    if enemy.reload_timer > 0.0 {
      enemy.reload_timer -= dt
      if enemy.reload_timer < 0.0 {
        enemy.reload_timer = 0.0
      }
    }
    if enemy.invuln_timer > 0.0 {
      enemy.invuln_timer -= dt
      if enemy.invuln_timer < 0.0 {
        enemy.invuln_timer = 0.0
      }
    }

    if game.freeze_all_timer > 0.0 {
      continue i + 1
    }

    enemy.ai_move_timer -= dt
    enemy.ai_fire_timer -= dt

    if enemy.ai_move_timer <= 0.0 {
      enemy.ai_move_timer = rand_rangef(game, 0.35, 1.25)
      let new_dir = enemy_desired_dir(game, enemy)
      enemy.dir = new_dir
    }

    let moved = try_move_enemy(game, i, enemy.dir, dt)
    if not(moved) {
      enemy.ai_stuck_timer += dt
      if enemy.ai_stuck_timer > 0.14 {
        enemy.ai_stuck_timer = 0.0
        enemy.dir = rand_range(game, 0, 3)
      }
    } else {
      enemy.ai_stuck_timer = 0.0
    }

    if enemy.ai_fire_timer <= 0.0 {
      enemy.ai_fire_timer = rand_rangef(game, 0.18, 0.62)
      enemy_shoot_if_ready(game, i)
    }

    for p = 0; p < max_players; p = p + 1 {
      let player = game.players[p]
      if not(player.active) {
        continue p + 1
      }
      let hit_r = tank_half + tank_half - 2.0
      if distance_sq(enemy.x, enemy.y, player.x, player.y) <= hit_r * hit_r {
        on_player_destroyed(game, p)
      }
    }
  }
}

///|
fn destroy_enemy(game : Game, enemy_index : Int, killer_team : Int) -> Unit {
  if not(game.enemies[enemy_index].active) {
    return
  }

  let enemy = game.enemies[enemy_index]
  game.enemies[enemy_index].active = false
  game.enemies_alive -= 1

  let score = enemy_score(enemy.enemy_kind)
  let mult = combo_multiplier(game)
  grant_score(game, killer_team, score * mult)
  bump_combo(game)

  spawn_explosion(game, enemy.x, enemy.y, 1.1)

  // Chance to drop a powerup.
  let drop_roll = rand_range(game, 0, 99)
  let base_bias = if enemy.enemy_kind == enemy_heavy { 22 } else { 14 }
  let drop_bias = clampi(base_bias + game.profile.drop_bonus, 4, 55)
  if drop_roll < drop_bias {
    spawn_random_powerup(game, enemy.x, enemy.y)
  }
}

///|
fn stage_is_clear(game : Game) -> Bool {
  game.enemies_spawned >= game.enemies_to_spawn && game.enemies_alive <= 0
}
