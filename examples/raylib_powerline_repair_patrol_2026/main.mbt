///|
struct PatrolCraft {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut heading : Float
  mut battery : Float
  battery_max : Float
  mut hull : Float
  hull_max : Float
  mut wire : Int
  mut fuse : Int
  wire_cap : Int
  fuse_cap : Int
  mut action_cd : Float
  mut pulse_cd : Float
  mut pulse_t : Float
  mut boost_heat : Float
  mut step_t : Float
}

///|
struct Depot {
  x : Float
  y : Float
  w : Float
  h : Float
}

///|
struct Substation {
  x : Float
  y : Float
  w : Float
  h : Float
}

///|
struct Tower {
  mut x : Float
  mut y : Float
  id : Int
  mut stress : Float
  mut alarm_t : Float
}

///|
struct Fault {
  mut active : Bool
  mut id : Int
  mut tower_id : Int
  mut severity : Int
  mut deadline : Float
  mut max_deadline : Float
  mut need_wire : Int
  mut need_fuse : Int
  mut reward : Int
  mut pulse : Float
}

///|
struct WindTunnel {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut vx : Float
  mut vy : Float
  mut turbulence : Float
  mut pulse : Float
}

///|
struct StormCell {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut radius : Float
  mut intensity : Float
  mut life : Float
  mut pulse : Float
}

///|
struct SupplyDrop {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut kind : Int
  mut amount : Int
  mut life : Float
  mut pulse : Float
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
fn maxi(a : Int, b : Int) -> Int {
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
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
fn inside_rectf(
  px : Float,
  py : Float,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
) -> Bool {
  px >= x && px <= x + w && py >= y && py <= y + h
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
fn pointer_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  let mut hit : Bool = false

  if mouse_hold && inside_rect(mouse_x, mouse_y, x, y, w, h) {
    hit = true
  }

  if not(hit) {
    for i = 0; i < touch_count; i = i + 1 {
      let p = @raylib.get_touch_position(i)
      if inside_rect(p.x, p.y, x, y, w, h) {
        hit = true
      }
    }
  }

  hit
}

///|
fn pointer_on_circle(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
  cx : Float,
  cy : Float,
  r : Float,
) -> Bool {
  let mut hit : Bool = false

  if mouse_hold && dist2(mouse_x, mouse_y, cx, cy) <= r * r {
    hit = true
  }

  if not(hit) {
    for i = 0; i < touch_count; i = i + 1 {
      let p = @raylib.get_touch_position(i)
      if dist2(p.x, p.y, cx, cy) <= r * r {
        hit = true
      }
    }
  }

  hit
}

///|
fn clear_faults(faults : Array[Fault]) -> Unit {
  for i = 0; i < faults.length(); i = i + 1 {
    faults[i].active = false
    faults[i].id = i + 1
    faults[i].tower_id = 0
    faults[i].severity = 1
    faults[i].deadline = 0.0
    faults[i].max_deadline = 0.0
    faults[i].need_wire = 0
    faults[i].need_fuse = 0
    faults[i].reward = 0
    faults[i].pulse = 0.0
  }
}

///|
fn clear_winds(winds : Array[WindTunnel]) -> Unit {
  for i = 0; i < winds.length(); i = i + 1 {
    winds[i].active = false
    winds[i].x = 0.0
    winds[i].y = 0.0
    winds[i].w = 0.0
    winds[i].h = 0.0
    winds[i].vx = 0.0
    winds[i].vy = 0.0
    winds[i].turbulence = 0.0
    winds[i].pulse = 0.0
  }
}

///|
fn clear_storms(storms : Array[StormCell]) -> Unit {
  for i = 0; i < storms.length(); i = i + 1 {
    storms[i].active = false
    storms[i].x = 0.0
    storms[i].y = 0.0
    storms[i].vx = 0.0
    storms[i].vy = 0.0
    storms[i].radius = 0.0
    storms[i].intensity = 0.0
    storms[i].life = 0.0
    storms[i].pulse = 0.0
  }
}

///|
fn clear_drops(drops : Array[SupplyDrop]) -> Unit {
  for i = 0; i < drops.length(); i = i + 1 {
    drops[i].active = false
    drops[i].x = 0.0
    drops[i].y = 0.0
    drops[i].vx = 0.0
    drops[i].vy = 0.0
    drops[i].kind = 0
    drops[i].amount = 0
    drops[i].life = 0.0
    drops[i].pulse = 0.0
  }
}

///|
fn clear_particles(parts : Array[Particle]) -> Unit {
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
fn spawn_particle(
  parts : Array[Particle],
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if parts[i].active {
      continue
    }

    parts[i].active = true
    parts[i].x = x
    parts[i].y = y
    parts[i].vx = vx
    parts[i].vy = vy
    parts[i].life = life
    parts[i].size = size
    parts[i].kind = kind
    break
  }
}

///|
fn burst_particles(
  parts : Array[Particle],
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    spawn_particle(
      parts,
      x + randf(-8.0, 8.0),
      y + randf(-8.0, 8.0),
      randf(-140.0, 140.0),
      randf(-150.0, 130.0),
      randf(0.28, 0.96),
      randf(2.0, 6.0),
      kind,
    )
  }
}

///|
fn update_particles(parts : Array[Particle], dt : Float) -> Unit {
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
    parts[i].vx = parts[i].vx * (1.0 - dt * 1.9)
    parts[i].vy = parts[i].vy * (1.0 - dt * 1.9) + dt * 26.0
  }
}

///|
fn init_towers(
  towers : Array[Tower],
  world_l : Float,
  world_t : Float,
  world_w : Float,
  world_h : Float,
) -> Unit {
  if towers.length() < 10 {
    return
  }

  towers[0].x = world_l + 220.0
  towers[0].y = world_t + 110.0
  towers[1].x = world_l + 450.0
  towers[1].y = world_t + 150.0
  towers[2].x = world_l + 730.0
  towers[2].y = world_t + 120.0
  towers[3].x = world_l + 1010.0
  towers[3].y = world_t + 190.0
  towers[4].x = world_l + 1240.0
  towers[4].y = world_t + 130.0

  towers[5].x = world_l + 260.0
  towers[5].y = world_t + world_h - 230.0
  towers[6].x = world_l + 520.0
  towers[6].y = world_t + world_h - 180.0
  towers[7].x = world_l + 800.0
  towers[7].y = world_t + world_h - 250.0
  towers[8].x = world_l + 1060.0
  towers[8].y = world_t + world_h - 170.0
  towers[9].x = world_l + 1310.0
  towers[9].y = world_t + world_h - 220.0

  for i = 0; i < towers.length(); i = i + 1 {
    towers[i].stress = randf(0.0, 0.6)
    towers[i].alarm_t = 0.0
  }
}

///|
fn init_winds(
  winds : Array[WindTunnel],
  world_l : Float,
  world_t : Float,
  world_w : Float,
  world_h : Float,
) -> Unit {
  clear_winds(winds)

  if winds.length() < 7 {
    return
  }

  winds[0].active = true
  winds[0].x = world_l + 160.0
  winds[0].y = world_t + 180.0
  winds[0].w = 220.0
  winds[0].h = 120.0
  winds[0].vx = 88.0
  winds[0].vy = -20.0
  winds[0].turbulence = 0.36
  winds[0].pulse = randf(0.0, 10.0)

  winds[1].active = true
  winds[1].x = world_l + world_w - 420.0
  winds[1].y = world_t + 190.0
  winds[1].w = 260.0
  winds[1].h = 120.0
  winds[1].vx = -108.0
  winds[1].vy = 28.0
  winds[1].turbulence = 0.44
  winds[1].pulse = randf(0.0, 10.0)

  winds[2].active = true
  winds[2].x = world_l + 440.0
  winds[2].y = world_t + 390.0
  winds[2].w = 220.0
  winds[2].h = 130.0
  winds[2].vx = 0.0
  winds[2].vy = -96.0
  winds[2].turbulence = 0.35
  winds[2].pulse = randf(0.0, 10.0)

  winds[3].active = true
  winds[3].x = world_l + world_w - 700.0
  winds[3].y = world_t + 400.0
  winds[3].w = 230.0
  winds[3].h = 130.0
  winds[3].vx = 0.0
  winds[3].vy = 104.0
  winds[3].turbulence = 0.4
  winds[3].pulse = randf(0.0, 10.0)

  winds[4].active = true
  winds[4].x = world_l + 210.0
  winds[4].y = world_t + world_h - 220.0
  winds[4].w = 260.0
  winds[4].h = 116.0
  winds[4].vx = 118.0
  winds[4].vy = -18.0
  winds[4].turbulence = 0.43
  winds[4].pulse = randf(0.0, 10.0)

  winds[5].active = true
  winds[5].x = world_l + world_w - 480.0
  winds[5].y = world_t + world_h - 230.0
  winds[5].w = 240.0
  winds[5].h = 112.0
  winds[5].vx = -116.0
  winds[5].vy = 16.0
  winds[5].turbulence = 0.38
  winds[5].pulse = randf(0.0, 10.0)

  winds[6].active = true
  winds[6].x = world_l + world_w * 0.44
  winds[6].y = world_t + 84.0
  winds[6].w = 176.0
  winds[6].h = world_h - 180.0
  winds[6].vx = 16.0
  winds[6].vy = 86.0
  winds[6].turbulence = 0.46
  winds[6].pulse = randf(0.0, 10.0)
}

///|
fn tower_has_fault(faults : Array[Fault], tower_id : Int) -> Bool {
  let mut out : Bool = false
  for i = 0; i < faults.length(); i = i + 1 {
    if faults[i].active && faults[i].tower_id == tower_id {
      out = true
    }
  }
  out
}

///|
fn spawn_fault(
  faults : Array[Fault],
  towers : Array[Tower],
  wave : Int,
  serial : Int,
) -> Bool {
  let mut placed : Bool = false

  for i = 0; i < faults.length(); i = i + 1 {
    if faults[i].active {
      continue
    }

    let mut tower_id : Int = randi(0, towers.length() - 1)
    let mut tries : Int = 0
    while tower_has_fault(faults, tower_id) && tries < 10 {
      tower_id = randi(0, towers.length() - 1)
      tries = tries + 1
    }

    if tower_has_fault(faults, tower_id) {
      continue
    }

    let sev : Int = if randi(0, 99) < 50 {
      1
    } else if randi(0, 99) < 82 {
      2
    } else {
      3
    }

    let base_deadline : Float = if sev == 1 {
      randf(38.0, 72.0)
    } else if sev == 2 {
      randf(30.0, 58.0)
    } else {
      randf(24.0, 46.0)
    }

    let deadline : Float = maxf(
      16.0,
      base_deadline - Float::from_int(wave) * 1.4,
    )

    faults[i].active = true
    faults[i].id = serial
    faults[i].tower_id = tower_id
    faults[i].severity = sev
    faults[i].deadline = deadline
    faults[i].max_deadline = deadline
    faults[i].need_wire = if sev == 1 { 1 } else if sev == 2 { 2 } else { 3 }
    faults[i].need_fuse = if sev == 1 { 1 } else if sev == 2 { 1 } else { 2 }
    faults[i].reward = 120 + sev * 36 + wave * 8
    faults[i].pulse = randf(0.0, 12.0)

    towers[tower_id].alarm_t = 1.6
    towers[tower_id].stress = clampf(
      towers[tower_id].stress + 0.5 + Float::from_int(sev) * 0.3,
      0.0,
      4.0,
    )

    placed = true
    break
  }

  placed
}

///|
fn spawn_storm_cell(
  storms : Array[StormCell],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  pressure : Float,
) -> Bool {
  let mut placed : Bool = false

  for i = 0; i < storms.length(); i = i + 1 {
    if storms[i].active {
      continue
    }

    let edge : Int = randi(0, 3)
    if edge == 0 {
      storms[i].x = world_l - 24.0
      storms[i].y = randf(world_t + 60.0, world_b - 60.0)
      storms[i].vx = randf(42.0, 110.0)
      storms[i].vy = randf(-40.0, 40.0)
    } else if edge == 1 {
      storms[i].x = world_r + 24.0
      storms[i].y = randf(world_t + 60.0, world_b - 60.0)
      storms[i].vx = -randf(42.0, 110.0)
      storms[i].vy = randf(-40.0, 40.0)
    } else if edge == 2 {
      storms[i].x = randf(world_l + 60.0, world_r - 60.0)
      storms[i].y = world_t - 24.0
      storms[i].vx = randf(-48.0, 48.0)
      storms[i].vy = randf(46.0, 118.0)
    } else {
      storms[i].x = randf(world_l + 60.0, world_r - 60.0)
      storms[i].y = world_b + 24.0
      storms[i].vx = randf(-48.0, 48.0)
      storms[i].vy = -randf(46.0, 118.0)
    }

    storms[i].active = true
    storms[i].radius = randf(52.0, 112.0)
    storms[i].intensity = randf(0.6, 1.8) + pressure * randf(0.3, 0.9)
    storms[i].life = randf(7.0, 14.0)
    storms[i].pulse = randf(0.0, 10.0)

    placed = true
    break
  }

  placed
}

///|
fn spawn_drop(
  drops : Array[SupplyDrop],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
) -> Bool {
  let mut placed : Bool = false

  for i = 0; i < drops.length(); i = i + 1 {
    if drops[i].active {
      continue
    }

    drops[i].active = true
    drops[i].x = randf(world_l + 110.0, world_r - 110.0)
    drops[i].y = randf(world_t + 100.0, world_b - 100.0)
    drops[i].vx = randf(-18.0, 18.0)
    drops[i].vy = randf(-18.0, 18.0)
    drops[i].kind = randi(0, 2)
    drops[i].amount = if drops[i].kind == 0 {
      randi(1, 3)
    } else if drops[i].kind == 1 {
      randi(1, 2)
    } else {
      randi(8, 20)
    }
    drops[i].life = randf(14.0, 24.0)
    drops[i].pulse = randf(0.0, 8.0)

    placed = true
    break
  }

  placed
}

///|
fn nearest_fault_index(
  faults : Array[Fault],
  towers : Array[Tower],
  x : Float,
  y : Float,
  radius : Float,
) -> Int {
  let mut found : Int = -1
  let mut best : Float = radius * radius

  for i = 0; i < faults.length(); i = i + 1 {
    if not(faults[i].active) {
      continue
    }

    let tid : Int = faults[i].tower_id
    let d2v : Float = dist2(x, y, towers[tid].x, towers[tid].y)
    if d2v <= best {
      best = d2v
      found = i
    }
  }

  found
}

///|
fn draw_sky_background(
  world_x : Int,
  world_y : Int,
  world_w : Int,
  world_h : Int,
  scene_t : Float,
) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    world_x,
    world_y,
    world_w,
    world_h,
    @raylib.Color::new(26, 52, 90, 255),
    @raylib.Color::new(14, 24, 46, 255),
  )

  for i = 0; i < 24; i = i + 1 {
    let y0 : Float = Float::from_int(world_y) +
      Float::from_int(i) * Float::from_int(world_h) / 24.0
    let wave : Float = sinf(scene_t * 1.5 + Float::from_int(i) * 0.42) * 0.5 +
      0.5
    let alpha : Int = 12 + (wave * 22.0).to_int()
    @raylib.draw_rectangle(
      world_x,
      y0.to_int(),
      world_w,
      2,
      @raylib.Color::new(84, 138, 198, alpha),
    )
  }
}

///|
fn draw_city_blocks(
  world_x : Int,
  world_y : Int,
  world_h : Int,
  scene_t : Float,
) -> Unit {
  let base_y : Int = world_y + world_h - 36
  for i = 0; i < 24; i = i + 1 {
    let bw : Int = 42 + i % 4 * 16
    let bh : Int = 62 + i * 9 % 7 * 20
    let bx : Int = world_x + i * 66 - 14
    let by : Int = base_y - bh

    @raylib.draw_rectangle(bx, by, bw, bh, @raylib.Color::new(24, 30, 44, 226))

    for j = 0; j < 3; j = j + 1 {
      let wx : Int = bx + 6 + j * 12
      let mut wy : Int = by + 8
      while wy < by + bh - 8 {
        let blink : Float = sinf(
            scene_t * 2.8 +
            Float::from_int(i * 5 + j) * 0.7 +
            Float::from_int(wy) * 0.03,
          ) *
          0.5 +
          0.5
        @raylib.draw_rectangle(
          wx,
          wy,
          7,
          8,
          if blink > 0.45 {
            @raylib.Color::new(246, 210, 122, 194)
          } else {
            @raylib.Color::new(52, 60, 78, 120)
          },
        )
        wy = wy + 14
      }
    }
  }
}

///|
fn draw_depot(depot : Depot, scene_t : Float) -> Unit {
  @raylib.draw_rectangle(
    depot.x.to_int(),
    depot.y.to_int(),
    depot.w.to_int(),
    depot.h.to_int(),
    @raylib.Color::new(34, 66, 72, 232),
  )
  @raylib.draw_rectangle_lines(
    depot.x.to_int(),
    depot.y.to_int(),
    depot.w.to_int(),
    depot.h.to_int(),
    @raylib.Color::new(156, 242, 214, 220),
  )
  @raylib.draw_text(
    "SUPPLY DEPOT",
    depot.x.to_int() + 16,
    depot.y.to_int() + 16,
    22,
    @raylib.Color::new(236, 252, 242, 238),
  )

  let pulse : Float = sinf(scene_t * 3.4) * 0.5 + 0.5
  @raylib.draw_circle_v(
    @raylib.Vector2::new(depot.x + depot.w * 0.5, depot.y + depot.h * 0.5),
    20.0 + pulse * 8.0,
    @raylib.Color::new(182, 248, 228, 72),
  )
}

///|
fn draw_substation(substation : Substation, scene_t : Float) -> Unit {
  @raylib.draw_rectangle(
    substation.x.to_int(),
    substation.y.to_int(),
    substation.w.to_int(),
    substation.h.to_int(),
    @raylib.Color::new(38, 54, 78, 232),
  )
  @raylib.draw_rectangle_lines(
    substation.x.to_int(),
    substation.y.to_int(),
    substation.w.to_int(),
    substation.h.to_int(),
    @raylib.Color::new(166, 212, 252, 220),
  )
  @raylib.draw_text(
    "SUBSTATION",
    substation.x.to_int() + 16,
    substation.y.to_int() + 16,
    22,
    @raylib.Color::new(232, 244, 255, 236),
  )

  let pulse : Float = sinf(scene_t * 4.0 + 2.0) * 0.5 + 0.5
  @raylib.draw_circle_v(
    @raylib.Vector2::new(
      substation.x + substation.w * 0.5,
      substation.y + substation.h * 0.5,
    ),
    18.0 + pulse * 7.0,
    @raylib.Color::new(188, 220, 252, 66),
  )
}

///|
fn draw_power_lines(
  towers : Array[Tower],
  faults : Array[Fault],
  scene_t : Float,
) -> Unit {
  fn edge_fault_level(faults : Array[Fault], a : Int, b : Int) -> Float {
    let mut v : Float = 0.0
    for i = 0; i < faults.length(); i = i + 1 {
      if not(faults[i].active) {
        continue
      }
      let t : Int = faults[i].tower_id
      if t == a || t == b {
        v = v + Float::from_int(faults[i].severity)
      }
    }
    v
  }

  fn draw_edge(
    towers : Array[Tower],
    faults : Array[Fault],
    a : Int,
    b : Int,
    scene_t : Float,
  ) -> Unit {
    let level : Float = edge_fault_level(faults, a, b)
    let pulse : Float = sinf(scene_t * 6.0 + Float::from_int(a * 3 + b) * 0.4) *
      0.5 +
      0.5

    let col = if level > 0.0 {
      @raylib.Color::new(252, 160, 116, 150 + (pulse * 70.0).to_int())
    } else {
      @raylib.Color::new(132, 206, 250, 120 + (pulse * 36.0).to_int())
    }

    @raylib.draw_line_ex(
      @raylib.Vector2::new(towers[a].x, towers[a].y),
      @raylib.Vector2::new(towers[b].x, towers[b].y),
      3.2,
      col,
    )
  }

  draw_edge(towers, faults, 0, 1, scene_t)
  draw_edge(towers, faults, 1, 2, scene_t)
  draw_edge(towers, faults, 2, 3, scene_t)
  draw_edge(towers, faults, 3, 4, scene_t)
  draw_edge(towers, faults, 5, 6, scene_t)
  draw_edge(towers, faults, 6, 7, scene_t)
  draw_edge(towers, faults, 7, 8, scene_t)
  draw_edge(towers, faults, 8, 9, scene_t)
  draw_edge(towers, faults, 1, 6, scene_t)
  draw_edge(towers, faults, 2, 7, scene_t)
  draw_edge(towers, faults, 3, 8, scene_t)
}

///|
fn draw_towers(
  towers : Array[Tower],
  faults : Array[Fault],
  scene_t : Float,
) -> Unit {
  for i = 0; i < towers.length(); i = i + 1 {
    let mut has_fault : Bool = false
    let mut sev_sum : Int = 0

    for j = 0; j < faults.length(); j = j + 1 {
      if faults[j].active && faults[j].tower_id == towers[i].id {
        has_fault = true
        sev_sum = sev_sum + faults[j].severity
      }
    }

    @raylib.draw_rectangle(
      (towers[i].x - 8.0).to_int(),
      (towers[i].y - 56.0).to_int(),
      16,
      112,
      @raylib.Color::new(64, 70, 84, 236),
    )

    @raylib.draw_line_ex(
      @raylib.Vector2::new(towers[i].x - 20.0, towers[i].y - 34.0),
      @raylib.Vector2::new(towers[i].x + 20.0, towers[i].y - 34.0),
      3.0,
      @raylib.Color::new(124, 144, 170, 236),
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(towers[i].x - 24.0, towers[i].y - 10.0),
      @raylib.Vector2::new(towers[i].x + 24.0, towers[i].y - 10.0),
      3.0,
      @raylib.Color::new(124, 144, 170, 236),
    )

    @raylib.draw_circle_v(
      @raylib.Vector2::new(towers[i].x, towers[i].y - 58.0),
      5.0,
      if has_fault {
        @raylib.Color::new(252, 148, 118, 236)
      } else {
        @raylib.Color::new(132, 210, 252, 220)
      },
    )

    if has_fault {
      let pulse : Float = sinf(scene_t * 9.0 + Float::from_int(i) * 0.8) * 0.5 +
        0.5
      @raylib.draw_circle_v(
        @raylib.Vector2::new(towers[i].x, towers[i].y - 58.0),
        9.0 + pulse * 5.0,
        @raylib.Color::new(255, 146, 122, 84),
      )

      @raylib.draw_text(
        "F\{sev_sum}",
        (towers[i].x - 12.0).to_int(),
        (towers[i].y - 88.0).to_int(),
        18,
        @raylib.Color::new(255, 210, 162, 240),
      )
    }
  }
}

///|
fn draw_winds(winds : Array[WindTunnel], scene_t : Float) -> Unit {
  for i = 0; i < winds.length(); i = i + 1 {
    if not(winds[i].active) {
      continue
    }

    let pulse : Float = sinf(scene_t * 5.8 + winds[i].pulse) * 0.5 + 0.5
    @raylib.draw_rectangle(
      winds[i].x.to_int(),
      winds[i].y.to_int(),
      winds[i].w.to_int(),
      winds[i].h.to_int(),
      @raylib.Color::new(86, 168, 240, 24 + (pulse * 40.0).to_int()),
    )

    @raylib.draw_rectangle_lines(
      winds[i].x.to_int(),
      winds[i].y.to_int(),
      winds[i].w.to_int(),
      winds[i].h.to_int(),
      @raylib.Color::new(114, 198, 252, 116),
    )

    let cx : Float = winds[i].x + winds[i].w * 0.5
    let cy : Float = winds[i].y + winds[i].h * 0.5
    let tip_x : Float = cx + winds[i].vx * 0.16
    let tip_y : Float = cy + winds[i].vy * 0.16
    @raylib.draw_line_ex(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(tip_x, tip_y),
      2.0,
      @raylib.Color::new(184, 232, 255, 156),
    )
  }
}

///|
fn draw_storms(storms : Array[StormCell], scene_t : Float) -> Unit {
  for i = 0; i < storms.length(); i = i + 1 {
    if not(storms[i].active) {
      continue
    }

    let pulse : Float = sinf(scene_t * 6.8 + storms[i].pulse) * 0.5 + 0.5
    let rr : Float = storms[i].radius * (0.86 + pulse * 0.2)

    @raylib.draw_circle_v(
      @raylib.Vector2::new(storms[i].x, storms[i].y),
      rr,
      @raylib.Color::new(
        126,
        184,
        248,
        34 + (storms[i].intensity * 42.0).to_int(),
      ),
    )
    @raylib.draw_circle_lines(
      storms[i].x.to_int(),
      storms[i].y.to_int(),
      rr,
      @raylib.Color::new(172, 220, 255, 122),
    )
  }
}

///|
fn draw_drops(drops : Array[SupplyDrop], scene_t : Float) -> Unit {
  for i = 0; i < drops.length(); i = i + 1 {
    if not(drops[i].active) {
      continue
    }

    let pulse : Float = sinf(scene_t * 5.2 + drops[i].pulse) * 0.5 + 0.5
    let col = if drops[i].kind == 0 {
      @raylib.Color::new(136, 230, 168, 228)
    } else if drops[i].kind == 1 {
      @raylib.Color::new(246, 178, 112, 228)
    } else {
      @raylib.Color::new(112, 198, 252, 228)
    }

    @raylib.draw_rectangle(
      (drops[i].x - 12.0).to_int(),
      (drops[i].y - 12.0).to_int(),
      24,
      24,
      col,
    )
    @raylib.draw_rectangle_lines(
      (drops[i].x - 12.0).to_int(),
      (drops[i].y - 12.0).to_int(),
      24,
      24,
      @raylib.Color::new(248, 252, 255, 228),
    )

    @raylib.draw_circle_v(
      @raylib.Vector2::new(drops[i].x, drops[i].y),
      18.0 + pulse * 7.0,
      @raylib.Color::new(236, 248, 255, (pulse * 84.0).to_int()),
    )

    @raylib.draw_text(
      "\{drops[i].amount}",
      (drops[i].x - 6.0).to_int(),
      (drops[i].y - 8.0).to_int(),
      18,
      @raylib.Color::new(20, 24, 30, 240),
    )
  }
}

///|
fn draw_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      continue
    }

    let a : Int = clampf(parts[i].life * 255.0, 0.0, 255.0).to_int()
    let c = if parts[i].kind == 0 {
      @raylib.Color::new(160, 226, 252, a)
    } else if parts[i].kind == 1 {
      @raylib.Color::new(252, 154, 120, a)
    } else {
      @raylib.Color::new(246, 236, 168, a)
    }
    @raylib.draw_circle_v(
      @raylib.Vector2::new(parts[i].x, parts[i].y),
      parts[i].size,
      c,
    )
  }
}

///|
fn draw_glider(glider : PatrolCraft, scene_t : Float) -> Unit {
  let bob : Float = sinf(scene_t * 11.0 + glider.step_t * 0.08) * 1.1

  @raylib.draw_triangle(
    @raylib.Vector2::new(glider.x + 23.0, glider.y + bob),
    @raylib.Vector2::new(glider.x - 18.0, glider.y - 14.0 + bob),
    @raylib.Vector2::new(glider.x - 18.0, glider.y + 14.0 + bob),
    @raylib.Color::new(250, 192, 116, 242),
  )

  @raylib.draw_triangle(
    @raylib.Vector2::new(glider.x + 10.0, glider.y + bob),
    @raylib.Vector2::new(glider.x - 11.0, glider.y - 8.0 + bob),
    @raylib.Vector2::new(glider.x - 11.0, glider.y + 8.0 + bob),
    @raylib.Color::new(236, 248, 255, 236),
  )

  @raylib.draw_circle_v(
    @raylib.Vector2::new(glider.x - 1.0, glider.y + bob),
    4.0,
    @raylib.Color::new(34, 38, 52, 242),
  )

  if glider.boost_heat > 0.01 {
    @raylib.draw_circle_v(
      @raylib.Vector2::new(glider.x - 20.0, glider.y + bob),
      8.0 + glider.boost_heat * 7.0,
      @raylib.Color::new(112, 202, 252, (glider.boost_heat * 180.0).to_int()),
    )
  }

  if glider.pulse_t > 0.0 {
    let pulse : Float = sinf(glider.pulse_t * 9.0) * 0.5 + 0.5
    @raylib.draw_circle_lines(
      glider.x.to_int(),
      glider.y.to_int(),
      78.0 + pulse * 72.0,
      @raylib.Color::new(250, 212, 126, 198),
    )
  }
}

///|
fn draw_faults_panel(
  panel_x : Int,
  panel_y : Int,
  panel_w : Int,
  faults : Array[Fault],
  scene_t : Float,
) -> Unit {
  @raylib.draw_text(
    "Fault Queue",
    panel_x + 18,
    panel_y + 384,
    30,
    @raylib.Color::new(236, 246, 255, 238),
  )

  let mut y : Int = panel_y + 426
  for i = 0; i < faults.length(); i = i + 1 {
    if not(faults[i].active) {
      continue
    }

    let urgency : Float = if faults[i].max_deadline <= 0.001 {
      0.0
    } else {
      clampf(1.0 - faults[i].deadline / faults[i].max_deadline, 0.0, 1.0)
    }

    let blink : Float = sinf(scene_t * 8.0 + faults[i].pulse) * 0.5 + 0.5
    let row_h : Int = 78

    @raylib.draw_rectangle(
      panel_x + 12,
      y,
      panel_w - 24,
      row_h,
      @raylib.Color::new(24, 30, 44, 236),
    )
    @raylib.draw_rectangle(
      panel_x + 14,
      y + 2,
      panel_w - 28,
      row_h - 4,
      @raylib.Color::new(44 + (urgency * 88.0).to_int(), 56, 72, 226),
    )
    @raylib.draw_rectangle_lines(
      panel_x + 12,
      y,
      panel_w - 24,
      row_h,
      @raylib.Color::new(188, 208, 234, 170),
    )

    @raylib.draw_text(
      "#\{faults[i].id} T\{faults[i].tower_id + 1} S\{faults[i].severity}",
      panel_x + 24,
      y + 10,
      21,
      @raylib.Color::new(236, 246, 255, 236),
    )
    @raylib.draw_text(
      "Need W\{faults[i].need_wire} F\{faults[i].need_fuse}  +\{faults[i].reward}",
      panel_x + 24,
      y + 38,
      18,
      @raylib.Color::new(248, 226, 138, 232),
    )

    let dd_txt : String = "\{faults[i].deadline.to_int()}s"
    @raylib.draw_text(
      dd_txt,
      panel_x + panel_w - 24 - @raylib.measure_text(dd_txt, 22),
      y + 10,
      22,
      if urgency > 0.72 {
        @raylib.Color::new(252, 140, 120, 246)
      } else {
        @raylib.Color::new(214, 232, 250, 232)
      },
    )

    @raylib.draw_rectangle(
      panel_x + panel_w - 188,
      y + 44,
      160,
      14,
      @raylib.Color::new(20, 22, 30, 232),
    )
    @raylib.draw_rectangle(
      panel_x + panel_w - 186,
      y + 46,
      (Float::from_int(156) * (1.0 - urgency)).to_int(),
      10,
      @raylib.Color::new(124, 228, 154, 200 + (blink * 44.0).to_int()),
    )
    @raylib.draw_rectangle_lines(
      panel_x + panel_w - 188,
      y + 44,
      160,
      14,
      @raylib.Color::new(210, 224, 244, 182),
    )

    y = y + row_h + 8
    if y > panel_y + 814 {
      break
    }
  }
}

///|
fn draw_hud(
  panel_x : Int,
  panel_y : Int,
  panel_w : Int,
  panel_h : Int,
  timer : Float,
  score : Int,
  target : Int,
  grid_health : Float,
  hull : Float,
  fuel : Float,
  wire : Int,
  fuse : Int,
  combo : Int,
  fixed : Int,
  failed : Int,
  msg : String,
) -> Unit {
  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(16, 22, 34, 248),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(166, 188, 214, 194),
  )

  @raylib.draw_text(
    "POWERLINE REPAIR PATROL 2026",
    panel_x + 18,
    panel_y + 16,
    30,
    @raylib.Color::new(236, 246, 255, 242),
  )

  let mm : Int = timer.to_int() / 60
  let ss : Int = timer.to_int() % 60
  let ss_txt : String = if ss < 10 { "0\{ss}" } else { "\{ss}" }

  @raylib.draw_text(
    "Time \{mm}:\{ss_txt}",
    panel_x + 20,
    panel_y + 52,
    28,
    @raylib.Color::new(236, 246, 255, 236),
  )
  @raylib.draw_text(
    "Score \{score}/\{target}",
    panel_x + 20,
    panel_y + 86,
    26,
    @raylib.Color::new(248, 226, 138, 236),
  )
  @raylib.draw_text(
    "Combo x\{combo}  Fixed \{fixed}  Failed \{failed}",
    panel_x + 20,
    panel_y + 118,
    22,
    @raylib.Color::new(204, 226, 246, 232),
  )
  @raylib.draw_text(
    "Cargo W\{wire} F\{fuse}",
    panel_x + 20,
    panel_y + 146,
    22,
    @raylib.Color::new(176, 234, 188, 234),
  )

  fn meter(
    title : String,
    value : Float,
    max_value : Float,
    x : Int,
    y : Int,
    w : Int,
    h : Int,
    col : @raylib.Color,
  ) -> Unit {
    let p : Float = if max_value <= 0.001 {
      0.0
    } else {
      clampf(value / max_value, 0.0, 1.0)
    }
    @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(20, 26, 38, 240))
    @raylib.draw_rectangle(
      x + 2,
      y + 2,
      (Float::from_int(w - 4) * p).to_int(),
      h - 4,
      col,
    )
    @raylib.draw_rectangle_lines(
      x,
      y,
      w,
      h,
      @raylib.Color::new(222, 234, 248, 186),
    )
    @raylib.draw_text(
      title,
      x,
      y - 20,
      18,
      @raylib.Color::new(224, 238, 252, 232),
    )
  }

  meter(
    "Grid Health",
    grid_health,
    100.0,
    panel_x + 20,
    panel_y + 184,
    panel_w - 40,
    22,
    @raylib.Color::new(116, 224, 156, 232),
  )
  meter(
    "Hull",
    hull,
    100.0,
    panel_x + 20,
    panel_y + 232,
    panel_w - 40,
    22,
    @raylib.Color::new(246, 138, 112, 232),
  )
  meter(
    "Fuel",
    fuel,
    100.0,
    panel_x + 20,
    panel_y + 280,
    panel_w - 40,
    22,
    @raylib.Color::new(122, 200, 252, 232),
  )

  @raylib.draw_rectangle(
    panel_x + 14,
    panel_y + panel_h - 170,
    panel_w - 28,
    148,
    @raylib.Color::new(24, 30, 44, 236),
  )
  @raylib.draw_rectangle_lines(
    panel_x + 14,
    panel_y + panel_h - 170,
    panel_w - 28,
    148,
    @raylib.Color::new(116, 146, 182, 196),
  )

  @raylib.draw_text(
    "Controls",
    panel_x + 24,
    panel_y + panel_h - 160,
    24,
    @raylib.Color::new(236, 246, 255, 236),
  )
  @raylib.draw_text(
    "Move: WASD/Arrows\nBoost: Space/J\nAct: L/U\nPulse: K/H",
    panel_x + 24,
    panel_y + panel_h - 124,
    20,
    @raylib.Color::new(194, 218, 244, 230),
  )

  @raylib.draw_text(
    msg,
    panel_x + 20,
    panel_y + 332,
    20,
    @raylib.Color::new(252, 226, 160, 236),
  )
}

///|
fn draw_touch_controls(
  sw : Int,
  sh : Int,
  mouse_x : Float,
  mouse_y : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  let pad_x : Int = 28
  let pad_y : Int = sh - 210
  let cell : Int = 72

  let up = pointer_on_rect(
    mouse_x,
    mouse_y,
    hold,
    touch_count,
    pad_x + cell,
    pad_y,
    cell,
    cell,
  )
  let left = pointer_on_rect(
    mouse_x,
    mouse_y,
    hold,
    touch_count,
    pad_x,
    pad_y + cell,
    cell,
    cell,
  )
  let right = pointer_on_rect(
    mouse_x,
    mouse_y,
    hold,
    touch_count,
    pad_x + cell * 2,
    pad_y + cell,
    cell,
    cell,
  )
  let down = pointer_on_rect(
    mouse_x,
    mouse_y,
    hold,
    touch_count,
    pad_x + cell,
    pad_y + cell * 2,
    cell,
    cell,
  )

  fn pad(x : Int, y : Int, label : String, active : Bool) -> Unit {
    @raylib.draw_rectangle(
      x,
      y,
      cell - 4,
      cell - 4,
      if active {
        @raylib.Color::new(98, 176, 236, 182)
      } else {
        @raylib.Color::new(36, 52, 78, 134)
      },
    )
    @raylib.draw_rectangle_lines(
      x,
      y,
      cell - 4,
      cell - 4,
      @raylib.Color::new(186, 212, 236, 170),
    )
    @raylib.draw_text(
      label,
      x + (cell - 4) / 2 - @raylib.measure_text(label, 24) / 2,
      y + (cell - 4) / 2 - 12,
      24,
      @raylib.Color::new(236, 246, 255, 236),
    )
  }

  pad(pad_x + cell, pad_y, "W", up)
  pad(pad_x, pad_y + cell, "A", left)
  pad(pad_x + cell * 2, pad_y + cell, "D", right)
  pad(pad_x + cell, pad_y + cell * 2, "S", down)

  let boost_x : Float = Float::from_int(sw - 304)
  let boost_y : Float = Float::from_int(sh - 162)
  let action_x : Float = Float::from_int(sw - 188)
  let action_y : Float = Float::from_int(sh - 236)
  let pulse_x : Float = Float::from_int(sw - 96)
  let pulse_y : Float = Float::from_int(sh - 144)

  let boost = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, boost_x, boost_y, 56.0,
  )
  let action = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, action_x, action_y, 44.0,
  )
  let pulse = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, pulse_x, pulse_y, 42.0,
  )

  fn btn(
    x : Float,
    y : Float,
    r : Float,
    label : String,
    active : Bool,
    cr : Int,
    cg : Int,
    cb : Int,
  ) -> Unit {
    @raylib.draw_circle_v(
      @raylib.Vector2::new(x, y),
      r,
      if active {
        @raylib.Color::new(cr, cg, cb, 224)
      } else {
        @raylib.Color::new(cr, cg, cb, 132)
      },
    )
    @raylib.draw_circle_lines(
      x.to_int(),
      y.to_int(),
      r,
      @raylib.Color::new(226, 238, 250, 212),
    )
    @raylib.draw_text(
      label,
      (x - Float::from_int(@raylib.measure_text(label, 20) / 2)).to_int(),
      (y - 10.0).to_int(),
      20,
      @raylib.Color::new(246, 252, 255, 238),
    )
  }

  btn(boost_x, boost_y, 56.0, "BOOST", boost, 66, 170, 242)
  btn(action_x, action_y, 44.0, "ACT", action, 84, 208, 152)
  btn(pulse_x, pulse_y, 42.0, "PULSE", pulse, 250, 190, 106)
}

///|
fn draw_menu(sw : Int, sh : Int, scene_t : Float) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 16, 28, 255))

  for i = 0; i < 24; i = i + 1 {
    let yy : Float = Float::from_int(i) / 24.0
    let wave : Float = sinf(scene_t * 1.2 + yy * 6.0) * 0.5 + 0.5
    let alpha : Int = 18 + (wave * 44.0).to_int()
    @raylib.draw_rectangle(
      0,
      (yy * Float::from_int(sh)).to_int(),
      sw,
      sh / 24 + 2,
      @raylib.Color::new(30, 56, 94, alpha),
    )
  }

  @raylib.draw_text(
    "POWERLINE REPAIR PATROL 2026",
    sw / 2 - @raylib.measure_text("POWERLINE REPAIR PATROL 2026", 64) / 2,
    176,
    64,
    @raylib.Color::new(236, 246, 255, 246),
  )
  @raylib.draw_text(
    "Race between towers to repair line faults, stabilize the city grid, and survive roaming storm cells.",
    sw / 2 -
    @raylib.measure_text(
      "Race between towers to repair line faults, stabilize the city grid, and survive roaming storm cells.",
      28,
    ) /
    2,
    292,
    28,
    @raylib.Color::new(186, 212, 236, 236),
  )

  let pulse : Float = sinf(scene_t * 3.8) * 0.5 + 0.5
  let bw : Int = 476
  let bh : Int = 94
  let bx : Int = sw / 2 - bw / 2
  let by : Int = 468
  @raylib.draw_rectangle(
    bx,
    by,
    bw,
    bh,
    @raylib.Color::new(64, 132, 214, 148 + (pulse * 88.0).to_int()),
  )
  @raylib.draw_rectangle_lines(
    bx,
    by,
    bw,
    bh,
    @raylib.Color::new(224, 236, 252, 226),
  )
  @raylib.draw_text(
    "PRESS ENTER / TAP TO START",
    sw / 2 - @raylib.measure_text("PRESS ENTER / TAP TO START", 38) / 2,
    by + bh / 2 - 19,
    38,
    @raylib.Color::new(246, 252, 255, 246),
  )

  @raylib.draw_text(
    "Mobile: D-pad + BOOST + ACT + PULSE",
    sw / 2 - @raylib.measure_text("Mobile: D-pad + BOOST + ACT + PULSE", 24) / 2,
    620,
    24,
    @raylib.Color::new(182, 208, 236, 228),
  )
}

///|
fn draw_end(
  sw : Int,
  sh : Int,
  win : Bool,
  score : Int,
  target : Int,
  grid : Float,
  fixed : Int,
  failed : Int,
) -> Unit {
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 224))

  let title : String = if win { "GRID STABILIZED" } else { "GRID FAILURE" }
  @raylib.draw_text(
    title,
    sw / 2 - @raylib.measure_text(title, 80) / 2,
    206,
    80,
    if win {
      @raylib.Color::new(164, 246, 190, 246)
    } else {
      @raylib.Color::new(252, 148, 132, 246)
    },
  )

  @raylib.draw_text(
    "Score: \{score}/\{target}",
    sw / 2 - @raylib.measure_text("Score: \{score}/\{target}", 40) / 2,
    326,
    40,
    @raylib.Color::new(236, 246, 255, 242),
  )
  @raylib.draw_text(
    "Grid Health: \{grid.to_int()}%",
    sw / 2 - @raylib.measure_text("Grid Health: \{grid.to_int()}%", 34) / 2,
    376,
    34,
    @raylib.Color::new(216, 232, 250, 236),
  )
  @raylib.draw_text(
    "Fixed: \{fixed}  Failed: \{failed}",
    sw / 2 - @raylib.measure_text("Fixed: \{fixed}  Failed: \{failed}", 30) / 2,
    420,
    30,
    @raylib.Color::new(206, 224, 244, 232),
  )
  @raylib.draw_text(
    "Press Enter / R to patrol again",
    sw / 2 - @raylib.measure_text("Press Enter / R to patrol again", 32) / 2,
    528,
    32,
    @raylib.Color::new(244, 250, 255, 236),
  )
}

///|
fn main {
  let sw : Int = 1700
  let sh : Int = 960
  @raylib.init_window(sw, sh, "raylib [game] powerline repair patrol 2026")
  defer @raylib.close_window()
  @raylib.set_target_fps(120)

  let world_x : Int = 20
  let world_y : Int = 20
  let panel_w : Int = 460
  let world_w : Int = sw - panel_w - 40
  let world_h : Int = sh - 40

  let world_l : Float = Float::from_int(world_x)
  let world_t : Float = Float::from_int(world_y)
  let world_r : Float = Float::from_int(world_x + world_w)
  let world_b : Float = Float::from_int(world_y + world_h)

  let depot : Depot = {
    x: world_l + 46.0,
    y: world_b - 164.0,
    w: 220.0,
    h: 120.0,
  }

  let substation : Substation = {
    x: world_r - 274.0,
    y: world_b - 164.0,
    w: 220.0,
    h: 120.0,
  }

  let towers : Array[Tower] = Array::makei(10, fn(i) {
    { x: 0.0, y: 0.0, id: i, stress: 0.0, alarm_t: 0.0 }
  })

  let faults : Array[Fault] = Array::makei(18, fn(i) {
    {
      active: false,
      id: i + 1,
      tower_id: 0,
      severity: 1,
      deadline: 0.0,
      max_deadline: 0.0,
      need_wire: 0,
      need_fuse: 0,
      reward: 0,
      pulse: 0.0,
    }
  })

  let winds : Array[WindTunnel] = Array::makei(8, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      w: 0.0,
      h: 0.0,
      vx: 0.0,
      vy: 0.0,
      turbulence: 0.0,
      pulse: 0.0,
    }
  })

  let storms : Array[StormCell] = Array::makei(26, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      radius: 0.0,
      intensity: 0.0,
      life: 0.0,
      pulse: 0.0,
    }
  })

  let drops : Array[SupplyDrop] = Array::makei(18, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      kind: 0,
      amount: 0,
      life: 0.0,
      pulse: 0.0,
    }
  })

  let parts : Array[Particle] = Array::makei(1200, fn(_i) {
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

  let craft : PatrolCraft = {
    x: depot.x + depot.w * 0.5,
    y: depot.y + depot.h * 0.5,
    vx: 0.0,
    vy: 0.0,
    heading: 0.0,
    battery: 100.0,
    battery_max: 100.0,
    hull: 100.0,
    hull_max: 100.0,
    wire: 0,
    fuse: 0,
    wire_cap: 12,
    fuse_cap: 8,
    action_cd: 0.0,
    pulse_cd: 0.0,
    pulse_t: 0.0,
    boost_heat: 0.0,
    step_t: 0.0,
  }

  let mut state : Int = 0 // 0 menu 1 play 2 win 3 lose
  let mut timer : Float = 430.0
  let mut scene_t : Float = 0.0

  let mut score : Int = 0
  let mut score_target : Int = 9800
  let mut grid_health : Float = 92.0
  let mut combo : Int = 0
  let mut fixed_count : Int = 0
  let mut failed_count : Int = 0
  let mut failed_limit : Int = 24
  let mut wave : Int = 1

  let mut fault_serial : Int = 1
  let mut fault_spawn_cd : Float = 1.2
  let mut storm_spawn_cd : Float = 3.0
  let mut drop_spawn_cd : Float = 12.0

  let mut msg : String = ""
  let mut msg_t : Float = 0.0

  fn reset_run() -> Unit {
    init_towers(
      towers,
      world_l,
      world_t,
      Float::from_int(world_w),
      Float::from_int(world_h),
    )
    clear_faults(faults)
    init_winds(
      winds,
      world_l,
      world_t,
      Float::from_int(world_w),
      Float::from_int(world_h),
    )
    clear_storms(storms)
    clear_drops(drops)
    clear_particles(parts)

    craft.x = depot.x + depot.w * 0.5
    craft.y = depot.y + depot.h * 0.5
    craft.vx = 0.0
    craft.vy = 0.0
    craft.heading = 0.0
    craft.battery = 100.0
    craft.hull = 100.0
    craft.wire = 0
    craft.fuse = 0
    craft.action_cd = 0.0
    craft.pulse_cd = 0.0
    craft.pulse_t = 0.0
    craft.boost_heat = 0.0
    craft.step_t = 0.0

    timer = 430.0
    scene_t = 0.0
    score = 0
    score_target = 9800
    grid_health = 92.0
    combo = 0
    fixed_count = 0
    failed_count = 0
    failed_limit = 24
    wave = 1

    fault_serial = 1
    fault_spawn_cd = 1.2
    storm_spawn_cd = 3.0
    drop_spawn_cd = 12.0

    msg = "Load supplies at depot and repair tower faults."
    msg_t = 3.0
  }

  reset_run()
  state = 0

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }
    scene_t = scene_t + dt

    let mouse = @raylib.get_mouse_position()
    let click : Bool = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
    let hold : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    let mut touch_count : Int = @raylib.get_touch_point_count()
    if touch_count > 10 {
      touch_count = 10
    }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    if craft.action_cd > 0.0 {
      craft.action_cd = craft.action_cd - dt
      if craft.action_cd < 0.0 {
        craft.action_cd = 0.0
      }
    }
    if craft.pulse_cd > 0.0 {
      craft.pulse_cd = craft.pulse_cd - dt
      if craft.pulse_cd < 0.0 {
        craft.pulse_cd = 0.0
      }
    }
    if craft.pulse_t > 0.0 {
      craft.pulse_t = craft.pulse_t - dt
      if craft.pulse_t < 0.0 {
        craft.pulse_t = 0.0
      }
    }

    update_particles(parts, dt)

    if state == 0 {
      if click ||
        touch_count > 0 ||
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

      wave = 1 + score / 1100
      if wave > 12 {
        wave = 12
      }

      // Input
      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)

      let mut boost_hold : Bool = @raylib.is_key_down(@raylib.KeySpace) ||
        @raylib.is_key_down(@raylib.KeyJ)
      let mut action_press : Bool = @raylib.is_key_pressed(@raylib.KeyL) ||
        @raylib.is_key_pressed(@raylib.KeyU)
      let mut pulse_press : Bool = @raylib.is_key_pressed(@raylib.KeyK) ||
        @raylib.is_key_pressed(@raylib.KeyH)

      if pointer_on_rect(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          28 + 72,
          sh - 210,
          72,
          72,
        ) {
        move_u = true
      }
      if pointer_on_rect(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          28,
          sh - 210 + 72,
          72,
          72,
        ) {
        move_l = true
      }
      if pointer_on_rect(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          28 + 144,
          sh - 210 + 72,
          72,
          72,
        ) {
        move_r = true
      }
      if pointer_on_rect(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          28 + 72,
          sh - 210 + 144,
          72,
          72,
        ) {
        move_d = true
      }
      if pointer_on_circle(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          Float::from_int(sw - 304),
          Float::from_int(sh - 162),
          56.0,
        ) {
        boost_hold = true
      }
      if pointer_on_circle(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          Float::from_int(sw - 188),
          Float::from_int(sh - 236),
          44.0,
        ) {
        action_press = true
      }
      if pointer_on_circle(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          Float::from_int(sw - 96),
          Float::from_int(sh - 144),
          42.0,
        ) {
        pulse_press = true
      }

      let mut input_x : Float = 0.0
      let mut input_y : Float = 0.0
      if move_l {
        input_x = input_x - 1.0
      }
      if move_r {
        input_x = input_x + 1.0
      }
      if move_u {
        input_y = input_y - 1.0
      }
      if move_d {
        input_y = input_y + 1.0
      }

      let norm : Float = (input_x * input_x + input_y * input_y).sqrt()
      if norm > 0.001 {
        input_x = input_x / norm
        input_y = input_y / norm
      }

      let mut accel : Float = 360.0
      let mut battery_drain : Float = 1.2
      if boost_hold && craft.battery > 0.4 {
        accel = 560.0
        battery_drain = battery_drain + 6.8
        craft.boost_heat = clampf(craft.boost_heat + dt * 0.9, 0.0, 1.0)
      } else {
        craft.boost_heat = clampf(craft.boost_heat - dt * 1.0, 0.0, 1.0)
      }

      craft.vx = craft.vx + input_x * accel * dt
      craft.vy = craft.vy + input_y * accel * dt

      let mut wind_penalty : Float = 0.0
      for i = 0; i < winds.length(); i = i + 1 {
        if not(winds[i].active) {
          continue
        }
        winds[i].pulse = winds[i].pulse + dt * 2.8

        if inside_rectf(
            craft.x,
            craft.y,
            winds[i].x,
            winds[i].y,
            winds[i].w,
            winds[i].h,
          ) {
          let wave_mul : Float = 0.72 +
            (sinf(winds[i].pulse) * 0.5 + 0.5) * 0.62
          craft.vx = craft.vx + winds[i].vx * dt * wave_mul
          craft.vy = craft.vy + winds[i].vy * dt * wave_mul
          wind_penalty = wind_penalty +
            winds[i].turbulence * (0.7 + wave_mul * 0.5)

          if winds[i].turbulence > 0.42 {
            craft.hull = craft.hull - dt * (winds[i].turbulence - 0.36) * 1.4
          }
        }
      }

      craft.vx = craft.vx * (1.0 - dt * (2.4 + wind_penalty * 0.35))
      craft.vy = craft.vy * (1.0 - dt * (2.4 + wind_penalty * 0.35))

      let speed : Float = (craft.vx * craft.vx + craft.vy * craft.vy).sqrt()
      let boost_bonus : Float = if boost_hold { 130.0 } else { 0.0 }
      let max_speed : Float = 300.0 + boost_bonus
      if speed > max_speed {
        let k : Float = max_speed / speed
        craft.vx = craft.vx * k
        craft.vy = craft.vy * k
      }

      craft.x = craft.x + craft.vx * dt
      craft.y = craft.y + craft.vy * dt
      if speed > 6.0 {
        craft.step_t = craft.step_t + dt * speed
      }

      if craft.x < world_l + 16.0 {
        craft.x = world_l + 16.0
        craft.vx = absf(craft.vx) * 0.32
      }
      if craft.x > world_r - 16.0 {
        craft.x = world_r - 16.0
        craft.vx = -absf(craft.vx) * 0.32
      }
      if craft.y < world_t + 16.0 {
        craft.y = world_t + 16.0
        craft.vy = absf(craft.vy) * 0.32
      }
      if craft.y > world_b - 16.0 {
        craft.y = world_b - 16.0
        craft.vy = -absf(craft.vy) * 0.32
      }

      craft.battery = craft.battery -
        dt * (battery_drain + speed * 0.003 + wind_penalty)
      craft.battery = clampf(craft.battery, 0.0, craft.battery_max)

      if craft.battery <= 0.0 {
        craft.vx = craft.vx * (1.0 - dt * 1.0)
        craft.vy = craft.vy * (1.0 - dt * 1.0)
      }

      // pulse ability
      if pulse_press && craft.pulse_cd <= 0.0 && craft.battery >= 8.0 {
        craft.pulse_t = 3.8
        craft.pulse_cd = 9.0
        craft.battery = craft.battery - 8.0
        msg = "Grid pulse fired: storms weakened and fault timers extended."
        msg_t = 1.2
        burst_particles(parts, craft.x, craft.y, 18, 2)

        for i = 0; i < faults.length(); i = i + 1 {
          if not(faults[i].active) {
            continue
          }
          if dist2(
              craft.x,
              craft.y,
              towers[faults[i].tower_id].x,
              towers[faults[i].tower_id].y,
            ) <=
            220.0 * 220.0 {
            faults[i].deadline = minf(
              faults[i].max_deadline,
              faults[i].deadline + 6.0,
            )
          }
        }

        for i = 0; i < storms.length(); i = i + 1 {
          if not(storms[i].active) {
            continue
          }
          if dist2(craft.x, craft.y, storms[i].x, storms[i].y) <= 240.0 * 240.0 {
            storms[i].intensity = maxf(0.2, storms[i].intensity - 0.7)
            storms[i].life = maxf(0.0, storms[i].life - 2.2)
          }
        }
      }

      // spawn systems
      fault_spawn_cd = fault_spawn_cd - dt
      if fault_spawn_cd <= 0.0 {
        ignore(spawn_fault(faults, towers, wave, fault_serial))
        fault_serial = fault_serial + 1
        fault_spawn_cd = maxf(0.9, 4.4 - Float::from_int(wave) * 0.24)
      }

      storm_spawn_cd = storm_spawn_cd - dt
      if storm_spawn_cd <= 0.0 {
        ignore(
          spawn_storm_cell(
            storms,
            world_l,
            world_t,
            world_r,
            world_b,
            clampf(1.0 - timer / 430.0, 0.0, 1.0),
          ),
        )
        storm_spawn_cd = maxf(1.0, 3.2 - Float::from_int(wave) * 0.08)
      }

      drop_spawn_cd = drop_spawn_cd - dt
      if drop_spawn_cd <= 0.0 {
        ignore(spawn_drop(drops, world_l, world_t, world_r, world_b))
        drop_spawn_cd = randf(10.0, 18.0)
      }

      // update storms and interactions
      for i = 0; i < storms.length(); i = i + 1 {
        if not(storms[i].active) {
          continue
        }

        storms[i].life = storms[i].life - dt
        storms[i].pulse = storms[i].pulse + dt * 4.6
        storms[i].x = storms[i].x + storms[i].vx * dt
        storms[i].y = storms[i].y + storms[i].vy * dt

        if storms[i].life <= 0.0 ||
          storms[i].x < world_l - 150.0 ||
          storms[i].x > world_r + 150.0 ||
          storms[i].y < world_t - 150.0 ||
          storms[i].y > world_b + 150.0 {
          storms[i].active = false
          continue
        }

        let rr : Float = storms[i].radius
        if dist2(craft.x, craft.y, storms[i].x, storms[i].y) <= rr * rr {
          let push : Float = storms[i].intensity * 90.0
          let dx : Float = craft.x - storms[i].x
          let dy : Float = craft.y - storms[i].y
          let dd : Float = maxf((dx * dx + dy * dy).sqrt(), 0.001)
          craft.vx = craft.vx + dx / dd * push * dt
          craft.vy = craft.vy + dy / dd * push * dt
          craft.hull = craft.hull - dt * storms[i].intensity * 2.3
        }

        for t = 0; t < towers.length(); t = t + 1 {
          if dist2(towers[t].x, towers[t].y, storms[i].x, storms[i].y) <=
            (rr + 24.0) * (rr + 24.0) {
            towers[t].stress = clampf(
              towers[t].stress + dt * storms[i].intensity * 0.7,
              0.0,
              4.0,
            )
            towers[t].alarm_t = 0.6
          }
        }
      }

      // update drops and pickup
      for i = 0; i < drops.length(); i = i + 1 {
        if not(drops[i].active) {
          continue
        }

        drops[i].life = drops[i].life - dt
        drops[i].pulse = drops[i].pulse + dt * 5.4
        drops[i].x = drops[i].x + drops[i].vx * dt
        drops[i].y = drops[i].y + drops[i].vy * dt

        if drops[i].life <= 0.0 {
          drops[i].active = false
          continue
        }

        if dist2(craft.x, craft.y, drops[i].x, drops[i].y) <= 30.0 * 30.0 {
          if drops[i].kind == 0 {
            craft.wire = mini(craft.wire_cap, craft.wire + drops[i].amount)
            msg = "Wire bundle +\{drops[i].amount}"
          } else if drops[i].kind == 1 {
            craft.fuse = mini(craft.fuse_cap, craft.fuse + drops[i].amount)
            msg = "Fuse pack +\{drops[i].amount}"
          } else {
            craft.battery = minf(
              craft.battery_max,
              craft.battery + Float::from_int(drops[i].amount),
            )
            msg = "Battery cell +\{drops[i].amount}"
          }
          msg_t = 1.1
          drops[i].active = false
          burst_particles(parts, craft.x, craft.y, 10, 0)
        }
      }

      // faults countdown
      let queue_penalty : Float = Float::from_int(active_faults_count(faults)) *
        0.03
      for i = 0; i < faults.length(); i = i + 1 {
        if not(faults[i].active) {
          continue
        }

        faults[i].pulse = faults[i].pulse + dt * 3.8
        let stress_penalty : Float = towers[faults[i].tower_id].stress * 0.2 +
          queue_penalty
        faults[i].deadline = faults[i].deadline - dt * (1.0 + stress_penalty)

        if faults[i].deadline <= 0.0 {
          faults[i].active = false
          failed_count = failed_count + 1
          combo = 0
          grid_health = grid_health -
            6.5 -
            Float::from_int(faults[i].severity) * 2.0
          msg = "Fault outage at tower T\{faults[i].tower_id + 1}!"
          msg_t = 1.2
          burst_particles(
            parts,
            towers[faults[i].tower_id].x,
            towers[faults[i].tower_id].y - 40.0,
            16,
            1,
          )
        }
      }

      // tower stress decay
      for i = 0; i < towers.length(); i = i + 1 {
        towers[i].stress = clampf(towers[i].stress - dt * 0.3, 0.0, 4.0)
        if towers[i].alarm_t > 0.0 {
          towers[i].alarm_t = towers[i].alarm_t - dt
          if towers[i].alarm_t < 0.0 {
            towers[i].alarm_t = 0.0
          }
        }
      }

      // interactions
      let at_depot : Bool = inside_rectf(
        craft.x,
        craft.y,
        depot.x,
        depot.y,
        depot.w,
        depot.h,
      )
      let at_substation : Bool = inside_rectf(
        craft.x,
        craft.y,
        substation.x,
        substation.y,
        substation.w,
        substation.h,
      )

      if at_depot {
        craft.battery = minf(craft.battery_max, craft.battery + dt * 24.0)
      }
      if at_substation {
        craft.hull = minf(craft.hull_max, craft.hull + dt * 6.4)
      }

      if action_press && craft.action_cd <= 0.0 {
        let mut did : Bool = false

        if at_depot {
          let add_w : Int = craft.wire_cap - craft.wire
          let add_f : Int = craft.fuse_cap - craft.fuse
          if add_w > 0 || add_f > 0 {
            craft.wire = craft.wire_cap
            craft.fuse = craft.fuse_cap
            did = true
            msg = "Depot loaded W\{add_w} F\{add_f}"
            msg_t = 1.1
            burst_particles(parts, craft.x, craft.y, 10, 0)
          }
        }

        if not(did) && at_substation {
          craft.battery = minf(craft.battery_max, craft.battery + 36.0)
          craft.hull = minf(craft.hull_max, craft.hull + 14.0)
          did = true
          msg = "Substation service: battery and hull restored."
          msg_t = 1.0
          burst_particles(parts, craft.x, craft.y, 10, 0)
        }

        if not(did) {
          let fi : Int = nearest_fault_index(
            faults,
            towers,
            craft.x,
            craft.y,
            90.0,
          )
          if fi >= 0 {
            if craft.wire >= faults[fi].need_wire &&
              craft.fuse >= faults[fi].need_fuse {
              craft.wire = craft.wire - faults[fi].need_wire
              craft.fuse = craft.fuse - faults[fi].need_fuse

              let bonus : Int = (faults[fi].deadline * 2.1).to_int()
              let gain : Int = faults[fi].reward + combo * 10 + bonus
              score = score + gain
              fixed_count = fixed_count + 1
              combo = mini(30, combo + 1)
              grid_health = minf(
                100.0,
                grid_health + 2.8 + Float::from_int(faults[fi].severity) * 1.6,
              )
              towers[faults[fi].tower_id].stress = maxf(
                0.0,
                towers[faults[fi].tower_id].stress - 1.2,
              )

              msg = "Tower T\{faults[fi].tower_id + 1} repaired +\{gain}"
              msg_t = 1.2
              burst_particles(
                parts,
                towers[faults[fi].tower_id].x,
                towers[faults[fi].tower_id].y - 40.0,
                16,
                2,
              )

              faults[fi].active = false
              did = true
            } else {
              msg = "Need W\{faults[fi].need_wire} F\{faults[fi].need_fuse}"
              msg_t = 1.0
            }
          }
        }

        craft.action_cd = 0.2
      }

      // passive drain
      grid_health = grid_health -
        dt * (0.025 + Float::from_int(active_faults_count(faults)) * 0.035)
      grid_health = clampf(grid_health, 0.0, 100.0)

      craft.hull = clampf(craft.hull, 0.0, craft.hull_max)

      // trail particles
      if speed > 12.0 {
        spawn_particle(
          parts,
          craft.x - craft.vx * 0.016,
          craft.y - craft.vy * 0.016,
          -craft.vx * 0.16 + randf(-12.0, 12.0),
          -craft.vy * 0.16 + randf(-12.0, 12.0),
          randf(0.2, 0.6),
          randf(1.2, 2.8),
          0,
        )
      }

      // end conditions
      if craft.hull <= 0.0 {
        state = 3
        msg = "Patrol craft destroyed."
      } else if grid_health <= 0.0 {
        state = 3
        msg = "Grid collapsed city-wide."
      } else if failed_count >= failed_limit {
        state = 3
        msg = "Too many outages unresolved."
      } else if timer <= 0.0 {
        if score >= score_target && grid_health >= 40.0 {
          state = 2
          msg = "Shift complete. Grid stabilized."
        } else {
          state = 3
          msg = "Shift ended below stability target."
        }
      } else if score >= score_target &&
        fixed_count >= 44 &&
        grid_health >= 55.0 {
        state = 2
        msg = "Stability target achieved early."
      }
    } else if state == 2 || state == 3 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeyR) ||
        click ||
        touch_count > 0 {
        reset_run()
        state = 1
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(10, 16, 26, 255))

    if state == 0 {
      draw_menu(sw, sh, scene_t)
    } else {
      draw_sky_background(world_x, world_y, world_w, world_h, scene_t)
      draw_city_blocks(world_x, world_y, world_h, scene_t)
      draw_power_lines(towers, faults, scene_t)
      draw_winds(winds, scene_t)
      draw_storms(storms, scene_t)
      draw_depot(depot, scene_t)
      draw_substation(substation, scene_t)
      draw_towers(towers, faults, scene_t)
      draw_drops(drops, scene_t)
      draw_particles(parts)
      draw_glider(craft, scene_t)

      let panel_x : Int = world_x + world_w + 10
      let panel_y : Int = world_y
      let panel_w2 : Int = panel_w - 10
      let panel_h : Int = world_h

      draw_hud(
        panel_x,
        panel_y,
        panel_w2,
        panel_h,
        timer,
        score,
        score_target,
        grid_health,
        craft.hull,
        craft.battery,
        craft.wire,
        craft.fuse,
        combo,
        fixed_count,
        failed_count,
        if msg_t > 0.0 {
          msg
        } else {
          ""
        },
      )
      draw_faults_panel(panel_x, panel_y, panel_w2, faults, scene_t)
      draw_touch_controls(sw, sh, mouse.x, mouse.y, hold, touch_count)

      if state == 2 || state == 3 {
        draw_end(
          sw,
          sh,
          state == 2,
          score,
          score_target,
          grid_health,
          fixed_count,
          failed_count,
        )
      }
    }

    @raylib.end_drawing()
  }
}

///|
fn active_faults_count(faults : Array[Fault]) -> Int {
  let mut c : Int = 0
  for i = 0; i < faults.length(); i = i + 1 {
    if faults[i].active {
      c = c + 1
    }
  }
  c
}
