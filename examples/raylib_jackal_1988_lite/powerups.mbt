///|
fn alloc_powerup(game : Game) -> Int {
  for i = 0; i < game.powerups.length(); i = i + 1 {
    if not(game.powerups[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_powerup(game : Game, kind : Int, x : Float, y : Float) -> Unit {
  let idx = alloc_powerup(game)
  if idx < 0 {
    return
  }
  game.powerups[idx].active = true
  game.powerups[idx].kind = kind
  game.powerups[idx].x = clampf(
    x,
    Float::from_int(tile_size),
    Float::from_int(map_pixel_w - tile_size),
  )
  game.powerups[idx].y = clampf(
    y,
    Float::from_int(tile_size),
    Float::from_int(map_pixel_h - tile_size),
  )
  game.powerups[idx].ttl = powerup_life
  game.powerups[idx].blink = 0.0
  game.powerups[idx].pulse = rand_rangef(game, 0.0, 6.2)
}

///|
fn spawn_random_powerup(game : Game, x : Float, y : Float) -> Unit {
  let roll = rand_range(game, 0, 99)
  let kind = if roll < 18 {
    powerup_shield
  } else if roll < 36 {
    powerup_star
  } else if roll < 54 {
    powerup_grenade
  } else if roll < 71 {
    powerup_clock
  } else if roll < 85 {
    powerup_shovel
  } else {
    powerup_tank
  }
  spawn_powerup(game, kind, x, y)
}

///|
fn clear_all_enemies_by_grenade(game : Game, team : Int) -> Unit {
  let mut killed = 0
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if game.enemies[i].active {
      let enemy = game.enemies[i]
      enemy.active = false
      game.enemies_alive -= 1
      spawn_explosion(game, enemy.x, enemy.y, 1.4)
      grant_score(game, team, enemy_score(enemy.enemy_kind))
      killed += 1
    }
  }
  if killed > 0 {
    bump_combo(game)
    let bonus = killed * 25
    grant_score(game, team, bonus)
  }
}

///|
fn apply_powerup(game : Game, player_index : Int, kind : Int) -> Unit {
  let player = game.players[player_index]
  let team = team_of_player(player_index)
  if kind == powerup_shield {
    player.shield_timer = 8.0
    player.invuln_timer = 2.0
    spawn_respawn_burst(game, player.x, player.y)
  } else if kind == powerup_star {
    player.weapon_level = clampi(player.weapon_level + 1, 0, 3)
    player.reload_delay = player_reload_base *
      (1.0 - Float::from_int(player.weapon_level) * 0.08)
    if player.reload_delay < 0.12 {
      player.reload_delay = 0.12
    }
    spawn_spark_burst(game, player.x, player.y, 20)
  } else if kind == powerup_grenade {
    clear_all_enemies_by_grenade(game, team)
    push_camera_shake(game, 2.2)
  } else if kind == powerup_clock {
    game.freeze_all_timer = freeze_duration
    spawn_spark_burst(game, player.x, player.y, 26)
  } else if kind == powerup_shovel {
    cache_base_ring(game)
    apply_shovel_fortress(game)
    game.shovel_timer = shovel_duration
    spawn_spark_burst(
      game,
      tile_center_x(base_tile_x),
      tile_center_y(base_tile_y),
      24,
    )
  } else if kind == powerup_tank {
    player.lives += 1
    spawn_respawn_burst(game, player.x, player.y)
  }
  grant_score(game, team, 120)
}

///|
fn powerup_radius(kind : Int) -> Float {
  if kind == powerup_shield {
    11.0
  } else if kind == powerup_star {
    10.0
  } else if kind == powerup_grenade {
    12.0
  } else if kind == powerup_clock {
    11.0
  } else if kind == powerup_shovel {
    11.0
  } else if kind == powerup_tank {
    12.0
  } else {
    10.0
  }
}

///|
fn update_powerups(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.powerups.length(); i = i + 1 {
    if not(game.powerups[i].active) {
      continue i + 1
    }

    let p = game.powerups[i]
    p.ttl -= dt
    p.blink += dt
    p.pulse += dt * 3.0
    if p.ttl <= 0.0 {
      p.active = false
      continue i + 1
    }

    for j = 0; j < max_players; j = j + 1 {
      let player = game.players[j]
      if not(player.active) {
        continue j + 1
      }
      let r = tank_half + powerup_radius(p.kind)
      if distance_sq(player.x, player.y, p.x, p.y) <= r * r {
        apply_powerup(game, j, p.kind)
        p.active = false
        break
      }
    }
  }
}

///|
fn update_global_effects(game : Game, dt : Float) -> Unit {
  if game.freeze_all_timer > 0.0 {
    game.freeze_all_timer -= dt
    if game.freeze_all_timer < 0.0 {
      game.freeze_all_timer = 0.0
    }
  }

  if game.shovel_timer > 0.0 {
    game.shovel_timer -= dt
    if game.shovel_timer <= 0.0 {
      game.shovel_timer = 0.0
      restore_base_ring(game)
    }
  }
}
