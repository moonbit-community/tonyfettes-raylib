///|
pub fn clear_particles(game : @types.Game) -> Unit {
  for i in 0..<game.particles.length() {
    game.particles[i] = @types.Particle::inactive()
  }
}

///|
fn alloc_particle(game : @types.Game) -> Int {
  for i in 0..<game.particles.length() {
    if not(game.particles[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_particle(
  game : @types.Game,
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
pub fn spawn_coin_burst(game : @types.Game, x : Float, y : Float) -> Unit {
  for i in 0..<10 {
    let a = @types.randf(0.0, 6.28)
    let s = @types.randf(45.0, 160.0)
    spawn_particle(
      game,
      x,
      y,
      @math.cosf(a) * s,
      @math.sinf(a) * s - 40.0,
      @types.randf(0.25, 0.5),
      @types.randf(1.5, 3.5),
      @raylib.gold,
    )
  }
}

///|
pub fn spawn_block_burst(
  game : @types.Game,
  x : Float,
  y : Float,
  color : @raylib.Color,
) -> Unit {
  for i in 0..<12 {
    let a = @types.randf(0.0, 6.28)
    let s = @types.randf(60.0, 220.0)
    spawn_particle(
      game,
      x,
      y,
      @math.cosf(a) * s,
      @math.sinf(a) * s,
      @types.randf(0.28, 0.62),
      @types.randf(1.8, 4.6),
      color,
    )
  }
}

///|
pub fn spawn_stomp_burst(game : @types.Game, x : Float, y : Float) -> Unit {
  for i in 0..<15 {
    let a = @types.randf(0.0, 6.28)
    let s = @types.randf(55.0, 200.0)
    spawn_particle(
      game,
      x,
      y,
      @math.cosf(a) * s,
      @math.sinf(a) * s - 30.0,
      @types.randf(0.35, 0.75),
      @types.randf(2.0, 4.0),
      @raylib.brown,
    )
  }
}

///|
pub fn spawn_hurt_burst(game : @types.Game, x : Float, y : Float) -> Unit {
  for i in 0..<18 {
    let a = @types.randf(0.0, 6.28)
    let s = @types.randf(80.0, 260.0)
    spawn_particle(
      game,
      x,
      y,
      @math.cosf(a) * s,
      @math.sinf(a) * s - 30.0,
      @types.randf(0.3, 0.9),
      @types.randf(2.0, 4.8),
      @raylib.red,
    )
  }
}

///|
pub fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.particles.length() {
    let p = game.particles[i]
    if not(p.active) {
      continue
    }
    p.life = p.life - dt
    if p.life <= 0.0 {
      p.active = false
      continue
    }
    p.vy = p.vy + 420.0 * dt
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
  }
}
