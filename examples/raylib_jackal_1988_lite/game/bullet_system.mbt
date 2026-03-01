///|
fn alloc_bullet(game : @types.Game) -> Int {
  for i in 0..<game.bullets.length() {
    if not(game.bullets[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_bullet(
  game : @types.Game,
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
  game.bullets[idx].vx = @types.dir_vector_x(dir) * speed
  game.bullets[idx].vy = @types.dir_vector_y(dir) * speed
  game.bullets[idx].ttl = 3.2
  game.bullets[idx].damage = 1
  game.bullets[idx].power = power
  game.bullets[idx].radius = @types.bullet_radius
}

///|
fn bullet_hit_enemy(game : @types.Game, bullet : @types.Bullet) -> Bool {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }
    let enemy = game.enemies[i]
    if enemy.invuln_timer > 0.0 {
      continue
    }

    let radius = @types.tank_half + bullet.radius
    if @types.distance_sq(bullet.x, bullet.y, enemy.x, enemy.y) <=
      radius * radius {
      enemy.hp -= bullet.damage
      @particles.spawn_spark_burst(game, bullet.x, bullet.y, 6)
      if enemy.hp <= 0 {
        let team = if bullet.owner_team == @types.team_player2 {
          @types.team_player2
        } else {
          @types.team_player1
        }
        destroy_enemy(game, i, team)
      } else {
        enemy.blink_timer = 0.8
        @types.push_camera_shake(game, 0.8)
      }
      return true
    }
  }
  false
}

///|
fn bullet_hit_player(game : @types.Game, bullet : @types.Bullet) -> Bool {
  for i in 0..<@types.max_players {
    let player = game.players[i]
    if not(player.active) {
      continue
    }
    let radius = @types.tank_half + bullet.radius
    if @types.distance_sq(bullet.x, bullet.y, player.x, player.y) <=
      radius * radius {
      on_player_destroyed(game, i)
      return true
    }
  }
  false
}

///|
fn update_bullet_vs_bullet(game : @types.Game) -> Unit {
  for i in 0..<game.bullets.length() {
    if not(game.bullets[i].active) {
      continue
    }
    for j in (i + 1)..<game.bullets.length() {
      if not(game.bullets[j].active) {
        continue
      }
      if game.bullets[i].owner_team == game.bullets[j].owner_team {
        continue
      }
      let r = game.bullets[i].radius + game.bullets[j].radius
      if @types.distance_sq(
          game.bullets[i].x,
          game.bullets[i].y,
          game.bullets[j].x,
          game.bullets[j].y,
        ) <=
        r * r {
        let mx = (game.bullets[i].x + game.bullets[j].x) * 0.5
        let my = (game.bullets[i].y + game.bullets[j].y) * 0.5
        @particles.spawn_spark_burst(game, mx, my, 10)
        game.bullets[i].active = false
        game.bullets[j].active = false
      }
    }
  }
}

///|
fn update_bullets(game : @types.Game, dt : Float) -> Unit {
  for bullet in game.bullets {
    if not(bullet.active) {
      continue
    }

    bullet.ttl -= dt
    if bullet.ttl <= 0.0 {
      bullet.active = false
      continue
    }

    // Sub-steps for robust collision with narrow walls.
    let steps = 2
    let step_dt = dt / Float::from_int(steps)
    let mut hit_something = false

    for _s in 0..<steps {
      if not(bullet.active) {
        break
      }

      bullet.x += bullet.vx * step_dt
      bullet.y += bullet.vy * step_dt

      if not(@world.point_in_world(bullet.x, bullet.y)) {
        bullet.active = false
        hit_something = true
        break
      }

      if damage_tile_at_point(game, bullet.x, bullet.y, bullet.power) {
        bullet.active = false
        hit_something = true
        break
      }

      if bullet.owner_team == @types.team_enemy {
        if bullet_hit_player(game, bullet) {
          bullet.active = false
          hit_something = true
          break
        }
      } else if bullet_hit_enemy(game, bullet) {
        bullet.active = false
        hit_something = true
        break
      }
    }

    if hit_something {
      continue
    }
  }

  update_bullet_vs_bullet(game)
}
