///|
fn push_camera_shake(game : Game, amount : Float) -> Unit {
  let next = game.camera_shake + amount
  if next > camera_shake_max {
    game.camera_shake = camera_shake_max
  } else {
    game.camera_shake = next
  }
}

///|
fn allocate_particle_slot(list : Array[Particle]) -> Int {
  for i = 0; i < list.length(); i = i + 1 {
    if not(list[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_stage_dust(
  game : Game,
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
  p.kind = spark_kind_hit
  p.x = x
  p.y = y
  p.vx = vx
  p.vy = vy
  p.life = f(0.45)
  p.max_life = f(0.45)
  p.size = rand_rangef(game, f(3.0), f(8.0))
  p.growth = rand_rangef(game, f(-8.0), f(10.0))
  p.spin = rand_rangef(game, f(-7.0), f(7.0))
  p.rot = rand_rangef(game, f(0.0), f(6.2))
  p.color = color
}

///|
fn spawn_hit_spark(
  game : Game,
  x : Float,
  y : Float,
  kind : Int,
  count : Int,
) -> Unit {
  let color = if kind == spark_kind_block {
    @raylib.Color::new(135, 186, 255, 255)
  } else if kind == spark_kind_super {
    @raylib.Color::new(255, 216, 120, 255)
  } else {
    @raylib.Color::new(255, 138, 86, 255)
  }

  for i = 0; i < count; i = i + 1 {
    let idx = allocate_particle_slot(game.hit_sparks)
    if idx < 0 {
      return
    }

    let angle = rand_rangef(game, f(0.0), f(6.28))
    let speed = rand_rangef(
      game,
      if kind == spark_kind_super {
        f(200.0)
      } else {
        f(120.0)
      },
      if kind == spark_kind_super {
        f(520.0)
      } else {
        f(360.0)
      },
    )
    let vx = Float::from_double(@math.cos(angle.to_double())) * speed
    let vy = Float::from_double(@math.sin(angle.to_double())) * speed -
      rand_rangef(game, f(30.0), f(90.0))

    let p = game.hit_sparks[idx]
    p.active = true
    p.kind = kind
    p.x = x
    p.y = y
    p.vx = vx
    p.vy = vy
    p.life = rand_rangef(game, f(0.18), f(0.48))
    p.max_life = p.life
    p.size = if kind == spark_kind_super {
      rand_rangef(game, f(5.0), f(12.0))
    } else {
      rand_rangef(game, f(3.0), f(8.0))
    }
    p.growth = rand_rangef(game, f(-10.0), f(12.0))
    p.spin = rand_rangef(game, f(-14.0), f(14.0))
    p.rot = angle
    p.color = color
  }
}

///|
fn spawn_ground_skid(game : Game, fighter : Fighter) -> Unit {
  let archetype = fighter_archetype(game, fighter)
  for i = 0; i < 3; i = i + 1 {
    let jitter_x = rand_rangef(game, f(-18.0), f(18.0))
    let jitter_y = rand_rangef(game, f(-3.0), f(3.0))
    spawn_stage_dust(
      game,
      fighter.x + jitter_x,
      floor_y + jitter_y,
      -fighter.vx * f(0.2) + rand_rangef(game, f(-30.0), f(30.0)),
      rand_rangef(game, f(-80.0), f(-20.0)),
      @raylib.color_alpha(archetype.aura_color, f(0.45)),
    )
  }
}

///|
fn update_particle_list(list : Array[Particle], dt : Float) -> Unit {
  for i = 0; i < list.length(); i = i + 1 {
    let p = list[i]
    if not(p.active) {
      continue i + 1
    }

    p.life -= dt
    if p.life <= f(0.0) {
      p.active = false
      continue i + 1
    }

    p.vy += particle_gravity * dt
    p.vx *= f(1.0) - (f(1.0) - particle_friction) * dt * f(60.0)
    p.vy *= f(1.0) - (f(1.0) - particle_friction) * dt * f(30.0)

    p.x += p.vx * dt
    p.y += p.vy * dt
    p.size += p.growth * dt
    if p.size < f(1.0) {
      p.size = f(1.0)
    }
    p.rot += p.spin * dt
  }
}

///|
fn draw_particle_list(
  list : Array[Particle],
  camera_x : Float,
  camera_y : Float,
) -> Unit {
  for i = 0; i < list.length(); i = i + 1 {
    let p = list[i]
    if not(p.active) {
      continue i + 1
    }

    let alpha = clampf(p.life / p.max_life, f(0.0), f(1.0))
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
fn update_particles(game : Game, dt : Float) -> Unit {
  update_particle_list(game.particles, dt)
  update_particle_list(game.hit_sparks, dt)
}

///|
fn draw_particles(game : Game) -> Unit {
  draw_particle_list(game.particles, game.camera_x, game.camera_y)
  draw_particle_list(game.hit_sparks, game.camera_x, game.camera_y)
}

///|
fn update_camera(game : Game, dt : Float) -> Unit {
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]
  let center_x = (p1.x + p2.x) * f(0.5)
  let target_camera_x = Float::from_int(screen_width) * f(0.5) - center_x
  game.camera_x = lerpf(game.camera_x, target_camera_x, dt * f(5.5))

  let center_y = minf(p1.y, p2.y) - f(250.0)
  let target_camera_y = Float::from_int(screen_height) * f(0.5) - center_y
  game.camera_y = lerpf(game.camera_y, target_camera_y, dt * f(4.2))

  let distance = fighter_distance_x(p1, p2)
  let target_zoom = if distance < f(190.0) {
    camera_zoom_close
  } else if distance > f(420.0) {
    camera_zoom_far
  } else {
    camera_zoom_base
  }
  game.camera_zoom = lerpf(game.camera_zoom, target_zoom, dt * f(1.8))

  if game.camera_shake > f(0.0) {
    game.camera_phase += dt * f(44.0)
    let sx = Float::from_double(@math.sin(game.camera_phase.to_double()))
    let sy = Float::from_double(
      @math.cos((game.camera_phase * f(1.33)).to_double()),
    )
    game.camera_x += sx * game.camera_shake
    game.camera_y += sy * game.camera_shake * f(0.7)

    game.camera_shake -= dt * camera_shake_decay * f(10.0)
    if game.camera_shake < f(0.0) {
      game.camera_shake = f(0.0)
    }
  }
}
