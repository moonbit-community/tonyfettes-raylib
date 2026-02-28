///|
pub fn push_camera_shake(game : @types.Game, amount : Float) -> Unit {
  let next = game.camera_shake + amount
  if next > @types.camera_shake_max {
    game.camera_shake = @types.camera_shake_max
  } else {
    game.camera_shake = next
  }
}

///|
pub fn allocate_particle_slot(list : Array[@types.Particle]) -> Int {
  for i in 0..<list.length() {
    if not(list[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn spawn_stage_dust(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  color : @raylib.Color,
) -> Unit {
  let idx = allocate_particle_slot(game.particles)
  if idx < 0 {
    return
  }
  let p = game.particles[idx]
  p.active = true
  p.x = x
  p.y = y
  p.vx = vx
  p.vy = vy
  p.life = @types.f(0.45)
  p.max_life = @types.f(0.45)
  p.size = @types.rand_rangef(game, @types.f(3.0), @types.f(8.0))
  p.growth = @types.rand_rangef(game, @types.f(-8.0), @types.f(10.0))
  p.color = color
}

///|
pub fn spawn_hit_spark(
  game : @types.Game,
  x : Float,
  y : Float,
  kind : Int,
  count : Int,
) -> Unit {
  let color = if kind == @types.spark_kind_block {
    @raylib.Color::new(135, 186, 255, 255)
  } else if kind == @types.spark_kind_super {
    @raylib.Color::new(255, 216, 120, 255)
  } else {
    @raylib.Color::new(255, 138, 86, 255)
  }

  for i in 0..<count {
    let idx = allocate_particle_slot(game.hit_sparks)
    if idx < 0 {
      return
    }

    let angle = @types.rand_rangef(game, @types.f(0.0), @types.f(6.28))
    let speed = @types.rand_rangef(
      game,
      if kind == @types.spark_kind_super {
        @types.f(200.0)
      } else {
        @types.f(120.0)
      },
      if kind == @types.spark_kind_super {
        @types.f(520.0)
      } else {
        @types.f(360.0)
      },
    )
    let vx = Float::from_double(@math.cos(angle.to_double())) * speed
    let vy = Float::from_double(@math.sin(angle.to_double())) * speed -
      @types.rand_rangef(game, @types.f(30.0), @types.f(90.0))

    let p = game.hit_sparks[idx]
    p.active = true
    p.x = x
    p.y = y
    p.vx = vx
    p.vy = vy
    p.life = @types.rand_rangef(game, @types.f(0.18), @types.f(0.48))
    p.max_life = p.life
    p.size = if kind == @types.spark_kind_super {
      @types.rand_rangef(game, @types.f(5.0), @types.f(12.0))
    } else {
      @types.rand_rangef(game, @types.f(3.0), @types.f(8.0))
    }
    p.growth = @types.rand_rangef(game, @types.f(-10.0), @types.f(12.0))
    p.color = color
  }
}

///|
pub fn spawn_ground_skid(game : @types.Game, fighter : @types.Fighter) -> Unit {
  let archetype = @types.fighter_archetype(game, fighter)
  for i in 0..<3 {
    let jitter_x = @types.rand_rangef(game, @types.f(-18.0), @types.f(18.0))
    let jitter_y = @types.rand_rangef(game, @types.f(-3.0), @types.f(3.0))
    spawn_stage_dust(
      game,
      fighter.x + jitter_x,
      @types.floor_y + jitter_y,
      -fighter.vx * @types.f(0.2) + @types.rand_rangef(game, @types.f(-30.0), @types.f(30.0)),
      @types.rand_rangef(game, @types.f(-80.0), @types.f(-20.0)),
      @raylib.color_alpha(archetype.aura_color, @types.f(0.45)),
    )
  }
}

///|
pub fn update_particle_list(list : Array[@types.Particle], dt : Float) -> Unit {
  for p in list {
    if not(p.active) {
      continue
    }

    p.life -= dt
    if p.life <= @types.f(0.0) {
      p.active = false
      continue
    }

    p.vy += @types.particle_gravity * dt
    p.vx *= @types.f(1.0) - (@types.f(1.0) - @types.particle_friction) * dt * @types.f(60.0)
    p.vy *= @types.f(1.0) - (@types.f(1.0) - @types.particle_friction) * dt * @types.f(30.0)

    p.x += p.vx * dt
    p.y += p.vy * dt
    p.size += p.growth * dt
    if p.size < @types.f(1.0) {
      p.size = @types.f(1.0)
    }
  }
}

///|
pub fn draw_particle_list(
  list : Array[@types.Particle],
  camera_x : Float,
  camera_y : Float,
) -> Unit {
  for p in list {
    if not(p.active) {
      continue
    }

    let alpha = @types.clampf(p.life / p.max_life, @types.f(0.0), @types.f(1.0))
    let color = @raylib.color_alpha(p.color, alpha)
    @raylib.draw_circle(
      (p.x + camera_x).to_int(),
      (p.y + camera_y).to_int(),
      p.size,
      color,
    )
  }
}

///|
pub fn update_particles(game : @types.Game, dt : Float) -> Unit {
  update_particle_list(game.particles, dt)
  update_particle_list(game.hit_sparks, dt)
}

///|
pub fn draw_particles(game : @types.Game) -> Unit {
  draw_particle_list(game.particles, game.camera_x, game.camera_y)
  draw_particle_list(game.hit_sparks, game.camera_x, game.camera_y)
}

///|
pub fn update_camera(game : @types.Game, dt : Float) -> Unit {
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]
  let center_x = (p1.x + p2.x) * @types.f(0.5)
  let target_camera_x = Float::from_int(@types.screen_width) * @types.f(0.5) - center_x
  game.camera_x = @types.lerpf(game.camera_x, target_camera_x, dt * @types.f(5.5))

  let center_y = @types.minf(p1.y, p2.y) - @types.f(250.0)
  let target_camera_y = Float::from_int(@types.screen_height) * @types.f(0.5) - center_y
  game.camera_y = @types.lerpf(game.camera_y, target_camera_y, dt * @types.f(4.2))

  let distance = @types.fighter_distance_x(p1, p2)
  let target_zoom = if distance < @types.f(190.0) {
    @types.camera_zoom_close
  } else if distance > @types.f(420.0) {
    @types.camera_zoom_far
  } else {
    @types.camera_zoom_base
  }
  game.camera_zoom = @types.lerpf(game.camera_zoom, target_zoom, dt * @types.f(1.8))

  if game.camera_shake > @types.f(0.0) {
    game.camera_phase += dt * @types.f(44.0)
    let sx = Float::from_double(@math.sin(game.camera_phase.to_double()))
    let sy = Float::from_double(
      @math.cos((game.camera_phase * @types.f(1.33)).to_double()),
    )
    game.camera_x += sx * game.camera_shake
    game.camera_y += sy * game.camera_shake * @types.f(0.7)

    game.camera_shake -= dt * @types.camera_shake_decay * @types.f(10.0)
    if game.camera_shake < @types.f(0.0) {
      game.camera_shake = @types.f(0.0)
    }
  }
}
