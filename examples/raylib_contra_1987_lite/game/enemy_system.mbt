///|
fn enemy_spawn_x(slot : Int) -> Float {
  if slot == 0 {
    @types.enemy_spawn_x0
  } else if slot == 1 {
    @types.enemy_spawn_x1
  } else {
    @types.enemy_spawn_x2
  }
}

///|
fn alloc_enemy_slot(game : @types.Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_enemy(game : @types.Game) -> Bool {
  if game.enemies_spawned >= game.enemies_to_spawn {
    return false
  }
  if game.enemies_alive >= @types.enemy_on_field_limit {
    return false
  }

  let slot = alloc_enemy_slot(game)
  if slot < 0 {
    return false
  }

  let spawn_lane = @types.rand_range(game, 0, 2)
  let sx = enemy_spawn_x(spawn_lane)
  let sy = @types.enemy_spawn_y

  if @world.tank_hits_world(game, sx, sy) ||
    @world.tank_hits_players(game, sx, sy, -1) ||
    @world.tank_hits_enemies(game, sx, sy, -1) {
    return false
  }

  let kind = stage_enemy_kind(game, game.stage_index, game.enemies_spawned)
  game.enemies[slot] = @types.Tank::new_enemy(kind, sx, sy)
  game.enemies_spawned += 1
  game.enemies_alive += 1
  @particles.spawn_respawn_burst(game, sx, sy)
  true
}

///|
fn choose_enemy_target_player(game : @types.Game, enemy : @types.Tank) -> Int {
  let mut best_idx = -1
  let mut best_dist : Float = Float::from_int(1000000000)
  for i in 0..<@types.max_players {
    let player = game.players[i]
    if player.active {
      let d = @types.distance_sq(enemy.x, enemy.y, player.x, player.y)
      if d < best_dist {
        best_dist = d
        best_idx = i
      }
    }
  }
  best_idx
}

///|
fn enemy_desired_dir(game : @types.Game, enemy : @types.Tank) -> @types.Dir {
  let target_player = choose_enemy_target_player(game, enemy)
  let mut target_x = @types.tile_center_x(@types.base_tile_x)
  let mut target_y = @types.tile_center_y(@types.base_tile_y)

  if target_player >= 0 {
    let player = game.players[target_player]
    if @types.rand_range(game, 0, 99) < 62 {
      target_x = player.x
      target_y = player.y
    }
  }

  let dx = target_x - enemy.x
  let dy = target_y - enemy.y
  let horiz : @types.Dir = if dx < 0.0 { @types.Left } else { @types.Right }
  let vert : @types.Dir = if dy < 0.0 { @types.Up } else { @types.Down }

  let r = @types.rand_range(game, 0, 99)
  if @types.absf(dx) > @types.absf(dy) {
    if r < 72 {
      horiz
    } else if r < 92 {
      vert
    } else {
      @types.rand_dir(game)
    }
  } else if r < 72 {
    vert
  } else if r < 92 {
    horiz
  } else {
    @types.rand_dir(game)
  }
}

///|
fn try_move_enemy(
  game : @types.Game,
  enemy_index : Int,
  dir : @types.Dir,
  dt : Float,
) -> Bool {
  let enemy = game.enemies[enemy_index]
  let step = enemy.move_speed * dt
  let nx = enemy.x + @types.dir_vector_x(dir) * step
  let ny = enemy.y + @types.dir_vector_y(dir) * step

  if @world.tank_hits_world(game, nx, ny) {
    return false
  }
  if @world.tank_hits_enemies(game, nx, ny, enemy_index) {
    return false
  }
  if @world.tank_hits_players(game, nx, ny, -1) {
    return false
  }

  enemy.x = nx
  enemy.y = ny
  true
}

///|
fn enemy_shoot_if_ready(game : @types.Game, enemy_index : Int) -> Unit {
  let enemy = game.enemies[enemy_index]
  if enemy.reload_timer > 0.0 || enemy.invuln_timer > 0.0 {
    return
  }

  let mut should_fire = false
  let target_player = choose_enemy_target_player(game, enemy)
  if target_player >= 0 {
    let player = game.players[target_player]
    if @types.absf(player.x - enemy.x) < Float::from_int(@types.tile_size) * 0.5 ||
      @types.absf(player.y - enemy.y) < Float::from_int(@types.tile_size) * 0.5 {
      if not(sight_blocked(game, enemy.x, enemy.y, player.x, player.y)) {
        should_fire = true
      }
    }
  }

  if not(should_fire) {
    let base_x = @types.tile_center_x(@types.base_tile_x)
    let base_y = @types.tile_center_y(@types.base_tile_y)
    if @types.absf(base_x - enemy.x) < Float::from_int(@types.tile_size) * 0.5 ||
      @types.absf(base_y - enemy.y) < Float::from_int(@types.tile_size) * 0.5 {
      if not(sight_blocked(game, enemy.x, enemy.y, base_x, base_y)) {
        should_fire = true
      }
    }
  }

  if not(should_fire) {
    let chance = if enemy.enemy_kind == @types.Fast {
      16
    } else if enemy.enemy_kind == @types.Heavy {
      11
    } else if enemy.enemy_kind == @types.Sniper {
      26
    } else {
      13
    }
    should_fire = @types.rand_range(game, 0, 99) < chance
  }

  if should_fire {
    let muzzle_x = enemy.x +
      @types.dir_vector_x(enemy.dir) * (@types.tank_half + 3.0)
    let muzzle_y = enemy.y +
      @types.dir_vector_y(enemy.dir) * (@types.tank_half + 3.0)
    let speed = if enemy.enemy_kind == @types.Sniper {
      @types.bullet_speed_enemy + 40.0
    } else {
      @types.bullet_speed_enemy
    }
    let power = if enemy.enemy_kind == @types.Heavy { 2 } else { 1 }
    spawn_bullet(
      game,
      @types.Enemy,
      muzzle_x,
      muzzle_y,
      enemy.dir,
      speed,
      power,
    )
    enemy.reload_timer = enemy.reload_delay
    @particles.spawn_spark_burst(game, muzzle_x, muzzle_y, 4)
  }
}

///|
fn update_enemy_spawn(game : @types.Game, dt : Float) -> Unit {
  if game.enemies_spawned >= game.enemies_to_spawn {
    return
  }
  game.spawn_timer -= dt
  if game.spawn_timer <= 0.0 {
    if spawn_enemy(game) {
      game.spawn_timer = @types.enemy_spawn_period * game.profile.spawn_scale
    } else {
      game.spawn_timer = 0.25 * game.profile.spawn_scale
    }
  }
}

///|
fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
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
      continue
    }

    enemy.ai_move_timer -= dt
    enemy.ai_fire_timer -= dt

    if enemy.ai_move_timer <= 0.0 {
      enemy.ai_move_timer = @types.rand_rangef(game, 0.35, 1.25)
      let new_dir = enemy_desired_dir(game, enemy)
      enemy.dir = new_dir
    }

    let moved = try_move_enemy(game, i, enemy.dir, dt)
    if not(moved) {
      enemy.ai_stuck_timer += dt
      if enemy.ai_stuck_timer > 0.14 {
        enemy.ai_stuck_timer = 0.0
        enemy.dir = @types.rand_dir(game)
      }
    } else {
      enemy.ai_stuck_timer = 0.0
    }

    if enemy.ai_fire_timer <= 0.0 {
      enemy.ai_fire_timer = @types.rand_rangef(game, 0.18, 0.62)
      enemy_shoot_if_ready(game, i)
    }
  }
}

///|
fn destroy_enemy(
  game : @types.Game,
  enemy_index : Int,
  killer_team : @types.Team,
) -> Unit {
  if not(game.enemies[enemy_index].active) {
    return
  }

  let enemy = game.enemies[enemy_index]
  game.enemies[enemy_index].active = false
  game.enemies_alive -= 1

  let score_val = @types.enemy_score(enemy.enemy_kind)
  let mult = @score.combo_multiplier(game)
  @score.grant_score(game, killer_team, score_val * mult)
  @score.bump_combo(game)

  @particles.spawn_explosion(game, enemy.x, enemy.y, 1.1)

  // Chance to drop a powerup.
  let drop_roll = @types.rand_range(game, 0, 99)
  let base_bias = if enemy.enemy_kind == @types.Heavy { 22 } else { 14 }
  let drop_bias = @types.clampi(base_bias + game.profile.drop_bonus, 4, 55)
  if drop_roll < drop_bias {
    spawn_random_powerup(game, enemy.x, enemy.y)
  }
}

///|
fn stage_is_clear(game : @types.Game) -> Bool {
  game.enemies_spawned >= game.enemies_to_spawn &&
  game.enemies_alive <= 0 &&
  core_objective_done(game)
}
