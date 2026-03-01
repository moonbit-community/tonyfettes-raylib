///|
fn alloc_powerup(game : @types.Game) -> Int {
  for i in 0..<game.powerups.length() {
    if not(game.powerups[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_powerup(
  game : @types.Game,
  kind : @types.PowerupKind,
  x : Float,
  y : Float,
) -> Unit {
  let idx = alloc_powerup(game)
  if idx < 0 {
    return
  }
  game.powerups[idx].active = true
  game.powerups[idx].kind = kind
  game.powerups[idx].x = @types.clampf(
    x,
    Float::from_int(@types.tile_size),
    Float::from_int(@types.map_pixel_w - @types.tile_size),
  )
  game.powerups[idx].y = @types.clampf(
    y,
    Float::from_int(@types.tile_size),
    Float::from_int(@types.map_pixel_h - @types.tile_size),
  )
  game.powerups[idx].ttl = @types.powerup_life
  game.powerups[idx].blink = 0.0
  game.powerups[idx].pulse = @types.rand_rangef(game, 0.0, 6.2)
}

///|
fn spawn_random_powerup(game : @types.Game, x : Float, y : Float) -> Unit {
  let roll = @types.rand_range(game, 0, 99)
  let kind : @types.PowerupKind = if roll < 18 {
    @types.Shield
  } else if roll < 36 {
    @types.Star
  } else if roll < 54 {
    @types.Grenade
  } else if roll < 71 {
    @types.Clock
  } else if roll < 85 {
    @types.Shovel
  } else {
    @types.ExtraLife
  }
  spawn_powerup(game, kind, x, y)
}

///|
fn clear_all_enemies_by_grenade(game : @types.Game, team : @types.Team) -> Unit {
  let mut killed = 0
  for enemy in game.enemies {
    if enemy.active {
      enemy.active = false
      game.enemies_alive -= 1
      @particles.spawn_explosion(game, enemy.x, enemy.y, 1.4)
      @score.grant_score(game, team, @types.enemy_score(enemy.enemy_kind))
      killed += 1
    }
  }
  if killed > 0 {
    @score.bump_combo(game)
    let bonus = killed * 25
    @score.grant_score(game, team, bonus)
  }
}

///|
fn apply_powerup(
  game : @types.Game,
  player_index : Int,
  kind : @types.PowerupKind,
) -> Unit {
  let player = game.players[player_index]
  let team = @types.team_of_player(player_index)
  match kind {
    @types.Shield => {
      player.shield_timer = 8.0
      player.invuln_timer = 2.0
      @particles.spawn_respawn_burst(game, player.x, player.y)
    }
    @types.Star => {
      player.weapon_level = @types.clampi(player.weapon_level + 1, 0, 3)
      player.reload_delay = @types.player_reload_base *
        (1.0 - Float::from_int(player.weapon_level) * 0.08)
      if player.reload_delay < 0.12 {
        player.reload_delay = 0.12
      }
      @particles.spawn_spark_burst(game, player.x, player.y, 20)
    }
    @types.Grenade => {
      clear_all_enemies_by_grenade(game, team)
      @types.push_camera_shake(game, 2.2)
    }
    @types.Clock => {
      game.freeze_all_timer = @types.freeze_duration
      @particles.spawn_spark_burst(game, player.x, player.y, 26)
    }
    @types.Shovel => {
      cache_base_ring(game)
      apply_shovel_fortress(game)
      game.shovel_timer = @types.shovel_duration
      @particles.spawn_spark_burst(
        game,
        @types.tile_center_x(@types.base_tile_x),
        @types.tile_center_y(@types.base_tile_y),
        24,
      )
    }
    @types.ExtraLife => {
      player.lives += 1
      @particles.spawn_respawn_burst(game, player.x, player.y)
    }
  }
  @score.grant_score(game, team, 120)
}

///|
fn powerup_radius(kind : @types.PowerupKind) -> Float {
  match kind {
    @types.Shield => 11.0
    @types.Star => 10.0
    @types.Grenade => 12.0
    @types.Clock => 11.0
    @types.Shovel => 11.0
    @types.ExtraLife => 12.0
  }
}

///|
fn update_powerups(game : @types.Game, dt : Float) -> Unit {
  for p in game.powerups {
    if not(p.active) {
      continue
    }

    p.ttl -= dt
    p.blink += dt
    p.pulse += dt * 3.0
    if p.ttl <= 0.0 {
      p.active = false
      continue
    }

    for j in 0..<@types.max_players {
      let player = game.players[j]
      if not(player.active) {
        continue
      }
      let r = @types.tank_half + powerup_radius(p.kind)
      if @types.distance_sq(player.x, player.y, p.x, p.y) <= r * r {
        apply_powerup(game, j, p.kind)
        p.active = false
        break
      }
    }
  }
}

///|
fn update_global_effects(game : @types.Game, dt : Float) -> Unit {
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
