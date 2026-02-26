///|
fn alloc_particle(game : @types.Game) -> Int {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn spawn_particle(
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
  game.particles[idx].active = true
  game.particles[idx].x = x
  game.particles[idx].y = y
  game.particles[idx].vx = vx
  game.particles[idx].vy = vy
  game.particles[idx].life = life
  game.particles[idx].max_life = life
  game.particles[idx].size = size
  game.particles[idx].rot = @types.rand_rangef(game, 0.0, 6.28318)
  game.particles[idx].spin = @types.rand_rangef(game, -5.2, 5.2)
  game.particles[idx].fade = @types.rand_rangef(game, 0.7, 1.5)
  game.particles[idx].color = color
}

///|
pub fn spawn_spark_burst(game : @types.Game, x : Float, y : Float, count : Int) -> Unit {
  for _i = 0; _i < count; _i = _i + 1 {
    let angle = @types.rand_rangef(game, 0.0, 6.28318)
    let speed = @types.rand_rangef(game, 65.0, 210.0)
    let vx = Float::from_double(@math.cos(angle.to_double())) * speed
    let vy = Float::from_double(@math.sin(angle.to_double())) * speed
    let life = @types.rand_rangef(game, 0.18, 0.55)
    spawn_particle(
      game,
      x,
      y,
      vx,
      vy,
      life,
      @types.rand_rangef(game, 1.2, 2.8),
      @raylib.gold,
    )
  }
}

///|
pub fn spawn_explosion(game : @types.Game, x : Float, y : Float, strength : Float) -> Unit {
  let sparks = @types.clampi((strength * 20.0).to_int(), 10, 70)
  for i = 0; i < sparks; i = i + 1 {
    let angle = @types.rand_rangef(game, 0.0, 6.28318)
    let speed = @types.rand_rangef(game, 40.0, 160.0) * strength
    let vx = Float::from_double(@math.cos(angle.to_double())) * speed
    let vy = Float::from_double(@math.sin(angle.to_double())) * speed
    let life = @types.rand_rangef(game, 0.25, 0.95)
    let size = @types.rand_rangef(game, 1.4, 4.0)
    let color = if i % 5 == 0 {
      @raylib.white
    } else if i % 3 == 0 {
      @raylib.yellow
    } else {
      @raylib.orange
    }
    spawn_particle(game, x, y, vx, vy, life, size, color)
  }

  // Smoke puffs.
  for _i = 0; _i < @types.clampi((strength * 10.0).to_int(), 4, 20); _i = _i + 1 {
    let angle = @types.rand_rangef(game, 0.0, 6.28318)
    let speed = @types.rand_rangef(game, 12.0, 58.0)
    let vx = Float::from_double(@math.cos(angle.to_double())) * speed
    let vy = Float::from_double(@math.sin(angle.to_double())) * speed
    let life = @types.rand_rangef(game, 0.65, 1.8)
    spawn_particle(
      game,
      x,
      y,
      vx,
      vy,
      life,
      @types.rand_rangef(game, 3.0, 7.5),
      @raylib.darkgray,
    )
  }

  @types.push_camera_shake(game, strength * 1.8)
}

///|
pub fn spawn_respawn_burst(game : @types.Game, x : Float, y : Float) -> Unit {
  for i = 0; i < 24; i = i + 1 {
    let angle = Float::from_int(i) / Float::from_int(24) * 6.28318
    let speed = Float::from_int(35 + i % 3 * 15)
    let vx = Float::from_double(@math.cos(angle.to_double())) * speed
    let vy = Float::from_double(@math.sin(angle.to_double())) * speed
    spawn_particle(
      game,
      x,
      y,
      vx,
      vy,
      @types.rand_rangef(game, 0.4, 0.95),
      2.4,
      @raylib.skyblue,
    )
  }
}

///|
pub fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      continue i + 1
    }
    let p = game.particles[i]
    p.life -= dt * p.fade
    if p.life <= 0.0 {
      p.active = false
      continue i + 1
    }
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.vx *= 1.0 - 0.8 * dt
    p.vy *= 1.0 - 0.8 * dt
    p.vy += 22.0 * dt
    p.rot += p.spin * dt
  }
}
