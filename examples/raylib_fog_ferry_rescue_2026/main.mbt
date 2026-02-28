///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut heading : Float
  mut hull : Float
  hull_max : Float
  mut fuel : Float
  fuel_max : Float
  mut passengers : Int
  capacity : Int
  mut rescue_cd : Float
  mut ping_cd : Float
  mut ping_t : Float
  mut ping_x : Float
  mut ping_y : Float
  mut wake_t : Float
}

///|
struct Dock {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut queue : Float
  mut decay : Float
  mut id : Int
}

///|
struct Group {
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
struct FogCell {
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
struct Debris {
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
fn clear_docks(docks : Array[Dock]) -> Unit {
  for i in 0..<docks.length() {
    docks[i].active = false
    docks[i].x = 0.0
    docks[i].y = 0.0
    docks[i].queue = 0.0
    docks[i].decay = 0.0
    docks[i].id = i + 1
  }
}

///|
fn clear_groups(groups : Array[Group]) -> Unit {
  for i in 0..<groups.length() {
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
fn clear_fogs(fogs : Array[FogCell]) -> Unit {
  for fog in fogs {
    fog.active = false
    fog.x = 0.0
    fog.y = 0.0
    fog.vx = 0.0
    fog.vy = 0.0
    fog.radius = 0.0
    fog.density = 0.0
    fog.life = 0.0
    fog.phase = 0.0
  }
}

///|
fn clear_debris(debris : Array[Debris]) -> Unit {
  for debri in debris {
    debri.active = false
    debri.x = 0.0
    debri.y = 0.0
    debri.vx = 0.0
    debri.vy = 0.0
    debri.size = 0.0
    debri.hard = 0.0
    debri.spin = 0.0
  }
}

///|
fn clear_parts(parts : Array[Particle]) -> Unit {
  for part in parts {
    part.active = false
    part.x = 0.0
    part.y = 0.0
    part.vx = 0.0
    part.vy = 0.0
    part.life = 0.0
    part.size = 0.0
    part.kind = 0
  }
}

///|
fn add_particle(
  parts : Array[Particle],
  x : Float,
  y : Float,
  kind : Int,
) -> Unit {
  for part in parts {
    if part.active {
      continue
    }

    part.active = true
    part.x = x
    part.y = y

    let a : Float = randf(0.0, 6.28318)
    let s : Float = if kind == 0 {
      randf(7.0, 38.0)
    } else if kind == 1 {
      randf(28.0, 128.0)
    } else {
      randf(14.0, 92.0)
    }

    part.vx = @math.cosf(a) * s
    part.vy = @math.sinf(a) * s
    part.life = if kind == 0 {
      randf(0.45, 1.05)
    } else if kind == 1 {
      randf(0.2, 0.55)
    } else {
      randf(0.24, 0.8)
    }
    part.size = if kind == 1 { randf(2.4, 8.0) } else { randf(1.8, 5.6) }
    part.kind = kind
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
  for _i in 0..<n {
    add_particle(parts, x, y, kind)
  }
}

///|
fn update_parts(parts : Array[Particle], dt : Float) -> Unit {
  for part in parts {
    if not(part.active) {
      continue
    }

    part.life = part.life - dt
    if part.life <= 0.0 {
      part.active = false
      continue
    }

    part.x = part.x + part.vx * dt
    part.y = part.y + part.vy * dt

    if part.kind == 0 {
      part.vx = part.vx * (1.0 - dt * 0.8)
      part.vy = part.vy + dt * 10.0
    } else if part.kind == 1 {
      part.vx = part.vx * (1.0 - dt * 4.0)
      part.vy = part.vy + dt * 180.0
    } else {
      part.vx = part.vx * (1.0 - dt * 2.0)
      part.vy = part.vy + dt * 44.0
    }
  }
}

///|
fn init_docks(
  docks : Array[Dock],
  world_x : Int,
  world_y : Int,
  world_w : Int,
  world_h : Int,
) -> Unit {
  clear_docks(docks)

  let left : Float = Float::from_int(world_x + 230)
  let right : Float = Float::from_int(world_x + world_w - 170)
  let top : Float = Float::from_int(world_y + 120)
  let bottom : Float = Float::from_int(world_y + world_h - 120)
  let mid_x : Float = Float::from_int(world_x + world_w / 2)
  let mid_y : Float = Float::from_int(world_y + world_h / 2)

  if docks.length() > 0 {
    docks[0].active = true
    docks[0].x = left + 40.0
    docks[0].y = top + 20.0
    docks[0].queue = 16.0
    docks[0].decay = 0.0
  }
  if docks.length() > 1 {
    docks[1].active = true
    docks[1].x = left + 280.0
    docks[1].y = mid_y - 150.0
    docks[1].queue = 22.0
    docks[1].decay = 0.0
  }
  if docks.length() > 2 {
    docks[2].active = true
    docks[2].x = mid_x - 50.0
    docks[2].y = bottom - 86.0
    docks[2].queue = 28.0
    docks[2].decay = 0.0
  }
  if docks.length() > 3 {
    docks[3].active = true
    docks[3].x = right - 120.0
    docks[3].y = top + 84.0
    docks[3].queue = 26.0
    docks[3].decay = 0.0
  }
  if docks.length() > 4 {
    docks[4].active = true
    docks[4].x = right - 44.0
    docks[4].y = mid_y + 164.0
    docks[4].queue = 20.0
    docks[4].decay = 0.0
  }
  if docks.length() > 5 {
    docks[5].active = true
    docks[5].x = mid_x + 260.0
    docks[5].y = mid_y - 34.0
    docks[5].queue = 18.0
    docks[5].decay = 0.0
  }
  if docks.length() > 6 {
    docks[6].active = true
    docks[6].x = left + 96.0
    docks[6].y = bottom - 146.0
    docks[6].queue = 24.0
    docks[6].decay = 0.0
  }
}

///|
fn init_debris(
  debris : Array[Debris],
  docks : Array[Dock],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  harbor_x : Float,
  harbor_y : Float,
) -> Unit {
  clear_debris(debris)

  let mut filled : Int = 0
  let target : Int = debris.length() - 12

  while filled < target {
    let x : Float = randf(world_l + 26.0, world_r - 26.0)
    let y : Float = randf(world_t + 26.0, world_b - 26.0)

    if dist2(x, y, harbor_x, harbor_y) < 180.0 * 180.0 {
      continue
    }

    let mut near_dock : Bool = false
    for dock in docks {
      if not(dock.active) {
        continue
      }
      if dist2(x, y, dock.x, dock.y) < 120.0 * 120.0 {
        near_dock = true
        break
      }
    }
    if near_dock {
      continue
    }

    let mut overlap : Bool = false
    for debri in debris {
      if not(debri.active) {
        continue
      }
      let rr : Float = debri.size + 12.0
      if dist2(x, y, debri.x, debri.y) < rr * rr {
        overlap = true
        break
      }
    }
    if overlap {
      continue
    }

    debris[filled].active = true
    debris[filled].x = x
    debris[filled].y = y
    debris[filled].vx = randf(-24.0, 24.0)
    debris[filled].vy = randf(-24.0, 24.0)
    debris[filled].size = randf(8.0, 22.0)
    debris[filled].hard = randf(24.0, 100.0)
    debris[filled].spin = randf(0.0, 20.0)

    filled = filled + 1
  }
}

///|
fn spawn_group(
  groups : Array[Group],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  tier : Int,
  serial : Int,
) -> Bool {
  for group in groups {
    if group.active {
      continue
    }

    let side : Int = @raylib.get_random_value(0, 3)
    if side == 0 {
      group.x = world_l + randf(26.0, 60.0)
      group.y = randf(world_t + 30.0, world_b - 30.0)
      group.drift_x = randf(6.0, 18.0)
      group.drift_y = randf(-7.0, 7.0)
    } else if side == 1 {
      group.x = world_r - randf(26.0, 60.0)
      group.y = randf(world_t + 30.0, world_b - 30.0)
      group.drift_x = randf(-18.0, -6.0)
      group.drift_y = randf(-7.0, 7.0)
    } else if side == 2 {
      group.x = randf(world_l + 30.0, world_r - 30.0)
      group.y = world_t + randf(26.0, 60.0)
      group.drift_x = randf(-8.0, 8.0)
      group.drift_y = randf(6.0, 18.0)
    } else {
      group.x = randf(world_l + 30.0, world_r - 30.0)
      group.y = world_b - randf(26.0, 60.0)
      group.drift_x = randf(-8.0, 8.0)
      group.drift_y = randf(-18.0, -6.0)
    }

    group.active = true
    group.count = 4 + @raylib.get_random_value(0, 8 + tier * 2)
    group.panic = randf(4.0, 26.0)
    group.flare_t = randf(0.3, 1.2)
    group.id = serial
    return true
  }

  false
}

///|
fn spawn_fog(
  fogs : Array[FogCell],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  tier : Int,
) -> Bool {
  for fog in fogs {
    if fog.active {
      continue
    }

    let side : Int = @raylib.get_random_value(0, 3)
    if side == 0 {
      fog.x = world_l - 80.0
      fog.y = randf(world_t + 20.0, world_b - 20.0)
      fog.vx = randf(12.0, 34.0)
      fog.vy = randf(-9.0, 9.0)
    } else if side == 1 {
      fog.x = world_r + 80.0
      fog.y = randf(world_t + 20.0, world_b - 20.0)
      fog.vx = randf(-34.0, -12.0)
      fog.vy = randf(-9.0, 9.0)
    } else if side == 2 {
      fog.x = randf(world_l + 20.0, world_r - 20.0)
      fog.y = world_t - 80.0
      fog.vx = randf(-12.0, 12.0)
      fog.vy = randf(14.0, 28.0)
    } else {
      fog.x = randf(world_l + 20.0, world_r - 20.0)
      fog.y = world_b + 80.0
      fog.vx = randf(-12.0, 12.0)
      fog.vy = randf(-28.0, -14.0)
    }

    fog.active = true
    fog.radius = randf(74.0, 148.0)
    fog.density = randf(0.45, 1.15) + Float::from_int(tier) * 0.04
    fog.life = randf(20.0, 42.0)
    fog.phase = randf(0.0, 20.0)
    return true
  }

  false
}

///|
fn active_groups(groups : Array[Group]) -> Int {
  let mut n : Int = 0
  for group in groups {
    if group.active {
      n = n + 1
    }
  }
  n
}

///|
fn active_fogs(fogs : Array[FogCell]) -> Int {
  let mut n : Int = 0
  for fog in fogs {
    if fog.active {
      n = n + 1
    }
  }
  n
}

///|
fn active_panic(groups : Array[Group]) -> Int {
  let mut n : Int = 0
  for group in groups {
    if group.active && group.panic >= 70.0 {
      n = n + 1
    }
  }
  n
}

///|
fn peak_group_panic(groups : Array[Group]) -> Float {
  let mut best : Float = 0.0
  for group in groups {
    if group.active && group.panic > best {
      best = group.panic
    }
  }
  best
}

///|
fn update_fogs(
  fogs : Array[FogCell],
  dt : Float,
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
) -> Unit {
  for fog in fogs {
    if not(fog.active) {
      continue
    }

    fog.life = fog.life - dt
    if fog.life <= 0.0 {
      fog.active = false
      continue
    }

    fog.phase = fog.phase + dt * (0.8 + fog.density * 0.35)
    let pulse : Float = 0.88 + 0.16 * (@math.sinf(fog.phase) * 0.5 + 0.5)

    fog.x = fog.x + fog.vx * dt * pulse
    fog.y = fog.y + fog.vy * dt * pulse

    if fog.x < world_l - 160.0 {
      fog.x = world_l - 160.0
      fog.vx = absf(fog.vx)
    } else if fog.x > world_r + 160.0 {
      fog.x = world_r + 160.0
      fog.vx = -absf(fog.vx)
    }

    if fog.y < world_t - 160.0 {
      fog.y = world_t - 160.0
      fog.vy = absf(fog.vy)
    } else if fog.y > world_b + 160.0 {
      fog.y = world_b + 160.0
      fog.vy = -absf(fog.vy)
    }
  }
}

///|
fn update_debris(
  debris : Array[Debris],
  dt : Float,
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
) -> Unit {
  for debri in debris {
    if not(debri.active) {
      continue
    }

    debri.spin = debri.spin + dt * 0.7

    let drift : Float = 0.84 + 0.24 * (@math.sinf(debri.spin) * 0.5 + 0.5)
    debri.x = debri.x + debri.vx * dt * drift
    debri.y = debri.y + debri.vy * dt * drift

    if debri.x < world_l + debri.size {
      debri.x = world_l + debri.size
      debri.vx = absf(debri.vx) * randf(0.65, 1.1)
    } else if debri.x > world_r - debri.size {
      debri.x = world_r - debri.size
      debri.vx = -absf(debri.vx) * randf(0.65, 1.1)
    }

    if debri.y < world_t + debri.size {
      debri.y = world_t + debri.size
      debri.vy = absf(debri.vy) * randf(0.65, 1.1)
    } else if debri.y > world_b - debri.size {
      debri.y = world_b - debri.size
      debri.vy = -absf(debri.vy) * randf(0.65, 1.1)
    }

    debri.hard = maxf(8.0, debri.hard - dt * 0.02)
  }
}

///|
fn update_groups(
  groups : Array[Group],
  fogs : Array[FogCell],
  dt : Float,
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  harbor_x : Float,
  harbor_y : Float,
) -> (Int, Float) {
  let mut lost : Int = 0
  let mut panic_sum : Float = 0.0

  for group in groups {
    if not(group.active) {
      continue
    }

    group.x = group.x + group.drift_x * dt
    group.y = group.y + group.drift_y * dt

    if group.x < world_l + 18.0 || group.x > world_r - 18.0 {
      group.drift_x = -group.drift_x
      group.x = clampf(group.x, world_l + 18.0, world_r - 18.0)
    }
    if group.y < world_t + 18.0 || group.y > world_b - 18.0 {
      group.drift_y = -group.drift_y
      group.y = clampf(group.y, world_t + 18.0, world_b - 18.0)
    }

    group.flare_t = group.flare_t - dt
    if group.flare_t <= 0.0 {
      group.flare_t = randf(0.6, 1.4)
    }

    let mut panic_gain : Float = dt * 2.2

    let harbor_d2 : Float = dist2(group.x, group.y, harbor_x, harbor_y)
    if harbor_d2 > 380.0 * 380.0 {
      panic_gain = panic_gain + dt * 0.8
    }

    for fog in fogs {
      if not(fog.active) {
        continue
      }

      let rr : Float = fog.radius
      let d2v : Float = dist2(group.x, group.y, fog.x, fog.y)
      if d2v < rr * rr {
        let ratio : Float = 1.0 - d2v.sqrt() / rr
        panic_gain = panic_gain + dt * fog.density * (0.8 + ratio * 1.6)
      }
    }

    group.panic = group.panic + panic_gain
    if group.panic > 100.0 {
      lost = lost + group.count
      group.active = false
      continue
    }

    panic_sum = panic_sum + group.panic
  }

  (lost, panic_sum)
}

///|
fn rescue_groups(
  player : Player,
  groups : Array[Group],
  parts : Array[Particle],
) -> (Int, Int) {
  if player.rescue_cd > 0.0 || player.passengers >= player.capacity {
    (0, 0)
  } else {
    let mut rescued_people : Int = 0
    let mut group_count : Int = 0

    for group in groups {
      if not(group.active) || group.count <= 0 {
        continue
      }

      let d2v : Float = dist2(player.x, player.y, group.x, group.y)
      if d2v > 82.0 * 82.0 {
        continue
      }

      let cap_left : Int = player.capacity - player.passengers
      if cap_left <= 0 {
        break
      }

      let take : Int = mini(group.count, mini(cap_left, 8))
      if take <= 0 {
        continue
      }

      player.passengers = player.passengers + take
      group.count = group.count - take
      group.panic = maxf(0.0, group.panic - Float::from_int(take) * 2.8)
      rescued_people = rescued_people + take
      group_count = group_count + 1
      burst(parts, group.x, group.y, 9 + take / 2, 2)

      if group.count <= 0 {
        group.active = false
      }
    }

    if rescued_people > 0 {
      player.rescue_cd = 0.35
    }

    (rescued_people, group_count)
  }
}

///|
fn nearest_urgent_group(
  groups : Array[Group],
  x : Float,
  y : Float,
) -> (Bool, Float, Float, Float) {
  let mut found : Bool = false
  let mut bx : Float = x
  let mut by : Float = y
  let mut bp : Float = 0.0
  let mut bd2 : Float = 999999999.0

  for group in groups {
    if not(group.active) || group.panic < 30.0 {
      continue
    }

    let d2v : Float = dist2(x, y, group.x, group.y)
    if d2v < bd2 {
      bd2 = d2v
      bx = group.x
      by = group.y
      bp = group.panic
      found = true
    }
  }

  (found, bx, by, bp)
}

///|
fn draw_water(
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
    @raylib.Color::new(8, 30, 52, 255),
  )

  let mut y : Int = world_y
  while y < world_y + world_h {
    let p : Float = Float::from_int(y - world_y) / Float::from_int(world_h)
    let wave : Float = @math.sinf(t * 0.9 + Float::from_int(y) * 0.02) * 0.5 +
      0.5

    let r : Int = 14 + (p * 22.0).to_int() + (wave * 6.0).to_int()
    let g : Int = 56 + (p * 42.0).to_int() + (wave * 8.0).to_int()
    let b : Int = 100 + (p * 38.0).to_int() + (wave * 12.0).to_int()

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
    @raylib.Color::new(130, 184, 224, 216),
  )
}

///|
fn draw_harbor(hx : Int, hy : Int, hw : Int, hh : Int) -> Unit {
  @raylib.draw_rectangle(hx, hy, hw, hh, @raylib.Color::new(42, 78, 114, 236))
  @raylib.draw_rectangle_lines(
    hx,
    hy,
    hw,
    hh,
    @raylib.Color::new(176, 214, 244, 246),
  )

  let mut x : Int = hx + 10
  while x < hx + hw - 8 {
    @raylib.draw_line(
      x,
      hy + 8,
      x,
      hy + hh - 8,
      @raylib.Color::new(88, 132, 170, 198),
    )
    x = x + 16
  }

  @raylib.draw_text(
    "SAFE HARBOR",
    hx + 8,
    hy + hh + 8,
    24,
    @raylib.Color::new(226, 242, 255, 246),
  )
}

///|
fn draw_docks(docks : Array[Dock], t : Float) -> Unit {
  for i in 0..<docks.length() {
    if not(docks[i].active) {
      continue
    }

    let q01 : Float = clampf(docks[i].queue / 100.0, 0.0, 1.0)
    let pulse : Float = @math.sinf(t * 3.2 + Float::from_int(i) * 0.9) * 0.5 +
      0.5

    let col : @raylib.Color = if docks[i].queue >= 70.0 {
      @raylib.Color::new(244, 154, 162, 252)
    } else {
      @raylib.Color::new(234, 240, 248, 252)
    }

    @raylib.draw_rectangle(
      (docks[i].x - 14.0).to_int(),
      (docks[i].y - 20.0).to_int(),
      28,
      28,
      col,
    )
    @raylib.draw_rectangle(
      (docks[i].x - 24.0).to_int(),
      (docks[i].y + 8.0).to_int(),
      48,
      8,
      @raylib.Color::new(96, 140, 178, 234),
    )

    let beam_r : Float = 26.0 + q01 * 54.0 + pulse * 6.0
    @raylib.draw_circle(
      docks[i].x.to_int(),
      (docks[i].y - 24.0).to_int(),
      beam_r,
      @raylib.Color::new(246, 236, 168, 46 + (q01 * 80.0).to_int()),
    )

    @raylib.draw_text(
      "D\{docks[i].id} Q:\{docks[i].queue.to_int()}",
      (docks[i].x - 44.0).to_int(),
      (docks[i].y + 24.0).to_int(),
      18,
      @raylib.Color::new(220, 238, 252, 236),
    )
  }
}

///|
fn draw_groups(groups : Array[Group], t : Float) -> Unit {
  for group in groups {
    if not(group.active) {
      continue
    }

    let p01 : Float = clampf(group.panic / 100.0, 0.0, 1.0)
    let flare : Float = @math.sinf(
        t * 6.0 + Float::from_int(group.id) * 0.3,
      ) *
      0.5 +
      0.5

    let col : @raylib.Color = if group.panic >= 72.0 {
      @raylib.Color::new(248, 154, 132, 252)
    } else {
      @raylib.Color::new(246, 226, 194, 248)
    }

    @raylib.draw_circle(
      group.x.to_int(),
      group.y.to_int(),
      11.0 + flare * 3.0,
      col,
    )
    @raylib.draw_circle(
      group.x.to_int(),
      group.y.to_int(),
      4.0,
      @raylib.Color::new(252, 246, 236, 246),
    )

    @raylib.draw_text(
      "G\{group.id} N:\{group.count} P:\{group.panic.to_int()}",
      (group.x - 54.0).to_int(),
      (group.y + 14.0).to_int(),
      16,
      @raylib.Color::new(246, 234, 220, 236),
    )

    if group.flare_t < 0.18 {
      let rr : Float = 18.0 + p01 * 42.0
      @raylib.draw_circle(
        group.x.to_int(),
        group.y.to_int(),
        rr,
        @raylib.Color::new(252, 204, 136, 66),
      )
    }
  }
}

///|
fn draw_fogs(fogs : Array[FogCell], t : Float) -> Unit {
  for fog in fogs {
    if not(fog.active) {
      continue
    }

    let pulse : Float = 0.84 +
      0.2 * (@math.sinf(t * 1.8 + fog.phase) * 0.5 + 0.5)
    let r0 : Float = fog.radius * pulse
    let r1 : Float = fog.radius * (0.58 + pulse * 0.18)

    let a0 : Int = 22 + (fog.density * 42.0).to_int()
    let a1 : Int = 12 + (fog.density * 24.0).to_int()

    @raylib.draw_circle(
      fog.x.to_int(),
      fog.y.to_int(),
      r0,
      @raylib.Color::new(210, 226, 238, a0),
    )
    @raylib.draw_circle(
      fog.x.to_int(),
      fog.y.to_int(),
      r1,
      @raylib.Color::new(238, 246, 252, a1),
    )
  }
}

///|
fn draw_debris(debris : Array[Debris], t : Float) -> Unit {
  for debri in debris {
    if not(debri.active) {
      continue
    }

    let wob : Float = @math.sinf(t * 4.0 + debri.spin) * 0.5 + 0.5
    let rr : Float = debri.size * (0.88 + wob * 0.2)
    let h01 : Float = clampf(debri.hard / 100.0, 0.0, 1.0)

    let r : Int = 88 + (h01 * 58.0).to_int()
    let g : Int = 98 + (h01 * 44.0).to_int()
    let b : Int = 88 + (h01 * 24.0).to_int()

    @raylib.draw_circle(
      debri.x.to_int(),
      debri.y.to_int(),
      rr + 1.8,
      @raylib.Color::new(46, 70, 92, 174),
    )
    @raylib.draw_circle(
      debri.x.to_int(),
      debri.y.to_int(),
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

  @raylib.draw_rectangle(
    (x - 14.0).to_int(),
    (y - 9.0).to_int(),
    28,
    18,
    hull_col,
  )
  @raylib.draw_rectangle(
    (x - 8.0).to_int(),
    (y - 14.0).to_int(),
    16,
    7,
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
    (@math.sinf(t * 4.4 + player.wake_t) * 0.5 + 0.5) * 6.0
  @raylib.draw_circle(
    (x - nx * 18.0).to_int(),
    (y - ny * 18.0).to_int(),
    wake_r,
    @raylib.Color::new(176, 214, 246, 86),
  )

  let shown : Int = mini(player.passengers, 6)
  for i in 0..<shown {
    let px : Int = (x - 10.0 + Float::from_int(i % 3) * 8.0).to_int()
    let py : Int = (y + 3.0 + Float::from_int(i / 3) * 5.0).to_int()
    @raylib.draw_rectangle(px, py, 6, 4, @raylib.Color::new(222, 176, 120, 236))
  }

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
  for part in parts {
    if not(part.active) {
      continue
    }

    let col : @raylib.Color = if part.kind == 0 {
      @raylib.Color::new(194, 226, 252, 184)
    } else if part.kind == 1 {
      @raylib.Color::new(248, 194, 146, 220)
    } else {
      @raylib.Color::new(170, 242, 206, 214)
    }

    @raylib.draw_circle(
      part.x.to_int(),
      part.y.to_int(),
      part.size,
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

  let boost_x : Float = Float::from_int(sw - 300)
  let boost_y : Float = Float::from_int(sh - 162)
  let rescue_x : Float = Float::from_int(sw - 184)
  let rescue_y : Float = Float::from_int(sh - 236)
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
    rescue_x,
    rescue_y,
    44.0,
    "RESCUE",
    hold && dist2(mx, my, rescue_x, rescue_y) <= 44.0 * 44.0,
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
  @raylib.init_window(sw, sh, "raylib [game] fog ferry rescue 2026")
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

  let harbor_x : Int = world_x + 18
  let harbor_y : Int = world_y + world_h / 2 - 72
  let harbor_w : Int = 128
  let harbor_h : Int = 144

  let harbor_cx : Float = Float::from_int(harbor_x + harbor_w / 2)
  let harbor_cy : Float = Float::from_int(harbor_y + harbor_h / 2)

  let docks : Array[Dock] = Array::makei(7, fn(i) {
    { active: false, x: 0.0, y: 0.0, queue: 0.0, decay: 0.0, id: i + 1 }
  })

  let groups : Array[Group] = Array::makei(26, fn(i) {
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

  let fogs : Array[FogCell] = Array::makei(24, fn(_i) {
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

  let debris : Array[Debris] = Array::makei(210, fn(_i) {
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

  let parts : Array[Particle] = Array::makei(900, fn(_i) {
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
    fuel: 100.0,
    fuel_max: 100.0,
    passengers: 0,
    capacity: 38,
    rescue_cd: 0.0,
    ping_cd: 0.0,
    ping_t: 0.0,
    ping_x: harbor_cx,
    ping_y: harbor_cy,
    wake_t: randf(0.0, 20.0),
  }

  let mut state : Int = 0 // 0 menu 1 play 2 win 3 lose
  let mut timer : Float = 420.0
  let mut rescued_total : Int = 0
  let mut target_rescued : Int = 620
  let mut score : Int = 0
  let mut tier : Int = 1

  let mut lost_people : Int = 0
  let mut lost_limit : Int = 150

  let mut spawn_cd : Float = 1.2
  let mut fog_cd : Float = 4.8

  let mut msg : String = ""
  let mut msg_t : Float = 0.0
  let mut scene_t : Float = 0.0

  let mut harbor_queue : Float = 200.0
  let mut harbor_queue_max : Float = 260.0
  let mut unload_cd : Float = 0.0

  let mut group_serial : Int = 1
  let mut urgent_peak : Int = 0

  fn reset_run() -> Unit {
    init_docks(docks, world_x, world_y, world_w, world_h)
    init_debris(
      debris, docks, world_l, world_t, world_r, world_b, harbor_cx, harbor_cy,
    )

    clear_groups(groups)
    clear_fogs(fogs)
    clear_parts(parts)

    player.x = harbor_cx
    player.y = harbor_cy
    player.vx = 0.0
    player.vy = 0.0
    player.heading = 0.0
    player.hull = 100.0
    player.fuel = 100.0
    player.passengers = 0
    player.rescue_cd = 0.0
    player.ping_cd = 0.0
    player.ping_t = 0.0
    player.ping_x = harbor_cx
    player.ping_y = harbor_cy
    player.wake_t = randf(0.0, 20.0)

    timer = 420.0
    rescued_total = 0
    target_rescued = 620
    score = 0
    tier = 1

    lost_people = 0
    lost_limit = 150

    spawn_cd = 1.2
    fog_cd = 4.8

    msg = "Locate stranded groups and ferry them to safe harbor"
    msg_t = 2.8
    scene_t = 0.0

    harbor_queue = 200.0
    harbor_queue_max = 260.0
    unload_cd = 0.0

    group_serial = 1
    urgent_peak = 0
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

    if player.rescue_cd > 0.0 {
      player.rescue_cd = player.rescue_cd - dt
      if player.rescue_cd < 0.0 {
        player.rescue_cd = 0.0
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

      tier = 1 + rescued_total / 110
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
      let mut rescue_press : Bool = @raylib.is_key_pressed(@raylib.KeyL) ||
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

        let boost_x : Float = Float::from_int(sw - 300)
        let boost_y : Float = Float::from_int(sh - 162)
        let rescue_x : Float = Float::from_int(sw - 184)
        let rescue_y : Float = Float::from_int(sh - 236)
        let ping_x : Float = Float::from_int(sw - 108)
        let ping_y : Float = Float::from_int(sh - 136)

        if dist2(mouse.x, mouse.y, boost_x, boost_y) <= 56.0 * 56.0 {
          boost_hold = true
        }
        if dist2(mouse.x, mouse.y, rescue_x, rescue_y) <= 44.0 * 44.0 {
          rescue_press = true
        }
        if dist2(mouse.x, mouse.y, ping_x, ping_y) <= 42.0 * 42.0 {
          ping_press = true
        }
      }

      // Fog effects near player
      let mut fog_drag : Float = 0.0
      let mut fog_fuel_mul : Float = 1.0
      for fog in fogs {
        if not(fog.active) {
          continue
        }

        let rr : Float = fog.radius
        let d2v : Float = dist2(player.x, player.y, fog.x, fog.y)
        if d2v < rr * rr {
          let ratio : Float = 1.0 - d2v.sqrt() / rr
          fog_drag = fog_drag + fog.density * (0.2 + ratio * 0.55)
          fog_fuel_mul = fog_fuel_mul + fog.density * (0.16 + ratio * 0.5)
        }
      }

      let boost_on : Bool = boost_hold && player.fuel > 1.0

      let accel_base : Float = if boost_on { 560.0 } else { 430.0 }
      let max_speed : Float = if boost_on { 302.0 } else { 226.0 }

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

      let drag_base : Float = if boost_on { 4.8 } else { 5.8 }
      let drag : Float = drag_base + fog_drag

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

      player.wake_t = player.wake_t + dt * (2.4 + sp2.sqrt() * 0.012)

      let speed_norm : Float = sp2.sqrt() / max_speed
      let boost_drain : Float = if boost_on { 1.8 } else { 0.0 }
      player.fuel = maxf(
        0.0,
        player.fuel -
        dt * (0.46 + speed_norm * 0.66 + boost_drain) * fog_fuel_mul,
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
        player.fuel = minf(player.fuel_max, player.fuel + dt * 24.0)
        player.hull = minf(player.hull_max, player.hull + dt * 5.4)

        if player.passengers > 0 && unload_cd <= 0.0 {
          let unload_n : Int = mini(player.passengers, 3)
          player.passengers = player.passengers - unload_n
          rescued_total = rescued_total + unload_n
          score = score + unload_n * 10
          harbor_queue = maxf(
            0.0,
            harbor_queue - Float::from_int(unload_n) * 1.2,
          )
          unload_cd = 0.12
          burst(parts, player.x, player.y, 7 + unload_n, 2)
        }
      }

      harbor_queue = minf(
        harbor_queue_max,
        harbor_queue + dt * (2.4 + Float::from_int(tier) * 0.16),
      )

      if rescue_press {
        let (rescued_now, gnum) = rescue_groups(player, groups, parts)
        if rescued_now > 0 {
          score = score + rescued_now * 6 + gnum * 8
          msg = "Picked up \{rescued_now} from \{gnum} group(s)"
          msg_t = 0.9
        } else {
          msg = "No rescue target in range"
          msg_t = 0.55
        }
      }

      if ping_press && player.ping_cd <= 0.0 {
        let (found, tx, ty, panic) = nearest_urgent_group(
          groups,
          player.x,
          player.y,
        )
        if found {
          player.ping_cd = 2.0
          player.ping_t = 2.0
          player.ping_x = tx
          player.ping_y = ty
          msg = "Ping lock: panic \{panic.to_int()}"
          msg_t = 0.9
          burst(parts, player.x, player.y, 8, 2)
          burst(parts, tx, ty, 10, 2)
        } else {
          player.ping_cd = 1.0
          msg = "No urgent rescue signal"
          msg_t = 0.6
        }
      }

      update_fogs(fogs, dt, world_l, world_t, world_r, world_b)
      update_debris(debris, dt, world_l, world_t, world_r, world_b)

      // Debris collision damage
      let mut collision_dmg : Float = 0.0
      for debri in debris {
        if not(debri.active) {
          continue
        }

        let rr : Float = debri.size + 11.0
        let d2v : Float = dist2(player.x, player.y, debri.x, debri.y)
        if d2v < rr * rr {
          let d : Float = maxf(0.0001, d2v.sqrt())
          let nx : Float = (player.x - debri.x) / d
          let ny : Float = (player.y - debri.y) / d
          let push : Float = (rr - d) * dt * 24.0

          player.x = player.x + nx * push
          player.y = player.y + ny * push

          if sp2 > 70.0 {
            collision_dmg = collision_dmg + dt * (1.1 + debri.hard * 0.018)
            burst(parts, player.x, player.y, 2, 1)
          }
        }
      }

      // Dock queues rise over time, especially during fog
      for dock in docks {
        if not(dock.active) {
          continue
        }

        let mut fog_load : Float = 0.0
        for fog in fogs {
          if not(fog.active) {
            continue
          }

          let rr : Float = fog.radius
          let d2v : Float = dist2(dock.x, dock.y, fog.x, fog.y)
          if d2v < rr * rr {
            let ratio : Float = 1.0 - d2v.sqrt() / rr
            fog_load = fog_load + fog.density * (0.3 + ratio * 0.9)
          }
        }

        dock.queue = dock.queue +
          dt * (1.7 + fog_load * 1.4 + Float::from_int(tier) * 0.2)

        if dock.queue > 100.0 {
          dock.queue = 74.0 + randf(0.0, 10.0)
          lost_people = lost_people + 3
          msg = "Dock D\{dock.id} overflow"
          msg_t = 0.85
          burst(parts, dock.x, dock.y, 14, 1)
        }

        dock.decay = dock.decay + dt
      }

      let (lost_now, _panic_sum) = update_groups(
        groups, fogs, dt, world_l, world_t, world_r, world_b, harbor_cx, harbor_cy,
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

      fog_cd = fog_cd - dt
      if fog_cd <= 0.0 {
        let max_fogs : Int = 2 + tier / 2
        if active_fogs(fogs) < max_fogs {
          ignore(spawn_fog(fogs, world_l, world_t, world_r, world_b, tier))
        }
        fog_cd = randf(5.0, 9.6) - Float::from_int(tier) * 0.22
        if fog_cd < 2.4 {
          fog_cd = 2.4
        }
      }

      let urgent_now : Int = active_panic(groups)
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
        msg = "Ferry destroyed"
        msg_t = 3.0
      } else if harbor_queue >= harbor_queue_max - 2.0 {
        state = 3
        msg = "Harbor overwhelmed"
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

    draw_water(world_x, world_y, world_w, world_h, scene_t)
    draw_harbor(harbor_x, harbor_y, harbor_w, harbor_h)
    draw_debris(debris, scene_t)
    draw_docks(docks, scene_t)
    draw_groups(groups, scene_t)
    draw_fogs(fogs, scene_t)
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
      "FOG FERRY RESCUE",
      panel_x + 16,
      36,
      34,
      @raylib.Color::new(236, 246, 255, 252),
    )
    @raylib.draw_text(
      "Search, rescue, and ferry under low visibility",
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
      "Rescued",
      panel_x + 16,
      154,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{rescued_total}/\{target_rescued}",
      panel_x + 132,
      154,
      30,
      @raylib.Color::new(138, 228, 164, 252),
    )

    @raylib.draw_text(
      "Lost",
      panel_x + 16,
      190,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{lost_people}/\{lost_limit}",
      panel_x + 88,
      190,
      30,
      @raylib.Color::new(246, 150, 164, 252),
    )

    @raylib.draw_text(
      "Tier",
      panel_x + 240,
      190,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{tier}",
      panel_x + 298,
      190,
      30,
      @raylib.Color::new(248, 212, 130, 252),
    )

    @raylib.draw_text(
      "Onboard",
      panel_x + 16,
      226,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{player.passengers}/\{player.capacity}",
      panel_x + 114,
      226,
      30,
      @raylib.Color::new(206, 232, 252, 252),
    )

    @raylib.draw_text(
      "Harbor load",
      panel_x + 16,
      262,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{harbor_queue.to_int()}",
      panel_x + 142,
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
      "Active groups",
      panel_x + 16,
      334,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{active_groups(groups)}",
      panel_x + 152,
      334,
      30,
      @raylib.Color::new(246, 196, 150, 248),
    )

    @raylib.draw_text(
      "Urgent groups",
      panel_x + 16,
      370,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{active_panic(groups)}",
      panel_x + 152,
      370,
      30,
      @raylib.Color::new(246, 196, 150, 248),
    )

    @raylib.draw_text(
      "Panic peak",
      panel_x + 236,
      370,
      24,
      @raylib.Color::new(214, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{peak_group_panic(groups).to_int()}",
      panel_x + 334,
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
      "Fuel",
      player.fuel,
      player.fuel_max,
      @raylib.Color::new(126, 206, 252, 252),
    )
    draw_bar(
      panel_x,
      562,
      "Harbor Capacity",
      harbor_queue,
      harbor_queue_max,
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
      "L / U : rescue nearby",
      panel_x + 16,
      734,
      22,
      @raylib.Color::new(198, 220, 252, 236),
    )
    @raylib.draw_text(
      "K / H : ping urgent group",
      panel_x + 16,
      760,
      22,
      @raylib.Color::new(198, 220, 252, 236),
    )
    @raylib.draw_text(
      "Mobile: d-pad + BOOST/RESCUE/PING",
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
        "FOG FERRY RESCUE",
        sw / 2 - 350,
        150,
        82,
        @raylib.Color::new(236, 246, 255, 255),
      )
      @raylib.draw_text(
        "Maritime SAR operations",
        sw / 2 - 180,
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
        "- Pick up stranded groups and unload at safe harbor",
        sw / 2 - 486,
        382,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Dense fog weakens control and burns extra fuel",
        sw / 2 - 486,
        418,
        29,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Avoid debris impacts and dock overflows",
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
        "- Harbor queue overload or ferry destroyed",
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
      draw_button(sw / 2 - 210, 638, 420, 94, "START RESCUE", hover)
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 24, 14, 206))
      @raylib.draw_text(
        "SEA LANE SECURED",
        sw / 2 - 304,
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
