///|
fn update_bullets(game : @types.Game, dt : Float) -> Unit {
  for bullet in game.bullets {
    if not(bullet.active) {
      continue
    }
    bullet.x = @types.wrap_x(bullet.x + bullet.vx * dt)
    bullet.y = @types.wrap_y(bullet.y + bullet.vy * dt)
    bullet.ttl = bullet.ttl - dt
    if bullet.ttl <= 0.0 {
      bullet.active = false
    }
  }
}

///|
fn update_rocks(game : @types.Game, dt : Float) -> Unit {
  for rock in game.rocks {
    if not(rock.active) {
      continue
    }
    rock.x = @types.wrap_x(rock.x + rock.vx * dt)
    rock.y = @types.wrap_y(rock.y + rock.vy * dt)
  }
}

///|
fn split_rock(
  game : @types.Game,
  rock : @types.Rock,
  hit_x : Float,
  hit_y : Float,
) -> Unit {
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
  for i in 0..<2 {
    let angle : Float = @types.random_range((0.0 : Float), @types.pi * 2.0)
    let speed : Float = @types.random_range(60.0, 160.0)
    let vx : Float = Float::from_double(@math.cos(angle.to_double())) * speed +
      rock.vx * 0.2
    let vy : Float = Float::from_double(@math.sin(angle.to_double())) * speed +
      rock.vy * 0.2
    @types.spawn_rock(game, next_size, hit_x, hit_y, vx, vy)
  }
}

///|
fn bullet_vs_rocks(game : @types.Game) -> Unit {
  for bullet in game.bullets {
    if not(bullet.active) {
      continue
    }
    for rock_copy in game.rocks {
      if not(rock_copy.active) {
        continue
      }
      let dx = bullet.x - rock_copy.x
      let dy = bullet.y - rock_copy.y
      let rr = rock_copy.radius
      if @types.length_sq(dx, dy) <= rr * rr {
        let hit_x = rock_copy.x
        let hit_y = rock_copy.y
        bullet.active = false
        rock_copy.active = false
        split_rock(game, rock_copy, hit_x, hit_y)
        break
      }
    }
  }
}

///|
fn ship_vs_rocks(game : @types.Game) -> Unit {
  if game.ship_invuln > 0.0 {
    return
  }

  let ship_r : Float = 11.0
  for rock in game.rocks {
    if not(rock.active) {
      continue
    }
    let dx = game.ship_x - rock.x
    let dy = game.ship_y - rock.y
    let rr : Float = ship_r + rock.radius
    if @types.length_sq(dx, dy) <= rr * rr {
      game.lives = game.lives - 1
      if game.lives <= 0 {
        game.game_over = true
        return
      }
      @types.ship_reset(game)
      return
    }
  }
}

///|
fn maybe_advance_wave(game : @types.Game) -> Unit {
  let mut alive = 0
  for rock in game.rocks {
    if rock.active {
      alive = alive + 1
    }
  }
  if alive == 0 {
    game.wave = game.wave + 1
    @types.spawn_wave(game)
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  if game.game_over {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      @types.reset_game(game)
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
