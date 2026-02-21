///|
fn alloc_grenade(game : Game) -> Int {
  for i = 0; i < game.grenades.length(); i = i + 1 {
    if not(game.grenades[i].active) {
      return i
    }
  }
  -1
}

///|
fn grenade_score_team(owner_team : Int) -> Int {
  if owner_team == team_player2 {
    team_player2
  } else {
    team_player1
  }
}

///|
fn can_player_throw_grenade(game : Game, player_index : Int) -> Bool {
  let player = game.players[player_index]
  player.active && player.grenade_stock > 0 && player.grenade_cooldown <= 0.0
}

///|
fn spawn_player_grenade(game : Game, player_index : Int) -> Bool {
  if not(can_player_throw_grenade(game, player_index)) {
    return false
  }

  let idx = alloc_grenade(game)
  if idx < 0 {
    return false
  }

  let player = game.players[player_index]
  let dir_x = dir_vector_x(player.dir)
  let dir_y = dir_vector_y(player.dir)
  let muzzle = tank_half + 6.0

  let grenade = game.grenades[idx]
  grenade.active = true
  grenade.owner_team = team_of_player(player_index)
  grenade.x = player.x + dir_x * muzzle
  grenade.y = player.y + dir_y * muzzle
  grenade.vx = dir_x * grenade_speed_player
  grenade.vy = dir_y * grenade_speed_player
  grenade.fuse = grenade_fuse_time + rand_rangef(game, -0.08, 0.16)
  grenade.blast_radius = grenade_blast_radius +
    Float::from_int(player.weapon_level) * 4.0
  grenade.power = 2 + player.weapon_level / 2
  grenade.spin = rand_rangef(game, 0.0, 6.2)

  player.grenade_stock -= 1
  player.grenade_cooldown = clampf(
    grenade_cooldown_base - Float::from_int(player.weapon_level) * 0.03,
    0.16,
    grenade_cooldown_base,
  )

  spawn_spark_burst(game, grenade.x, grenade.y, 9)
  true
}

///|
fn damage_tiles_by_grenade(
  game : Game,
  x : Float,
  y : Float,
  radius : Float,
  power : Int,
) -> Unit {
  let center_tx = world_x_to_tile(x)
  let center_ty = world_y_to_tile(y)
  for ty = center_ty - 2; ty <= center_ty + 2; ty = ty + 1 {
    if ty < 0 || ty >= map_tiles_h {
      continue ty + 1
    }
    for tx = center_tx - 2; tx <= center_tx + 2; tx = tx + 1 {
      if tx < 0 || tx >= map_tiles_w {
        continue tx + 1
      }
      let cx = tile_center_x(tx)
      let cy = tile_center_y(ty)
      let tile_r = Float::from_int(tile_size / 2)
      if distance_sq(x, y, cx, cy) > (radius + tile_r) * (radius + tile_r) {
        continue tx + 1
      }

      let tile = get_tile(game, tx, ty)
      if tile == tile_brick {
        set_tile(game, tx, ty, tile_empty, 0)
        spawn_spark_burst(game, cx, cy, 10)
      } else if tile == tile_steel && power >= 3 {
        set_tile(game, tx, ty, tile_empty, 0)
        spawn_spark_burst(game, cx, cy, 12)
      } else if tile == tile_base {
        game.base_alive = false
        game.base_flash = 1.0
      }
    }
  }
}

///|
fn detonate_grenade(game : Game, grenade_index : Int) -> Unit {
  if grenade_index < 0 || grenade_index >= game.grenades.length() {
    return
  }
  let grenade = game.grenades[grenade_index]
  if not(grenade.active) {
    return
  }
  grenade.active = false

  let score_team = grenade_score_team(grenade.owner_team)
  let radius = grenade.blast_radius

  damage_tiles_by_grenade(game, grenade.x, grenade.y, radius, grenade.power)

  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      continue i + 1
    }
    let enemy = game.enemies[i]
    let hit_r = radius + tank_half
    if distance_sq(grenade.x, grenade.y, enemy.x, enemy.y) <= hit_r * hit_r {
      enemy.hp -= grenade.power + 1
      if enemy.hp <= 0 {
        destroy_enemy(game, i, score_team)
      } else {
        enemy.blink_timer = 1.0
        spawn_spark_burst(game, enemy.x, enemy.y, 8)
      }
    }
  }

  for i = 0; i < game.cores.length(); i = i + 1 {
    if not(game.cores[i].active) {
      continue i + 1
    }
    let core = game.cores[i]
    let hit_r = radius + core_radius
    if distance_sq(grenade.x, grenade.y, core.x, core.y) <= hit_r * hit_r {
      ignore(damage_core(game, i, score_team, grenade.power + 2))
    }
  }

  if grenade.owner_team == team_enemy {
    for i = 0; i < max_players; i = i + 1 {
      let player = game.players[i]
      if not(player.active) {
        continue i + 1
      }
      let hit_r = radius + tank_half
      if distance_sq(grenade.x, grenade.y, player.x, player.y) <= hit_r * hit_r {
        on_player_destroyed(game, i)
      }
    }
  }

  spawn_explosion(game, grenade.x, grenade.y, 1.9)
  spawn_spark_burst(game, grenade.x, grenade.y, 24)
  push_camera_shake(game, 2.6)
}

///|
fn update_grenades(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.grenades.length(); i = i + 1 {
    if not(game.grenades[i].active) {
      continue i + 1
    }

    let grenade = game.grenades[i]
    grenade.fuse -= dt
    grenade.spin += dt * 12.0
    grenade.x += grenade.vx * dt
    grenade.y += grenade.vy * dt
    grenade.vx *= clampf(1.0 - dt * 1.8, 0.0, 1.0)
    grenade.vy *= clampf(1.0 - dt * 1.8, 0.0, 1.0)

    let mut bounced = false
    if grenade.x < 0.0 {
      grenade.x = 0.0
      grenade.vx = -grenade.vx * 0.42
      bounced = true
    } else if grenade.x > Float::from_int(map_pixel_w) {
      grenade.x = Float::from_int(map_pixel_w)
      grenade.vx = -grenade.vx * 0.42
      bounced = true
    }

    if grenade.y < 0.0 {
      grenade.y = 0.0
      grenade.vy = -grenade.vy * 0.42
      bounced = true
    } else if grenade.y > Float::from_int(map_pixel_h) {
      grenade.y = Float::from_int(map_pixel_h)
      grenade.vy = -grenade.vy * 0.42
      bounced = true
    }

    if bounced {
      spawn_spark_burst(game, grenade.x, grenade.y, 3)
    }

    let tx = world_x_to_tile(grenade.x)
    let ty = world_y_to_tile(grenade.y)
    let tile = get_tile(game, tx, ty)
    if tile == tile_brick || tile == tile_steel {
      grenade.fuse = clampf(grenade.fuse, 0.0, 0.08)
    }

    if grenade.fuse <= 0.0 {
      detonate_grenade(game, i)
      continue i + 1
    }

    if grenade.owner_team != team_enemy {
      for enemy_i = 0; enemy_i < game.enemies.length(); enemy_i = enemy_i + 1 {
        if not(game.enemies[enemy_i].active) {
          continue enemy_i + 1
        }
        if distance_sq(
            grenade.x,
            grenade.y,
            game.enemies[enemy_i].x,
            game.enemies[enemy_i].y,
          ) <=
          grenade_contact_radius * grenade_contact_radius {
          grenade.fuse = 0.0
          break
        }
      }
    }
  }
}
