///|
fn clear_entities_for_stage(game : @types.Game) -> Unit {
  for i in 0..<game.enemies.length() {
    game.enemies[i] = @types.Tank::inactive()
  }
  for i in 0..<game.bullets.length() {
    game.bullets[i] = @types.Bullet::inactive()
  }
  for i in 0..<game.bombs.length() {
    game.bombs[i] = @types.Bomb::inactive()
  }
  for i in 0..<game.particles.length() {
    game.particles[i] = @types.Particle::inactive()
  }
  for i in 0..<game.powerups.length() {
    game.powerups[i] = @types.Powerup::inactive()
  }
  game.enemies_alive = 0
  game.enemies_spawned = 0
  game.spawn_timer = @types.enemy_spawn_period * game.profile.spawn_scale
  game.freeze_all_timer = 0.0
  game.shovel_timer = 0.0
  game.kill_combo = 0
  game.combo_timer = 0.0
  game.base_flash = 0.0
}

///|
fn stage_enemy_total(stage : Int) -> Int {
  let wave = stage + 1
  @types.clampi(16 + wave * 2, 18, 44)
}

///|
fn stage_enemy_kind(game : @types.Game, stage : Int, spawned_index : Int) -> Int {
  let wave = stage + 1
  let roll = @types.rand_range(game, 0, 99)
  if wave < 4 {
    if roll < 70 {
      @types.enemy_basic
    } else if roll < 88 {
      @types.enemy_fast
    } else if roll < 96 {
      @types.enemy_sniper
    } else {
      @types.enemy_heavy
    }
  } else if wave < 10 {
    if roll < 52 {
      @types.enemy_basic
    } else if roll < 72 {
      @types.enemy_fast
    } else if roll < 88 {
      @types.enemy_sniper
    } else {
      @types.enemy_heavy
    }
  } else {
    let bias = (spawned_index + wave) % 6
    if bias == 0 {
      @types.enemy_heavy
    } else if roll < 36 {
      @types.enemy_basic
    } else if roll < 58 {
      @types.enemy_fast
    } else if roll < 80 {
      @types.enemy_sniper
    } else {
      @types.enemy_heavy
    }
  }
}

///|
fn parse_level_char(ch : Byte) -> (Int, Int) {
  if ch == b'#' {
    (@types.tile_brick, 1)
  } else if ch == b'@' {
    (@types.tile_steel, 999)
  } else if ch == b'~' {
    (@types.tile_water, 1)
  } else if ch == b'^' {
    (@types.tile_bush, 1)
  } else if ch == b'=' {
    (@types.tile_ice, 1)
  } else if ch == b'B' {
    (@types.tile_base, 1)
  } else {
    (@types.tile_empty, 0)
  }
}

///|
fn cache_base_ring(game : @types.Game) -> Unit {
  for i in 0..<@types.base_ring_count {
    let tx = @types.base_ring_x[i]
    let ty = @types.base_ring_y[i]
    game.base_tiles_cached[i] = @types.get_tile(game, tx, ty)
  }
}

///|
fn apply_shovel_fortress(game : @types.Game) -> Unit {
  for i in 0..<@types.base_ring_count {
    let tx = @types.base_ring_x[i]
    let ty = @types.base_ring_y[i]
    let tile = @types.get_tile(game, tx, ty)
    if tile != @types.tile_base {
      @types.set_tile(game, tx, ty, @types.tile_steel, 999)
    }
  }
}

///|
fn restore_base_ring(game : @types.Game) -> Unit {
  for i in 0..<@types.base_ring_count {
    let tx = @types.base_ring_x[i]
    let ty = @types.base_ring_y[i]
    let cached = game.base_tiles_cached[i]
    if @types.get_tile(game, tx, ty) != @types.tile_base {
      if cached == @types.tile_steel {
        @types.set_tile(game, tx, ty, @types.tile_steel, 999)
      } else if cached == @types.tile_brick {
        @types.set_tile(game, tx, ty, @types.tile_brick, 1)
      } else if cached == @types.tile_empty {
        @types.set_tile(game, tx, ty, @types.tile_empty, 0)
      } else {
        @types.set_tile(game, tx, ty, cached, 1)
      }
    }
  }
}

///|
fn respawn_player_tank(game : @types.Game, index : Int) -> Unit {
  let spawn_x = if index == 0 { @types.player1_spawn_x } else { @types.player2_spawn_x }
  let spawn_y = if index == 0 { @types.player1_spawn_y } else { @types.player2_spawn_y }
  let player = game.players[index]
  player.active = true
  player.x = spawn_x
  player.y = spawn_y
  player.hp = 1
  player.move_speed = @types.speed_player
  player.reload_delay = @types.player_reload_base *
    (1.0 - Float::from_int(player.weapon_level) * 0.07)
  player.reload_timer = 0.0
  player.ai_move_timer = 0.0
  player.ai_fire_timer = 0.0
  player.ai_stuck_timer = 0.0
  player.dir = @types.dir_up
  player.invuln_timer = @types.player_invuln_spawn
  player.shield_timer = 0.0
  player.respawn_timer = 0.0
  player.skid_timer = 0.0
  player.blink_timer = 0.0
}

///|
fn prepare_players_for_stage(game : @types.Game) -> Unit {
  for i in 0..<@types.max_players {
    if i == 1 && not(game.coop_enabled) {
      game.players[i].active = false
      game.players[i].lives = 0
      game.players[i].respawn_timer = 0.0
      continue
    }
    if game.players[i].lives < 0 {
      game.players[i].lives = 0
    }
    if game.players[i].lives == 0 {
      game.players[i].active = false
      game.players[i].respawn_timer = 0.0
    } else {
      respawn_player_tank(game, i)
    }
  }
}

///|
fn load_stage_map(game : @types.Game, stage : Int) -> Unit {
  let rows = @levels.level_pattern(stage)
  for y in 0..<@types.map_tiles_h {
    let row = rows[y]
    let bytes = @utf8.encode(row)
    for x in 0..<@types.map_tiles_w {
      let ch = bytes[x]
      let (tile, hp) = parse_level_char(ch)
      @types.set_tile(game, x, y, tile, hp)
    }
  }

  // Guarantee a fortified base shell in case the pattern is too open.
  for i in 0..<@types.base_ring_count {
    let tx = @types.base_ring_x[i]
    let ty = @types.base_ring_y[i]
    if @types.get_tile(game, tx, ty) == @types.tile_empty {
      @types.set_tile(game, tx, ty, @types.tile_brick, 1)
    }
  }

  @types.set_tile(game, @types.base_tile_x, @types.base_tile_y, @types.tile_base, 1)
  @types.set_tile(game, @types.base_tile_x + 1, @types.base_tile_y, @types.tile_base, 1)

  game.base_alive = true
  cache_base_ring(game)
}

///|
fn reset_campaign(game : @types.Game) -> Unit {
  game.score_total = 0
  game.stage_index = 0
  for i in 0..<@types.max_players {
    game.players[i] = if i == 0 {
      @types.Tank::new_player(0, @types.player1_spawn_x, @types.player1_spawn_y)
    } else {
      @types.Tank::new_player(1, @types.player2_spawn_x, @types.player2_spawn_y)
    }
    if i == 1 && not(game.coop_enabled) {
      game.players[i].active = false
      game.players[i].lives = 0
    }
  }
}

///|
fn load_stage(game : @types.Game, stage : Int) -> Unit {
  game.profile = @levels.get_stage_profile(stage)
  clear_entities_for_stage(game)
  load_stage_map(game, stage)
  prepare_players_for_stage(game)
  let base_total = stage_enemy_total(stage)
  game.enemies_to_spawn = @types.clampi(base_total + game.profile.enemy_bonus, 18, 60)
  game.stage_intro_timer = if game.demo_mode { 0.45 } else { @types.stage_intro_time }
  game.stage_clear_timer = 0.0
  game.game_over_timer = 0.0
  game.campaign_clear_timer = 0.0
  game.state = @types.state_stage_intro
}

///|
fn start_new_campaign(game : @types.Game) -> Unit {
  reset_campaign(game)
  load_stage(game, 0)
}
