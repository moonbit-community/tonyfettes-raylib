///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut heading : Float
  mut hull : Float
  hull_max : Float
  mut energy : Float
  energy_max : Float
  mut cargo : Int
  cargo_cap : Int
  mut ping_cd : Float
  mut ping_t : Float
  mut ping_x : Float
  mut ping_y : Float
  mut wake_t : Float
}

///|
struct Lighthouse {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut demand : Float
  mut warning_t : Float
  mut priority : Int
  mut served : Int
  mut id : Int
}

///|
struct Reef {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut radius : Float
  mut hardness : Float
  mut pulse : Float
}

///|
struct Storm {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut radius : Float
  mut intensity : Float
  mut life : Float
  mut phase : Float
}

///|
struct Pirate {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut speed : Float
  mut attack_cd : Float
  mut blink_t : Float
  mut target_i : Int
  mut id : Int
}

///|
struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
fn clear_lights(lights : Array[Lighthouse]) -> Unit {
  for i = 0; i < lights.length(); i = i + 1 {
    lights[i].active = false
    lights[i].x = 0.0
    lights[i].y = 0.0
    lights[i].demand = 0.0
    lights[i].warning_t = 0.0
    lights[i].priority = 1
    lights[i].served = 0
    lights[i].id = i + 1
  }
}

///|
fn clear_reefs(reefs : Array[Reef]) -> Unit {
  for i = 0; i < reefs.length(); i = i + 1 {
    reefs[i].active = false
    reefs[i].x = 0.0
    reefs[i].y = 0.0
    reefs[i].radius = 0.0
    reefs[i].hardness = 0.0
    reefs[i].pulse = 0.0
  }
}

///|
fn clear_storms(storms : Array[Storm]) -> Unit {
  for i = 0; i < storms.length(); i = i + 1 {
    storms[i].active = false
    storms[i].x = 0.0
    storms[i].y = 0.0
    storms[i].vx = 0.0
    storms[i].vy = 0.0
    storms[i].radius = 0.0
    storms[i].intensity = 0.0
    storms[i].life = 0.0
    storms[i].phase = 0.0
  }
}

///|
fn clear_pirates(pirates : Array[Pirate]) -> Unit {
  for i = 0; i < pirates.length(); i = i + 1 {
    pirates[i].active = false
    pirates[i].x = 0.0
    pirates[i].y = 0.0
    pirates[i].vx = 0.0
    pirates[i].vy = 0.0
    pirates[i].speed = 0.0
    pirates[i].attack_cd = 0.0
    pirates[i].blink_t = 0.0
    pirates[i].target_i = -1
    pirates[i].id = i + 1
  }
}

///|
fn clear_parts(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    parts[i].active = false
    parts[i].x = 0.0
    parts[i].y = 0.0
    parts[i].vx = 0.0
    parts[i].vy = 0.0
    parts[i].life = 0.0
    parts[i].size = 0.0
    parts[i].kind = 0
  }
}

///|
fn add_particle(
  parts : Array[Particle],
  x : Float,
  y : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if parts[i].active {
      continue
    }

    parts[i].active = true
    parts[i].x = x
    parts[i].y = y
    let a : Float = randf(0.0, 6.28318)
    let s : Float = if kind == 0 {
      randf(8.0, 40.0)
    } else if kind == 1 {
      randf(24.0, 120.0)
    } else {
      randf(14.0, 88.0)
    }
    parts[i].vx = @math.cosf(a) * s
    parts[i].vy = @math.sinf(a) * s
    parts[i].life = if kind == 0 {
      randf(0.4, 1.0)
    } else if kind == 1 {
      randf(0.15, 0.45)
    } else {
      randf(0.25, 0.8)
    }
    parts[i].size = if kind == 1 { randf(2.4, 7.6) } else { randf(1.7, 5.2) }
    parts[i].kind = kind
    return
  }
}

///|
fn burst(
  parts : Array[Particle],
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    add_particle(parts, x, y, kind)
  }
}

///|
fn update_parts(parts : Array[Particle], dt : Float) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      continue
    }

    parts[i].life = parts[i].life - dt
    if parts[i].life <= 0.0 {
      parts[i].active = false
      continue
    }

    parts[i].x = parts[i].x + parts[i].vx * dt
    parts[i].y = parts[i].y + parts[i].vy * dt

    if parts[i].kind == 0 {
      parts[i].vx = parts[i].vx * (1.0 - dt * 0.8)
      parts[i].vy = parts[i].vy + dt * 8.0
    } else if parts[i].kind == 1 {
      parts[i].vx = parts[i].vx * (1.0 - dt * 4.2)
      parts[i].vy = parts[i].vy + dt * 170.0
    } else {
      parts[i].vx = parts[i].vx * (1.0 - dt * 2.1)
      parts[i].vy = parts[i].vy + dt * 44.0
    }
  }
}

///|
fn init_lights(
  lights : Array[Lighthouse],
  world_x : Int,
  world_y : Int,
  world_w : Int,
  world_h : Int,
) -> Unit {
  clear_lights(lights)

  let left : Float = Float::from_int(world_x + 180)
  let right : Float = Float::from_int(world_x + world_w - 180)
  let top : Float = Float::from_int(world_y + 120)
  let bottom : Float = Float::from_int(world_y + world_h - 120)
  let mid_x : Float = Float::from_int(world_x + world_w / 2)
  let mid_y : Float = Float::from_int(world_y + world_h / 2)

  let spots : Array[(Float, Float, Int)] = [
    (left + 160.0, top + 30.0, 3),
    (left + 320.0, mid_y - 160.0, 2),
    (mid_x - 60.0, bottom - 80.0, 4),
    (right - 120.0, mid_y + 150.0, 3),
    (right - 200.0, top + 90.0, 5),
    (mid_x + 220.0, mid_y - 40.0, 2),
    (left + 80.0, bottom - 130.0, 4),
  ]

  for i = 0; i < lights.length() && i < spots.length(); i = i + 1 {
    let (sx, sy, pri) = spots[i]
    lights[i].active = true
    lights[i].x = sx + randf(-14.0, 14.0)
    lights[i].y = sy + randf(-14.0, 14.0)
    lights[i].demand = randf(8.0, 32.0)
    lights[i].warning_t = 0.0
    lights[i].priority = pri
    lights[i].served = 0
    lights[i].id = i + 1
  }
}

///|
fn init_reefs(
  reefs : Array[Reef],
  lights : Array[Lighthouse],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  harbor_x : Float,
  harbor_y : Float,
) -> Unit {
  clear_reefs(reefs)

  let mut count : Int = 0
  let target : Int = reefs.length() - 16

  while count < target {
    let x : Float = randf(world_l + 30.0, world_r - 30.0)
    let y : Float = randf(world_t + 30.0, world_b - 30.0)
    let rr : Float = randf(10.0, 28.0)

    if dist2(x, y, harbor_x, harbor_y) < 180.0 * 180.0 {
      continue
    }

    let mut near_light : Bool = false
    for i = 0; i < lights.length(); i = i + 1 {
      if not(lights[i].active) {
        continue
      }
      if dist2(x, y, lights[i].x, lights[i].y) < 120.0 * 120.0 {
        near_light = true
        break
      }
    }
    if near_light {
      continue
    }

    let mut overlap : Bool = false
    for i = 0; i < reefs.length(); i = i + 1 {
      if not(reefs[i].active) {
        continue
      }

      let rsum : Float = rr + reefs[i].radius + 8.0
      if dist2(x, y, reefs[i].x, reefs[i].y) < rsum * rsum {
        overlap = true
        break
      }
    }
    if overlap {
      continue
    }

    reefs[count].active = true
    reefs[count].x = x
    reefs[count].y = y
    reefs[count].radius = rr
    reefs[count].hardness = randf(20.0, 110.0)
    reefs[count].pulse = randf(0.0, 20.0)

    count = count + 1
  }
}

///|
fn active_storms(storms : Array[Storm]) -> Int {
  let mut n : Int = 0
  for i = 0; i < storms.length(); i = i + 1 {
    if storms[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn active_pirates(pirates : Array[Pirate]) -> Int {
  let mut n : Int = 0
  for i = 0; i < pirates.length(); i = i + 1 {
    if pirates[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn peak_demand(lights : Array[Lighthouse]) -> Float {
  let mut best : Float = 0.0
  for i = 0; i < lights.length(); i = i + 1 {
    if not(lights[i].active) {
      continue
    }
    if lights[i].demand > best {
      best = lights[i].demand
    }
  }
  best
}

///|
fn total_demand(lights : Array[Lighthouse]) -> Float {
  let mut sum : Float = 0.0
  for i = 0; i < lights.length(); i = i + 1 {
    if lights[i].active {
      sum = sum + lights[i].demand
    }
  }
  sum
}

///|
fn spawn_storm(
  storms : Array[Storm],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  tier : Int,
) -> Bool {
  for i = 0; i < storms.length(); i = i + 1 {
    if storms[i].active {
      continue
    }

    let side : Int = @raylib.get_random_value(0, 3)
    if side == 0 {
      storms[i].x = world_l - 56.0
      storms[i].y = randf(world_t + 20.0, world_b - 20.0)
      storms[i].vx = randf(18.0, 48.0)
      storms[i].vy = randf(-12.0, 12.0)
    } else if side == 1 {
      storms[i].x = world_r + 56.0
      storms[i].y = randf(world_t + 20.0, world_b - 20.0)
      storms[i].vx = randf(-48.0, -18.0)
      storms[i].vy = randf(-12.0, 12.0)
    } else if side == 2 {
      storms[i].x = randf(world_l + 20.0, world_r - 20.0)
      storms[i].y = world_t - 56.0
      storms[i].vx = randf(-16.0, 16.0)
      storms[i].vy = randf(20.0, 42.0)
    } else {
      storms[i].x = randf(world_l + 20.0, world_r - 20.0)
      storms[i].y = world_b + 56.0
      storms[i].vx = randf(-16.0, 16.0)
      storms[i].vy = randf(-42.0, -20.0)
    }

    storms[i].active = true
    storms[i].radius = randf(64.0, 136.0)
    storms[i].intensity = randf(0.75, 1.55) + Float::from_int(tier) * 0.03
    storms[i].life = randf(18.0, 42.0)
    storms[i].phase = randf(0.0, 20.0)
    return true
  }
  false
}

///|
fn spawn_pirate(
  pirates : Array[Pirate],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  tier : Int,
  serial : Int,
) -> Bool {
  for i = 0; i < pirates.length(); i = i + 1 {
    if pirates[i].active {
      continue
    }

    let side : Int = @raylib.get_random_value(0, 3)
    if side == 0 {
      pirates[i].x = world_l - 34.0
      pirates[i].y = randf(world_t + 16.0, world_b - 16.0)
    } else if side == 1 {
      pirates[i].x = world_r + 34.0
      pirates[i].y = randf(world_t + 16.0, world_b - 16.0)
    } else if side == 2 {
      pirates[i].x = randf(world_l + 16.0, world_r - 16.0)
      pirates[i].y = world_t - 34.0
    } else {
      pirates[i].x = randf(world_l + 16.0, world_r - 16.0)
      pirates[i].y = world_b + 34.0
    }

    pirates[i].active = true
    pirates[i].vx = 0.0
    pirates[i].vy = 0.0
    pirates[i].speed = randf(68.0, 98.0) + Float::from_int(tier) * 2.1
    pirates[i].attack_cd = randf(0.2, 1.0)
    pirates[i].blink_t = 0.0
    pirates[i].target_i = -1
    pirates[i].id = serial
    return true
  }
  false
}

///|
fn update_storms(
  storms : Array[Storm],
  dt : Float,
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
) -> Unit {
  for i = 0; i < storms.length(); i = i + 1 {
    if not(storms[i].active) {
      continue
    }

    storms[i].life = storms[i].life - dt
    if storms[i].life <= 0.0 {
      storms[i].active = false
      continue
    }

    storms[i].phase = storms[i].phase + dt * (0.8 + storms[i].intensity * 0.35)
    let p : Float = 0.88 + 0.2 * (@math.sinf(storms[i].phase) * 0.5 + 0.5)

    storms[i].x = storms[i].x + storms[i].vx * dt * p
    storms[i].y = storms[i].y + storms[i].vy * dt * p

    if storms[i].x < world_l - 130.0 {
      storms[i].x = world_l - 130.0
      storms[i].vx = absf(storms[i].vx)
    } else if storms[i].x > world_r + 130.0 {
      storms[i].x = world_r + 130.0
      storms[i].vx = -absf(storms[i].vx)
    }

    if storms[i].y < world_t - 130.0 {
      storms[i].y = world_t - 130.0
      storms[i].vy = absf(storms[i].vy)
    } else if storms[i].y > world_b + 130.0 {
      storms[i].y = world_b + 130.0
      storms[i].vy = -absf(storms[i].vy)
    }
  }
}

///|
fn highest_demand_light(lights : Array[Lighthouse]) -> Int {
  let mut best_i : Int = -1
  let mut best : Float = -1.0
  for i = 0; i < lights.length(); i = i + 1 {
    if not(lights[i].active) {
      continue
    }
    if lights[i].demand > best {
      best = lights[i].demand
      best_i = i
    }
  }
  best_i
}

///|
fn update_pirates(
  pirates : Array[Pirate],
  lights : Array[Lighthouse],
  player : Player,
  parts : Array[Particle],
  dt : Float,
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
) -> (Int, Float) {
  let mut steals : Int = 0
  let mut hull_dmg : Float = 0.0

  let best_light : Int = highest_demand_light(lights)

  for i = 0; i < pirates.length(); i = i + 1 {
    if not(pirates[i].active) {
      continue
    }

    if pirates[i].attack_cd > 0.0 {
      pirates[i].attack_cd = pirates[i].attack_cd - dt
      if pirates[i].attack_cd < 0.0 {
        pirates[i].attack_cd = 0.0
      }
    }

    if pirates[i].blink_t > 0.0 {
      pirates[i].blink_t = pirates[i].blink_t - dt
      if pirates[i].blink_t < 0.0 {
        pirates[i].blink_t = 0.0
      }
    }

    let mut tx : Float = player.x
    let mut ty : Float = player.y

    if best_light >= 0 && (player.cargo <= 0 || i % 2 == 0) {
      pirates[i].target_i = best_light
      tx = lights[best_light].x
      ty = lights[best_light].y
    } else {
      pirates[i].target_i = -1
    }

    let dx : Float = tx - pirates[i].x
    let dy : Float = ty - pirates[i].y
    let d : Float = maxf(0.001, (dx * dx + dy * dy).sqrt())

    let chase_scale : Float = if player.cargo > 0 { 1.1 } else { 0.92 }

    pirates[i].vx = dx / d * pirates[i].speed * chase_scale
    pirates[i].vy = dy / d * pirates[i].speed * chase_scale

    pirates[i].x = pirates[i].x + pirates[i].vx * dt
    pirates[i].y = pirates[i].y + pirates[i].vy * dt

    pirates[i].x = clampf(pirates[i].x, world_l - 80.0, world_r + 80.0)
    pirates[i].y = clampf(pirates[i].y, world_t - 80.0, world_b + 80.0)

    let d2p : Float = dist2(pirates[i].x, pirates[i].y, player.x, player.y)
    if d2p < 36.0 * 36.0 && pirates[i].attack_cd <= 0.0 {
      pirates[i].attack_cd = 0.9
      pirates[i].blink_t = 0.35

      if player.cargo > 0 {
        player.cargo = player.cargo - 1
        steals = steals + 1
      }

      let dmg : Float = randf(1.0, 3.2)
      hull_dmg = hull_dmg + dmg

      burst(parts, player.x, player.y, 8, 1)
    }
  }

  (steals, hull_dmg)
}

///|
fn update_light_demands(
  lights : Array[Lighthouse],
  dt : Float,
  tier : Int,
) -> (Int, Int, Float) {
  let mut blackout_gain : Int = 0
  let mut urgent_count : Int = 0
  let mut demand_sum : Float = 0.0

  for i = 0; i < lights.length(); i = i + 1 {
    if not(lights[i].active) {
      continue
    }

    if lights[i].warning_t > 0.0 {
      lights[i].warning_t = lights[i].warning_t - dt
      if lights[i].warning_t < 0.0 {
        lights[i].warning_t = 0.0
      }
    }

    let inc : Float = dt *
      (
        2.3 +
        Float::from_int(lights[i].priority) * 0.65 +
        Float::from_int(tier) * 0.22
      )
    lights[i].demand = lights[i].demand + inc

    if lights[i].demand >= 72.0 {
      urgent_count = urgent_count + 1
    }

    if lights[i].demand >= 100.0 {
      blackout_gain = blackout_gain + 1
      lights[i].demand = randf(56.0, 70.0)
      lights[i].warning_t = 1.6
    }

    demand_sum = demand_sum + lights[i].demand
  }

  (blackout_gain, urgent_count, demand_sum)
}

///|
fn deliver_to_lights(
  player : Player,
  lights : Array[Lighthouse],
  parts : Array[Particle],
) -> (Int, Int) {
  if player.cargo <= 0 {
    (0, 0)
  } else {
    let mut used : Int = 0
    let mut lights_served : Int = 0

    for i = 0; i < lights.length(); i = i + 1 {
      if not(lights[i].active) || lights[i].demand <= 0.1 || player.cargo <= 0 {
        continue
      }

      let d2 : Float = dist2(player.x, player.y, lights[i].x, lights[i].y)
      if d2 > 92.0 * 92.0 {
        continue
      }

      let need_i : Int = lights[i].demand.to_int() + 1
      let give : Int = mini(player.cargo, mini(need_i, 18))
      if give <= 0 {
        continue
      }

      player.cargo = player.cargo - give
      used = used + give
      lights_served = lights_served + 1
      lights[i].served = lights[i].served + give
      lights[i].demand = maxf(
        0.0,
        lights[i].demand - Float::from_int(give) * 1.3,
      )
      lights[i].warning_t = 0.0

      burst(parts, lights[i].x, lights[i].y, 10 + give / 2, 2)
    }

    (used, lights_served)
  }
}

///|
fn nearest_urgent_light(
  lights : Array[Lighthouse],
  x : Float,
  y : Float,
) -> (Bool, Float, Float, Float) {
  let mut found : Bool = false
  let mut best_d2 : Float = 999999999.0
  let mut best_x : Float = x
  let mut best_y : Float = y
  let mut best_dem : Float = 0.0

  for i = 0; i < lights.length(); i = i + 1 {
    if not(lights[i].active) || lights[i].demand < 40.0 {
      continue
    }

    let d2v : Float = dist2(x, y, lights[i].x, lights[i].y)
    if d2v < best_d2 {
      best_d2 = d2v
      best_x = lights[i].x
      best_y = lights[i].y
      best_dem = lights[i].demand
      found = true
    }
  }

  (found, best_x, best_y, best_dem)
}

///|
fn draw_ocean(
  world_x : Int,
  world_y : Int,
  world_w : Int,
  world_h : Int,
  t : Float,
) -> Unit {
  @raylib.draw_rectangle(
    world_x,
    world_y,
    world_w,
    world_h,
    @raylib.Color::new(10, 32, 56, 255),
  )

  let mut y : Int = world_y
  while y < world_y + world_h {
    let p : Float = Float::from_int(y - world_y) / Float::from_int(world_h)
    let w : Float = @math.sinf(t * 0.8 + Float::from_int(y) * 0.018) * 0.5 + 0.5

    let r : Int = 18 + (p * 24.0).to_int() + (w * 6.0).to_int()
    let g : Int = 64 + (p * 44.0).to_int() + (w * 8.0).to_int()
    let b : Int = 108 + (p * 34.0).to_int() + (w * 11.0).to_int()

    @raylib.draw_rectangle(
      world_x,
      y,
      world_w,
      4,
      @raylib.Color::new(r, g, b, 255),
    )
    y = y + 4
  }

  @raylib.draw_rectangle_lines(
    world_x,
    world_y,
    world_w,
    world_h,
    @raylib.Color::new(136, 188, 226, 214),
  )
}

///|
fn draw_harbor(
  harbor_x : Int,
  harbor_y : Int,
  harbor_w : Int,
  harbor_h : Int,
) -> Unit {
  @raylib.draw_rectangle(
    harbor_x,
    harbor_y,
    harbor_w,
    harbor_h,
    @raylib.Color::new(42, 76, 110, 232),
  )
  @raylib.draw_rectangle_lines(
    harbor_x,
    harbor_y,
    harbor_w,
    harbor_h,
    @raylib.Color::new(178, 214, 244, 242),
  )

  let mut x : Int = harbor_x + 10
  while x < harbor_x + harbor_w - 8 {
    @raylib.draw_line(
      x,
      harbor_y + 8,
      x,
      harbor_y + harbor_h - 8,
      @raylib.Color::new(90, 132, 168, 200),
    )
    x = x + 16
  }

  @raylib.draw_text(
    "HARBOR",
    harbor_x + 12,
    harbor_y + harbor_h + 8,
    24,
    @raylib.Color::new(228, 242, 255, 246),
  )
}

///|
fn draw_lights(lights : Array[Lighthouse], t : Float) -> Unit {
  for i = 0; i < lights.length(); i = i + 1 {
    if not(lights[i].active) {
      continue
    }

    let p01 : Float = clampf(lights[i].demand / 100.0, 0.0, 1.0)
    let blink : Float = @math.sinf(t * 3.4 + Float::from_int(i) * 0.8) * 0.5 +
      0.5

    let body_col : @raylib.Color = if lights[i].warning_t > 0.0 ||
      lights[i].demand >= 80.0 {
      @raylib.Color::new(246, 162, 152, 252)
    } else {
      @raylib.Color::new(232, 238, 246, 252)
    }

    @raylib.draw_rectangle(
      (lights[i].x - 10.0).to_int(),
      (lights[i].y - 34.0).to_int(),
      20,
      40,
      body_col,
    )
    @raylib.draw_rectangle(
      (lights[i].x - 16.0).to_int(),
      (lights[i].y + 6.0).to_int(),
      32,
      8,
      @raylib.Color::new(104, 146, 184, 236),
    )

    let beam_r : Float = 30.0 + p01 * 72.0 + blink * 6.0
    let beam_a : Int = 54 + (p01 * 88.0).to_int()
    @raylib.draw_circle(
      lights[i].x.to_int(),
      (lights[i].y - 38.0).to_int(),
      beam_r,
      @raylib.Color::new(250, 240, 178, beam_a),
    )

    @raylib.draw_circle(
      lights[i].x.to_int(),
      (lights[i].y - 38.0).to_int(),
      6.0,
      @raylib.Color::new(252, 248, 220, 252),
    )

    @raylib.draw_text(
      "L\{lights[i].id} D:\{lights[i].demand.to_int()}",
      (lights[i].x - 42.0).to_int(),
      (lights[i].y + 20.0).to_int(),
      18,
      @raylib.Color::new(228, 240, 252, 236),
    )
  }
}

///|
fn draw_reefs(reefs : Array[Reef], t : Float) -> Unit {
  for i = 0; i < reefs.length(); i = i + 1 {
    if not(reefs[i].active) {
      continue
    }

    let pulse : Float = 0.86 +
      0.22 * (@math.sinf(t * 1.8 + reefs[i].pulse) * 0.5 + 0.5)
    let rr : Float = reefs[i].radius * pulse
    let h01 : Float = clampf(reefs[i].hardness / 120.0, 0.0, 1.0)

    let r : Int = 88 + (h01 * 40.0).to_int()
    let g : Int = 130 + (h01 * 44.0).to_int()
    let b : Int = 120 + (h01 * 14.0).to_int()

    @raylib.draw_circle(
      reefs[i].x.to_int(),
      reefs[i].y.to_int(),
      rr + 2.0,
      @raylib.Color::new(54, 88, 116, 170),
    )
    @raylib.draw_circle(
      reefs[i].x.to_int(),
      reefs[i].y.to_int(),
      rr,
      @raylib.Color::new(r, g, b, 238),
    )
  }
}

///|
fn draw_storms(storms : Array[Storm], t : Float) -> Unit {
  for i = 0; i < storms.length(); i = i + 1 {
    if not(storms[i].active) {
      continue
    }

    let p : Float = 0.84 +
      0.22 * (@math.sinf(t * 2.0 + storms[i].phase) * 0.5 + 0.5)
    let rr0 : Float = storms[i].radius * p
    let rr1 : Float = storms[i].radius * (0.58 + p * 0.2)

    let a0 : Int = 50 + (storms[i].intensity * 62.0).to_int()
    let a1 : Int = 22 + (storms[i].intensity * 30.0).to_int()

    @raylib.draw_circle(
      storms[i].x.to_int(),
      storms[i].y.to_int(),
      rr0,
      @raylib.Color::new(132, 168, 212, a0),
    )
    @raylib.draw_circle(
      storms[i].x.to_int(),
      storms[i].y.to_int(),
      rr1,
      @raylib.Color::new(186, 214, 246, a1),
    )

    let bx : Int = (storms[i].x +
    @math.sinf(t * 5.2 + storms[i].phase) * storms[i].radius * 0.24).to_int()
    let by : Int = (storms[i].y +
    @math.cosf(t * 4.4 + storms[i].phase * 0.6) * storms[i].radius * 0.24).to_int()
    @raylib.draw_circle(
      bx,
      by,
      2.6 + storms[i].intensity * 2.2,
      @raylib.Color::new(248, 252, 255, 206),
    )
  }
}

///|
fn draw_pirates(pirates : Array[Pirate], t : Float) -> Unit {
  for i = 0; i < pirates.length(); i = i + 1 {
    if not(pirates[i].active) {
      continue
    }

    let col : @raylib.Color = if pirates[i].blink_t > 0.0 {
      @raylib.Color::new(248, 192, 162, 252)
    } else {
      @raylib.Color::new(228, 122, 122, 250)
    }

    let wob : Float = @math.sinf(t * 4.0 + Float::from_int(i) * 0.7) * 2.4

    @raylib.draw_rectangle(
      (pirates[i].x - 12.0).to_int(),
      (pirates[i].y - 8.0 + wob).to_int(),
      24,
      16,
      col,
    )
    @raylib.draw_rectangle(
      (pirates[i].x - 8.0).to_int(),
      (pirates[i].y - 13.0 + wob).to_int(),
      16,
      6,
      @raylib.Color::new(246, 214, 206, 236),
    )

    @raylib.draw_text(
      "P\{pirates[i].id}",
      (pirates[i].x - 13.0).to_int(),
      (pirates[i].y - 28.0 + wob).to_int(),
      15,
      @raylib.Color::new(252, 224, 216, 240),
    )

    if pirates[i].target_i >= 0 {
      @raylib.draw_text(
        "L\{pirates[i].target_i + 1}",
        (pirates[i].x - 10.0).to_int(),
        (pirates[i].y + 12.0 + wob).to_int(),
        13,
        @raylib.Color::new(252, 226, 214, 220),
      )
    }
  }
}

///|
fn draw_player(player : Player, t : Float) -> Unit {
  let x : Float = player.x
  let y : Float = player.y

  let nx : Float = @math.cosf(player.heading)
  let ny : Float = @math.sinf(player.heading)

  let hull_col : @raylib.Color = if player.hull < 36.0 {
    @raylib.Color::new(248, 162, 170, 252)
  } else {
    @raylib.Color::new(240, 244, 252, 252)
  }

  @raylib.draw_rectangle(
    (x - 13.0).to_int(),
    (y - 8.0).to_int(),
    26,
    16,
    hull_col,
  )
  @raylib.draw_rectangle(
    (x - 8.0).to_int(),
    (y - 12.0).to_int(),
    16,
    6,
    @raylib.Color::new(204, 230, 250, 238),
  )

  @raylib.draw_line(
    x.to_int(),
    y.to_int(),
    (x + nx * 24.0).to_int(),
    (y + ny * 24.0).to_int(),
    @raylib.Color::new(252, 248, 214, 236),
  )

  let wake_r : Float = 8.0 +
    (@math.sinf(t * 4.4 + player.wake_t) * 0.5 + 0.5) * 5.5
  @raylib.draw_circle(
    (x - nx * 18.0).to_int(),
    (y - ny * 18.0).to_int(),
    wake_r,
    @raylib.Color::new(176, 214, 246, 82),
  )

  // cargo markers on deck
  let shown : Int = mini(player.cargo, 6)
  for i = 0; i < shown; i = i + 1 {
    let cx : Int = (x - 10.0 + Float::from_int(i % 3) * 8.0).to_int()
    let cy : Int = (y + 3.0 + Float::from_int(i / 3) * 5.0).to_int()
    @raylib.draw_rectangle(cx, cy, 6, 4, @raylib.Color::new(180, 132, 92, 234))
  }

  if player.ping_t > 0.0 {
    let rr : Float = (2.2 - player.ping_t) * 72.0 + 16.0
    @raylib.draw_circle(
      player.x.to_int(),
      player.y.to_int(),
      rr,
      @raylib.Color::new(170, 226, 252, 88),
    )
  }
}

///|
fn draw_parts(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      continue
    }

    let col : @raylib.Color = if parts[i].kind == 0 {
      @raylib.Color::new(194, 226, 252, 186)
    } else if parts[i].kind == 1 {
      @raylib.Color::new(248, 194, 144, 220)
    } else {
      @raylib.Color::new(170, 242, 206, 214)
    }

    @raylib.draw_circle(
      parts[i].x.to_int(),
      parts[i].y.to_int(),
      parts[i].size,
      col,
    )
  }
}

///|
fn draw_touch_controls(
  sw : Int,
  sh : Int,
  mx : Float,
  my : Float,
  hold : Bool,
) -> Unit {
  let pad_x : Int = 28
  let pad_y : Int = sh - 198

  fn draw_dpad(
    x : Int,
    y : Int,
    w : Int,
    h : Int,
    text : String,
    active : Bool,
  ) -> Unit {
    let col : @raylib.Color = if active {
      @raylib.Color::new(122, 180, 222, 226)
    } else {
      @raylib.Color::new(42, 74, 108, 198)
    }

    @raylib.draw_rectangle(x, y, w, h, col)
    @raylib.draw_rectangle_lines(
      x,
      y,
      w,
      h,
      @raylib.Color::new(170, 208, 240, 240),
    )
    @raylib.draw_text(
      text,
      x + w / 2 - @raylib.measure_text(text, 28) / 2,
      y + 10,
      28,
      @raylib.Color::new(236, 248, 255, 252),
    )
  }

  draw_dpad(
    pad_x + 84,
    pad_y,
    74,
    56,
    "U",
    hold && inside_rect(mx, my, pad_x + 84, pad_y, 74, 56),
  )
  draw_dpad(
    pad_x,
    pad_y + 66,
    74,
    56,
    "L",
    hold && inside_rect(mx, my, pad_x, pad_y + 66, 74, 56),
  )
  draw_dpad(
    pad_x + 168,
    pad_y + 66,
    74,
    56,
    "R",
    hold && inside_rect(mx, my, pad_x + 168, pad_y + 66, 74, 56),
  )
  draw_dpad(
    pad_x + 84,
    pad_y + 132,
    74,
    56,
    "D",
    hold && inside_rect(mx, my, pad_x + 84, pad_y + 132, 74, 56),
  )

  let boost_x : Float = Float::from_int(sw - 302)
  let boost_y : Float = Float::from_int(sh - 164)
  let drop_x : Float = Float::from_int(sw - 190)
  let drop_y : Float = Float::from_int(sh - 238)
  let ping_x : Float = Float::from_int(sw - 106)
  let ping_y : Float = Float::from_int(sh - 142)

  fn round_btn(
    x : Float,
    y : Float,
    r : Float,
    label : String,
    active : Bool,
  ) -> Unit {
    let col : @raylib.Color = if active {
      @raylib.Color::new(126, 194, 236, 226)
    } else {
      @raylib.Color::new(40, 78, 116, 196)
    }

    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      r + 4.0,
      @raylib.Color::new(10, 18, 32, 176),
    )
    @raylib.draw_circle(x.to_int(), y.to_int(), r, col)
    @raylib.draw_text(
      label,
      x.to_int() - @raylib.measure_text(label, 23) / 2,
      y.to_int() - 10,
      23,
      @raylib.Color::new(236, 246, 255, 248),
    )
  }

  round_btn(
    boost_x,
    boost_y,
    56.0,
    "BOOST",
    hold && dist2(mx, my, boost_x, boost_y) <= 56.0 * 56.0,
  )
  round_btn(
    drop_x,
    drop_y,
    44.0,
    "DROP",
    hold && dist2(mx, my, drop_x, drop_y) <= 44.0 * 44.0,
  )
  round_btn(
    ping_x,
    ping_y,
    42.0,
    "PING",
    hold && dist2(mx, my, ping_x, ping_y) <= 42.0 * 42.0,
  )
}

///|
fn draw_bar(
  panel_x : Int,
  y : Int,
  label : String,
  value : Float,
  maxv : Float,
  col : @raylib.Color,
) -> Unit {
  @raylib.draw_text(
    label,
    panel_x + 16,
    y,
    23,
    @raylib.Color::new(216, 236, 252, 242),
  )
  @raylib.draw_rectangle(
    panel_x + 16,
    y + 28,
    364,
    20,
    @raylib.Color::new(18, 28, 44, 255),
  )

  let p01 : Float = if maxv <= 0.0001 {
    0.0
  } else {
    clampf(value / maxv, 0.0, 1.0)
  }
  let fw : Int = (Float::from_int(364) * p01).to_int()

  @raylib.draw_rectangle(panel_x + 16, y + 28, fw, 20, col)
  @raylib.draw_rectangle_lines(
    panel_x + 16,
    y + 28,
    364,
    20,
    @raylib.Color::new(166, 202, 236, 238),
  )

  @raylib.draw_text(
    "\{value.to_int()}/\{maxv.to_int()}",
    panel_x + 264,
    y + 52,
    19,
    @raylib.Color::new(220, 240, 254, 240),
  )
}

///|
fn draw_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  text : String,
  hover : Bool,
) -> Unit {
  let col : @raylib.Color = if hover {
    @raylib.Color::new(108, 176, 218, 242)
  } else {
    @raylib.Color::new(44, 84, 124, 222)
  }

  @raylib.draw_rectangle(x, y, w, h, col)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(198, 226, 252, 246),
  )
  @raylib.draw_text(
    text,
    x + w / 2 - @raylib.measure_text(text, 34) / 2,
    y + h / 2 - 17,
    34,
    @raylib.Color::new(238, 248, 255, 252),
  )
}

///|
fn main {
  let sw : Int = 1680
  let sh : Int = 940
  @raylib.init_window(sw, sh, "raylib [game] lighthouse supply run 2026")
  defer @raylib.close_window()

  @raylib.set_target_fps(120)

  let world_x : Int = 20
  let world_y : Int = 20
  let panel_w : Int = 420
  let world_w : Int = sw - panel_w - 40
  let world_h : Int = sh - 40

  let world_l : Float = Float::from_int(world_x)
  let world_t : Float = Float::from_int(world_y)
  let world_r : Float = Float::from_int(world_x + world_w)
  let world_b : Float = Float::from_int(world_y + world_h)

  let harbor_x : Int = world_x + 16
  let harbor_y : Int = world_y + world_h / 2 - 70
  let harbor_w : Int = 118
  let harbor_h : Int = 140

  let harbor_cx : Float = Float::from_int(harbor_x + harbor_w / 2)
  let harbor_cy : Float = Float::from_int(harbor_y + harbor_h / 2)

  let lights : Array[Lighthouse] = Array::makei(8, fn(i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      demand: 0.0,
      warning_t: 0.0,
      priority: 1,
      served: 0,
      id: i + 1,
    }
  })

  let reefs : Array[Reef] = Array::makei(180, fn(_i) {
    { active: false, x: 0.0, y: 0.0, radius: 0.0, hardness: 0.0, pulse: 0.0 }
  })

  let storms : Array[Storm] = Array::makei(20, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      radius: 0.0,
      intensity: 0.0,
      life: 0.0,
      phase: 0.0,
    }
  })

  let pirates : Array[Pirate] = Array::makei(14, fn(i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      speed: 0.0,
      attack_cd: 0.0,
      blink_t: 0.0,
      target_i: -1,
      id: i + 1,
    }
  })

  let parts : Array[Particle] = Array::makei(960, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      life: 0.0,
      size: 0.0,
      kind: 0,
    }
  })

  let player : Player = {
    x: harbor_cx,
    y: harbor_cy,
    vx: 0.0,
    vy: 0.0,
    heading: 0.0,
    hull: 100.0,
    hull_max: 100.0,
    energy: 100.0,
    energy_max: 100.0,
    cargo: 0,
    cargo_cap: 40,
    ping_cd: 0.0,
    ping_t: 0.0,
    ping_x: harbor_cx,
    ping_y: harbor_cy,
    wake_t: randf(0.0, 20.0),
  }

  let mut state : Int = 0 // 0 menu 1 play 2 win 3 lose
  let mut timer : Float = 420.0
  let mut delivered_total : Int = 0
  let mut target_delivered : Int = 560
  let mut score : Int = 0
  let mut tier : Int = 1
  let mut blackouts : Int = 0
  let mut blackout_limit : Int = 14
  let mut msg : String = ""
  let mut msg_t : Float = 0.0
  let mut scene_t : Float = 0.0

  let mut harbor_stock : Float = 180.0
  let mut harbor_stock_max : Float = 220.0
  let mut load_cd : Float = 0.0

  let mut storm_cd : Float = 5.5
  let mut pirate_cd : Float = 8.0
  let mut pirate_serial : Int = 1

  let mut steals_total : Int = 0
  let mut urgency_peak : Int = 0

  fn reset_run() -> Unit {
    init_lights(lights, world_x, world_y, world_w, world_h)
    init_reefs(
      reefs, lights, world_l, world_t, world_r, world_b, harbor_cx, harbor_cy,
    )

    clear_storms(storms)
    clear_pirates(pirates)
    clear_parts(parts)

    player.x = harbor_cx
    player.y = harbor_cy
    player.vx = 0.0
    player.vy = 0.0
    player.heading = 0.0
    player.hull = 100.0
    player.energy = 100.0
    player.cargo = 0
    player.ping_cd = 0.0
    player.ping_t = 0.0
    player.ping_x = harbor_cx
    player.ping_y = harbor_cy
    player.wake_t = randf(0.0, 20.0)

    timer = 420.0
    delivered_total = 0
    target_delivered = 560
    score = 0
    tier = 1
    blackouts = 0
    blackout_limit = 14

    harbor_stock = 180.0
    harbor_stock_max = 220.0
    load_cd = 0.0

    storm_cd = 5.5
    pirate_cd = 8.0
    pirate_serial = 1

    steals_total = 0
    urgency_peak = 0

    msg = "Load supplies at harbor and service lighthouse demand"
    msg_t = 2.6
  }

  reset_run()

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }
    scene_t = scene_t + dt

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    let mouse = @raylib.get_mouse_position()
    let click : Bool = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
    let hold : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    if load_cd > 0.0 {
      load_cd = load_cd - dt
      if load_cd < 0.0 {
        load_cd = 0.0
      }
    }

    if player.ping_cd > 0.0 {
      player.ping_cd = player.ping_cd - dt
      if player.ping_cd < 0.0 {
        player.ping_cd = 0.0
      }
    }

    if player.ping_t > 0.0 {
      player.ping_t = player.ping_t - dt
      if player.ping_t < 0.0 {
        player.ping_t = 0.0
      }
    }

    update_parts(parts, dt)

    if state == 0 {
      if click ||
        @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeySpace) {
        reset_run()
        state = 1
      }
    } else if state == 1 {
      timer = timer - dt
      if timer < 0.0 {
        timer = 0.0
      }

      tier = 1 + delivered_total / 90
      if tier > 9 {
        tier = 9
      }

      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)

      let mut boost_hold : Bool = @raylib.is_key_down(@raylib.KeyJ) ||
        @raylib.is_key_down(@raylib.KeySpace)
      let mut drop_press : Bool = @raylib.is_key_pressed(@raylib.KeyL) ||
        @raylib.is_key_pressed(@raylib.KeyU)
      let mut ping_press : Bool = @raylib.is_key_pressed(@raylib.KeyK) ||
        @raylib.is_key_pressed(@raylib.KeyH)

      if hold {
        let pad_x : Int = 28
        let pad_y : Int = sh - 198

        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y, 74, 56) {
          move_u = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 66, 74, 56) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 168, pad_y + 66, 74, 56) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y + 132, 74, 56) {
          move_d = true
        }

        let boost_x : Float = Float::from_int(sw - 302)
        let boost_y : Float = Float::from_int(sh - 164)
        let drop_x : Float = Float::from_int(sw - 190)
        let drop_y : Float = Float::from_int(sh - 238)

        if dist2(mouse.x, mouse.y, boost_x, boost_y) <= 56.0 * 56.0 {
          boost_hold = true
        }
        if dist2(mouse.x, mouse.y, drop_x, drop_y) <= 44.0 * 44.0 {
          drop_press = true
        }
      }

      if click {
        let ping_x : Float = Float::from_int(sw - 106)
        let ping_y : Float = Float::from_int(sh - 142)
        if dist2(mouse.x, mouse.y, ping_x, ping_y) <= 42.0 * 42.0 {
          ping_press = true
        }
      }

      let boost_on : Bool = boost_hold && player.energy > 1.0

      let accel_base : Float = if boost_on { 560.0 } else { 420.0 }
      let max_speed : Float = if boost_on { 296.0 } else { 220.0 }

      if move_l {
        player.vx = player.vx - accel_base * dt
      }
      if move_r {
        player.vx = player.vx + accel_base * dt
      }
      if move_u {
        player.vy = player.vy - accel_base * dt
      }
      if move_d {
        player.vy = player.vy + accel_base * dt
      }

      let drag : Float = if boost_on { 4.8 } else { 5.8 }
      player.vx = player.vx * (1.0 - dt * drag)
      player.vy = player.vy * (1.0 - dt * drag)

      let sp2 : Float = player.vx * player.vx + player.vy * player.vy
      if sp2 > max_speed * max_speed {
        let k : Float = max_speed / sp2.sqrt()
        player.vx = player.vx * k
        player.vy = player.vy * k
      }

      player.x = clampf(player.x + player.vx * dt, world_l + 8.0, world_r - 8.0)
      player.y = clampf(player.y + player.vy * dt, world_t + 8.0, world_b - 8.0)

      if sp2 > 54.0 {
        player.heading = @math.atan2f(player.vy, player.vx)
      }

      player.wake_t = player.wake_t + dt * (2.4 + sp2.sqrt() * 0.012)

      let speed_norm : Float = sp2.sqrt() / max_speed
      let boost_drain : Float = if boost_on { 1.9 } else { 0.0 }
      player.energy = maxf(
        0.0,
        player.energy - dt * (0.4 + speed_norm * 0.7 + boost_drain),
      )

      let near_harbor : Bool = inside_rect(
        player.x,
        player.y,
        harbor_x - 8,
        harbor_y - 8,
        harbor_w + 16,
        harbor_h + 16,
      )
      if near_harbor {
        player.energy = minf(player.energy_max, player.energy + dt * 22.0)
        player.hull = minf(player.hull_max, player.hull + dt * 5.0)

        if load_cd <= 0.0 &&
          harbor_stock >= 1.0 &&
          player.cargo < player.cargo_cap {
          player.cargo = player.cargo + 1
          harbor_stock = harbor_stock - 1.0
          load_cd = 0.11
        }
      }

      harbor_stock = minf(
        harbor_stock_max,
        harbor_stock + dt * (3.8 + Float::from_int(tier) * 0.2),
      )

      if drop_press {
        if near_harbor {
          // quick load action at harbor
          let can_load : Int = player.cargo_cap - player.cargo
          let load_n : Int = mini(can_load, mini(18, harbor_stock.to_int()))
          if load_n > 0 {
            player.cargo = player.cargo + load_n
            harbor_stock = harbor_stock - Float::from_int(load_n)
            score = score + load_n
            msg = "Loaded \{load_n} supply crates"
            msg_t = 0.8
            burst(parts, player.x, player.y, 8 + load_n / 2, 0)
          } else {
            msg = "Harbor stock empty"
            msg_t = 0.6
          }
        } else {
          let (used, served_lights) = deliver_to_lights(player, lights, parts)
          if used > 0 {
            delivered_total = delivered_total + used
            score = score + used * 6 + served_lights * 12
            msg = "Delivered \{used} crates to \{served_lights} light(s)"
            msg_t = 1.0
          } else {
            msg = "No lighthouse in delivery range"
            msg_t = 0.6
          }
        }
      }

      if ping_press && player.ping_cd <= 0.0 {
        let (found, tx, ty, demand) = nearest_urgent_light(
          lights,
          player.x,
          player.y,
        )
        if found {
          player.ping_cd = 2.2
          player.ping_t = 2.2
          player.ping_x = tx
          player.ping_y = ty
          msg = "Ping lock: urgent demand \{demand.to_int()}"
          msg_t = 0.9
          burst(parts, player.x, player.y, 9, 2)
          burst(parts, tx, ty, 12, 2)
        } else {
          player.ping_cd = 1.0
          msg = "No urgent lighthouse"
          msg_t = 0.6
        }
      }

      // Reef collisions
      let mut reef_damage : Float = 0.0
      for i = 0; i < reefs.length(); i = i + 1 {
        if not(reefs[i].active) {
          continue
        }

        reefs[i].pulse = reefs[i].pulse + dt * 0.5

        let rr : Float = reefs[i].radius + 11.0
        let d2v : Float = dist2(player.x, player.y, reefs[i].x, reefs[i].y)
        if d2v >= rr * rr {
          continue
        }

        let d : Float = maxf(0.0001, d2v.sqrt())
        let nx : Float = (player.x - reefs[i].x) / d
        let ny : Float = (player.y - reefs[i].y) / d
        let push : Float = (rr - d) * dt * 18.0

        player.x = player.x + nx * push
        player.y = player.y + ny * push

        if sp2 > 80.0 {
          reef_damage = reef_damage + dt * (1.0 + reefs[i].hardness * 0.02)
        }
      }

      update_storms(storms, dt, world_l, world_t, world_r, world_b)

      let mut storm_damage : Float = 0.0
      for i = 0; i < storms.length(); i = i + 1 {
        if not(storms[i].active) {
          continue
        }

        let d2v : Float = dist2(player.x, player.y, storms[i].x, storms[i].y)
        let rr : Float = storms[i].radius
        if d2v < rr * rr {
          let ratio : Float = 1.0 - d2v.sqrt() / rr
          storm_damage = storm_damage +
            dt * storms[i].intensity * (1.4 + ratio * 2.1)
          player.energy = maxf(
            0.0,
            player.energy - dt * storms[i].intensity * (0.8 + ratio * 1.7),
          )
        }
      }

      let (steals, pirate_hull_dmg) = update_pirates(
        pirates, lights, player, parts, dt, world_l, world_t, world_r, world_b,
      )
      steals_total = steals_total + steals
      if steals > 0 {
        score = score - steals * 10
      }

      let damage : Float = reef_damage + storm_damage + pirate_hull_dmg
      if damage > 0.0 {
        player.hull = maxf(0.0, player.hull - damage)
      }

      let (blackout_gain, urgent_now, demand_sum) = update_light_demands(
        lights, dt, tier,
      )
      blackouts = blackouts + blackout_gain
      if urgent_now > urgency_peak {
        urgency_peak = urgent_now
      }

      if blackout_gain > 0 {
        score = score - blackout_gain * 26
        msg = "Blackout events +\{blackout_gain}"
        msg_t = 1.0
      }

      if demand_sum > 360.0 {
        score = score - (dt * 5.0).to_int()
      }

      storm_cd = storm_cd - dt
      if storm_cd <= 0.0 {
        let max_s : Int = 2 + tier / 2
        if active_storms(storms) < max_s {
          ignore(spawn_storm(storms, world_l, world_t, world_r, world_b, tier))
        }
        storm_cd = randf(5.8, 10.6) - Float::from_int(tier) * 0.25
        if storm_cd < 2.4 {
          storm_cd = 2.4
        }
      }

      pirate_cd = pirate_cd - dt
      if pirate_cd <= 0.0 {
        let max_p : Int = 1 + tier / 2
        if active_pirates(pirates) < max_p {
          if spawn_pirate(
              pirates, world_l, world_t, world_r, world_b, tier, pirate_serial,
            ) {
            pirate_serial = pirate_serial + 1
          }
        }
        pirate_cd = randf(7.0, 12.0) - Float::from_int(tier) * 0.28
        if pirate_cd < 2.8 {
          pirate_cd = 2.8
        }
      }

      if delivered_total >= target_delivered {
        state = 2
        msg = "All lighthouse routes stabilized"
        msg_t = 3.0
        burst(parts, player.x, player.y, 70, 2)
      } else if timer <= 0.0 {
        state = 3
        msg = "Shift ended before quotas"
        msg_t = 3.0
      } else if blackouts >= blackout_limit {
        state = 3
        msg = "Grid blackouts exceeded limit"
        msg_t = 3.0
      } else if player.hull <= 0.0 {
        state = 3
        msg = "Courier ship destroyed"
        msg_t = 3.0
      }
    } else if click ||
      @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeyR) {
      state = 0
    }

    @raylib.begin_drawing()
    defer @raylib.end_drawing()

    @raylib.clear_background(@raylib.Color::new(8, 16, 28, 255))

    draw_ocean(world_x, world_y, world_w, world_h, scene_t)
    draw_harbor(harbor_x, harbor_y, harbor_w, harbor_h)
    draw_reefs(reefs, scene_t)
    draw_storms(storms, scene_t)
    draw_lights(lights, scene_t)
    draw_pirates(pirates, scene_t)
    draw_player(player, scene_t)

    if player.ping_t > 0.0 {
      let rr : Float = 20.0 + (2.2 - player.ping_t) * 58.0
      @raylib.draw_circle(
        player.ping_x.to_int(),
        player.ping_y.to_int(),
        rr,
        @raylib.Color::new(170, 230, 252, 84),
      )
      @raylib.draw_circle(
        player.ping_x.to_int(),
        player.ping_y.to_int(),
        9.0,
        @raylib.Color::new(248, 252, 255, 214),
      )
      @raylib.draw_line(
        player.x.to_int(),
        player.y.to_int(),
        player.ping_x.to_int(),
        player.ping_y.to_int(),
        @raylib.Color::new(188, 228, 252, 164),
      )
    }

    draw_parts(parts)

    let panel_x : Int = world_x + world_w + 16
    @raylib.draw_rectangle(
      panel_x,
      world_y,
      panel_w - 16,
      world_h,
      @raylib.Color::new(14, 24, 38, 246),
    )
    @raylib.draw_rectangle_lines(
      panel_x,
      world_y,
      panel_w - 16,
      world_h,
      @raylib.Color::new(126, 168, 208, 242),
    )

    @raylib.draw_text(
      "LIGHTHOUSE SUPPLY RUN",
      panel_x + 16,
      36,
      34,
      @raylib.Color::new(236, 246, 255, 252),
    )
    @raylib.draw_text(
      "Ocean logistics under pressure",
      panel_x + 16,
      78,
      20,
      @raylib.Color::new(194, 220, 252, 238),
    )

    @raylib.draw_text(
      "Time",
      panel_x + 16,
      118,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{timer.to_int()}s",
      panel_x + 102,
      118,
      30,
      @raylib.Color::new(248, 220, 152, 252),
    )

    @raylib.draw_text(
      "Delivered",
      panel_x + 16,
      154,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{delivered_total}/\{target_delivered}",
      panel_x + 148,
      154,
      30,
      @raylib.Color::new(138, 228, 164, 252),
    )

    @raylib.draw_text(
      "Blackouts",
      panel_x + 16,
      190,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{blackouts}/\{blackout_limit}",
      panel_x + 132,
      190,
      30,
      @raylib.Color::new(246, 150, 164, 252),
    )

    @raylib.draw_text(
      "Tier",
      panel_x + 248,
      190,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{tier}",
      panel_x + 304,
      190,
      30,
      @raylib.Color::new(248, 212, 130, 252),
    )

    @raylib.draw_text(
      "Cargo",
      panel_x + 16,
      226,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{player.cargo}/\{player.cargo_cap}",
      panel_x + 94,
      226,
      30,
      @raylib.Color::new(206, 232, 252, 252),
    )

    @raylib.draw_text(
      "Harbor stock",
      panel_x + 16,
      262,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{harbor_stock.to_int()}",
      panel_x + 152,
      262,
      30,
      @raylib.Color::new(206, 232, 252, 252),
    )

    @raylib.draw_text(
      "Score",
      panel_x + 16,
      298,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{score}",
      panel_x + 92,
      298,
      30,
      @raylib.Color::new(158, 220, 252, 252),
    )

    @raylib.draw_text(
      "Pirate theft",
      panel_x + 16,
      334,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{steals_total}",
      panel_x + 148,
      334,
      30,
      @raylib.Color::new(246, 196, 150, 248),
    )

    @raylib.draw_text(
      "Urgency peak",
      panel_x + 16,
      370,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{urgency_peak}",
      panel_x + 148,
      370,
      30,
      @raylib.Color::new(246, 196, 150, 248),
    )

    @raylib.draw_text(
      "Demand peak",
      panel_x + 236,
      370,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{peak_demand(lights).to_int()}",
      panel_x + 352 - 50,
      370,
      30,
      @raylib.Color::new(246, 196, 150, 248),
    )

    draw_bar(
      panel_x,
      414,
      "Hull",
      player.hull,
      player.hull_max,
      @raylib.Color::new(130, 228, 164, 252),
    )
    draw_bar(
      panel_x,
      488,
      "Energy",
      player.energy,
      player.energy_max,
      @raylib.Color::new(126, 206, 252, 252),
    )
    draw_bar(
      panel_x,
      562,
      "Network Demand",
      total_demand(lights),
      560.0,
      @raylib.Color::new(246, 186, 126, 252),
    )

    @raylib.draw_text(
      "Controls",
      panel_x + 16,
      644,
      30,
      @raylib.Color::new(236, 246, 255, 252),
    )
    @raylib.draw_text(
      "WASD / Arrows : steer",
      panel_x + 16,
      682,
      22,
      @raylib.Color::new(198, 220, 252, 236),
    )
    @raylib.draw_text(
      "J / Space : hold boost",
      panel_x + 16,
      708,
      22,
      @raylib.Color::new(198, 220, 252, 236),
    )
    @raylib.draw_text(
      "L / U : load or deliver",
      panel_x + 16,
      734,
      22,
      @raylib.Color::new(198, 220, 252, 236),
    )
    @raylib.draw_text(
      "K / H : ping urgent light",
      panel_x + 16,
      760,
      22,
      @raylib.Color::new(198, 220, 252, 236),
    )
    @raylib.draw_text(
      "Mobile: d-pad + BOOST/DROP/PING",
      panel_x + 16,
      786,
      22,
      @raylib.Color::new(198, 220, 252, 236),
    )

    draw_touch_controls(sw, sh, mouse.x, mouse.y, hold)

    if msg_t > 0.0 {
      let bw : Int = @raylib.measure_text(msg, 30) + 44
      let bx : Int = world_x + world_w / 2 - bw / 2
      @raylib.draw_rectangle(
        bx,
        18,
        bw,
        52,
        @raylib.Color::new(10, 18, 30, 230),
      )
      @raylib.draw_rectangle_lines(
        bx,
        18,
        bw,
        52,
        @raylib.Color::new(188, 214, 248, 246),
      )
      @raylib.draw_text(
        msg,
        bx + 22,
        30,
        30,
        @raylib.Color::new(236, 246, 255, 252),
      )
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 14, 24, 212))
      @raylib.draw_text(
        "LIGHTHOUSE SUPPLY RUN",
        sw / 2 - 430,
        150,
        82,
        @raylib.Color::new(236, 246, 255, 255),
      )
      @raylib.draw_text(
        "Maritime dispatch simulation",
        sw / 2 - 220,
        240,
        38,
        @raylib.Color::new(194, 220, 252, 248),
      )

      @raylib.draw_rectangle(
        sw / 2 - 520,
        304,
        1040,
        288,
        @raylib.Color::new(16, 26, 42, 238),
      )
      @raylib.draw_rectangle_lines(
        sw / 2 - 520,
        304,
        1040,
        288,
        @raylib.Color::new(166, 196, 244, 244),
      )

      @raylib.draw_text(
        "Mission",
        sw / 2 - 486,
        338,
        34,
        @raylib.Color::new(236, 246, 255, 252),
      )
      @raylib.draw_text(
        "- Load at harbor, then deliver to high-demand lighthouses",
        sw / 2 - 486,
        382,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Storms and pirates increase as throughput rises",
        sw / 2 - 486,
        418,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Prevent blackout events while meeting delivery quota",
        sw / 2 - 486,
        454,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Fully touch playable on mobile",
        sw / 2 - 486,
        490,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )

      @raylib.draw_text(
        "Failure",
        sw / 2 + 64,
        338,
        34,
        @raylib.Color::new(236, 246, 255, 252),
      )
      @raylib.draw_text(
        "- Timer expires",
        sw / 2 + 64,
        382,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Blackout count exceeds limit",
        sw / 2 + 64,
        418,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Courier ship hull reaches zero",
        sw / 2 + 64,
        454,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )

      let hover : Bool = inside_rect(
        mouse.x,
        mouse.y,
        sw / 2 - 210,
        638,
        420,
        94,
      )
      draw_button(sw / 2 - 210, 638, 420, 94, "START VOYAGE", hover)
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 24, 14, 206))
      @raylib.draw_text(
        "ROUTES STABILIZED",
        sw / 2 - 316,
        194,
        84,
        @raylib.Color::new(170, 248, 188, 252),
      )
      @raylib.draw_text(
        "Delivered \{delivered_total}/\{target_delivered}",
        sw / 2 - 192,
        334,
        42,
        @raylib.Color::new(236, 248, 240, 252),
      )
      @raylib.draw_text(
        "Score \{score}",
        sw / 2 - 102,
        388,
        38,
        @raylib.Color::new(248, 232, 166, 248),
      )
      @raylib.draw_text(
        "Tap or Enter",
        sw / 2 - 94,
        466,
        34,
        @raylib.Color::new(214, 234, 252, 244),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(26, 8, 14, 214))
      @raylib.draw_text(
        "DISPATCH FAILED",
        sw / 2 - 272,
        194,
        84,
        @raylib.Color::new(248, 156, 168, 252),
      )
      @raylib.draw_text(
        "Delivered \{delivered_total}/\{target_delivered}",
        sw / 2 - 192,
        334,
        42,
        @raylib.Color::new(246, 230, 236, 252),
      )
      @raylib.draw_text(
        "Blackouts \{blackouts}/\{blackout_limit}",
        sw / 2 - 142,
        388,
        38,
        @raylib.Color::new(252, 190, 198, 246),
      )
      @raylib.draw_text(
        "Tap or Enter",
        sw / 2 - 94,
        466,
        34,
        @raylib.Color::new(220, 234, 252, 244),
      )
    }
  }
}
