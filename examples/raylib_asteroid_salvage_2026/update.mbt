///|
fn length_sq(dx : Float, dy : Float) -> Float {
  dx * dx + dy * dy
}

///|
fn fire_bullet(game : Game) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if not(game.bullets[i].active) {
      let dir_x : Float = Float::from_double(
        @math.cos(game.ship_angle.to_double()),
      )
      let dir_y : Float = Float::from_double(
        @math.sin(game.ship_angle.to_double()),
      )
      game.bullets[i].active = true
      game.bullets[i].x = game.ship_x + dir_x * 14.0
      game.bullets[i].y = game.ship_y + dir_y * 14.0
      game.bullets[i].vx = game.ship_vx + dir_x * 360.0
      game.bullets[i].vy = game.ship_vy + dir_y * 360.0
      game.bullets[i].ttl = 1.35
      game.fire_cooldown = 0.14
      return
    }
  }
}

///|
fn update_ship(game : Game, dt : Float) -> Unit {
  let rotate_speed : Float = 4.5
  let thrust : Float = 180.0

  if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
    game.ship_angle = game.ship_angle - rotate_speed * dt
  }
  if @raylib.is_key_down(@raylib.KeyRight) || @raylib.is_key_down(@raylib.KeyD) {
    game.ship_angle = game.ship_angle + rotate_speed * dt
  }
  if @raylib.is_key_down(@raylib.KeyUp) || @raylib.is_key_down(@raylib.KeyW) {
    let dir_x : Float = Float::from_double(
      @math.cos(game.ship_angle.to_double()),
    )
    let dir_y : Float = Float::from_double(
      @math.sin(game.ship_angle.to_double()),
    )
    game.ship_vx = game.ship_vx + dir_x * thrust * dt
    game.ship_vy = game.ship_vy + dir_y * thrust * dt
  }

  let damping : Float = (1.0 : Float) - (0.35 : Float) * dt
  game.ship_vx = game.ship_vx * damping
  game.ship_vy = game.ship_vy * damping

  game.ship_x = wrap_x(game.ship_x + game.ship_vx * dt)
  game.ship_y = wrap_y(game.ship_y + game.ship_vy * dt)

  if game.fire_cooldown > 0.0 {
    game.fire_cooldown = game.fire_cooldown - dt
    if game.fire_cooldown < 0.0 {
      game.fire_cooldown = 0.0
    }
  }

  if game.ship_invuln > 0.0 {
    game.ship_invuln = game.ship_invuln - dt
    if game.ship_invuln < 0.0 {
      game.ship_invuln = 0.0
    }
  }

  if (
      @raylib.is_key_down(@raylib.KeySpace) || @raylib.is_key_down(@raylib.KeyX)
    ) &&
    game.fire_cooldown <= 0.0 {
    fire_bullet(game)
  }
}

///|
fn update_bullets(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if not(game.bullets[i].active) {
      continue
    }
    game.bullets[i].x = wrap_x(game.bullets[i].x + game.bullets[i].vx * dt)
    game.bullets[i].y = wrap_y(game.bullets[i].y + game.bullets[i].vy * dt)
    game.bullets[i].ttl = game.bullets[i].ttl - dt
    if game.bullets[i].ttl <= 0.0 {
      game.bullets[i].active = false
    }
  }
}

///|
fn update_rocks(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.rocks.length(); i = i + 1 {
    if not(game.rocks[i].active) {
      continue
    }
    game.rocks[i].x = wrap_x(game.rocks[i].x + game.rocks[i].vx * dt)
    game.rocks[i].y = wrap_y(game.rocks[i].y + game.rocks[i].vy * dt)
  }
}

///|
fn split_rock(game : Game, rock : Rock, hit_x : Float, hit_y : Float) -> Unit {
  let gained = match rock.size {
    2 => 30
    1 => 60
    _ => 120
  }
  game.score = game.score + gained

  if rock.size <= 0 {
    return
  }

  let next_size = rock.size - 1
  for i = 0; i < 2; i = i + 1 {
    let angle : Float = random_range((0.0 : Float), pi * 2.0)
    let speed : Float = random_range(60.0, 160.0)
    let vx : Float = Float::from_double(@math.cos(angle.to_double())) * speed +
      rock.vx * 0.2
    let vy : Float = Float::from_double(@math.sin(angle.to_double())) * speed +
      rock.vy * 0.2
    spawn_rock(game, next_size, hit_x, hit_y, vx, vy)
  }
}

///|
fn bullet_vs_rocks(game : Game) -> Unit {
  for bi = 0; bi < game.bullets.length(); bi = bi + 1 {
    if not(game.bullets[bi].active) {
      continue
    }
    for ri = 0; ri < game.rocks.length(); ri = ri + 1 {
      if not(game.rocks[ri].active) {
        continue
      }
      let dx = game.bullets[bi].x - game.rocks[ri].x
      let dy = game.bullets[bi].y - game.rocks[ri].y
      let rr = game.rocks[ri].radius
      if length_sq(dx, dy) <= rr * rr {
        let hit_x = game.rocks[ri].x
        let hit_y = game.rocks[ri].y
        let rock_copy = game.rocks[ri]
        game.bullets[bi].active = false
        game.rocks[ri].active = false
        split_rock(game, rock_copy, hit_x, hit_y)
        break
      }
    }
  }
}

///|
fn ship_vs_rocks(game : Game) -> Unit {
  if game.ship_invuln > 0.0 {
    return
  }

  let ship_r : Float = 11.0
  for ri = 0; ri < game.rocks.length(); ri = ri + 1 {
    if not(game.rocks[ri].active) {
      continue
    }
    let dx = game.ship_x - game.rocks[ri].x
    let dy = game.ship_y - game.rocks[ri].y
    let rr : Float = ship_r + game.rocks[ri].radius
    if length_sq(dx, dy) <= rr * rr {
      game.lives = game.lives - 1
      if game.lives <= 0 {
        game.game_over = true
        return
      }
      ship_reset(game)
      return
    }
  }
}

///|
fn maybe_advance_wave(game : Game) -> Unit {
  let mut alive = 0
  for i = 0; i < game.rocks.length(); i = i + 1 {
    if game.rocks[i].active {
      alive = alive + 1
    }
  }
  if alive == 0 {
    game.wave = game.wave + 1
    spawn_wave(game)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  if game.game_over {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_game(game)
    }
    return
  }

  update_ship(game, dt)
  update_bullets(game, dt)
  update_rocks(game, dt)
  bullet_vs_rocks(game)
  ship_vs_rocks(game)
  maybe_advance_wave(game)
}
