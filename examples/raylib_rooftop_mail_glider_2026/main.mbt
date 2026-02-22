///|
struct Glider {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut heading : Float
  mut fuel : Float
  fuel_max : Float
  mut hull : Float
  hull_max : Float
  mut bags : Int
  bag_cap : Int
  mut action_cd : Float
  mut flare_cd : Float
  mut flare_t : Float
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
struct Pad {
  x : Float
  y : Float
  w : Float
  h : Float
  id : Int
}

///|
struct Delivery {
  mut active : Bool
  mut id : Int
  mut pad_id : Int
  mut deadline : Float
  mut max_deadline : Float
  mut reward : Int
  mut priority : Float
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
struct Bird {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut size : Float
  mut danger : Float
  mut life : Float
  mut wing_t : Float
}

///|
struct Crate {
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
fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
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
fn clear_deliveries(deliveries : Array[Delivery]) -> Unit {
  for i = 0; i < deliveries.length(); i = i + 1 {
    deliveries[i].active = false
    deliveries[i].id = i + 1
    deliveries[i].pad_id = 0
    deliveries[i].deadline = 0.0
    deliveries[i].max_deadline = 0.0
    deliveries[i].reward = 0
    deliveries[i].priority = 0.0
    deliveries[i].pulse = 0.0
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
fn clear_birds(birds : Array[Bird]) -> Unit {
  for i = 0; i < birds.length(); i = i + 1 {
    birds[i].active = false
    birds[i].x = 0.0
    birds[i].y = 0.0
    birds[i].vx = 0.0
    birds[i].vy = 0.0
    birds[i].size = 0.0
    birds[i].danger = 0.0
    birds[i].life = 0.0
    birds[i].wing_t = 0.0
  }
}

///|
fn clear_crates(crates : Array[Crate]) -> Unit {
  for i = 0; i < crates.length(); i = i + 1 {
    crates[i].active = false
    crates[i].x = 0.0
    crates[i].y = 0.0
    crates[i].vx = 0.0
    crates[i].vy = 0.0
    crates[i].kind = 0
    crates[i].amount = 0
    crates[i].life = 0.0
    crates[i].pulse = 0.0
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
  count : Int,
  kind : Int,
) -> Unit {
  for _i = 0; _i < count; _i = _i + 1 {
    spawn_particle(
      parts,
      x + randf(-8.0, 8.0),
      y + randf(-8.0, 8.0),
      randf(-140.0, 140.0),
      randf(-140.0, 120.0),
      randf(0.3, 1.0),
      randf(2.0, 5.8),
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
    parts[i].vy = parts[i].vy * (1.0 - dt * 1.9) + dt * 28.0
  }
}

///|
fn init_wind_tunnels(
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
  winds[0].x = world_l + 140.0
  winds[0].y = world_t + 160.0
  winds[0].w = 210.0
  winds[0].h = 128.0
  winds[0].vx = 86.0
  winds[0].vy = -24.0
  winds[0].turbulence = 0.36
  winds[0].pulse = randf(0.0, 8.0)

  winds[1].active = true
  winds[1].x = world_l + world_w - 410.0
  winds[1].y = world_t + 180.0
  winds[1].w = 250.0
  winds[1].h = 120.0
  winds[1].vx = -104.0
  winds[1].vy = 34.0
  winds[1].turbulence = 0.42
  winds[1].pulse = randf(0.0, 8.0)

  winds[2].active = true
  winds[2].x = world_l + 420.0
  winds[2].y = world_t + 380.0
  winds[2].w = 210.0
  winds[2].h = 126.0
  winds[2].vx = 0.0
  winds[2].vy = -94.0
  winds[2].turbulence = 0.33
  winds[2].pulse = randf(0.0, 8.0)

  winds[3].active = true
  winds[3].x = world_l + world_w - 680.0
  winds[3].y = world_t + 390.0
  winds[3].w = 220.0
  winds[3].h = 130.0
  winds[3].vx = 0.0
  winds[3].vy = 98.0
  winds[3].turbulence = 0.39
  winds[3].pulse = randf(0.0, 8.0)

  winds[4].active = true
  winds[4].x = world_l + 190.0
  winds[4].y = world_t + world_h - 210.0
  winds[4].w = 230.0
  winds[4].h = 110.0
  winds[4].vx = 120.0
  winds[4].vy = -12.0
  winds[4].turbulence = 0.41
  winds[4].pulse = randf(0.0, 8.0)

  winds[5].active = true
  winds[5].x = world_l + world_w - 450.0
  winds[5].y = world_t + world_h - 220.0
  winds[5].w = 230.0
  winds[5].h = 112.0
  winds[5].vx = -112.0
  winds[5].vy = 18.0
  winds[5].turbulence = 0.37
  winds[5].pulse = randf(0.0, 8.0)

  winds[6].active = true
  winds[6].x = world_l + world_w * 0.44
  winds[6].y = world_t + 82.0
  winds[6].w = 170.0
  winds[6].h = world_h - 180.0
  winds[6].vx = 18.0
  winds[6].vy = 82.0
  winds[6].turbulence = 0.46
  winds[6].pulse = randf(0.0, 8.0)
}

///|
fn active_delivery_count(deliveries : Array[Delivery]) -> Int {
  let mut c : Int = 0
  for i = 0; i < deliveries.length(); i = i + 1 {
    if deliveries[i].active {
      c = c + 1
    }
  }
  c
}

///|
fn active_delivery_for_pad(deliveries : Array[Delivery], pad_id : Int) -> Int {
  let mut c : Int = 0
  for i = 0; i < deliveries.length(); i = i + 1 {
    if deliveries[i].active && deliveries[i].pad_id == pad_id {
      c = c + 1
    }
  }
  c
}

///|
fn spawn_delivery(
  deliveries : Array[Delivery],
  wave : Int,
  serial : Int,
  pad_count : Int,
) -> Bool {
  let mut placed : Bool = false

  for i = 0; i < deliveries.length(); i = i + 1 {
    if deliveries[i].active {
      continue
    }

    let mut pad_id : Int = randi(0, pad_count - 1)
    let mut tries : Int = 0
    while active_delivery_for_pad(deliveries, pad_id) >= 2 && tries < 6 {
      pad_id = randi(0, pad_count - 1)
      tries = tries + 1
    }

    let base_deadline : Float = randf(34.0, 74.0)
    let wave_penalty : Float = Float::from_int(wave) * 1.45
    let deadline : Float = maxf(18.0, base_deadline - wave_penalty)

    deliveries[i].active = true
    deliveries[i].id = serial
    deliveries[i].pad_id = pad_id
    deliveries[i].deadline = deadline
    deliveries[i].max_deadline = deadline
    deliveries[i].reward = 110 + wave * 7 + randi(0, 56)
    deliveries[i].priority = randf(0.0, 1.0)
    deliveries[i].pulse = randf(0.0, 10.0)

    placed = true
    break
  }

  placed
}

///|
fn spawn_bird(
  birds : Array[Bird],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  pressure : Float,
) -> Bool {
  let mut placed : Bool = false

  for i = 0; i < birds.length(); i = i + 1 {
    if birds[i].active {
      continue
    }

    let edge : Int = randi(0, 3)
    if edge == 0 {
      birds[i].x = world_l - 24.0
      birds[i].y = randf(world_t + 18.0, world_b - 18.0)
      birds[i].vx = randf(96.0, 188.0)
      birds[i].vy = randf(-44.0, 44.0)
    } else if edge == 1 {
      birds[i].x = world_r + 24.0
      birds[i].y = randf(world_t + 18.0, world_b - 18.0)
      birds[i].vx = -randf(96.0, 188.0)
      birds[i].vy = randf(-44.0, 44.0)
    } else if edge == 2 {
      birds[i].x = randf(world_l + 24.0, world_r - 24.0)
      birds[i].y = world_t - 24.0
      birds[i].vx = randf(-64.0, 64.0)
      birds[i].vy = randf(96.0, 182.0)
    } else {
      birds[i].x = randf(world_l + 24.0, world_r - 24.0)
      birds[i].y = world_b + 24.0
      birds[i].vx = randf(-64.0, 64.0)
      birds[i].vy = -randf(96.0, 182.0)
    }

    birds[i].active = true
    birds[i].size = randf(9.0, 18.0)
    birds[i].danger = randf(0.6, 1.6) + pressure * randf(0.2, 0.8)
    birds[i].life = randf(6.0, 14.0)
    birds[i].wing_t = randf(0.0, 12.0)

    placed = true
    break
  }

  placed
}

///|
fn spawn_crate(
  crates : Array[Crate],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
) -> Bool {
  let mut placed : Bool = false

  for i = 0; i < crates.length(); i = i + 1 {
    if crates[i].active {
      continue
    }

    crates[i].active = true
    crates[i].x = randf(world_l + 120.0, world_r - 120.0)
    crates[i].y = randf(world_t + 90.0, world_b - 90.0)
    crates[i].vx = randf(-20.0, 20.0)
    crates[i].vy = randf(-18.0, 18.0)
    crates[i].kind = randi(0, 2)
    crates[i].amount = if crates[i].kind == 0 {
      randi(10, 22)
    } else if crates[i].kind == 1 {
      randi(10, 20)
    } else {
      randi(1, 3)
    }
    crates[i].life = randf(14.0, 24.0)
    crates[i].pulse = randf(0.0, 8.0)

    placed = true
    break
  }

  placed
}

///|
fn nearest_pad_id(
  pads : Array[Pad],
  x : Float,
  y : Float,
  radius : Float,
) -> Int {
  let mut found : Int = -1
  let mut best : Float = radius * radius

  for i = 0; i < pads.length(); i = i + 1 {
    let cx : Float = pads[i].x + pads[i].w * 0.5
    let cy : Float = pads[i].y + pads[i].h * 0.5
    let d2v : Float = dist2(x, y, cx, cy)
    if d2v <= best {
      best = d2v
      found = pads[i].id
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
    @raylib.Color::new(30, 58, 98, 255),
    @raylib.Color::new(18, 30, 54, 255),
  )

  for i = 0; i < 26; i = i + 1 {
    let y0 : Float = Float::from_int(world_y) +
      Float::from_int(i) * Float::from_int(world_h) / 26.0
    let wave : Float = sinf(scene_t * 1.6 + Float::from_int(i) * 0.4) * 0.5 +
      0.5
    let alpha : Int = 10 + (wave * 24.0).to_int()
    @raylib.draw_rectangle(
      world_x,
      y0.to_int(),
      world_w,
      2,
      @raylib.Color::new(88, 140, 196, alpha),
    )
  }
}

///|
fn draw_city_blocks(
  world_x : Int,
  world_y : Int,
  world_w : Int,
  world_h : Int,
  scene_t : Float,
) -> Unit {
  let base_y : Int = world_y + world_h - 40

  for i = 0; i < 22; i = i + 1 {
    let w : Int = 44 + i % 4 * 18
    let h : Int = 64 + i * 13 % 7 * 22
    let x : Int = world_x + i * 72 - 20
    let y : Int = base_y - h

    @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(26, 32, 44, 228))

    for j = 0; j < 3; j = j + 1 {
      let wx : Int = x + 6 + j * 14
      let mut wy : Int = y + 8
      while wy < y + h - 8 {
        let blink : Float = sinf(
            scene_t * 3.0 +
            Float::from_int(i * 5 + j) * 0.6 +
            Float::from_int(wy) * 0.03,
          ) *
          0.5 +
          0.5
        let lit : Int = if blink > 0.4 { 1 } else { 0 }
        @raylib.draw_rectangle(
          wx,
          wy,
          7,
          9,
          if lit == 1 {
            @raylib.Color::new(248, 216, 122, 200)
          } else {
            @raylib.Color::new(52, 60, 78, 130)
          },
        )
        wy = wy + 15
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
    @raylib.Color::new(32, 64, 70, 232),
  )
  @raylib.draw_rectangle_lines(
    depot.x.to_int(),
    depot.y.to_int(),
    depot.w.to_int(),
    depot.h.to_int(),
    @raylib.Color::new(154, 240, 212, 218),
  )
  @raylib.draw_text(
    "MAIL DEPOT",
    depot.x.to_int() + 18,
    depot.y.to_int() + 16,
    22,
    @raylib.Color::new(232, 252, 240, 236),
  )

  let pulse : Float = sinf(scene_t * 3.4) * 0.5 + 0.5
  @raylib.draw_circle_v(
    @raylib.Vector2::new(depot.x + depot.w * 0.5, depot.y + depot.h * 0.5),
    20.0 + pulse * 8.0,
    @raylib.Color::new(180, 248, 226, 66),
  )
}

///|
fn draw_pads(
  pads : Array[Pad],
  deliveries : Array[Delivery],
  scene_t : Float,
) -> Unit {
  for i = 0; i < pads.length(); i = i + 1 {
    let has_request : Bool = active_delivery_for_pad(deliveries, pads[i].id) > 0

    @raylib.draw_rectangle(
      pads[i].x.to_int(),
      pads[i].y.to_int(),
      pads[i].w.to_int(),
      pads[i].h.to_int(),
      if has_request {
        @raylib.Color::new(84, 92, 112, 230)
      } else {
        @raylib.Color::new(54, 62, 82, 210)
      },
    )
    @raylib.draw_rectangle_lines(
      pads[i].x.to_int(),
      pads[i].y.to_int(),
      pads[i].w.to_int(),
      pads[i].h.to_int(),
      if has_request {
        @raylib.Color::new(246, 214, 130, 222)
      } else {
        @raylib.Color::new(168, 182, 212, 170)
      },
    )

    @raylib.draw_text(
      "P\{pads[i].id + 1}",
      pads[i].x.to_int() + 10,
      pads[i].y.to_int() + 10,
      18,
      @raylib.Color::new(232, 240, 252, 236),
    )

    if has_request {
      let pulse : Float = sinf(scene_t * 8.0 + Float::from_int(i) * 0.7) * 0.5 +
        0.5
      @raylib.draw_circle_v(
        @raylib.Vector2::new(pads[i].x + pads[i].w * 0.5, pads[i].y - 8.0),
        6.0 + pulse * 4.0,
        @raylib.Color::new(255, 184, 118, 186),
      )
    }
  }
}

///|
fn draw_wind_tunnels(winds : Array[WindTunnel], scene_t : Float) -> Unit {
  for i = 0; i < winds.length(); i = i + 1 {
    if not(winds[i].active) {
      continue
    }

    let pulse : Float = sinf(scene_t * 6.0 + winds[i].pulse) * 0.5 + 0.5

    @raylib.draw_rectangle(
      winds[i].x.to_int(),
      winds[i].y.to_int(),
      winds[i].w.to_int(),
      winds[i].h.to_int(),
      @raylib.Color::new(88, 168, 238, 24 + (pulse * 42.0).to_int()),
    )
    @raylib.draw_rectangle_lines(
      winds[i].x.to_int(),
      winds[i].y.to_int(),
      winds[i].w.to_int(),
      winds[i].h.to_int(),
      @raylib.Color::new(118, 200, 252, 120),
    )

    let cx : Float = winds[i].x + winds[i].w * 0.5
    let cy : Float = winds[i].y + winds[i].h * 0.5
    let tip_x : Float = cx + winds[i].vx * 0.18
    let tip_y : Float = cy + winds[i].vy * 0.18
    @raylib.draw_line_ex(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(tip_x, tip_y),
      2.0,
      @raylib.Color::new(184, 232, 255, 160),
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(tip_x, tip_y),
      3.0,
      @raylib.Color::new(214, 244, 255, 162),
    )
  }
}

///|
fn draw_birds(birds : Array[Bird], scene_t : Float) -> Unit {
  for i = 0; i < birds.length(); i = i + 1 {
    if not(birds[i].active) {
      continue
    }

    let wing : Float = sinf(scene_t * 16.0 + birds[i].wing_t) * 0.5 + 0.5
    let spread : Float = 6.0 + wing * 7.0

    @raylib.draw_triangle(
      @raylib.Vector2::new(birds[i].x + birds[i].size, birds[i].y),
      @raylib.Vector2::new(birds[i].x - birds[i].size, birds[i].y - spread),
      @raylib.Vector2::new(birds[i].x - birds[i].size, birds[i].y + spread),
      @raylib.Color::new(52, 38, 30, 240),
    )

    @raylib.draw_circle_v(
      @raylib.Vector2::new(birds[i].x + birds[i].size * 0.22, birds[i].y),
      3.0,
      @raylib.Color::new(232, 216, 164, 230),
    )
  }
}

///|
fn draw_crates(crates : Array[Crate], scene_t : Float) -> Unit {
  for i = 0; i < crates.length(); i = i + 1 {
    if not(crates[i].active) {
      continue
    }

    let pulse : Float = sinf(scene_t * 5.4 + crates[i].pulse) * 0.5 + 0.5
    let col = if crates[i].kind == 0 {
      @raylib.Color::new(106, 204, 252, 220)
    } else if crates[i].kind == 1 {
      @raylib.Color::new(250, 138, 110, 220)
    } else {
      @raylib.Color::new(136, 232, 162, 220)
    }

    @raylib.draw_rectangle(
      (crates[i].x - 14.0).to_int(),
      (crates[i].y - 14.0).to_int(),
      28,
      28,
      col,
    )
    @raylib.draw_rectangle_lines(
      (crates[i].x - 14.0).to_int(),
      (crates[i].y - 14.0).to_int(),
      28,
      28,
      @raylib.Color::new(246, 252, 255, 224),
    )

    @raylib.draw_circle_v(
      @raylib.Vector2::new(crates[i].x, crates[i].y),
      20.0 + pulse * 7.0,
      @raylib.Color::new(236, 248, 255, (pulse * 86.0).to_int()),
    )

    @raylib.draw_text(
      "\{crates[i].amount}",
      (crates[i].x - 6.0).to_int(),
      (crates[i].y - 8.0).to_int(),
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
      @raylib.Color::new(164, 226, 252, a)
    } else if parts[i].kind == 1 {
      @raylib.Color::new(252, 156, 120, a)
    } else {
      @raylib.Color::new(244, 236, 168, a)
    }
    @raylib.draw_circle_v(
      @raylib.Vector2::new(parts[i].x, parts[i].y),
      parts[i].size,
      c,
    )
  }
}

///|
fn draw_glider(glider : Glider, scene_t : Float) -> Unit {
  let bob : Float = sinf(scene_t * 12.0 + glider.step_t * 0.08) * 1.1

  @raylib.draw_triangle(
    @raylib.Vector2::new(glider.x + 22.0, glider.y + bob),
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
      @raylib.Vector2::new(glider.x - 19.0, glider.y + bob),
      8.0 + glider.boost_heat * 6.0,
      @raylib.Color::new(116, 204, 252, (glider.boost_heat * 180.0).to_int()),
    )
  }

  if glider.flare_t > 0.0 {
    let pulse : Float = sinf(glider.flare_t * 9.0) * 0.5 + 0.5
    @raylib.draw_circle_lines(
      glider.x.to_int(),
      glider.y.to_int(),
      82.0 + pulse * 70.0,
      @raylib.Color::new(250, 214, 128, 200),
    )
  }
}

///|
fn draw_deliveries_panel(
  panel_x : Int,
  panel_y : Int,
  panel_w : Int,
  deliveries : Array[Delivery],
  scene_t : Float,
) -> Unit {
  @raylib.draw_text(
    "Active Deliveries",
    panel_x + 18,
    panel_y + 388,
    30,
    @raylib.Color::new(236, 246, 255, 238),
  )

  let mut y : Int = panel_y + 430
  for i = 0; i < deliveries.length(); i = i + 1 {
    if not(deliveries[i].active) {
      continue
    }

    let urgency : Float = if deliveries[i].max_deadline <= 0.001 {
      0.0
    } else {
      clampf(
        1.0 - deliveries[i].deadline / deliveries[i].max_deadline,
        0.0,
        1.0,
      )
    }

    let blink : Float = sinf(scene_t * 8.0 + deliveries[i].pulse) * 0.5 + 0.5
    let row_h : Int = 72

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
      @raylib.Color::new(44 + (urgency * 84.0).to_int(), 56, 72, 226),
    )
    @raylib.draw_rectangle_lines(
      panel_x + 12,
      y,
      panel_w - 24,
      row_h,
      @raylib.Color::new(188, 208, 234, 170),
    )

    @raylib.draw_text(
      "#\{deliveries[i].id} -> Pad P\{deliveries[i].pad_id + 1}",
      panel_x + 24,
      y + 10,
      22,
      @raylib.Color::new(236, 246, 255, 236),
    )
    @raylib.draw_text(
      "Reward \{deliveries[i].reward}",
      panel_x + 24,
      y + 40,
      18,
      @raylib.Color::new(250, 226, 138, 232),
    )

    let dd_txt : String = "\{deliveries[i].deadline.to_int()}s"
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
      y + 42,
      160,
      14,
      @raylib.Color::new(20, 22, 30, 232),
    )
    @raylib.draw_rectangle(
      panel_x + panel_w - 186,
      y + 44,
      (Float::from_int(156) * (1.0 - urgency)).to_int(),
      10,
      @raylib.Color::new(120, 224, 152, 210 + (blink * 38.0).to_int()),
    )
    @raylib.draw_rectangle_lines(
      panel_x + panel_w - 188,
      y + 42,
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
  rep : Float,
  hull : Float,
  fuel : Float,
  bags : Int,
  bag_cap : Int,
  combo : Int,
  completed : Int,
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
    "ROOFTOP MAIL GLIDER 2026",
    panel_x + 18,
    panel_y + 16,
    32,
    @raylib.Color::new(236, 246, 255, 242),
  )

  let mm : Int = timer.to_int() / 60
  let ss : Int = timer.to_int() % 60
  let ss_txt : String = if ss < 10 { "0\{ss}" } else { "\{ss}" }

  @raylib.draw_text(
    "Time \{mm}:\{ss_txt}",
    panel_x + 20,
    panel_y + 56,
    28,
    @raylib.Color::new(236, 246, 255, 236),
  )
  @raylib.draw_text(
    "Score \{score}/\{target}",
    panel_x + 20,
    panel_y + 90,
    26,
    @raylib.Color::new(248, 226, 138, 236),
  )
  @raylib.draw_text(
    "Combo x\{combo}  Completed \{completed}  Failed \{failed}",
    panel_x + 20,
    panel_y + 122,
    22,
    @raylib.Color::new(204, 226, 246, 232),
  )
  @raylib.draw_text(
    "Bags \{bags}/\{bag_cap}",
    panel_x + 20,
    panel_y + 150,
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
    "Reputation",
    rep,
    100.0,
    panel_x + 20,
    panel_y + 190,
    panel_w - 40,
    22,
    @raylib.Color::new(116, 224, 156, 232),
  )
  meter(
    "Hull",
    hull,
    100.0,
    panel_x + 20,
    panel_y + 238,
    panel_w - 40,
    22,
    @raylib.Color::new(246, 138, 112, 232),
  )
  meter(
    "Fuel",
    fuel,
    100.0,
    panel_x + 20,
    panel_y + 286,
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
    "Move: WASD/Arrows\nBoost: Space/J\nAct: L/U\nFlare: K/H",
    panel_x + 24,
    panel_y + panel_h - 124,
    20,
    @raylib.Color::new(194, 218, 244, 230),
  )

  @raylib.draw_text(
    msg,
    panel_x + 20,
    panel_y + 336,
    21,
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
  let flare_x : Float = Float::from_int(sw - 96)
  let flare_y : Float = Float::from_int(sh - 144)

  let boost = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, boost_x, boost_y, 56.0,
  )
  let action = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, action_x, action_y, 44.0,
  )
  let flare = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, flare_x, flare_y, 42.0,
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
  btn(flare_x, flare_y, 42.0, "FLARE", flare, 250, 190, 106)
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
    "ROOFTOP MAIL GLIDER 2026",
    sw / 2 - @raylib.measure_text("ROOFTOP MAIL GLIDER 2026", 68) / 2,
    176,
    68,
    @raylib.Color::new(236, 246, 255, 246),
  )
  @raylib.draw_text(
    "Load bags at the depot, rush deliveries to rooftop pads, and avoid birds in unstable wind corridors.",
    sw / 2 -
    @raylib.measure_text(
      "Load bags at the depot, rush deliveries to rooftop pads, and avoid birds in unstable wind corridors.",
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
    "Mobile: D-pad + BOOST + ACT + FLARE",
    sw / 2 - @raylib.measure_text("Mobile: D-pad + BOOST + ACT + FLARE", 24) / 2,
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
  rep : Float,
  completed : Int,
  failed : Int,
) -> Unit {
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 224))

  let title : String = if win { "SHIFT SUCCESS" } else { "SHIFT FAILED" }
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
    "Reputation: \{rep.to_int()}%",
    sw / 2 - @raylib.measure_text("Reputation: \{rep.to_int()}%", 34) / 2,
    376,
    34,
    @raylib.Color::new(216, 232, 250, 236),
  )
  @raylib.draw_text(
    "Completed: \{completed}  Failed: \{failed}",
    sw / 2 -
    @raylib.measure_text("Completed: \{completed}  Failed: \{failed}", 30) / 2,
    420,
    30,
    @raylib.Color::new(206, 224, 244, 232),
  )
  @raylib.draw_text(
    "Press Enter / R to fly again",
    sw / 2 - @raylib.measure_text("Press Enter / R to fly again", 32) / 2,
    528,
    32,
    @raylib.Color::new(244, 250, 255, 236),
  )
}

///|
fn main {
  let sw : Int = 1700
  let sh : Int = 960
  @raylib.init_window(sw, sh, "raylib [game] rooftop mail glider 2026")
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
    x: world_l + 42.0,
    y: world_b - 156.0,
    w: 220.0,
    h: 116.0,
  }

  let pads : Array[Pad] = [
    { x: world_l + 280.0, y: world_t + 84.0, w: 126.0, h: 76.0, id: 0 },
    { x: world_l + 516.0, y: world_t + 160.0, w: 132.0, h: 80.0, id: 1 },
    { x: world_l + 774.0, y: world_t + 90.0, w: 128.0, h: 78.0, id: 2 },
    { x: world_l + 1044.0, y: world_t + 176.0, w: 126.0, h: 76.0, id: 3 },
    { x: world_l + 360.0, y: world_t + 402.0, w: 130.0, h: 78.0, id: 4 },
    { x: world_l + 686.0, y: world_t + 504.0, w: 132.0, h: 80.0, id: 5 },
    { x: world_l + 964.0, y: world_t + 420.0, w: 128.0, h: 78.0, id: 6 },
    { x: world_l + 1168.0, y: world_t + 566.0, w: 132.0, h: 80.0, id: 7 },
  ]

  let deliveries : Array[Delivery] = Array::makei(14, fn(i) {
    {
      active: false,
      id: i + 1,
      pad_id: 0,
      deadline: 0.0,
      max_deadline: 0.0,
      reward: 0,
      priority: 0.0,
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

  let birds : Array[Bird] = Array::makei(120, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      size: 0.0,
      danger: 0.0,
      life: 0.0,
      wing_t: 0.0,
    }
  })

  let crates : Array[Crate] = Array::makei(18, fn(_i) {
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

  let parts : Array[Particle] = Array::makei(1100, fn(_i) {
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

  let glider : Glider = {
    x: depot.x + depot.w * 0.5,
    y: depot.y + depot.h * 0.5,
    vx: 0.0,
    vy: 0.0,
    heading: 0.0,
    fuel: 100.0,
    fuel_max: 100.0,
    hull: 100.0,
    hull_max: 100.0,
    bags: 0,
    bag_cap: 18,
    action_cd: 0.0,
    flare_cd: 0.0,
    flare_t: 0.0,
    boost_heat: 0.0,
    step_t: 0.0,
  }

  let mut state : Int = 0 // 0 menu 1 play 2 win 3 lose
  let mut timer : Float = 420.0
  let mut scene_t : Float = 0.0

  let mut score : Int = 0
  let mut score_target : Int = 9600
  let mut rep : Float = 92.0
  let mut combo : Int = 0
  let mut completed : Int = 0
  let mut failed : Int = 0
  let mut failed_limit : Int = 22
  let mut wave : Int = 1

  let mut delivery_serial : Int = 1
  let mut delivery_spawn_cd : Float = 1.4
  let mut bird_spawn_cd : Float = 0.5
  let mut crate_spawn_cd : Float = 11.0

  let mut msg : String = ""
  let mut msg_t : Float = 0.0

  fn reset_run() -> Unit {
    clear_deliveries(deliveries)
    init_wind_tunnels(
      winds,
      world_l,
      world_t,
      Float::from_int(world_w),
      Float::from_int(world_h),
    )
    clear_birds(birds)
    clear_crates(crates)
    clear_particles(parts)

    glider.x = depot.x + depot.w * 0.5
    glider.y = depot.y + depot.h * 0.5
    glider.vx = 0.0
    glider.vy = 0.0
    glider.heading = 0.0
    glider.fuel = 100.0
    glider.hull = 100.0
    glider.bags = 0
    glider.action_cd = 0.0
    glider.flare_cd = 0.0
    glider.flare_t = 0.0
    glider.boost_heat = 0.0
    glider.step_t = 0.0

    timer = 420.0
    scene_t = 0.0

    score = 0
    score_target = 9600
    rep = 92.0
    combo = 0
    completed = 0
    failed = 0
    failed_limit = 22
    wave = 1

    delivery_serial = 1
    delivery_spawn_cd = 1.4
    bird_spawn_cd = 0.5
    crate_spawn_cd = 11.0

    msg = "Load bags at depot and deliver to active pads."
    msg_t = 3.2
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

    if glider.action_cd > 0.0 {
      glider.action_cd = glider.action_cd - dt
      if glider.action_cd < 0.0 {
        glider.action_cd = 0.0
      }
    }
    if glider.flare_cd > 0.0 {
      glider.flare_cd = glider.flare_cd - dt
      if glider.flare_cd < 0.0 {
        glider.flare_cd = 0.0
      }
    }
    if glider.flare_t > 0.0 {
      glider.flare_t = glider.flare_t - dt
      if glider.flare_t < 0.0 {
        glider.flare_t = 0.0
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

      wave = 1 + score / 1000
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
      let mut flare_press : Bool = @raylib.is_key_pressed(@raylib.KeyK) ||
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
        flare_press = true
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
      let mut fuel_drain : Float = 1.8
      if boost_hold && glider.fuel > 0.4 {
        accel = 560.0
        fuel_drain = fuel_drain + 7.6
        glider.boost_heat = clampf(glider.boost_heat + dt * 0.9, 0.0, 1.0)
      } else {
        glider.boost_heat = clampf(glider.boost_heat - dt * 1.0, 0.0, 1.0)
      }

      glider.vx = glider.vx + input_x * accel * dt
      glider.vy = glider.vy + input_y * accel * dt

      let mut wind_drain : Float = 0.0
      for i = 0; i < winds.length(); i = i + 1 {
        if not(winds[i].active) {
          continue
        }
        winds[i].pulse = winds[i].pulse + dt * 2.8

        if inside_rectf(
            glider.x,
            glider.y,
            winds[i].x,
            winds[i].y,
            winds[i].w,
            winds[i].h,
          ) {
          let wave_mul : Float = 0.72 +
            (sinf(winds[i].pulse) * 0.5 + 0.5) * 0.62
          glider.vx = glider.vx + winds[i].vx * dt * wave_mul
          glider.vy = glider.vy + winds[i].vy * dt * wave_mul
          wind_drain = wind_drain + winds[i].turbulence * (0.7 + wave_mul * 0.5)

          if winds[i].turbulence > 0.42 {
            glider.hull = glider.hull - dt * (winds[i].turbulence - 0.36) * 1.3
          }
        }
      }

      glider.vx = glider.vx * (1.0 - dt * (2.4 + wind_drain * 0.35))
      glider.vy = glider.vy * (1.0 - dt * (2.4 + wind_drain * 0.35))

      let speed : Float = (glider.vx * glider.vx + glider.vy * glider.vy).sqrt()
      let boost_bonus : Float = if boost_hold { 130.0 } else { 0.0 }
      let max_speed : Float = 300.0 + boost_bonus
      if speed > max_speed {
        let k : Float = max_speed / speed
        glider.vx = glider.vx * k
        glider.vy = glider.vy * k
      }

      glider.x = glider.x + glider.vx * dt
      glider.y = glider.y + glider.vy * dt
      if speed > 6.0 {
        glider.step_t = glider.step_t + dt * speed
      }

      if glider.x < world_l + 16.0 {
        glider.x = world_l + 16.0
        glider.vx = absf(glider.vx) * 0.32
      }
      if glider.x > world_r - 16.0 {
        glider.x = world_r - 16.0
        glider.vx = -absf(glider.vx) * 0.32
      }
      if glider.y < world_t + 16.0 {
        glider.y = world_t + 16.0
        glider.vy = absf(glider.vy) * 0.32
      }
      if glider.y > world_b - 16.0 {
        glider.y = world_b - 16.0
        glider.vy = -absf(glider.vy) * 0.32
      }

      glider.fuel = glider.fuel - dt * (fuel_drain + speed * 0.003 + wind_drain)
      glider.fuel = clampf(glider.fuel, 0.0, glider.fuel_max)
      if glider.fuel <= 0.0 {
        glider.vx = glider.vx * (1.0 - dt * 1.0)
        glider.vy = glider.vy * (1.0 - dt * 1.0)
      }

      // Flare ability
      if flare_press && glider.flare_cd <= 0.0 && glider.fuel >= 6.0 {
        glider.flare_t = 3.8
        glider.flare_cd = 9.0
        glider.fuel = glider.fuel - 6.0
        msg = "Flare launched: nearby birds scatter."
        msg_t = 1.2
        burst_particles(parts, glider.x, glider.y, 18, 2)
      }

      // Spawn systems
      delivery_spawn_cd = delivery_spawn_cd - dt
      if delivery_spawn_cd <= 0.0 {
        let spawned : Bool = spawn_delivery(
          deliveries,
          wave,
          delivery_serial,
          pads.length(),
        )
        if spawned {
          delivery_serial = delivery_serial + 1
        }
        delivery_spawn_cd = maxf(1.0, 4.2 - Float::from_int(wave) * 0.22)
      }

      bird_spawn_cd = bird_spawn_cd - dt
      if bird_spawn_cd <= 0.0 {
        ignore(
          spawn_bird(
            birds,
            world_l,
            world_t,
            world_r,
            world_b,
            clampf(1.0 - timer / 420.0, 0.0, 1.0),
          ),
        )
        bird_spawn_cd = maxf(0.12, 0.55 - Float::from_int(wave) * 0.02)
      }

      crate_spawn_cd = crate_spawn_cd - dt
      if crate_spawn_cd <= 0.0 {
        ignore(spawn_crate(crates, world_l, world_t, world_r, world_b))
        crate_spawn_cd = randf(10.0, 18.0)
      }

      // Deliveries countdown
      let queue_pressure : Float = Float::from_int(
          active_delivery_count(deliveries),
        ) *
        0.01
      for i = 0; i < deliveries.length(); i = i + 1 {
        if not(deliveries[i].active) {
          continue
        }

        deliveries[i].pulse = deliveries[i].pulse + dt * 3.6
        deliveries[i].deadline = deliveries[i].deadline -
          dt * (1.0 + queue_pressure)

        if deliveries[i].deadline <= 0.0 {
          deliveries[i].active = false
          failed = failed + 1
          combo = 0
          rep = rep - 7.6
          msg = "Delivery request expired."
          msg_t = 1.0
          burst_particles(parts, world_r - 80.0, world_t + 90.0, 12, 1)
        }
      }

      // Birds update and collision
      for i = 0; i < birds.length(); i = i + 1 {
        if not(birds[i].active) {
          continue
        }

        birds[i].life = birds[i].life - dt
        birds[i].wing_t = birds[i].wing_t + dt * 6.8

        if glider.flare_t > 0.0 {
          let d2v : Float = dist2(glider.x, glider.y, birds[i].x, birds[i].y)
          if d2v <= 220.0 * 220.0 {
            let d : Float = maxf(d2v.sqrt(), 0.001)
            let nx : Float = (birds[i].x - glider.x) / d
            let ny : Float = (birds[i].y - glider.y) / d
            birds[i].vx = birds[i].vx + nx * dt * 220.0
            birds[i].vy = birds[i].vy + ny * dt * 220.0
          }
        }

        birds[i].x = birds[i].x + birds[i].vx * dt
        birds[i].y = birds[i].y + birds[i].vy * dt

        if birds[i].life <= 0.0 ||
          birds[i].x < world_l - 120.0 ||
          birds[i].x > world_r + 120.0 ||
          birds[i].y < world_t - 120.0 ||
          birds[i].y > world_b + 120.0 {
          birds[i].active = false
          continue
        }

        let rr : Float = birds[i].size + 12.0
        if dist2(glider.x, glider.y, birds[i].x, birds[i].y) <= rr * rr {
          let dmg : Float = 4.0 + birds[i].danger * 5.0
          glider.hull = glider.hull - dmg
          glider.vx = glider.vx - birds[i].vx * 0.18
          glider.vy = glider.vy - birds[i].vy * 0.18
          if glider.bags > 0 {
            glider.bags = glider.bags - 1
          }
          birds[i].active = false
          combo = 0
          rep = rep - 1.6
          msg = "Bird strike! Hull damage and cargo loss."
          msg_t = 1.0
          burst_particles(parts, glider.x, glider.y, 14, 1)
        }
      }

      // Crate update and pickup
      for i = 0; i < crates.length(); i = i + 1 {
        if not(crates[i].active) {
          continue
        }

        crates[i].life = crates[i].life - dt
        crates[i].pulse = crates[i].pulse + dt * 5.2
        crates[i].x = crates[i].x + crates[i].vx * dt
        crates[i].y = crates[i].y + crates[i].vy * dt

        if crates[i].life <= 0.0 {
          crates[i].active = false
          continue
        }

        if dist2(glider.x, glider.y, crates[i].x, crates[i].y) <= 30.0 * 30.0 {
          if crates[i].kind == 0 {
            glider.fuel = minf(
              glider.fuel_max,
              glider.fuel + Float::from_int(crates[i].amount),
            )
            msg = "Collected fuel +\{crates[i].amount}"
          } else if crates[i].kind == 1 {
            glider.hull = minf(
              glider.hull_max,
              glider.hull + Float::from_int(crates[i].amount),
            )
            msg = "Collected repair pack +\{crates[i].amount}"
          } else {
            glider.bags = mini(glider.bag_cap, glider.bags + crates[i].amount)
            msg = "Collected extra bags +\{crates[i].amount}"
          }
          msg_t = 1.2
          crates[i].active = false
          burst_particles(parts, glider.x, glider.y, 10, 0)
        }
      }

      // Station interactions
      let at_depot : Bool = inside_rectf(
        glider.x,
        glider.y,
        depot.x,
        depot.y,
        depot.w,
        depot.h,
      )
      if at_depot {
        glider.fuel = minf(glider.fuel_max, glider.fuel + dt * 26.0)
        glider.hull = minf(glider.hull_max, glider.hull + dt * 6.0)
      }

      if action_press && glider.action_cd <= 0.0 {
        let mut did : Bool = false

        if at_depot {
          let refill : Int = glider.bag_cap - glider.bags
          if refill > 0 {
            glider.bags = glider.bag_cap
            did = true
            msg = "Depot loaded \{refill} bags"
            msg_t = 1.0
            burst_particles(parts, glider.x, glider.y, 10, 0)
          }
        }

        if not(did) {
          let pad_id : Int = nearest_pad_id(pads, glider.x, glider.y, 92.0)
          if pad_id >= 0 {
            if glider.bags > 0 {
              let mut delivered : Bool = false
              for i = 0; i < deliveries.length(); i = i + 1 {
                if deliveries[i].active && deliveries[i].pad_id == pad_id {
                  let bonus : Int = (deliveries[i].deadline * 2.2).to_int()
                  let gain : Int = deliveries[i].reward + combo * 10 + bonus
                  score = score + gain
                  completed = completed + 1
                  combo = mini(30, combo + 1)
                  rep = minf(100.0, rep + 2.2 + Float::from_int(combo) * 0.06)
                  glider.bags = glider.bags - 1
                  deliveries[i].active = false
                  delivered = true
                  did = true
                  msg = "Delivered to pad P\{pad_id + 1} +\{gain}"
                  msg_t = 1.1
                  burst_particles(parts, glider.x, glider.y, 16, 2)
                  break
                }
              }

              if not(delivered) {
                msg = "No request for this pad right now."
                msg_t = 1.0
              }
            } else {
              msg = "No bags loaded. Return to depot."
              msg_t = 1.0
            }
          }
        }

        glider.action_cd = 0.2
      }

      // Passive reputation drift
      rep = rep -
        dt *
        (0.018 + Float::from_int(active_delivery_count(deliveries)) * 0.002)
      rep = clampf(rep, 0.0, 100.0)

      glider.hull = clampf(glider.hull, 0.0, glider.hull_max)

      // Motion trail
      if speed > 12.0 {
        spawn_particle(
          parts,
          glider.x - glider.vx * 0.016,
          glider.y - glider.vy * 0.016,
          -glider.vx * 0.16 + randf(-12.0, 12.0),
          -glider.vy * 0.16 + randf(-12.0, 12.0),
          randf(0.2, 0.6),
          randf(1.2, 2.8),
          0,
        )
      }

      // Win/Lose
      if glider.hull <= 0.0 {
        state = 3
        msg = "Glider destroyed."
      } else if rep <= 0.0 {
        state = 3
        msg = "Reputation collapsed."
      } else if failed >= failed_limit {
        state = 3
        msg = "Too many failed deliveries."
      } else if timer <= 0.0 {
        if score >= score_target && rep >= 40.0 {
          state = 2
          msg = "Shift complete."
        } else {
          state = 3
          msg = "Shift ended below target."
        }
      } else if score >= score_target && completed >= 52 && rep >= 55.0 {
        state = 2
        msg = "Route cleared early."
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
      draw_city_blocks(world_x, world_y, world_w, world_h, scene_t)
      draw_wind_tunnels(winds, scene_t)
      draw_depot(depot, scene_t)
      draw_pads(pads, deliveries, scene_t)
      draw_crates(crates, scene_t)
      draw_birds(birds, scene_t)
      draw_particles(parts)
      draw_glider(glider, scene_t)

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
        rep,
        glider.hull,
        glider.fuel,
        glider.bags,
        glider.bag_cap,
        combo,
        completed,
        failed,
        if msg_t > 0.0 {
          msg
        } else {
          ""
        },
      )
      draw_deliveries_panel(panel_x, panel_y, panel_w2, deliveries, scene_t)
      draw_touch_controls(sw, sh, mouse.x, mouse.y, hold, touch_count)

      if state == 2 || state == 3 {
        draw_end(
          sw,
          sh,
          state == 2,
          score,
          score_target,
          rep,
          completed,
          failed,
        )
      }
    }

    @raylib.end_drawing()
  }
}
