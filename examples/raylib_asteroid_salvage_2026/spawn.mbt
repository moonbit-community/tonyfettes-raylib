///|
fn random01() -> Float {
  Float::from_int(@raylib.get_random_value(0, 10_000)) / (10_000.0 : Float)
}

///|
fn random_range(min : Float, max : Float) -> Float {
  min + (max - min) * random01()
}

///|
fn wrap_x(x : Float) -> Float {
  let w = Float::from_int(screen_width)
  if x < (0.0 : Float) {
    x + w
  } else if x >= w {
    x - w
  } else {
    x
  }
}

///|
fn wrap_y(y : Float) -> Float {
  let h = Float::from_int(screen_height)
  if y < (0.0 : Float) {
    y + h
  } else if y >= h {
    y - h
  } else {
    y
  }
}

///|
fn ship_reset(game : Game) -> Unit {
  game.ship_x = Float::from_int(screen_width) * (0.5 : Float)
  game.ship_y = Float::from_int(screen_height) * (0.5 : Float)
  game.ship_vx = 0.0
  game.ship_vy = 0.0
  game.ship_angle = -pi * (0.5 : Float)
  game.ship_invuln = 2.0
}

///|
fn clear_entities(game : Game) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    game.bullets[i].active = false
  }
  for i = 0; i < game.rocks.length(); i = i + 1 {
    game.rocks[i].active = false
  }
}

///|
fn spawn_rock(
  game : Game,
  size : Int,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
) -> Unit {
  for i = 0; i < game.rocks.length(); i = i + 1 {
    if not(game.rocks[i].active) {
      game.rocks[i].active = true
      game.rocks[i].size = size
      game.rocks[i].radius = match size {
        2 => (34.0 : Float)
        1 => (22.0 : Float)
        _ => (13.0 : Float)
      }
      game.rocks[i].x = wrap_x(x)
      game.rocks[i].y = wrap_y(y)
      game.rocks[i].vx = vx
      game.rocks[i].vy = vy
      return
    }
  }
}

///|
fn spawn_wave(game : Game) -> Unit {
  let count = 4 + game.wave
  for i = 0; i < count; i = i + 1 {
    let edge = @raylib.get_random_value(0, 3)
    let mut x : Float = 0.0
    let mut y : Float = 0.0
    match edge {
      0 => {
        x = random_range((0.0 : Float), Float::from_int(screen_width))
        y = 2.0
      }
      1 => {
        x = random_range((0.0 : Float), Float::from_int(screen_width))
        y = Float::from_int(screen_height - 2)
      }
      2 => {
        x = 2.0
        y = random_range((0.0 : Float), Float::from_int(screen_height))
      }
      _ => {
        x = Float::from_int(screen_width - 2)
        y = random_range((0.0 : Float), Float::from_int(screen_height))
      }
    }

    let angle : Float = random_range((0.0 : Float), pi * 2.0)
    let speed : Float = random_range(30.0, 95.0 + Float::from_int(game.wave * 8))
    let vx : Float = Float::from_double(@math.cos(angle.to_double())) * speed
    let vy : Float = Float::from_double(@math.sin(angle.to_double())) * speed
    spawn_rock(game, 2, x, y, vx, vy)
  }
}

///|
fn reset_game(game : Game) -> Unit {
  game.score = 0
  game.lives = 3
  game.wave = 1
  game.game_over = false
  game.fire_cooldown = 0.0
  clear_entities(game)
  ship_reset(game)
  spawn_wave(game)
}
