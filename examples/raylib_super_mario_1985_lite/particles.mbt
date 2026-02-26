///|
fn clear_particles(game : Game) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    game.particles[i] = Particle::inactive()
  }
}

///|
fn alloc_particle(game : Game) -> Int {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_particle(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  color : @raylib.Color,
) -> Unit {
  let idx = alloc_particle(game)
  if idx < 0 {
    return
  }
  let p = game.particles[idx]
  p.active = true
  p.x = x
  p.y = y
  p.vx = vx
  p.vy = vy
  p.life = life
  p.max_life = life
  p.size = size
  p.color = color
}

///|
fn spawn_coin_burst(game : Game, x : Float, y : Float) -> Unit {
  for i = 0; i < 10; i = i + 1 {
    let a = randf(0.0, 6.28)
    let s = randf(45.0, 160.0)
    spawn_particle(
      game,
      x,
      y,
      @math.cosf(a) * s,
      @math.sinf(a) * s - 40.0,
      randf(0.25, 0.5),
      randf(1.5, 3.5),
      @raylib.gold,
    )
  }
}

///|
fn spawn_block_burst(
  game : Game,
  x : Float,
  y : Float,
  color : @raylib.Color,
) -> Unit {
  for i = 0; i < 12; i = i + 1 {
    let a = randf(0.0, 6.28)
    let s = randf(60.0, 220.0)
    spawn_particle(
      game,
      x,
      y,
      @math.cosf(a) * s,
      @math.sinf(a) * s,
      randf(0.28, 0.62),
      randf(1.8, 4.6),
      color,
    )
  }
}

///|
fn spawn_stomp_burst(game : Game, x : Float, y : Float) -> Unit {
  for i = 0; i < 15; i = i + 1 {
    let a = randf(0.0, 6.28)
    let s = randf(55.0, 200.0)
    spawn_particle(
      game,
      x,
      y,
      @math.cosf(a) * s,
      @math.sinf(a) * s - 30.0,
      randf(0.35, 0.75),
      randf(2.0, 4.0),
      @raylib.brown,
    )
  }
}

///|
fn spawn_hurt_burst(game : Game, x : Float, y : Float) -> Unit {
  for i = 0; i < 18; i = i + 1 {
    let a = randf(0.0, 6.28)
    let s = randf(80.0, 260.0)
    spawn_particle(
      game,
      x,
      y,
      @math.cosf(a) * s,
      @math.sinf(a) * s - 30.0,
      randf(0.3, 0.9),
      randf(2.0, 4.8),
      @raylib.red,
    )
  }
}

///|
fn update_particles(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    let p = game.particles[i]
    if not(p.active) {
      continue i + 1
    }
    p.life = p.life - dt
    if p.life <= 0.0 {
      p.active = false
      continue i + 1
    }
    p.vy = p.vy + 420.0 * dt
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
  }
}
