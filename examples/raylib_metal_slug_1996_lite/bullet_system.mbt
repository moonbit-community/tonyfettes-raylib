///|
fn alloc_bullet(game : Game) -> Int {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if not(game.bullets[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_bullet(
  game : Game,
  owner_team : Int,
  x : Float,
  y : Float,
  dir : Int,
  speed : Float,
  power : Int,
) -> Unit {
  let idx = alloc_bullet(game)
  if idx < 0 {
    return
  }

  game.bullets[idx].active = true
  game.bullets[idx].owner_team = owner_team
  game.bullets[idx].x = x
  game.bullets[idx].y = y
  game.bullets[idx].vx = dir_vector_x(dir) * speed
  game.bullets[idx].vy = dir_vector_y(dir) * speed
  game.bullets[idx].ttl = 3.2
  game.bullets[idx].damage = 1
  game.bullets[idx].power = power
  game.bullets[idx].radius = bullet_radius
}

///|
fn bullet_hit_enemy(game : Game, bullet : Bullet) -> Bool {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      continue i + 1
    }
    let enemy = game.enemies[i]
    if enemy.invuln_timer > 0.0 {
      continue i + 1
    }

    let radius = tank_half + bullet.radius
    if distance_sq(bullet.x, bullet.y, enemy.x, enemy.y) <= radius * radius {
      enemy.hp -= bullet.damage
      spawn_spark_burst(game, bullet.x, bullet.y, 6)
      if enemy.hp <= 0 {
        let team = if bullet.owner_team == team_player2 {
          team_player2
        } else {
          team_player1
        }
        destroy_enemy(game, i, team)
      } else {
        enemy.blink_timer = 0.8
        push_camera_shake(game, 0.8)
      }
      return true
    }
  }
  false
}

///|
fn bullet_hit_player(game : Game, bullet : Bullet) -> Bool {
  for i = 0; i < max_players; i = i + 1 {
    let player = game.players[i]
    if not(player.active) {
      continue i + 1
    }
    let radius = tank_half + bullet.radius
    if distance_sq(bullet.x, bullet.y, player.x, player.y) <= radius * radius {
      on_player_destroyed(game, i)
      return true
    }
  }
  false
}

///|
fn bullet_hit_core(game : Game, bullet : Bullet) -> Bool {
  for i = 0; i < game.cores.length(); i = i + 1 {
    if not(game.cores[i].active) {
      continue i + 1
    }
    let core = game.cores[i]
    let r = core_radius + bullet.radius
    if distance_sq(bullet.x, bullet.y, core.x, core.y) <= r * r {
      let team = if bullet.owner_team == team_player2 {
        team_player2
      } else {
        team_player1
      }
      ignore(damage_core(game, i, team, bullet.power))
      return true
    }
  }
  false
}

///|
fn update_bullet_vs_bullet(game : Game) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if not(game.bullets[i].active) {
      continue i + 1
    }
    for j = i + 1; j < game.bullets.length(); j = j + 1 {
      if not(game.bullets[j].active) {
        continue j + 1
      }
      if game.bullets[i].owner_team == game.bullets[j].owner_team {
        continue j + 1
      }
      let r = game.bullets[i].radius + game.bullets[j].radius
      if distance_sq(
          game.bullets[i].x,
          game.bullets[i].y,
          game.bullets[j].x,
          game.bullets[j].y,
        ) <=
        r * r {
        let mx = (game.bullets[i].x + game.bullets[j].x) * 0.5
        let my = (game.bullets[i].y + game.bullets[j].y) * 0.5
        spawn_spark_burst(game, mx, my, 10)
        game.bullets[i].active = false
        game.bullets[j].active = false
      }
    }
  }
}

///|
fn update_bullets(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if not(game.bullets[i].active) {
      continue i + 1
    }

    let bullet = game.bullets[i]
    bullet.ttl -= dt
    if bullet.ttl <= 0.0 {
      bullet.active = false
      continue i + 1
    }

    // Sub-steps for robust collision with narrow walls.
    let steps = 2
    let step_dt = dt / Float::from_int(steps)
    let mut hit_something = false

    for _s = 0; _s < steps; _s = _s + 1 {
      if not(bullet.active) {
        break
      }

      bullet.x += bullet.vx * step_dt
      bullet.y += bullet.vy * step_dt

      if not(point_in_world(bullet.x, bullet.y)) {
        bullet.active = false
        hit_something = true
        break
      }

      if damage_tile_at_point(game, bullet.x, bullet.y, bullet.power) {
        bullet.active = false
        hit_something = true
        break
      }

      if bullet.owner_team == team_enemy {
        if bullet_hit_player(game, bullet) {
          bullet.active = false
          hit_something = true
          break
        }
      } else {
        if bullet_hit_core(game, bullet) {
          bullet.active = false
          hit_something = true
          break
        }
        if bullet_hit_enemy(game, bullet) {
          bullet.active = false
          hit_something = true
          break
        }
      }
    }

    if hit_something {
      continue i + 1
    }
  }

  update_bullet_vs_bullet(game)
}
