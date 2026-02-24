///|
fn clear_entities_for_stage(game : Game) -> Unit {
  clear_cores(game)
  for i = 0; i < game.enemies.length(); i = i + 1 {
    game.enemies[i] = Tank::inactive()
  }
  for i = 0; i < game.bullets.length(); i = i + 1 {
    game.bullets[i] = Bullet::inactive()
  }
  for i = 0; i < game.particles.length(); i = i + 1 {
    game.particles[i] = Particle::inactive()
  }
  for i = 0; i < game.powerups.length(); i = i + 1 {
    game.powerups[i] = Powerup::inactive()
  }
  game.enemies_alive = 0
  game.enemies_spawned = 0
  game.spawn_timer = enemy_spawn_period * game.profile.spawn_scale
  game.freeze_all_timer = 0.0
  game.shovel_timer = 0.0
  game.kill_combo = 0
  game.combo_timer = 0.0
  game.base_flash = 0.0
}

///|
fn stage_enemy_total(stage : Int) -> Int {
  let wave = stage + 1
  clampi(16 + wave * 2, 18, 44)
}

///|
fn stage_enemy_kind(game : Game, stage : Int, spawned_index : Int) -> Int {
  let wave = stage + 1
  let roll = rand_range(game, 0, 99)
  if wave < 4 {
    if roll < 70 {
      enemy_basic
    } else if roll < 88 {
      enemy_fast
    } else if roll < 96 {
      enemy_sniper
    } else {
      enemy_heavy
    }
  } else if wave < 10 {
    if roll < 52 {
      enemy_basic
    } else if roll < 72 {
      enemy_fast
    } else if roll < 88 {
      enemy_sniper
    } else {
      enemy_heavy
    }
  } else {
    let bias = (spawned_index + wave) % 6
    if bias == 0 {
      enemy_heavy
    } else if roll < 36 {
      enemy_basic
    } else if roll < 58 {
      enemy_fast
    } else if roll < 80 {
      enemy_sniper
    } else {
      enemy_heavy
    }
  }
}

///|
fn parse_level_char(ch : Byte) -> (Int, Int) {
  if ch == b'#' {
    (tile_brick, 1)
  } else if ch == b'@' {
    (tile_steel, 999)
  } else if ch == b'~' {
    (tile_water, 1)
  } else if ch == b'^' {
    (tile_bush, 1)
  } else if ch == b'=' {
    (tile_ice, 1)
  } else if ch == b'B' {
    (tile_base, 1)
  } else {
    (tile_empty, 0)
  }
}

///|
fn cache_base_ring(game : Game) -> Unit {
  for i = 0; i < base_ring_count; i = i + 1 {
    let tx = base_ring_x[i]
    let ty = base_ring_y[i]
    game.base_tiles_cached[i] = get_tile(game, tx, ty)
  }
}

///|
fn apply_shovel_fortress(game : Game) -> Unit {
  for i = 0; i < base_ring_count; i = i + 1 {
    let tx = base_ring_x[i]
    let ty = base_ring_y[i]
    let tile = get_tile(game, tx, ty)
    if tile != tile_base {
      set_tile(game, tx, ty, tile_steel, 999)
    }
  }
}

///|
fn restore_base_ring(game : Game) -> Unit {
  for i = 0; i < base_ring_count; i = i + 1 {
    let tx = base_ring_x[i]
    let ty = base_ring_y[i]
    let cached = game.base_tiles_cached[i]
    if get_tile(game, tx, ty) != tile_base {
      if cached == tile_steel {
        set_tile(game, tx, ty, tile_steel, 999)
      } else if cached == tile_brick {
        set_tile(game, tx, ty, tile_brick, 1)
      } else if cached == tile_empty {
        set_tile(game, tx, ty, tile_empty, 0)
      } else {
        set_tile(game, tx, ty, cached, 1)
      }
    }
  }
}

///|
fn respawn_player_tank(game : Game, index : Int) -> Unit {
  let spawn_x = if index == 0 { player1_spawn_x } else { player2_spawn_x }
  let spawn_y = if index == 0 { player1_spawn_y } else { player2_spawn_y }
  let player = game.players[index]
  player.active = true
  player.x = spawn_x
  player.y = spawn_y
  player.spawn_x = spawn_x
  player.spawn_y = spawn_y
  player.hp = 1
  player.max_hp = 1
  player.move_speed = speed_player
  player.reload_delay = player_reload_base *
    (1.0 - Float::from_int(player.weapon_level) * 0.07)
  player.reload_timer = 0.0
  player.ai_move_timer = 0.0
  player.ai_fire_timer = 0.0
  player.ai_stuck_timer = 0.0
  player.dir = dir_up
  player.invuln_timer = player_invuln_spawn
  player.shield_timer = 0.0
  player.respawn_timer = 0.0
  player.skid_timer = 0.0
  player.blink_timer = 0.0
}

///|
fn prepare_players_for_stage(game : Game) -> Unit {
  for i = 0; i < max_players; i = i + 1 {
    if i == 1 && not(game.coop_enabled) {
      game.players[i].active = false
      game.players[i].lives = 0
      game.players[i].respawn_timer = 0.0
      continue i + 1
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
fn load_stage_map(game : Game, stage : Int) -> Unit {
  let rows = level_pattern(stage)
  for y = 0; y < map_tiles_h; y = y + 1 {
    let row = rows[y]
    let bytes = @utf8.encode(row)
    for x = 0; x < map_tiles_w; x = x + 1 {
      let ch = bytes[x]
      let (tile, hp) = parse_level_char(ch)
      set_tile(game, x, y, tile, hp)
    }
  }

  // Guarantee a fortified base shell in case the pattern is too open.
  for i = 0; i < base_ring_count; i = i + 1 {
    let tx = base_ring_x[i]
    let ty = base_ring_y[i]
    if get_tile(game, tx, ty) == tile_empty {
      set_tile(game, tx, ty, tile_brick, 1)
    }
  }

  set_tile(game, base_tile_x, base_tile_y, tile_base, 1)
  set_tile(game, base_tile_x + 1, base_tile_y, tile_base, 1)

  game.base_alive = true
  cache_base_ring(game)
}

///|
fn reset_campaign(game : Game) -> Unit {
  game.score_total = 0
  game.stage_index = 0
  for i = 0; i < max_players; i = i + 1 {
    game.players[i] = if i == 0 {
      Tank::new_player(0, player1_spawn_x, player1_spawn_y)
    } else {
      Tank::new_player(1, player2_spawn_x, player2_spawn_y)
    }
    if i == 1 && not(game.coop_enabled) {
      game.players[i].active = false
      game.players[i].lives = 0
    }
  }
}

///|
fn load_stage(game : Game, stage : Int) -> Unit {
  game.profile = get_stage_profile(stage)
  clear_entities_for_stage(game)
  load_stage_map(game, stage)
  seed_stage_cores(game, stage)
  prepare_players_for_stage(game)
  let base_total = stage_enemy_total(stage)
  game.enemies_to_spawn = clampi(base_total + game.profile.enemy_bonus, 18, 60)
  game.stage_intro_timer = if game.demo_mode { 0.45 } else { stage_intro_time }
  game.stage_clear_timer = 0.0
  game.game_over_timer = 0.0
  game.campaign_clear_timer = 0.0
  game.state = state_stage_intro
}

///|
fn start_new_campaign(game : Game) -> Unit {
  reset_campaign(game)
  load_stage(game, 0)
}
