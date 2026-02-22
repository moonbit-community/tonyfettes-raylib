///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut heading : Float
  mut hull : Float
  hull_max : Float
  mut battery : Float
  battery_max : Float
  mut onboard : Int
  capacity : Int
  mut medkits : Int
  medkit_max : Int
  mut action_cd : Float
  mut ping_cd : Float
  mut ping_t : Float
  mut ping_x : Float
  mut ping_y : Float
  mut engine_t : Float
}

///|
struct Hospital {
  x : Float
  y : Float
  w : Int
  h : Int
}

///|
struct District {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut queue : Float
  mut stress : Float
  mut alarm_t : Float
  id : Int
}

///|
struct SurvivorGroup {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut count : Int
  mut panic : Float
  mut drift_x : Float
  mut drift_y : Float
  mut flare_t : Float
  mut id : Int
}

///|
struct CrackZone {
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
struct DustCloud {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut radius : Float
  mut density : Float
  mut life : Float
  mut phase : Float
}

///|
struct Obstacle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut size : Float
  mut hard : Float
  mut spin : Float
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
fn mini(a : Int, b : Int) -> Int {
  if a < b {
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
fn clear_districts(districts : Array[District]) -> Unit {
  for i = 0; i < districts.length(); i = i + 1 {
    districts[i].active = false
    districts[i].x = 0.0
    districts[i].y = 0.0
    districts[i].queue = 0.0
    districts[i].stress = 0.0
    districts[i].alarm_t = 0.0
  }
}

///|
fn clear_groups(groups : Array[SurvivorGroup]) -> Unit {
  for i = 0; i < groups.length(); i = i + 1 {
    groups[i].active = false
    groups[i].x = 0.0
    groups[i].y = 0.0
    groups[i].count = 0
    groups[i].panic = 0.0
    groups[i].drift_x = 0.0
    groups[i].drift_y = 0.0
    groups[i].flare_t = 0.0
    groups[i].id = i + 1
  }
}

///|
fn clear_cracks(cracks : Array[CrackZone]) -> Unit {
  for i = 0; i < cracks.length(); i = i + 1 {
    cracks[i].active = false
    cracks[i].x = 0.0
    cracks[i].y = 0.0
    cracks[i].vx = 0.0
    cracks[i].vy = 0.0
    cracks[i].radius = 0.0
    cracks[i].intensity = 0.0
    cracks[i].life = 0.0
    cracks[i].phase = 0.0
  }
}

///|
fn clear_dusts(dusts : Array[DustCloud]) -> Unit {
  for i = 0; i < dusts.length(); i = i + 1 {
    dusts[i].active = false
    dusts[i].x = 0.0
    dusts[i].y = 0.0
    dusts[i].vx = 0.0
    dusts[i].vy = 0.0
    dusts[i].radius = 0.0
    dusts[i].density = 0.0
    dusts[i].life = 0.0
    dusts[i].phase = 0.0
  }
}

///|
fn clear_obstacles(obstacles : Array[Obstacle]) -> Unit {
  for i = 0; i < obstacles.length(); i = i + 1 {
    obstacles[i].active = false
    obstacles[i].x = 0.0
    obstacles[i].y = 0.0
    obstacles[i].vx = 0.0
    obstacles[i].vy = 0.0
    obstacles[i].size = 0.0
    obstacles[i].hard = 0.0
    obstacles[i].spin = 0.0
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
      randf(8.0, 42.0)
    } else if kind == 1 {
      randf(28.0, 132.0)
    } else if kind == 2 {
      randf(18.0, 120.0)
    } else {
      randf(14.0, 90.0)
    }

    parts[i].vx = @math.cosf(a) * s
    parts[i].vy = @math.sinf(a) * s
    parts[i].life = if kind == 0 {
      randf(0.45, 1.0)
    } else if kind == 1 {
      randf(0.18, 0.52)
    } else if kind == 2 {
      randf(0.2, 0.62)
    } else {
      randf(0.24, 0.8)
    }
    parts[i].size = if kind == 1 { randf(2.4, 8.0) } else { randf(1.8, 5.4) }
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
      parts[i].vy = parts[i].vy + dt * 10.0
    } else if parts[i].kind == 1 {
      parts[i].vx = parts[i].vx * (1.0 - dt * 4.0)
      parts[i].vy = parts[i].vy + dt * 172.0
    } else if parts[i].kind == 2 {
      parts[i].vx = parts[i].vx * (1.0 - dt * 2.6)
      parts[i].vy = parts[i].vy - dt * 18.0
    } else {
      parts[i].vx = parts[i].vx * (1.0 - dt * 2.0)
      parts[i].vy = parts[i].vy + dt * 42.0
    }
  }
}

///|
fn init_districts(
  districts : Array[District],
  world_x : Int,
  world_y : Int,
  world_w : Int,
  world_h : Int,
) -> Unit {
  clear_districts(districts)

  let left : Float = Float::from_int(world_x + 220)
  let right : Float = Float::from_int(world_x + world_w - 170)
  let top : Float = Float::from_int(world_y + 120)
  let bottom : Float = Float::from_int(world_y + world_h - 120)
  let mid_x : Float = Float::from_int(world_x + world_w / 2)
  let mid_y : Float = Float::from_int(world_y + world_h / 2)

  if districts.length() > 0 {
    districts[0].active = true
    districts[0].x = left + 50.0
    districts[0].y = top + 20.0
    districts[0].queue = 18.0
    districts[0].stress = 18.0
    districts[0].alarm_t = 0.0
  }
  if districts.length() > 1 {
    districts[1].active = true
    districts[1].x = left + 300.0
    districts[1].y = mid_y - 152.0
    districts[1].queue = 22.0
    districts[1].stress = 24.0
    districts[1].alarm_t = 0.0
  }
  if districts.length() > 2 {
    districts[2].active = true
    districts[2].x = mid_x - 40.0
    districts[2].y = bottom - 86.0
    districts[2].queue = 28.0
    districts[2].stress = 30.0
    districts[2].alarm_t = 0.0
  }
  if districts.length() > 3 {
    districts[3].active = true
    districts[3].x = right - 110.0
    districts[3].y = top + 82.0
    districts[3].queue = 24.0
    districts[3].stress = 26.0
    districts[3].alarm_t = 0.0
  }
  if districts.length() > 4 {
    districts[4].active = true
    districts[4].x = right - 42.0
    districts[4].y = mid_y + 164.0
    districts[4].queue = 18.0
    districts[4].stress = 22.0
    districts[4].alarm_t = 0.0
  }
  if districts.length() > 5 {
    districts[5].active = true
    districts[5].x = mid_x + 258.0
    districts[5].y = mid_y - 34.0
    districts[5].queue = 20.0
    districts[5].stress = 24.0
    districts[5].alarm_t = 0.0
  }
  if districts.length() > 6 {
    districts[6].active = true
    districts[6].x = left + 90.0
    districts[6].y = bottom - 144.0
    districts[6].queue = 25.0
    districts[6].stress = 28.0
    districts[6].alarm_t = 0.0
  }
}

///|
fn init_obstacles(
  obstacles : Array[Obstacle],
  districts : Array[District],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  safe_x : Float,
  safe_y : Float,
) -> Unit {
  clear_obstacles(obstacles)

  let mut filled : Int = 0
  let target : Int = obstacles.length() - 12

  while filled < target {
    let x : Float = randf(world_l + 24.0, world_r - 24.0)
    let y : Float = randf(world_t + 24.0, world_b - 24.0)

    if dist2(x, y, safe_x, safe_y) < 185.0 * 185.0 {
      continue
    }

    let mut near_dist : Bool = false
    for i = 0; i < districts.length(); i = i + 1 {
      if not(districts[i].active) {
        continue
      }
      if dist2(x, y, districts[i].x, districts[i].y) < 120.0 * 120.0 {
        near_dist = true
        break
      }
    }
    if near_dist {
      continue
    }

    let mut overlap : Bool = false
    for i = 0; i < obstacles.length(); i = i + 1 {
      if not(obstacles[i].active) {
        continue
      }
      let rr : Float = obstacles[i].size + 12.0
      if dist2(x, y, obstacles[i].x, obstacles[i].y) < rr * rr {
        overlap = true
        break
      }
    }
    if overlap {
      continue
    }

    obstacles[filled].active = true
    obstacles[filled].x = x
    obstacles[filled].y = y
    obstacles[filled].vx = randf(-22.0, 22.0)
    obstacles[filled].vy = randf(-22.0, 22.0)
    obstacles[filled].size = randf(8.0, 21.0)
    obstacles[filled].hard = randf(20.0, 96.0)
    obstacles[filled].spin = randf(0.0, 20.0)

    filled = filled + 1
  }
}

///|
fn spawn_group(
  groups : Array[SurvivorGroup],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  tier : Int,
  serial : Int,
) -> Bool {
  for i = 0; i < groups.length(); i = i + 1 {
    if groups[i].active {
      continue
    }

    let side : Int = @raylib.get_random_value(0, 3)
    if side == 0 {
      groups[i].x = world_l + randf(26.0, 60.0)
      groups[i].y = randf(world_t + 30.0, world_b - 30.0)
      groups[i].drift_x = randf(6.0, 18.0)
      groups[i].drift_y = randf(-7.0, 7.0)
    } else if side == 1 {
      groups[i].x = world_r - randf(26.0, 60.0)
      groups[i].y = randf(world_t + 30.0, world_b - 30.0)
      groups[i].drift_x = randf(-18.0, -6.0)
      groups[i].drift_y = randf(-7.0, 7.0)
    } else if side == 2 {
      groups[i].x = randf(world_l + 30.0, world_r - 30.0)
      groups[i].y = world_t + randf(26.0, 60.0)
      groups[i].drift_x = randf(-8.0, 8.0)
      groups[i].drift_y = randf(6.0, 18.0)
    } else {
      groups[i].x = randf(world_l + 30.0, world_r - 30.0)
      groups[i].y = world_b - randf(26.0, 60.0)
      groups[i].drift_x = randf(-8.0, 8.0)
      groups[i].drift_y = randf(-18.0, -6.0)
    }

    groups[i].active = true
    groups[i].count = 4 + @raylib.get_random_value(0, 8 + tier * 2)
    groups[i].panic = randf(4.0, 24.0)
    groups[i].flare_t = randf(0.5, 1.3)
    groups[i].id = serial
    return true
  }

  false
}

///|
fn spawn_crack(
  cracks : Array[CrackZone],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  tier : Int,
) -> Bool {
  for i = 0; i < cracks.length(); i = i + 1 {
    if cracks[i].active {
      continue
    }

    let side : Int = @raylib.get_random_value(0, 3)
    if side == 0 {
      cracks[i].x = world_l - 84.0
      cracks[i].y = randf(world_t + 20.0, world_b - 20.0)
      cracks[i].vx = randf(12.0, 34.0)
      cracks[i].vy = randf(-9.0, 9.0)
    } else if side == 1 {
      cracks[i].x = world_r + 84.0
      cracks[i].y = randf(world_t + 20.0, world_b - 20.0)
      cracks[i].vx = randf(-34.0, -12.0)
      cracks[i].vy = randf(-9.0, 9.0)
    } else if side == 2 {
      cracks[i].x = randf(world_l + 20.0, world_r - 20.0)
      cracks[i].y = world_t - 84.0
      cracks[i].vx = randf(-12.0, 12.0)
      cracks[i].vy = randf(14.0, 30.0)
    } else {
      cracks[i].x = randf(world_l + 20.0, world_r - 20.0)
      cracks[i].y = world_b + 84.0
      cracks[i].vx = randf(-12.0, 12.0)
      cracks[i].vy = randf(-30.0, -14.0)
    }

    cracks[i].active = true
    cracks[i].radius = randf(70.0, 146.0)
    cracks[i].intensity = randf(0.46, 1.14) + Float::from_int(tier) * 0.04
    cracks[i].life = randf(20.0, 42.0)
    cracks[i].phase = randf(0.0, 20.0)
    return true
  }

  false
}

///|
fn spawn_dust(
  dusts : Array[DustCloud],
  x : Float,
  y : Float,
  intensity : Float,
) -> Bool {
  for i = 0; i < dusts.length(); i = i + 1 {
    if dusts[i].active {
      continue
    }

    dusts[i].active = true
    dusts[i].x = x + randf(-22.0, 22.0)
    dusts[i].y = y + randf(-22.0, 22.0)
    dusts[i].vx = randf(-16.0, 16.0)
    dusts[i].vy = randf(-32.0, -8.0)
    dusts[i].radius = randf(28.0, 74.0)
    dusts[i].density = randf(0.4, 1.0) + intensity * 0.2
    dusts[i].life = randf(4.0, 10.0)
    dusts[i].phase = randf(0.0, 20.0)
    return true
  }

  false
}

///|
fn active_groups(groups : Array[SurvivorGroup]) -> Int {
  let mut n : Int = 0
  for i = 0; i < groups.length(); i = i + 1 {
    if groups[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn active_cracks(cracks : Array[CrackZone]) -> Int {
  let mut n : Int = 0
  for i = 0; i < cracks.length(); i = i + 1 {
    if cracks[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn active_critical(groups : Array[SurvivorGroup]) -> Int {
  let mut n : Int = 0
  for i = 0; i < groups.length(); i = i + 1 {
    if groups[i].active && groups[i].panic >= 70.0 {
      n = n + 1
    }
  }
  n
}

///|
fn peak_group_panic(groups : Array[SurvivorGroup]) -> Float {
  let mut best : Float = 0.0
  for i = 0; i < groups.length(); i = i + 1 {
    if groups[i].active && groups[i].panic > best {
      best = groups[i].panic
    }
  }
  best
}

///|
fn peak_crack_intensity(cracks : Array[CrackZone]) -> Float {
  let mut best : Float = 0.0
  for i = 0; i < cracks.length(); i = i + 1 {
    if cracks[i].active && cracks[i].intensity > best {
      best = cracks[i].intensity
    }
  }
  best
}

///|
fn update_cracks(
  cracks : Array[CrackZone],
  dusts : Array[DustCloud],
  dt : Float,
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
) -> Unit {
  for i = 0; i < cracks.length(); i = i + 1 {
    if not(cracks[i].active) {
      continue
    }

    cracks[i].life = cracks[i].life - dt
    if cracks[i].life <= 0.0 {
      cracks[i].active = false
      continue
    }

    cracks[i].phase = cracks[i].phase + dt * (0.8 + cracks[i].intensity * 0.35)
    let pulse : Float = 0.88 + 0.16 * (@math.sinf(cracks[i].phase) * 0.5 + 0.5)

    cracks[i].x = cracks[i].x + cracks[i].vx * dt * pulse
    cracks[i].y = cracks[i].y + cracks[i].vy * dt * pulse

    if cracks[i].x < world_l - 160.0 {
      cracks[i].x = world_l - 160.0
      cracks[i].vx = absf(cracks[i].vx)
    } else if cracks[i].x > world_r + 160.0 {
      cracks[i].x = world_r + 160.0
      cracks[i].vx = -absf(cracks[i].vx)
    }

    if cracks[i].y < world_t - 160.0 {
      cracks[i].y = world_t - 160.0
      cracks[i].vy = absf(cracks[i].vy)
    } else if cracks[i].y > world_b + 160.0 {
      cracks[i].y = world_b + 160.0
      cracks[i].vy = -absf(cracks[i].vy)
    }

    cracks[i].intensity = clampf(cracks[i].intensity + dt * 0.06, 0.2, 2.2)

    if @raylib.get_random_value(0, 100) < 14 {
      ignore(spawn_dust(dusts, cracks[i].x, cracks[i].y, cracks[i].intensity))
    }
  }
}

///|
fn update_dusts(
  dusts : Array[DustCloud],
  dt : Float,
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
) -> Unit {
  for i = 0; i < dusts.length(); i = i + 1 {
    if not(dusts[i].active) {
      continue
    }

    dusts[i].life = dusts[i].life - dt
    if dusts[i].life <= 0.0 {
      dusts[i].active = false
      continue
    }

    dusts[i].phase = dusts[i].phase + dt * (0.7 + dusts[i].density * 0.3)
    let pulse : Float = 0.82 + 0.22 * (@math.sinf(dusts[i].phase) * 0.5 + 0.5)

    dusts[i].x = dusts[i].x + dusts[i].vx * dt * pulse
    dusts[i].y = dusts[i].y + dusts[i].vy * dt * pulse

    dusts[i].x = clampf(dusts[i].x, world_l - 120.0, world_r + 120.0)
    dusts[i].y = clampf(dusts[i].y, world_t - 140.0, world_b + 60.0)
  }
}

///|
fn update_obstacles(
  obstacles : Array[Obstacle],
  dt : Float,
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
) -> Unit {
  for i = 0; i < obstacles.length(); i = i + 1 {
    if not(obstacles[i].active) {
      continue
    }

    obstacles[i].spin = obstacles[i].spin + dt * 0.7

    let drift : Float = 0.84 +
      0.22 * (@math.sinf(obstacles[i].spin) * 0.5 + 0.5)
    obstacles[i].x = obstacles[i].x + obstacles[i].vx * dt * drift
    obstacles[i].y = obstacles[i].y + obstacles[i].vy * dt * drift

    if obstacles[i].x < world_l + obstacles[i].size {
      obstacles[i].x = world_l + obstacles[i].size
      obstacles[i].vx = absf(obstacles[i].vx) * randf(0.66, 1.1)
    } else if obstacles[i].x > world_r - obstacles[i].size {
      obstacles[i].x = world_r - obstacles[i].size
      obstacles[i].vx = -absf(obstacles[i].vx) * randf(0.66, 1.1)
    }

    if obstacles[i].y < world_t + obstacles[i].size {
      obstacles[i].y = world_t + obstacles[i].size
      obstacles[i].vy = absf(obstacles[i].vy) * randf(0.66, 1.1)
    } else if obstacles[i].y > world_b - obstacles[i].size {
      obstacles[i].y = world_b - obstacles[i].size
      obstacles[i].vy = -absf(obstacles[i].vy) * randf(0.66, 1.1)
    }

    obstacles[i].hard = maxf(8.0, obstacles[i].hard - dt * 0.02)
  }
}

///|
fn update_groups(
  groups : Array[SurvivorGroup],
  cracks : Array[CrackZone],
  dusts : Array[DustCloud],
  dt : Float,
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  safe_x : Float,
  safe_y : Float,
) -> (Int, Float) {
  let mut lost : Int = 0
  let mut panic_sum : Float = 0.0

  for i = 0; i < groups.length(); i = i + 1 {
    if not(groups[i].active) {
      continue
    }

    groups[i].x = groups[i].x + groups[i].drift_x * dt
    groups[i].y = groups[i].y + groups[i].drift_y * dt

    if groups[i].x < world_l + 18.0 || groups[i].x > world_r - 18.0 {
      groups[i].drift_x = -groups[i].drift_x
      groups[i].x = clampf(groups[i].x, world_l + 18.0, world_r - 18.0)
    }
    if groups[i].y < world_t + 18.0 || groups[i].y > world_b - 18.0 {
      groups[i].drift_y = -groups[i].drift_y
      groups[i].y = clampf(groups[i].y, world_t + 18.0, world_b - 18.0)
    }

    groups[i].flare_t = groups[i].flare_t - dt
    if groups[i].flare_t <= 0.0 {
      groups[i].flare_t = randf(0.6, 1.4)
    }

    let mut panic_gain : Float = dt * 2.1

    let safe_d2 : Float = dist2(groups[i].x, groups[i].y, safe_x, safe_y)
    if safe_d2 > 390.0 * 390.0 {
      panic_gain = panic_gain + dt * 0.8
    }

    for j = 0; j < cracks.length(); j = j + 1 {
      if not(cracks[j].active) {
        continue
      }

      let rr : Float = cracks[j].radius
      let d2v : Float = dist2(
        groups[i].x,
        groups[i].y,
        cracks[j].x,
        cracks[j].y,
      )
      if d2v < rr * rr {
        let ratio : Float = 1.0 - d2v.sqrt() / rr
        panic_gain = panic_gain + dt * cracks[j].intensity * (0.9 + ratio * 1.8)
      }
    }

    for j = 0; j < dusts.length(); j = j + 1 {
      if not(dusts[j].active) {
        continue
      }

      let rr : Float = dusts[j].radius
      let d2v : Float = dist2(groups[i].x, groups[i].y, dusts[j].x, dusts[j].y)
      if d2v < rr * rr {
        let ratio : Float = 1.0 - d2v.sqrt() / rr
        panic_gain = panic_gain + dt * dusts[j].density * (0.4 + ratio * 1.1)
      }
    }

    groups[i].panic = groups[i].panic + panic_gain
    if groups[i].panic > 100.0 {
      lost = lost + groups[i].count
      groups[i].active = false
      continue
    }

    panic_sum = panic_sum + groups[i].panic
  }

  (lost, panic_sum)
}

///|
fn rescue_groups(
  player : Player,
  groups : Array[SurvivorGroup],
  parts : Array[Particle],
) -> (Int, Int) {
  if player.action_cd > 0.0 || player.onboard >= player.capacity {
    (0, 0)
  } else {
    let mut rescued_people : Int = 0
    let mut groups_hit : Int = 0

    for i = 0; i < groups.length(); i = i + 1 {
      if not(groups[i].active) || groups[i].count <= 0 {
        continue
      }

      let d2v : Float = dist2(player.x, player.y, groups[i].x, groups[i].y)
      if d2v > 84.0 * 84.0 {
        continue
      }

      let cap_left : Int = player.capacity - player.onboard
      if cap_left <= 0 {
        break
      }

      let take : Int = mini(groups[i].count, mini(cap_left, 8))
      if take <= 0 {
        continue
      }

      player.onboard = player.onboard + take
      groups[i].count = groups[i].count - take
      groups[i].panic = maxf(0.0, groups[i].panic - Float::from_int(take) * 2.8)
      rescued_people = rescued_people + take
      groups_hit = groups_hit + 1

      burst(parts, groups[i].x, groups[i].y, 9 + take / 2, 2)

      if groups[i].count <= 0 {
        groups[i].active = false
      }
    }

    if rescued_people > 0 {
      player.action_cd = 0.32
    }

    (rescued_people, groups_hit)
  }
}

///|
fn stabilize_cracks(
  player : Player,
  cracks : Array[CrackZone],
  parts : Array[Particle],
) -> (Int, Float) {
  if player.action_cd > 0.0 || player.medkits <= 0 {
    (0, 0.0)
  } else {
    let mut hits : Int = 0
    let mut reduction : Float = 0.0

    for i = 0; i < cracks.length(); i = i + 1 {
      if not(cracks[i].active) {
        continue
      }

      let rr : Float = cracks[i].radius + 70.0
      let d2v : Float = dist2(player.x, player.y, cracks[i].x, cracks[i].y)
      if d2v > rr * rr {
        continue
      }

      let cut : Float = 0.24 + Float::from_int(player.medkits) * 0.02
      cracks[i].intensity = maxf(0.12, cracks[i].intensity - cut)
      cracks[i].radius = maxf(28.0, cracks[i].radius - 8.0)
      player.medkits = player.medkits - 1
      hits = hits + 1
      reduction = reduction + cut

      burst(parts, cracks[i].x, cracks[i].y, 12, 3)

      if cracks[i].intensity <= 0.14 {
        cracks[i].active = false
        burst(parts, cracks[i].x, cracks[i].y, 16, 2)
      }

      if player.medkits <= 0 {
        break
      }
    }

    if hits > 0 {
      player.action_cd = 0.34
    }

    (hits, reduction)
  }
}

///|
fn nearest_urgent_group(
  groups : Array[SurvivorGroup],
  x : Float,
  y : Float,
) -> (Bool, Float, Float, Float) {
  let mut found : Bool = false
  let mut bx : Float = x
  let mut by : Float = y
  let mut bp : Float = 0.0
  let mut bd2 : Float = 999999999.0

  for i = 0; i < groups.length(); i = i + 1 {
    if not(groups[i].active) || groups[i].panic < 30.0 {
      continue
    }

    let d2v : Float = dist2(x, y, groups[i].x, groups[i].y)
    if d2v < bd2 {
      bd2 = d2v
      bx = groups[i].x
      by = groups[i].y
      bp = groups[i].panic
      found = true
    }
  }

  (found, bx, by, bp)
}

///|
fn nearest_hot_crack(
  cracks : Array[CrackZone],
  x : Float,
  y : Float,
) -> (Bool, Float, Float, Float) {
  let mut found : Bool = false
  let mut bx : Float = x
  let mut by : Float = y
  let mut bi : Float = 0.0
  let mut bd2 : Float = 999999999.0

  for i = 0; i < cracks.length(); i = i + 1 {
    if not(cracks[i].active) || cracks[i].intensity < 0.8 {
      continue
    }

    let d2v : Float = dist2(x, y, cracks[i].x, cracks[i].y)
    if d2v < bd2 {
      bd2 = d2v
      bx = cracks[i].x
      by = cracks[i].y
      bi = cracks[i].intensity
      found = true
    }
  }

  (found, bx, by, bi)
}

///|
fn draw_city(
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
    @raylib.Color::new(18, 30, 28, 255),
  )

  let mut y : Int = world_y
  while y < world_y + world_h {
    let p : Float = Float::from_int(y - world_y) / Float::from_int(world_h)
    let wave : Float = @math.sinf(t * 0.8 + Float::from_int(y) * 0.02) * 0.5 +
      0.5

    let r : Int = 26 + (p * 20.0).to_int() + (wave * 6.0).to_int()
    let g : Int = 44 + (p * 26.0).to_int() + (wave * 8.0).to_int()
    let b : Int = 32 + (p * 18.0).to_int() + (wave * 5.0).to_int()

    @raylib.draw_rectangle(
      world_x,
      y,
      world_w,
      4,
      @raylib.Color::new(r, g, b, 255),
    )
    y = y + 4
  }

  // road grid
  let mut gx : Int = world_x + 40
  while gx < world_x + world_w {
    @raylib.draw_line(
      gx,
      world_y + 4,
      gx,
      world_y + world_h - 4,
      @raylib.Color::new(74, 86, 74, 96),
    )
    gx = gx + 78
  }
  let mut gy : Int = world_y + 36
  while gy < world_y + world_h {
    @raylib.draw_line(
      world_x + 4,
      gy,
      world_x + world_w - 4,
      gy,
      @raylib.Color::new(74, 86, 74, 96),
    )
    gy = gy + 66
  }

  @raylib.draw_rectangle_lines(
    world_x,
    world_y,
    world_w,
    world_h,
    @raylib.Color::new(140, 184, 132, 188),
  )
}

///|
fn draw_hospital(hospital : Hospital) -> Unit {
  @raylib.draw_rectangle(
    hospital.x.to_int(),
    hospital.y.to_int(),
    hospital.w,
    hospital.h,
    @raylib.Color::new(42, 78, 114, 236),
  )
  @raylib.draw_rectangle_lines(
    hospital.x.to_int(),
    hospital.y.to_int(),
    hospital.w,
    hospital.h,
    @raylib.Color::new(176, 214, 244, 246),
  )

  let mut x : Int = hospital.x.to_int() + 10
  while x < hospital.x.to_int() + hospital.w - 8 {
    @raylib.draw_line(
      x,
      hospital.y.to_int() + 8,
      x,
      hospital.y.to_int() + hospital.h - 8,
      @raylib.Color::new(88, 132, 170, 198),
    )
    x = x + 16
  }

  @raylib.draw_text(
    "MED HUB",
    hospital.x.to_int() + 18,
    hospital.y.to_int() + hospital.h + 8,
    24,
    @raylib.Color::new(226, 242, 255, 246),
  )
}

///|
fn draw_districts(districts : Array[District], t : Float) -> Unit {
  for i = 0; i < districts.length(); i = i + 1 {
    if not(districts[i].active) {
      continue
    }

    let q01 : Float = clampf(districts[i].queue / 100.0, 0.0, 1.0)
    let pulse : Float = @math.sinf(t * 3.2 + Float::from_int(i) * 0.9) * 0.5 +
      0.5

    let col : @raylib.Color = if districts[i].queue >= 70.0 {
      @raylib.Color::new(244, 154, 162, 252)
    } else {
      @raylib.Color::new(234, 240, 248, 252)
    }

    @raylib.draw_rectangle(
      (districts[i].x - 14.0).to_int(),
      (districts[i].y - 20.0).to_int(),
      28,
      28,
      col,
    )
    @raylib.draw_rectangle(
      (districts[i].x - 24.0).to_int(),
      (districts[i].y + 8.0).to_int(),
      48,
      8,
      @raylib.Color::new(96, 140, 178, 234),
    )

    let beam_r : Float = 26.0 + q01 * 54.0 + pulse * 6.0
    @raylib.draw_circle(
      districts[i].x.to_int(),
      (districts[i].y - 24.0).to_int(),
      beam_r,
      @raylib.Color::new(246, 236, 168, 46 + (q01 * 80.0).to_int()),
    )

    @raylib.draw_text(
      "D\{districts[i].id} Q:\{districts[i].queue.to_int()} S:\{districts[i].stress.to_int()}",
      (districts[i].x - 56.0).to_int(),
      (districts[i].y + 24.0).to_int(),
      15,
      @raylib.Color::new(220, 238, 252, 236),
    )

    if districts[i].alarm_t > 0.0 {
      @raylib.draw_circle(
        districts[i].x.to_int(),
        districts[i].y.to_int(),
        22.0,
        @raylib.Color::new(252, 170, 162, 72),
      )
    }
  }
}

///|
fn draw_groups(groups : Array[SurvivorGroup], t : Float) -> Unit {
  for i = 0; i < groups.length(); i = i + 1 {
    if not(groups[i].active) {
      continue
    }

    let p01 : Float = clampf(groups[i].panic / 100.0, 0.0, 1.0)
    let flare : Float = @math.sinf(
        t * 6.0 + Float::from_int(groups[i].id) * 0.3,
      ) *
      0.5 +
      0.5

    let col : @raylib.Color = if groups[i].panic >= 72.0 {
      @raylib.Color::new(248, 154, 132, 252)
    } else {
      @raylib.Color::new(246, 226, 194, 248)
    }

    @raylib.draw_circle(
      groups[i].x.to_int(),
      groups[i].y.to_int(),
      11.0 + flare * 3.0,
      col,
    )
    @raylib.draw_circle(
      groups[i].x.to_int(),
      groups[i].y.to_int(),
      4.0,
      @raylib.Color::new(252, 246, 236, 246),
    )

    @raylib.draw_text(
      "G\{groups[i].id} N:\{groups[i].count} P:\{groups[i].panic.to_int()}",
      (groups[i].x - 54.0).to_int(),
      (groups[i].y + 14.0).to_int(),
      16,
      @raylib.Color::new(246, 234, 220, 236),
    )

    if groups[i].flare_t < 0.18 {
      let rr : Float = 18.0 + p01 * 42.0
      @raylib.draw_circle(
        groups[i].x.to_int(),
        groups[i].y.to_int(),
        rr,
        @raylib.Color::new(252, 204, 136, 66),
      )
    }
  }
}

///|
fn draw_cracks(cracks : Array[CrackZone], t : Float) -> Unit {
  for i = 0; i < cracks.length(); i = i + 1 {
    if not(cracks[i].active) {
      continue
    }

    let pulse : Float = 0.84 +
      0.2 * (@math.sinf(t * 1.8 + cracks[i].phase) * 0.5 + 0.5)
    let r0 : Float = cracks[i].radius * pulse
    let r1 : Float = cracks[i].radius * (0.58 + pulse * 0.18)

    let a0 : Int = 24 + (cracks[i].intensity * 42.0).to_int()
    let a1 : Int = 12 + (cracks[i].intensity * 24.0).to_int()

    @raylib.draw_circle(
      cracks[i].x.to_int(),
      cracks[i].y.to_int(),
      r0,
      @raylib.Color::new(196, 110, 70, a0),
    )
    @raylib.draw_circle(
      cracks[i].x.to_int(),
      cracks[i].y.to_int(),
      r1,
      @raylib.Color::new(238, 176, 116, a1),
    )

    let spark_x : Float = cracks[i].x +
      @math.sinf(t * 5.0 + cracks[i].phase) * cracks[i].radius * 0.24
    let spark_y : Float = cracks[i].y +
      @math.cosf(t * 4.6 + cracks[i].phase * 0.8) * cracks[i].radius * 0.24
    @raylib.draw_circle(
      spark_x.to_int(),
      spark_y.to_int(),
      3.0 + cracks[i].intensity * 2.0,
      @raylib.Color::new(255, 238, 180, 208),
    )
  }
}

///|
fn draw_dusts(dusts : Array[DustCloud], t : Float) -> Unit {
  for i = 0; i < dusts.length(); i = i + 1 {
    if not(dusts[i].active) {
      continue
    }

    let pulse : Float = 0.84 +
      0.2 * (@math.sinf(t * 1.8 + dusts[i].phase) * 0.5 + 0.5)
    let r0 : Float = dusts[i].radius * pulse
    let r1 : Float = dusts[i].radius * (0.62 + pulse * 0.14)

    let a0 : Int = 20 + (dusts[i].density * 56.0).to_int()
    let a1 : Int = 10 + (dusts[i].density * 30.0).to_int()

    @raylib.draw_circle(
      dusts[i].x.to_int(),
      dusts[i].y.to_int(),
      r0,
      @raylib.Color::new(98, 96, 92, a0),
    )
    @raylib.draw_circle(
      dusts[i].x.to_int(),
      dusts[i].y.to_int(),
      r1,
      @raylib.Color::new(138, 132, 124, a1),
    )
  }
}

///|
fn draw_obstacles(obstacles : Array[Obstacle], t : Float) -> Unit {
  for i = 0; i < obstacles.length(); i = i + 1 {
    if not(obstacles[i].active) {
      continue
    }

    let wob : Float = @math.sinf(t * 4.0 + obstacles[i].spin) * 0.5 + 0.5
    let rr : Float = obstacles[i].size * (0.88 + wob * 0.2)
    let h01 : Float = clampf(obstacles[i].hard / 100.0, 0.0, 1.0)

    let r : Int = 92 + (h01 * 54.0).to_int()
    let g : Int = 88 + (h01 * 38.0).to_int()
    let b : Int = 74 + (h01 * 22.0).to_int()

    @raylib.draw_circle(
      obstacles[i].x.to_int(),
      obstacles[i].y.to_int(),
      rr + 1.8,
      @raylib.Color::new(46, 70, 92, 174),
    )
    @raylib.draw_circle(
      obstacles[i].x.to_int(),
      obstacles[i].y.to_int(),
      rr,
      @raylib.Color::new(r, g, b, 238),
    )
  }
}

///|
fn draw_player(player : Player, t : Float) -> Unit {
  let x : Float = player.x
  let y : Float = player.y

  let nx : Float = @math.cosf(player.heading)
  let ny : Float = @math.sinf(player.heading)

  let hull_col : @raylib.Color = if player.hull < 34.0 {
    @raylib.Color::new(248, 164, 174, 252)
  } else {
    @raylib.Color::new(240, 244, 252, 252)
  }

  // convoy van
  @raylib.draw_rectangle(
    (x - 14.0).to_int(),
    (y - 8.0).to_int(),
    28,
    16,
    hull_col,
  )
  @raylib.draw_rectangle(
    (x - 8.0).to_int(),
    (y - 13.0).to_int(),
    16,
    6,
    @raylib.Color::new(204, 230, 250, 238),
  )

  @raylib.draw_line(
    x.to_int(),
    y.to_int(),
    (x + nx * 24.0).to_int(),
    (y + ny * 24.0).to_int(),
    @raylib.Color::new(252, 246, 214, 236),
  )

  let wake_r : Float = 9.0 +
    (@math.sinf(t * 4.4 + player.engine_t) * 0.5 + 0.5) * 6.0
  @raylib.draw_circle(
    (x - nx * 18.0).to_int(),
    (y - ny * 18.0).to_int(),
    wake_r,
    @raylib.Color::new(176, 214, 246, 86),
  )

  let shown_people : Int = mini(player.onboard, 6)
  for i = 0; i < shown_people; i = i + 1 {
    let px : Int = (x - 12.0 + Float::from_int(i % 3) * 8.0).to_int()
    let py : Int = (y + 2.0 + Float::from_int(i / 3) * 5.0).to_int()
    @raylib.draw_rectangle(px, py, 6, 4, @raylib.Color::new(222, 176, 120, 236))
  }

  // medkit indicator
  let kit_w : Int = (Float::from_int(22) *
  (Float::from_int(player.medkits) / Float::from_int(player.medkit_max))).to_int()
  @raylib.draw_rectangle(
    (x - 11.0).to_int(),
    (y + 10.0).to_int(),
    22,
    4,
    @raylib.Color::new(26, 38, 56, 224),
  )
  @raylib.draw_rectangle(
    (x - 11.0).to_int(),
    (y + 10.0).to_int(),
    kit_w,
    4,
    @raylib.Color::new(160, 232, 166, 236),
  )

  if player.ping_t > 0.0 {
    let rr : Float = (2.0 - player.ping_t) * 72.0 + 18.0
    @raylib.draw_circle(
      player.x.to_int(),
      player.y.to_int(),
      rr,
      @raylib.Color::new(168, 224, 252, 88),
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
      @raylib.Color::new(194, 226, 252, 184)
    } else if parts[i].kind == 1 {
      @raylib.Color::new(248, 194, 146, 220)
    } else if parts[i].kind == 2 {
      @raylib.Color::new(160, 210, 250, 214)
    } else {
      @raylib.Color::new(248, 236, 190, 214)
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
  let pad_x : Int = 30
  let pad_y : Int = sh - 198

  fn dpad_box(
    x : Int,
    y : Int,
    w : Int,
    h : Int,
    text : String,
    active : Bool,
  ) -> Unit {
    let col : @raylib.Color = if active {
      @raylib.Color::new(124, 182, 224, 226)
    } else {
      @raylib.Color::new(42, 74, 108, 196)
    }
    @raylib.draw_rectangle(x, y, w, h, col)
    @raylib.draw_rectangle_lines(
      x,
      y,
      w,
      h,
      @raylib.Color::new(170, 208, 240, 238),
    )
    @raylib.draw_text(
      text,
      x + w / 2 - @raylib.measure_text(text, 28) / 2,
      y + 10,
      28,
      @raylib.Color::new(236, 248, 255, 252),
    )
  }

  dpad_box(
    pad_x + 84,
    pad_y,
    76,
    56,
    "U",
    hold && inside_rect(mx, my, pad_x + 84, pad_y, 76, 56),
  )
  dpad_box(
    pad_x,
    pad_y + 66,
    76,
    56,
    "L",
    hold && inside_rect(mx, my, pad_x, pad_y + 66, 76, 56),
  )
  dpad_box(
    pad_x + 168,
    pad_y + 66,
    76,
    56,
    "R",
    hold && inside_rect(mx, my, pad_x + 168, pad_y + 66, 76, 56),
  )
  dpad_box(
    pad_x + 84,
    pad_y + 132,
    76,
    56,
    "D",
    hold && inside_rect(mx, my, pad_x + 84, pad_y + 132, 76, 56),
  )

  let boost_x : Float = Float::from_int(sw - 304)
  let boost_y : Float = Float::from_int(sh - 166)
  let action_x : Float = Float::from_int(sw - 188)
  let action_y : Float = Float::from_int(sh - 238)
  let ping_x : Float = Float::from_int(sw - 108)
  let ping_y : Float = Float::from_int(sh - 136)

  fn circle_btn(
    x : Float,
    y : Float,
    r : Float,
    text : String,
    active : Bool,
  ) -> Unit {
    let col : @raylib.Color = if active {
      @raylib.Color::new(128, 196, 236, 226)
    } else {
      @raylib.Color::new(40, 78, 116, 194)
    }
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      r + 4.0,
      @raylib.Color::new(10, 18, 32, 176),
    )
    @raylib.draw_circle(x.to_int(), y.to_int(), r, col)
    @raylib.draw_text(
      text,
      x.to_int() - @raylib.measure_text(text, 22) / 2,
      y.to_int() - 10,
      22,
      @raylib.Color::new(236, 246, 255, 248),
    )
  }

  circle_btn(
    boost_x,
    boost_y,
    56.0,
    "BOOST",
    hold && dist2(mx, my, boost_x, boost_y) <= 56.0 * 56.0,
  )
  circle_btn(
    action_x,
    action_y,
    44.0,
    "ACT",
    hold && dist2(mx, my, action_x, action_y) <= 44.0 * 44.0,
  )
  circle_btn(
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
  @raylib.init_window(sw, sh, "raylib [game] aftershock rescue convoy 2026")
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

  let hospital : Hospital = {
    x: Float::from_int(world_x + 18),
    y: Float::from_int(world_y + world_h / 2 - 72),
    w: 128,
    h: 144,
  }

  let hospital_cx : Float = hospital.x + Float::from_int(hospital.w / 2)
  let hospital_cy : Float = hospital.y + Float::from_int(hospital.h / 2)

  let districts : Array[District] = Array::makei(7, fn(i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      queue: 0.0,
      stress: 0.0,
      alarm_t: 0.0,
      id: i + 1,
    }
  })

  let groups : Array[SurvivorGroup] = Array::makei(26, fn(i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      count: 0,
      panic: 0.0,
      drift_x: 0.0,
      drift_y: 0.0,
      flare_t: 0.0,
      id: i + 1,
    }
  })

  let cracks : Array[CrackZone] = Array::makei(24, fn(_i) {
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

  let dusts : Array[DustCloud] = Array::makei(40, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      radius: 0.0,
      density: 0.0,
      life: 0.0,
      phase: 0.0,
    }
  })

  let obstacles : Array[Obstacle] = Array::makei(200, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      size: 0.0,
      hard: 0.0,
      spin: 0.0,
    }
  })

  let parts : Array[Particle] = Array::makei(920, fn(_i) {
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
    x: hospital_cx,
    y: hospital_cy,
    vx: 0.0,
    vy: 0.0,
    heading: 0.0,
    hull: 100.0,
    hull_max: 100.0,
    battery: 100.0,
    battery_max: 100.0,
    onboard: 0,
    capacity: 38,
    medkits: 8,
    medkit_max: 8,
    action_cd: 0.0,
    ping_cd: 0.0,
    ping_t: 0.0,
    ping_x: hospital_cx,
    ping_y: hospital_cy,
    engine_t: randf(0.0, 20.0),
  }

  let mut state : Int = 0 // 0 menu 1 play 2 win 3 lose
  let mut timer : Float = 430.0
  let mut rescued_total : Int = 0
  let mut target_rescued : Int = 680
  let mut score : Int = 0
  let mut tier : Int = 1

  let mut lost_people : Int = 0
  let mut lost_limit : Int = 170

  let mut spawn_cd : Float = 1.2
  let mut crack_cd : Float = 4.8

  let mut msg : String = ""
  let mut msg_t : Float = 0.0
  let mut scene_t : Float = 0.0

  let mut hospital_queue : Float = 210.0
  let mut hospital_queue_max : Float = 280.0
  let mut unload_cd : Float = 0.0

  let mut group_serial : Int = 1
  let mut urgent_peak : Int = 0
  let mut stabilized_total : Float = 0.0

  fn reset_run() -> Unit {
    init_districts(districts, world_x, world_y, world_w, world_h)
    init_obstacles(
      obstacles, districts, world_l, world_t, world_r, world_b, hospital_cx, hospital_cy,
    )

    clear_groups(groups)
    clear_cracks(cracks)
    clear_dusts(dusts)
    clear_parts(parts)

    player.x = hospital_cx
    player.y = hospital_cy
    player.vx = 0.0
    player.vy = 0.0
    player.heading = 0.0
    player.hull = 100.0
    player.battery = 100.0
    player.onboard = 0
    player.medkits = 8
    player.action_cd = 0.0
    player.ping_cd = 0.0
    player.ping_t = 0.0
    player.ping_x = hospital_cx
    player.ping_y = hospital_cy
    player.engine_t = randf(0.0, 20.0)

    timer = 430.0
    rescued_total = 0
    target_rescued = 680
    score = 0
    tier = 1

    lost_people = 0
    lost_limit = 170

    spawn_cd = 1.2
    crack_cd = 4.8

    msg = "Rescue civilians and stabilize aftershock cracks"
    msg_t = 2.8
    scene_t = 0.0

    hospital_queue = 210.0
    hospital_queue_max = 280.0
    unload_cd = 0.0

    group_serial = 1
    urgent_peak = 0
    stabilized_total = 0.0
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

    if player.action_cd > 0.0 {
      player.action_cd = player.action_cd - dt
      if player.action_cd < 0.0 {
        player.action_cd = 0.0
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

    if unload_cd > 0.0 {
      unload_cd = unload_cd - dt
      if unload_cd < 0.0 {
        unload_cd = 0.0
      }
    }

    player.engine_t = player.engine_t + dt * 14.0

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

      tier = 1 + rescued_total / 120
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
      let mut action_press : Bool = @raylib.is_key_pressed(@raylib.KeyL) ||
        @raylib.is_key_pressed(@raylib.KeyU)
      let mut ping_press : Bool = @raylib.is_key_pressed(@raylib.KeyK) ||
        @raylib.is_key_pressed(@raylib.KeyH)

      if hold {
        let pad_x : Int = 30
        let pad_y : Int = sh - 198

        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y, 76, 56) {
          move_u = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 66, 76, 56) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 168, pad_y + 66, 76, 56) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y + 132, 76, 56) {
          move_d = true
        }

        let boost_x : Float = Float::from_int(sw - 304)
        let boost_y : Float = Float::from_int(sh - 166)
        let action_x : Float = Float::from_int(sw - 188)
        let action_y : Float = Float::from_int(sh - 238)
        let ping_x : Float = Float::from_int(sw - 108)
        let ping_y : Float = Float::from_int(sh - 136)

        if dist2(mouse.x, mouse.y, boost_x, boost_y) <= 56.0 * 56.0 {
          boost_hold = true
        }
        if dist2(mouse.x, mouse.y, action_x, action_y) <= 44.0 * 44.0 {
          action_press = true
        }
        if dist2(mouse.x, mouse.y, ping_x, ping_y) <= 42.0 * 42.0 {
          ping_press = true
        }
      }

      // Crack/dust effects near player
      let mut crack_drag : Float = 0.0
      let mut battery_mul : Float = 1.0
      let mut dust_damage : Float = 0.0
      for i = 0; i < cracks.length(); i = i + 1 {
        if not(cracks[i].active) {
          continue
        }

        let rr : Float = cracks[i].radius
        let d2v : Float = dist2(player.x, player.y, cracks[i].x, cracks[i].y)
        if d2v < rr * rr {
          let ratio : Float = 1.0 - d2v.sqrt() / rr
          crack_drag = crack_drag + cracks[i].intensity * (0.2 + ratio * 0.56)
          battery_mul = battery_mul +
            cracks[i].intensity * (0.16 + ratio * 0.48)
          dust_damage = dust_damage +
            dt * cracks[i].intensity * (0.42 + ratio * 1.0)
        }
      }

      for i = 0; i < dusts.length(); i = i + 1 {
        if not(dusts[i].active) {
          continue
        }

        let rr : Float = dusts[i].radius
        let d2v : Float = dist2(player.x, player.y, dusts[i].x, dusts[i].y)
        if d2v < rr * rr {
          let ratio : Float = 1.0 - d2v.sqrt() / rr
          crack_drag = crack_drag + dusts[i].density * (0.14 + ratio * 0.34)
          battery_mul = battery_mul + dusts[i].density * (0.12 + ratio * 0.3)
          dust_damage = dust_damage +
            dt * dusts[i].density * (0.3 + ratio * 0.7)
        }
      }

      let boost_on : Bool = boost_hold && player.battery > 1.0

      let accel_base : Float = if boost_on { 560.0 } else { 430.0 }
      let max_speed : Float = if boost_on { 308.0 } else { 228.0 }

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

      let drag_base : Float = if boost_on { 4.7 } else { 5.7 }
      let drag : Float = drag_base + crack_drag

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

      if sp2 > 56.0 {
        player.heading = @math.atan2f(player.vy, player.vx)
      }

      let speed_norm : Float = sp2.sqrt() / max_speed
      let boost_drain : Float = if boost_on { 1.8 } else { 0.0 }
      player.battery = maxf(
        0.0,
        player.battery -
        dt * (0.48 + speed_norm * 0.66 + boost_drain) * battery_mul,
      )

      if dust_damage > 0.0 {
        player.hull = maxf(0.0, player.hull - dust_damage)
      }

      let near_hospital : Bool = inside_rect(
        player.x,
        player.y,
        hospital.x.to_int() - 8,
        hospital.y.to_int() - 8,
        hospital.w + 16,
        hospital.h + 16,
      )
      if near_hospital {
        player.battery = minf(player.battery_max, player.battery + dt * 24.0)
        player.hull = minf(player.hull_max, player.hull + dt * 5.2)

        // refill medkits at hospital gradually
        if @raylib.get_random_value(0, 100) < 28 &&
          player.medkits < player.medkit_max {
          player.medkits = player.medkits + 1
        }

        if player.onboard > 0 && unload_cd <= 0.0 {
          let unload_n : Int = mini(player.onboard, 3)
          player.onboard = player.onboard - unload_n
          rescued_total = rescued_total + unload_n
          score = score + unload_n * 10
          hospital_queue = maxf(
            0.0,
            hospital_queue - Float::from_int(unload_n) * 1.2,
          )
          unload_cd = 0.12
          burst(parts, player.x, player.y, 7 + unload_n, 2)
        }
      }

      hospital_queue = minf(
        hospital_queue_max,
        hospital_queue + dt * (2.2 + Float::from_int(tier) * 0.18),
      )

      if action_press {
        let (hits, reduction) = stabilize_cracks(player, cracks, parts)
        if hits > 0 {
          stabilized_total = stabilized_total + reduction
          score = score + (reduction * 80.0).to_int()
          msg = "Stabilized \{hits} crack zone(s)"
          msg_t = 0.9
        } else {
          let (rescued_now, gnum) = rescue_groups(player, groups, parts)
          if rescued_now > 0 {
            score = score + rescued_now * 6 + gnum * 8
            msg = "Picked up \{rescued_now} from \{gnum} group(s)"
            msg_t = 0.9
          } else {
            msg = "No action target in range"
            msg_t = 0.55
          }
        }
      }

      if ping_press && player.ping_cd <= 0.0 {
        let (fg, gx, gy, gp) = nearest_urgent_group(groups, player.x, player.y)
        let (fc, cx, cy, ci) = nearest_hot_crack(cracks, player.x, player.y)

        if fg && (not(fc) || gp >= 62.0) {
          player.ping_cd = 2.0
          player.ping_t = 2.0
          player.ping_x = gx
          player.ping_y = gy
          msg = "Ping: critical group panic \{gp.to_int()}"
          msg_t = 0.9
          burst(parts, player.x, player.y, 8, 2)
          burst(parts, gx, gy, 10, 2)
        } else if fc {
          player.ping_cd = 2.0
          player.ping_t = 2.0
          player.ping_x = cx
          player.ping_y = cy
          msg = "Ping: crack intensity \{(ci * 100.0).to_int()}"
          msg_t = 0.9
          burst(parts, player.x, player.y, 8, 2)
          burst(parts, cx, cy, 10, 3)
        } else {
          player.ping_cd = 1.0
          msg = "No urgent signal"
          msg_t = 0.6
        }
      }

      update_cracks(cracks, dusts, dt, world_l, world_t, world_r, world_b)
      update_dusts(dusts, dt, world_l, world_t, world_r, world_b)
      update_obstacles(obstacles, dt, world_l, world_t, world_r, world_b)

      // Obstacle collision damage
      let mut collision_dmg : Float = 0.0
      for i = 0; i < obstacles.length(); i = i + 1 {
        if not(obstacles[i].active) {
          continue
        }

        let rr : Float = obstacles[i].size + 11.0
        let d2v : Float = dist2(
          player.x,
          player.y,
          obstacles[i].x,
          obstacles[i].y,
        )
        if d2v < rr * rr {
          let d : Float = maxf(0.0001, d2v.sqrt())
          let nx : Float = (player.x - obstacles[i].x) / d
          let ny : Float = (player.y - obstacles[i].y) / d
          let push : Float = (rr - d) * dt * 24.0

          player.x = player.x + nx * push
          player.y = player.y + ny * push

          if sp2 > 70.0 {
            collision_dmg = collision_dmg +
              dt * (1.0 + obstacles[i].hard * 0.018)
            burst(parts, player.x, player.y, 2, 1)
          }
        }
      }

      // District queues rise over time, especially near cracks/dust
      for i = 0; i < districts.length(); i = i + 1 {
        if not(districts[i].active) {
          continue
        }

        if districts[i].alarm_t > 0.0 {
          districts[i].alarm_t = districts[i].alarm_t - dt
          if districts[i].alarm_t < 0.0 {
            districts[i].alarm_t = 0.0
          }
        }

        let mut crack_load : Float = 0.0
        for j = 0; j < cracks.length(); j = j + 1 {
          if not(cracks[j].active) {
            continue
          }

          let rr : Float = cracks[j].radius
          let d2v : Float = dist2(
            districts[i].x,
            districts[i].y,
            cracks[j].x,
            cracks[j].y,
          )
          if d2v < rr * rr {
            let ratio : Float = 1.0 - d2v.sqrt() / rr
            crack_load = crack_load + cracks[j].intensity * (0.4 + ratio * 1.0)
          }
        }

        for j = 0; j < dusts.length(); j = j + 1 {
          if not(dusts[j].active) {
            continue
          }

          let rr : Float = dusts[j].radius
          let d2v : Float = dist2(
            districts[i].x,
            districts[i].y,
            dusts[j].x,
            dusts[j].y,
          )
          if d2v < rr * rr {
            let ratio : Float = 1.0 - d2v.sqrt() / rr
            crack_load = crack_load + dusts[j].density * (0.2 + ratio * 0.7)
          }
        }

        districts[i].stress = clampf(
          districts[i].stress + dt * (0.9 + crack_load * 2.2),
          0.0,
          100.0,
        )
        districts[i].queue = districts[i].queue +
          dt * (1.6 + crack_load * 1.4 + Float::from_int(tier) * 0.2)

        if districts[i].queue > 100.0 {
          districts[i].queue = 74.0 + randf(0.0, 10.0)
          districts[i].alarm_t = 1.2
          lost_people = lost_people + 3
          msg = "District D\{districts[i].id} overwhelmed"
          msg_t = 0.85
          burst(parts, districts[i].x, districts[i].y, 14, 1)
        }
      }

      let (lost_now, _panic_sum) = update_groups(
        groups, cracks, dusts, dt, world_l, world_t, world_r, world_b, hospital_cx,
        hospital_cy,
      )
      if lost_now > 0 {
        lost_people = lost_people + lost_now
        score = score - lost_now * 5
        msg = "Group lost \{lost_now} people"
        msg_t = 0.9
      }

      spawn_cd = spawn_cd - dt
      if spawn_cd <= 0.0 {
        if spawn_group(
            groups, world_l, world_t, world_r, world_b, tier, group_serial,
          ) {
          group_serial = group_serial + 1
        }
        spawn_cd = randf(1.7, 3.6) - Float::from_int(tier) * 0.1
        if spawn_cd < 0.8 {
          spawn_cd = 0.8
        }
      }

      crack_cd = crack_cd - dt
      if crack_cd <= 0.0 {
        let max_c : Int = 2 + tier / 2
        if active_cracks(cracks) < max_c {
          ignore(spawn_crack(cracks, world_l, world_t, world_r, world_b, tier))
        }
        crack_cd = randf(5.0, 9.6) - Float::from_int(tier) * 0.22
        if crack_cd < 2.4 {
          crack_cd = 2.4
        }
      }

      let urgent_now : Int = active_critical(groups)
      if urgent_now > urgent_peak {
        urgent_peak = urgent_now
      }

      if collision_dmg > 0.0 {
        player.hull = maxf(0.0, player.hull - collision_dmg)
      }

      if rescued_total >= target_rescued {
        state = 2
        msg = "Rescue corridor stabilized"
        msg_t = 3.0
        burst(parts, player.x, player.y, 70, 2)
      } else if timer <= 0.0 {
        state = 3
        msg = "Shift ended"
        msg_t = 3.0
      } else if lost_people >= lost_limit {
        state = 3
        msg = "Too many civilians lost"
        msg_t = 3.0
      } else if player.hull <= 0.0 {
        state = 3
        msg = "Convoy destroyed"
        msg_t = 3.0
      } else if hospital_queue >= hospital_queue_max - 2.0 {
        state = 3
        msg = "Hospital overwhelmed"
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

    draw_city(world_x, world_y, world_w, world_h, scene_t)
    draw_hospital(hospital)
    draw_obstacles(obstacles, scene_t)
    draw_districts(districts, scene_t)
    draw_groups(groups, scene_t)
    draw_cracks(cracks, scene_t)
    draw_dusts(dusts, scene_t)
    draw_player(player, scene_t)

    if player.ping_t > 0.0 {
      let rr : Float = 18.0 + (2.0 - player.ping_t) * 62.0
      @raylib.draw_circle(
        player.ping_x.to_int(),
        player.ping_y.to_int(),
        rr,
        @raylib.Color::new(170, 228, 252, 88),
      )
      @raylib.draw_circle(
        player.ping_x.to_int(),
        player.ping_y.to_int(),
        8.0,
        @raylib.Color::new(248, 252, 255, 214),
      )
      @raylib.draw_line(
        player.x.to_int(),
        player.y.to_int(),
        player.ping_x.to_int(),
        player.ping_y.to_int(),
        @raylib.Color::new(188, 228, 252, 166),
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
      "AFTERSHOCK RESCUE CONVOY",
      panel_x + 16,
      36,
      30,
      @raylib.Color::new(236, 246, 255, 252),
    )
    @raylib.draw_text(
      "Urban rescue under seismic instability",
      panel_x + 16,
      74,
      20,
      @raylib.Color::new(194, 220, 252, 238),
    )

    @raylib.draw_text(
      "Time",
      panel_x + 16,
      110,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{timer.to_int()}s",
      panel_x + 102,
      110,
      30,
      @raylib.Color::new(248, 220, 152, 252),
    )

    @raylib.draw_text(
      "Rescued",
      panel_x + 16,
      146,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{rescued_total}/\{target_rescued}",
      panel_x + 132,
      146,
      30,
      @raylib.Color::new(138, 228, 164, 252),
    )

    @raylib.draw_text(
      "Lost",
      panel_x + 16,
      182,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{lost_people}/\{lost_limit}",
      panel_x + 88,
      182,
      30,
      @raylib.Color::new(246, 150, 164, 252),
    )

    @raylib.draw_text(
      "Tier",
      panel_x + 240,
      182,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{tier}",
      panel_x + 298,
      182,
      30,
      @raylib.Color::new(248, 212, 130, 252),
    )

    @raylib.draw_text(
      "Onboard",
      panel_x + 16,
      218,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{player.onboard}/\{player.capacity}",
      panel_x + 114,
      218,
      30,
      @raylib.Color::new(206, 232, 252, 252),
    )

    @raylib.draw_text(
      "Medkits",
      panel_x + 16,
      254,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{player.medkits}/\{player.medkit_max}",
      panel_x + 108,
      254,
      30,
      @raylib.Color::new(160, 232, 166, 252),
    )

    @raylib.draw_text(
      "Hospital load",
      panel_x + 16,
      290,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{hospital_queue.to_int()}",
      panel_x + 164,
      290,
      30,
      @raylib.Color::new(206, 232, 252, 252),
    )

    @raylib.draw_text(
      "Score",
      panel_x + 16,
      326,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{score}",
      panel_x + 92,
      326,
      30,
      @raylib.Color::new(158, 220, 252, 252),
    )

    @raylib.draw_text(
      "Stabilized",
      panel_x + 16,
      362,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{stabilized_total.to_int()}",
      panel_x + 148,
      362,
      30,
      @raylib.Color::new(246, 196, 150, 248),
    )

    @raylib.draw_text(
      "Active groups",
      panel_x + 16,
      398,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{active_groups(groups)}",
      panel_x + 152,
      398,
      30,
      @raylib.Color::new(246, 196, 150, 248),
    )

    @raylib.draw_text(
      "Active cracks",
      panel_x + 16,
      434,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{active_cracks(cracks)}",
      panel_x + 148,
      434,
      30,
      @raylib.Color::new(246, 196, 150, 248),
    )

    @raylib.draw_text(
      "Peak crack",
      panel_x + 212,
      434,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{(peak_crack_intensity(cracks) * 100.0).to_int()}",
      panel_x + 316,
      434,
      30,
      @raylib.Color::new(246, 196, 150, 248),
    )

    @raylib.draw_text(
      "Critical groups",
      panel_x + 16,
      470,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{active_critical(groups)}",
      panel_x + 166,
      470,
      30,
      @raylib.Color::new(246, 196, 150, 248),
    )

    @raylib.draw_text(
      "Panic peak",
      panel_x + 214,
      470,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{peak_group_panic(groups).to_int()}",
      panel_x + 314,
      470,
      30,
      @raylib.Color::new(246, 196, 150, 248),
    )

    draw_bar(
      panel_x,
      506,
      "Hull",
      player.hull,
      player.hull_max,
      @raylib.Color::new(130, 228, 164, 252),
    )
    draw_bar(
      panel_x,
      580,
      "Battery",
      player.battery,
      player.battery_max,
      @raylib.Color::new(126, 206, 252, 252),
    )
    draw_bar(
      panel_x,
      654,
      "Hospital Capacity",
      hospital_queue,
      hospital_queue_max,
      @raylib.Color::new(246, 186, 126, 252),
    )

    @raylib.draw_text(
      "Controls",
      panel_x + 16,
      730,
      28,
      @raylib.Color::new(236, 246, 255, 252),
    )
    @raylib.draw_text(
      "WASD / Arrows : drive",
      panel_x + 16,
      762,
      21,
      @raylib.Color::new(198, 220, 252, 236),
    )
    @raylib.draw_text(
      "J / Space : hold boost",
      panel_x + 16,
      784,
      21,
      @raylib.Color::new(198, 220, 252, 236),
    )
    @raylib.draw_text(
      "L / U : rescue or stabilize",
      panel_x + 16,
      806,
      21,
      @raylib.Color::new(198, 220, 252, 236),
    )
    @raylib.draw_text(
      "K / H : ping urgent target",
      panel_x + 16,
      828,
      21,
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
        "AFTERSHOCK RESCUE CONVOY",
        sw / 2 - 500,
        150,
        82,
        @raylib.Color::new(236, 246, 255, 255),
      )
      @raylib.draw_text(
        "Ground rescue and crack stabilization",
        sw / 2 - 300,
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
        "- Evacuate survivors and unload at MED HUB",
        sw / 2 - 486,
        382,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Stabilize aftershock cracks using medkits",
        sw / 2 - 486,
        418,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Prevent district overload and casualty spikes",
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
        "- Too many civilians lost",
        sw / 2 + 64,
        418,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Hospital overload or convoy destruction",
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
      draw_button(sw / 2 - 210, 638, 420, 94, "START CONVOY", hover)
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 24, 14, 206))
      @raylib.draw_text(
        "RESCUE SUCCESS",
        sw / 2 - 278,
        194,
        84,
        @raylib.Color::new(170, 248, 188, 252),
      )
      @raylib.draw_text(
        "Rescued \{rescued_total}/\{target_rescued}",
        sw / 2 - 196,
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
        "MISSION FAILED",
        sw / 2 - 266,
        194,
        84,
        @raylib.Color::new(248, 156, 168, 252),
      )
      @raylib.draw_text(
        "Rescued \{rescued_total}/\{target_rescued}",
        sw / 2 - 196,
        334,
        42,
        @raylib.Color::new(246, 230, 236, 252),
      )
      @raylib.draw_text(
        "Lost \{lost_people}/\{lost_limit}",
        sw / 2 - 116,
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
