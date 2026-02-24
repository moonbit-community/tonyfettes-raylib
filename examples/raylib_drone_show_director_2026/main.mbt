///|
struct Director {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut heading : Float
  mut energy : Float
  energy_max : Float
  mut action_cd : Float
  mut sync_t : Float
  mut boost_heat : Float
  mut step_t : Float
}

///|
struct Drone {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut battery : Float
  mut temp : Float
  mut state : Int
  mut flash_t : Float
  id : Int
}

///|
struct Request {
  mut active : Bool
  mut id : Int
  mut pattern : Int
  mut deadline : Float
  mut max_deadline : Float
  mut min_quality : Float
  mut reward : Int
  mut progress : Float
  mut pulse : Float
}

///|
struct Gust {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut radius : Float
  mut life : Float
  mut strength : Float
  mut pulse : Float
}

///|
struct Firework {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut burst_t : Float
  mut color : Int
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
struct Station {
  x : Float
  y : Float
  w : Float
  h : Float
  kind : Int
}

///|
struct Vec2f {
  x : Float
  y : Float
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
fn pattern_name(pattern : Int) -> String {
  match pattern {
    0 => "Solar Ring"
    1 => "Dragon Spiral"
    2 => "River Wave"
    3 => "Lotus Bloom"
    _ => "Phoenix Wings"
  }
}

///|
fn pattern_short(pattern : Int) -> String {
  match pattern {
    0 => "Ring"
    1 => "Spiral"
    2 => "Wave"
    3 => "Lotus"
    _ => "Wings"
  }
}

///|
fn pattern_color(pattern : Int) -> @raylib.Color {
  match pattern {
    0 => @raylib.Color::new(120, 206, 255, 220)
    1 => @raylib.Color::new(255, 176, 116, 220)
    2 => @raylib.Color::new(146, 246, 188, 220)
    3 => @raylib.Color::new(246, 186, 248, 220)
    _ => @raylib.Color::new(250, 226, 132, 220)
  }
}

///|
fn pattern_target(
  pattern : Int,
  idx : Int,
  count : Int,
  cx : Float,
  cy : Float,
  phase : Float,
) -> Vec2f {
  let t : Float = Float::from_int(idx) / Float::from_int(count)
  let a : Float = t * 6.283185 + phase

  match pattern {
    0 => {
      let r : Float = 142.0 + sinf(phase * 0.9 + t * 10.0) * 16.0
      { x: cx + cosf(a) * r, y: cy + sinf(a) * r }
    }
    1 => {
      let layer : Float = 48.0 + t * 210.0
      let aa : Float = a * 1.5 + t * 4.0
      { x: cx + cosf(aa) * layer, y: cy + sinf(aa) * layer * 0.72 }
    }
    2 => {
      let px : Float = cx - 250.0 + t * 500.0
      let py : Float = cy + sinf(t * 18.0 + phase * 3.2) * 112.0
      { x: px, y: py }
    }
    3 => {
      let rr : Float = 60.0 + (sinf(t * 12.0 + phase * 2.4) * 0.5 + 0.5) * 168.0
      let aa : Float = a * 2.2
      { x: cx + cosf(aa) * rr * 0.62, y: cy + sinf(aa) * rr }
    }
    _ => {
      let wing : Float = if t < 0.5 { -1.0 } else { 1.0 }
      let p : Float = if t < 0.5 { t * 2.0 } else { (t - 0.5) * 2.0 }
      {
        x: cx + wing * (70.0 + p * 210.0),
        y: cy + sinf(p * 10.0 + phase * 4.0) * 84.0 - p * 64.0,
      }
    }
  }
}

///|
fn clear_requests(requests : Array[Request]) -> Unit {
  for i = 0; i < requests.length(); i = i + 1 {
    requests[i].active = false
    requests[i].id = i + 1
    requests[i].pattern = 0
    requests[i].deadline = 0.0
    requests[i].max_deadline = 0.0
    requests[i].min_quality = 0.0
    requests[i].reward = 0
    requests[i].progress = 0.0
    requests[i].pulse = 0.0
  }
}

///|
fn clear_gusts(gusts : Array[Gust]) -> Unit {
  for i = 0; i < gusts.length(); i = i + 1 {
    gusts[i].active = false
    gusts[i].x = 0.0
    gusts[i].y = 0.0
    gusts[i].vx = 0.0
    gusts[i].vy = 0.0
    gusts[i].radius = 0.0
    gusts[i].life = 0.0
    gusts[i].strength = 0.0
    gusts[i].pulse = 0.0
  }
}

///|
fn clear_fireworks(fireworks : Array[Firework]) -> Unit {
  for i = 0; i < fireworks.length(); i = i + 1 {
    fireworks[i].active = false
    fireworks[i].x = 0.0
    fireworks[i].y = 0.0
    fireworks[i].vx = 0.0
    fireworks[i].vy = 0.0
    fireworks[i].life = 0.0
    fireworks[i].burst_t = 0.0
    fireworks[i].color = 0
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
      x + randf(-6.0, 6.0),
      y + randf(-6.0, 6.0),
      randf(-140.0, 140.0),
      randf(-140.0, 120.0),
      randf(0.3, 1.0),
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
    parts[i].vy = parts[i].vy * (1.0 - dt * 1.9) + dt * 28.0
  }
}

///|
fn spawn_request(requests : Array[Request], wave : Int, serial : Int) -> Bool {
  let mut placed : Bool = false
  for i = 0; i < requests.length(); i = i + 1 {
    if requests[i].active {
      continue
    }

    requests[i].active = true
    requests[i].id = serial
    requests[i].pattern = randi(0, 4)
    let base_deadline : Float = randf(34.0, 68.0)
    requests[i].deadline = maxf(
      18.0,
      base_deadline - Float::from_int(wave) * 1.3,
    )
    requests[i].max_deadline = requests[i].deadline
    requests[i].min_quality = randf(58.0, 82.0) + Float::from_int(wave) * 0.7
    requests[i].reward = 120 + requests[i].pattern * 20 + wave * 8
    requests[i].progress = 0.0
    requests[i].pulse = randf(0.0, 12.0)

    placed = true
    break
  }
  placed
}

///|
fn spawn_gust(
  gusts : Array[Gust],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  pressure : Float,
) -> Bool {
  let mut placed : Bool = false
  for i = 0; i < gusts.length(); i = i + 1 {
    if gusts[i].active {
      continue
    }

    let edge : Int = randi(0, 3)
    if edge == 0 {
      gusts[i].x = world_l - 20.0
      gusts[i].y = randf(world_t + 40.0, world_b - 40.0)
      gusts[i].vx = randf(50.0, 130.0)
      gusts[i].vy = randf(-56.0, 56.0)
    } else if edge == 1 {
      gusts[i].x = world_r + 20.0
      gusts[i].y = randf(world_t + 40.0, world_b - 40.0)
      gusts[i].vx = -randf(50.0, 130.0)
      gusts[i].vy = randf(-56.0, 56.0)
    } else if edge == 2 {
      gusts[i].x = randf(world_l + 40.0, world_r - 40.0)
      gusts[i].y = world_t - 20.0
      gusts[i].vx = randf(-64.0, 64.0)
      gusts[i].vy = randf(50.0, 130.0)
    } else {
      gusts[i].x = randf(world_l + 40.0, world_r - 40.0)
      gusts[i].y = world_b + 20.0
      gusts[i].vx = randf(-64.0, 64.0)
      gusts[i].vy = -randf(50.0, 130.0)
    }

    gusts[i].active = true
    gusts[i].radius = randf(56.0, 110.0)
    gusts[i].life = randf(5.0, 9.0)
    gusts[i].strength = randf(38.0, 86.0) + pressure * randf(8.0, 28.0)
    gusts[i].pulse = randf(0.0, 16.0)
    placed = true
    break
  }
  placed
}

///|
fn spawn_firework(
  fireworks : Array[Firework],
  world_l : Float,
  world_r : Float,
  world_b : Float,
) -> Bool {
  let mut placed : Bool = false
  for i = 0; i < fireworks.length(); i = i + 1 {
    if fireworks[i].active {
      continue
    }
    fireworks[i].active = true
    fireworks[i].x = randf(world_l + 40.0, world_r - 40.0)
    fireworks[i].y = world_b + 18.0
    fireworks[i].vx = randf(-24.0, 24.0)
    fireworks[i].vy = -randf(170.0, 280.0)
    fireworks[i].life = randf(0.9, 1.5)
    fireworks[i].burst_t = randf(0.4, 1.1)
    fireworks[i].color = randi(0, 4)
    placed = true
    break
  }
  placed
}

///|
fn formation_quality(
  drones : Array[Drone],
  pattern : Int,
  cx : Float,
  cy : Float,
  phase : Float,
) -> Float {
  let mut total : Float = 0.0
  let mut n : Int = 0

  for i = 0; i < drones.length(); i = i + 1 {
    if not(drones[i].active) {
      continue
    }
    let target : Vec2f = pattern_target(
      pattern,
      i,
      drones.length(),
      cx,
      cy,
      phase,
    )
    let d : Float = dist2(drones[i].x, drones[i].y, target.x, target.y).sqrt()
    let state_penalty : Float = if drones[i].state == 0 {
      0.0
    } else if drones[i].state == 1 {
      26.0
    } else {
      52.0
    }
    total = total + d + state_penalty
    n = n + 1
  }

  if n <= 0 {
    0.0
  } else {
    clampf(100.0 - total / Float::from_int(n) * 0.54, 0.0, 100.0)
  }
}

///|
fn nearest_station_kind(
  stations : Array[Station],
  x : Float,
  y : Float,
  radius : Float,
) -> Int {
  let mut found : Int = -1
  let mut best : Float = radius * radius
  for i = 0; i < stations.length(); i = i + 1 {
    let cx : Float = stations[i].x + stations[i].w * 0.5
    let cy : Float = stations[i].y + stations[i].h * 0.5
    let d2v : Float = dist2(x, y, cx, cy)
    if d2v <= best {
      best = d2v
      found = stations[i].kind
    }
  }
  found
}

///|
fn active_requests_count(requests : Array[Request]) -> Int {
  let mut c : Int = 0
  for i = 0; i < requests.length(); i = i + 1 {
    if requests[i].active {
      c = c + 1
    }
  }
  c
}

///|
fn draw_background(
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
    @raylib.Color::new(14, 22, 38, 255),
    @raylib.Color::new(9, 14, 26, 255),
  )

  for i = 0; i < 22; i = i + 1 {
    let y0 : Float = Float::from_int(world_y) +
      Float::from_int(i) * Float::from_int(world_h) / 22.0
    let wave : Float = sinf(scene_t * 1.4 + Float::from_int(i) * 0.7) * 0.5 +
      0.5
    let alpha : Int = 8 + (wave * 26.0).to_int()
    @raylib.draw_rectangle(
      world_x,
      y0.to_int(),
      world_w,
      2,
      @raylib.Color::new(44, 86, 140, alpha),
    )
  }
}

///|
fn draw_stage(cx : Float, cy : Float, radius : Float, scene_t : Float) -> Unit {
  @raylib.draw_circle_v(
    @raylib.Vector2::new(cx, cy),
    radius,
    @raylib.Color::new(26, 34, 54, 228),
  )
  @raylib.draw_circle_lines(
    cx.to_int(),
    cy.to_int(),
    radius,
    @raylib.Color::new(148, 176, 214, 214),
  )

  for i = 0; i < 6; i = i + 1 {
    let p : Float = sinf(scene_t * 2.0 + Float::from_int(i) * 0.82) * 0.5 + 0.5
    let rr : Float = radius * (0.38 + Float::from_int(i) * 0.12)
    @raylib.draw_circle_lines(
      cx.to_int(),
      cy.to_int(),
      rr + p * 3.0,
      @raylib.Color::new(92, 136, 194, 64),
    )
  }
}

///|
fn draw_targets(
  drones : Array[Drone],
  pattern : Int,
  cx : Float,
  cy : Float,
  phase : Float,
  scene_t : Float,
) -> Unit {
  let col = pattern_color(pattern)
  for i = 0; i < drones.length(); i = i + 1 {
    let t : Vec2f = pattern_target(pattern, i, drones.length(), cx, cy, phase)
    let pulse : Float = sinf(scene_t * 6.0 + Float::from_int(i) * 0.18) * 0.5 +
      0.5
    @raylib.draw_circle_v(
      @raylib.Vector2::new(t.x, t.y),
      2.0 + pulse * 2.0,
      @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 96),
    )
  }
}

///|
fn draw_stations(
  stations : Array[Station],
  director : Director,
  scene_t : Float,
) -> Unit {
  for i = 0; i < stations.length(); i = i + 1 {
    let s = stations[i]
    let near : Bool = inside_rectf(director.x, director.y, s.x, s.y, s.w, s.h)

    let base = match s.kind {
      0 => @raylib.Color::new(122, 222, 158, if near { 238 } else { 172 })
      1 => @raylib.Color::new(112, 196, 246, if near { 238 } else { 172 })
      _ => @raylib.Color::new(246, 202, 112, if near { 238 } else { 172 })
    }

    @raylib.draw_rectangle(
      s.x.to_int(),
      s.y.to_int(),
      s.w.to_int(),
      s.h.to_int(),
      @raylib.Color::new(24, 30, 44, 232),
    )
    @raylib.draw_rectangle(
      (s.x + 4.0).to_int(),
      (s.y + 4.0).to_int(),
      (s.w - 8.0).to_int(),
      (s.h - 8.0).to_int(),
      base,
    )
    @raylib.draw_rectangle_lines(
      s.x.to_int(),
      s.y.to_int(),
      s.w.to_int(),
      s.h.to_int(),
      @raylib.Color::new(224, 234, 248, 212),
    )

    let label : String = match s.kind {
      0 => "RECHARGE"
      1 => "COOLING"
      _ => "BROADCAST"
    }

    @raylib.draw_text(
      label,
      s.x.to_int() + s.w.to_int() / 2 - @raylib.measure_text(label, 18) / 2,
      s.y.to_int() + s.h.to_int() / 2 - 9,
      18,
      @raylib.Color::new(18, 24, 34, 242),
    )

    let pulse : Float = sinf(scene_t * 4.6 + Float::from_int(i) * 1.7) * 0.5 +
      0.5
    @raylib.draw_circle_v(
      @raylib.Vector2::new(s.x + s.w * 0.5, s.y + s.h * 0.5),
      10.0 + pulse * 7.0,
      @raylib.Color::new(250, 252, 255, if near { 86 } else { 42 }),
    )
  }
}

///|
fn draw_gusts(gusts : Array[Gust], scene_t : Float) -> Unit {
  for i = 0; i < gusts.length(); i = i + 1 {
    if not(gusts[i].active) {
      continue
    }
    let pulse : Float = sinf(scene_t * 5.0 + gusts[i].pulse) * 0.5 + 0.5
    let rr : Float = gusts[i].radius * (0.86 + pulse * 0.18)
    @raylib.draw_circle_lines(
      gusts[i].x.to_int(),
      gusts[i].y.to_int(),
      rr,
      @raylib.Color::new(120, 190, 255, 166),
    )
    @raylib.draw_circle_lines(
      gusts[i].x.to_int(),
      gusts[i].y.to_int(),
      rr * 0.62,
      @raylib.Color::new(176, 224, 255, 122),
    )
  }
}

///|
fn draw_drones(drones : Array[Drone], scene_t : Float) -> Unit {
  for i = 0; i < drones.length(); i = i + 1 {
    let d = drones[i]
    if not(d.active) {
      continue
    }

    let b : Float = clampf(d.battery / 100.0, 0.0, 1.0)
    let t : Float = clampf(d.temp / 100.0, 0.0, 1.0)
    let red : Int = 86 + (t * 168.0).to_int()
    let green : Int = 94 + (b * 150.0).to_int()
    let blue : Int = 186 + (b * 48.0).to_int() - (t * 80.0).to_int()

    let radius : Float = if d.state == 2 {
      8.6
    } else if d.state == 1 {
      7.8
    } else {
      7.2
    }

    @raylib.draw_circle_v(
      @raylib.Vector2::new(d.x, d.y),
      radius,
      @raylib.Color::new(
        red,
        green,
        clampf(Float::from_int(blue), 50.0, 255.0).to_int(),
        240,
      ),
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(d.x, d.y),
      2.6,
      @raylib.Color::new(250, 252, 255, 240),
    )

    let flash : Float = sinf(scene_t * 9.0 + d.flash_t) * 0.5 + 0.5
    @raylib.draw_circle_v(
      @raylib.Vector2::new(d.x, d.y),
      10.0 + flash * 4.0,
      @raylib.Color::new(182, 224, 255, 30 + (flash * 50.0).to_int()),
    )
  }
}

///|
fn draw_fireworks(fireworks : Array[Firework]) -> Unit {
  for i = 0; i < fireworks.length(); i = i + 1 {
    if not(fireworks[i].active) {
      continue
    }
    @raylib.draw_circle_v(
      @raylib.Vector2::new(fireworks[i].x, fireworks[i].y),
      3.2,
      match fireworks[i].color {
        0 => @raylib.Color::new(255, 156, 126, 220)
        1 => @raylib.Color::new(132, 228, 166, 220)
        2 => @raylib.Color::new(134, 210, 255, 220)
        3 => @raylib.Color::new(244, 194, 255, 220)
        _ => @raylib.Color::new(255, 238, 152, 220)
      },
    )
  }
}

///|
fn draw_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      continue
    }

    let alpha : Int = clampf(parts[i].life * 255.0, 0.0, 255.0).to_int()
    let color = if parts[i].kind == 0 {
      @raylib.Color::new(156, 222, 252, alpha)
    } else if parts[i].kind == 1 {
      @raylib.Color::new(252, 166, 118, alpha)
    } else {
      @raylib.Color::new(255, 238, 172, alpha)
    }

    @raylib.draw_circle_v(
      @raylib.Vector2::new(parts[i].x, parts[i].y),
      parts[i].size,
      color,
    )
  }
}

///|
fn draw_director(director : Director, scene_t : Float) -> Unit {
  let bob : Float = sinf(scene_t * 11.0 + director.step_t * 0.07) * 1.2
  @raylib.draw_circle_v(
    @raylib.Vector2::new(director.x, director.y + bob),
    16.0,
    @raylib.Color::new(254, 220, 160, 242),
  )
  @raylib.draw_circle_v(
    @raylib.Vector2::new(director.x, director.y - 16.0 + bob),
    9.5,
    @raylib.Color::new(252, 252, 255, 244),
  )

  if director.sync_t > 0.0 {
    let pulse : Float = sinf(director.sync_t * 8.0) * 0.5 + 0.5
    @raylib.draw_circle_lines(
      director.x.to_int(),
      director.y.to_int(),
      72.0 + pulse * 56.0,
      @raylib.Color::new(248, 214, 124, 188),
    )
  }
}

///|
fn draw_requests_panel(
  panel_x : Int,
  panel_y : Int,
  panel_w : Int,
  requests : Array[Request],
  current_pattern : Int,
  quality : Float,
  scene_t : Float,
) -> Unit {
  @raylib.draw_text(
    "Audience Requests",
    panel_x + 18,
    panel_y + 398,
    30,
    @raylib.Color::new(236, 246, 255, 238),
  )

  let mut y : Int = panel_y + 438
  for i = 0; i < requests.length(); i = i + 1 {
    if not(requests[i].active) {
      continue
    }

    let urgency : Float = if requests[i].max_deadline <= 0.001 {
      0.0
    } else {
      clampf(1.0 - requests[i].deadline / requests[i].max_deadline, 0.0, 1.0)
    }

    let blink : Float = sinf(scene_t * 7.0 + requests[i].pulse) * 0.5 + 0.5
    let matching : Bool = current_pattern == requests[i].pattern
    let row_h : Int = 84

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
      @raylib.Color::new(40 + (urgency * 88.0).to_int(), 54, 72, 230),
    )
    @raylib.draw_rectangle_lines(
      panel_x + 12,
      y,
      panel_w - 24,
      row_h,
      @raylib.Color::new(186, 208, 232, 176),
    )

    let pc = pattern_color(requests[i].pattern)
    @raylib.draw_circle_v(
      @raylib.Vector2::new(
        Float::from_int(panel_x + 42),
        Float::from_int(y + 42),
      ),
      16.0,
      pc,
    )

    @raylib.draw_text(
      "#\{requests[i].id} \{pattern_short(requests[i].pattern)}",
      panel_x + 66,
      y + 10,
      23,
      @raylib.Color::new(236, 246, 255, 236),
    )

    let dd_txt : String = "\{requests[i].deadline.to_int()}s"
    @raylib.draw_text(
      dd_txt,
      panel_x + panel_w - 24 - @raylib.measure_text(dd_txt, 22),
      y + 12,
      22,
      if urgency > 0.72 {
        @raylib.Color::new(255, 132, 118, 246)
      } else {
        @raylib.Color::new(214, 232, 252, 236)
      },
    )

    @raylib.draw_text(
      "Need Q\{requests[i].min_quality.to_int()}  Reward \{requests[i].reward}",
      panel_x + 66,
      y + 40,
      18,
      @raylib.Color::new(198, 220, 244, 226),
    )

    let progress_bar_w : Int = 136
    @raylib.draw_rectangle(
      panel_x + panel_w - progress_bar_w - 24,
      y + 46,
      progress_bar_w,
      16,
      @raylib.Color::new(18, 22, 32, 236),
    )
    @raylib.draw_rectangle(
      panel_x + panel_w - progress_bar_w - 22,
      y + 48,
      (Float::from_int(progress_bar_w - 4) *
      clampf(requests[i].progress / 100.0, 0.0, 1.0)).to_int(),
      12,
      if matching && quality >= requests[i].min_quality {
        @raylib.Color::new(126, 236, 152, 232)
      } else {
        @raylib.Color::new(244, 204, 124, 180 + (blink * 60.0).to_int())
      },
    )
    @raylib.draw_rectangle_lines(
      panel_x + panel_w - progress_bar_w - 24,
      y + 46,
      progress_bar_w,
      16,
      @raylib.Color::new(210, 224, 242, 180),
    )

    y = y + row_h + 8
    if y > panel_y + 820 {
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
  score_target : Int,
  rep : Float,
  quality : Float,
  energy : Float,
  heat_avg : Float,
  active_drones : Int,
  drone_losses : Int,
  combo : Int,
  pattern : Int,
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
    @raylib.Color::new(166, 188, 214, 196),
  )

  @raylib.draw_text(
    "DRONE SHOW DIRECTOR 2026",
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
    panel_y + 58,
    28,
    @raylib.Color::new(236, 246, 255, 238),
  )
  @raylib.draw_text(
    "Score \{score}/\{score_target}",
    panel_x + 20,
    panel_y + 92,
    26,
    @raylib.Color::new(250, 226, 136, 236),
  )
  @raylib.draw_text(
    "Pattern: \{pattern_name(pattern)}",
    panel_x + 20,
    panel_y + 124,
    22,
    pattern_color(pattern),
  )
  @raylib.draw_text(
    "Combo x\{combo}  Drones \{active_drones}  Lost \{drone_losses}",
    panel_x + 20,
    panel_y + 152,
    22,
    @raylib.Color::new(204, 226, 246, 232),
  )

  fn meter(
    title : String,
    value : Float,
    max_value : Float,
    x : Int,
    y : Int,
    w : Int,
    h : Int,
    color : @raylib.Color,
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
      color,
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
      @raylib.Color::new(226, 238, 250, 232),
    )
  }

  meter(
    "Reputation",
    rep,
    100.0,
    panel_x + 20,
    panel_y + 194,
    panel_w - 40,
    22,
    @raylib.Color::new(116, 224, 156, 232),
  )
  meter(
    "Formation Quality",
    quality,
    100.0,
    panel_x + 20,
    panel_y + 242,
    panel_w - 40,
    22,
    @raylib.Color::new(120, 204, 252, 232),
  )
  meter(
    "Director Energy",
    energy,
    100.0,
    panel_x + 20,
    panel_y + 290,
    panel_w - 40,
    22,
    @raylib.Color::new(250, 206, 126, 232),
  )
  meter(
    "Drone Heat",
    heat_avg,
    100.0,
    panel_x + 20,
    panel_y + 338,
    panel_w - 40,
    22,
    @raylib.Color::new(248, 136, 104, 232),
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
    "Move: WASD/Arrows\nBoost: Space/J\nAct: L/U\nCycle Pattern: Q/E",
    panel_x + 24,
    panel_y + panel_h - 124,
    20,
    @raylib.Color::new(190, 216, 244, 230),
  )

  @raylib.draw_text(
    msg,
    panel_x + 20,
    panel_y + 372,
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
        @raylib.Color::new(36, 52, 78, 136)
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

  let boost_x : Float = Float::from_int(sw - 320)
  let boost_y : Float = Float::from_int(sh - 156)
  let act_x : Float = Float::from_int(sw - 200)
  let act_y : Float = Float::from_int(sh - 230)
  let cycle_x : Float = Float::from_int(sw - 92)
  let cycle_y : Float = Float::from_int(sh - 146)

  let boost = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, boost_x, boost_y, 56.0,
  )
  let act = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, act_x, act_y, 46.0,
  )
  let cycle = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, cycle_x, cycle_y, 42.0,
  )

  fn button(
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

  button(boost_x, boost_y, 56.0, "BOOST", boost, 68, 170, 242)
  button(act_x, act_y, 46.0, "ACT", act, 84, 208, 152)
  button(cycle_x, cycle_y, 42.0, "NEXT", cycle, 246, 188, 102)
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
    "DRONE SHOW DIRECTOR 2026",
    sw / 2 - @raylib.measure_text("DRONE SHOW DIRECTOR 2026", 70) / 2,
    176,
    70,
    @raylib.Color::new(236, 246, 255, 246),
  )
  @raylib.draw_text(
    "Conduct a swarm in real time: switch formations, satisfy audience requests, and survive weather turbulence.",
    sw / 2 -
    @raylib.measure_text(
      "Conduct a swarm in real time: switch formations, satisfy audience requests, and survive weather turbulence.",
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
    "Mobile: D-pad + BOOST + ACT + NEXT",
    sw / 2 - @raylib.measure_text("Mobile: D-pad + BOOST + ACT + NEXT", 24) / 2,
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
  served : Int,
  failed : Int,
  losses : Int,
) -> Unit {
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 222))
  let title : String = if win { "SHOW OVATION" } else { "SHOW COLLAPSED" }

  @raylib.draw_text(
    title,
    sw / 2 - @raylib.measure_text(title, 78) / 2,
    206,
    78,
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
    "Served: \{served}  Failed: \{failed}  Drone Losses: \{losses}",
    sw / 2 -
    @raylib.measure_text(
      "Served: \{served}  Failed: \{failed}  Drone Losses: \{losses}",
      30,
    ) /
    2,
    420,
    30,
    @raylib.Color::new(206, 224, 244, 232),
  )
  @raylib.draw_text(
    "Press Enter / R to run another show",
    sw / 2 - @raylib.measure_text("Press Enter / R to run another show", 32) / 2,
    528,
    32,
    @raylib.Color::new(244, 250, 255, 236),
  )
}

///|
fn main {
  let sw : Int = 1700
  let sh : Int = 960
  @raylib.init_window(sw, sh, "raylib [game] drone show director 2026")
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

  let stage_cx : Float = world_l + Float::from_int(world_w) * 0.52
  let stage_cy : Float = world_t + Float::from_int(world_h) * 0.54
  let stage_r : Float = 296.0

  let stations : Array[Station] = [
    { x: world_l + 34.0, y: world_b - 128.0, w: 196.0, h: 92.0, kind: 0 },
    { x: world_r - 230.0, y: world_b - 128.0, w: 196.0, h: 92.0, kind: 1 },
    { x: stage_cx - 96.0, y: world_t + 38.0, w: 192.0, h: 92.0, kind: 2 },
  ]

  let drones : Array[Drone] = Array::makei(58, fn(i) {
    {
      active: true,
      x: stage_cx + randf(-120.0, 120.0),
      y: stage_cy + randf(-90.0, 90.0),
      vx: randf(-14.0, 14.0),
      vy: randf(-14.0, 14.0),
      battery: randf(76.0, 100.0),
      temp: randf(14.0, 24.0),
      state: 0,
      flash_t: randf(0.0, 10.0),
      id: i + 1,
    }
  })

  let requests : Array[Request] = Array::makei(10, fn(i) {
    {
      active: false,
      id: i + 1,
      pattern: 0,
      deadline: 0.0,
      max_deadline: 0.0,
      min_quality: 0.0,
      reward: 0,
      progress: 0.0,
      pulse: 0.0,
    }
  })

  let gusts : Array[Gust] = Array::makei(24, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      radius: 0.0,
      life: 0.0,
      strength: 0.0,
      pulse: 0.0,
    }
  })

  let fireworks : Array[Firework] = Array::makei(20, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      life: 0.0,
      burst_t: 0.0,
      color: 0,
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

  let director : Director = {
    x: stage_cx,
    y: stage_cy + 20.0,
    vx: 0.0,
    vy: 0.0,
    heading: 0.0,
    energy: 100.0,
    energy_max: 100.0,
    action_cd: 0.0,
    sync_t: 0.0,
    boost_heat: 0.0,
    step_t: 0.0,
  }

  let mut state : Int = 0 // 0 menu 1 play 2 win 3 lose
  let mut timer : Float = 420.0
  let mut scene_t : Float = 0.0

  let mut current_pattern : Int = 0
  let mut pattern_phase : Float = 0.0
  let mut quality : Float = 0.0

  let mut score : Int = 0
  let mut score_target : Int = 9800
  let mut rep : Float = 90.0
  let mut combo : Int = 0
  let mut served : Int = 0
  let mut failed : Int = 0
  let mut drone_losses : Int = 0

  let mut order_serial : Int = 1
  let mut wave : Int = 1
  let mut order_spawn_cd : Float = 1.2
  let mut gust_spawn_cd : Float = 3.4
  let mut firework_cd : Float = 0.75

  let mut msg : String = ""
  let mut msg_t : Float = 0.0

  fn reset_run() -> Unit {
    clear_requests(requests)
    clear_gusts(gusts)
    clear_fireworks(fireworks)
    clear_particles(parts)

    for i = 0; i < drones.length(); i = i + 1 {
      drones[i].active = true
      drones[i].x = stage_cx + randf(-120.0, 120.0)
      drones[i].y = stage_cy + randf(-90.0, 90.0)
      drones[i].vx = randf(-14.0, 14.0)
      drones[i].vy = randf(-14.0, 14.0)
      drones[i].battery = randf(76.0, 100.0)
      drones[i].temp = randf(14.0, 24.0)
      drones[i].state = 0
      drones[i].flash_t = randf(0.0, 10.0)
    }

    director.x = stage_cx
    director.y = stage_cy + 20.0
    director.vx = 0.0
    director.vy = 0.0
    director.heading = 0.0
    director.energy = 100.0
    director.action_cd = 0.0
    director.sync_t = 0.0
    director.boost_heat = 0.0
    director.step_t = 0.0

    timer = 420.0
    scene_t = 0.0
    current_pattern = 0
    pattern_phase = 0.0
    quality = 0.0

    score = 0
    score_target = 9800
    rep = 90.0
    combo = 0
    served = 0
    failed = 0
    drone_losses = 0

    order_serial = 1
    wave = 1
    order_spawn_cd = 1.2
    gust_spawn_cd = 3.4
    firework_cd = 0.75

    msg = "Switch patterns and satisfy audience requests."
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
    if director.action_cd > 0.0 {
      director.action_cd = director.action_cd - dt
      if director.action_cd < 0.0 {
        director.action_cd = 0.0
      }
    }
    if director.sync_t > 0.0 {
      director.sync_t = director.sync_t - dt
      if director.sync_t < 0.0 {
        director.sync_t = 0.0
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
      if wave > 14 {
        wave = 14
      }

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
      let mut cycle_press : Bool = @raylib.is_key_pressed(@raylib.KeyQ) ||
        @raylib.is_key_pressed(@raylib.KeyE)

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
          Float::from_int(sw - 320),
          Float::from_int(sh - 156),
          56.0,
        ) {
        boost_hold = true
      }
      if pointer_on_circle(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          Float::from_int(sw - 200),
          Float::from_int(sh - 230),
          46.0,
        ) {
        action_press = true
      }
      if pointer_on_circle(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          Float::from_int(sw - 92),
          Float::from_int(sh - 146),
          42.0,
        ) {
        cycle_press = true
      }

      if cycle_press {
        current_pattern = (current_pattern + 1) % 5
        msg = "Pattern switched to \{pattern_name(current_pattern)}"
        msg_t = 1.0
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

      let mut speed : Float = 230.0
      if boost_hold && director.energy > 0.4 {
        speed = 360.0
        director.energy = director.energy - dt * 38.0
        director.boost_heat = clampf(director.boost_heat + dt * 0.9, 0.0, 1.0)
      } else {
        director.boost_heat = clampf(director.boost_heat - dt * 0.85, 0.0, 1.0)
        director.energy = minf(director.energy_max, director.energy + dt * 16.0)
      }

      director.vx = input_x * speed
      director.vy = input_y * speed
      director.x = director.x + director.vx * dt
      director.y = director.y + director.vy * dt
      if director.vx != 0.0 || director.vy != 0.0 {
        director.step_t = director.step_t + dt * speed
      }

      if director.x < world_l + 18.0 {
        director.x = world_l + 18.0
      }
      if director.x > world_r - 18.0 {
        director.x = world_r - 18.0
      }
      if director.y < world_t + 18.0 {
        director.y = world_t + 18.0
      }
      if director.y > world_b - 18.0 {
        director.y = world_b - 18.0
      }

      if action_press && director.action_cd <= 0.0 {
        let near : Int = nearest_station_kind(
          stations,
          director.x,
          director.y,
          96.0,
        )
        if near == 0 {
          let mut revived : Bool = false
          for i = 0; i < drones.length(); i = i + 1 {
            if not(drones[i].active) && not(revived) {
              drones[i].active = true
              drones[i].x = director.x + randf(-30.0, 30.0)
              drones[i].y = director.y + randf(-30.0, 30.0)
              drones[i].vx = randf(-20.0, 20.0)
              drones[i].vy = randf(-20.0, 20.0)
              drones[i].battery = 58.0
              drones[i].temp = 28.0
              drones[i].state = 1
              revived = true
              drone_losses = maxi(0, drone_losses - 1)
            }
            if drones[i].active {
              drones[i].battery = minf(100.0, drones[i].battery + 22.0)
            }
          }
          director.energy = minf(director.energy_max, director.energy + 32.0)
          msg = if revived {
            "Recharge wave restored a drone and battery pack."
          } else {
            "Recharge wave boosted all active drones."
          }
          msg_t = 1.2
          burst_particles(
            parts,
            stations[0].x + 96.0,
            stations[0].y + 46.0,
            18,
            0,
          )
        } else if near == 1 {
          for i = 0; i < drones.length(); i = i + 1 {
            if drones[i].active {
              drones[i].temp = maxf(0.0, drones[i].temp - 26.0)
            }
          }
          msg = "Cooling mist lowered swarm temperature."
          msg_t = 1.1
          burst_particles(
            parts,
            stations[1].x + 98.0,
            stations[1].y + 46.0,
            18,
            0,
          )
        } else if near == 2 {
          director.sync_t = 4.2
          msg = "Broadcast sync pulse active."
          msg_t = 1.0
          burst_particles(
            parts,
            stations[2].x + 96.0,
            stations[2].y + 46.0,
            16,
            2,
          )
        } else {
          msg = "Act near a station: RECHARGE / COOLING / BROADCAST"
          msg_t = 1.0
        }
        director.action_cd = 0.26
      }

      let storm_pressure : Float = clampf(1.0 - timer / 420.0, 0.0, 1.0)
      pattern_phase = pattern_phase + dt * (0.7 + storm_pressure * 1.2)

      // Spawns
      order_spawn_cd = order_spawn_cd - dt
      if order_spawn_cd <= 0.0 {
        ignore(spawn_request(requests, wave, order_serial))
        order_serial = order_serial + 1
        order_spawn_cd = maxf(1.2, 4.8 - Float::from_int(wave) * 0.24)
      }

      gust_spawn_cd = gust_spawn_cd - dt
      if gust_spawn_cd <= 0.0 {
        ignore(
          spawn_gust(gusts, world_l, world_t, world_r, world_b, storm_pressure),
        )
        gust_spawn_cd = maxf(0.9, 3.4 - storm_pressure * 1.7)
      }

      firework_cd = firework_cd - dt
      if firework_cd <= 0.0 {
        ignore(spawn_firework(fireworks, world_l, world_r, world_b))
        firework_cd = randf(0.42, 1.0)
      }

      // Update gusts
      for i = 0; i < gusts.length(); i = i + 1 {
        if not(gusts[i].active) {
          continue
        }
        gusts[i].life = gusts[i].life - dt
        gusts[i].pulse = gusts[i].pulse + dt * 4.5
        gusts[i].x = gusts[i].x + gusts[i].vx * dt
        gusts[i].y = gusts[i].y + gusts[i].vy * dt

        if gusts[i].life <= 0.0 ||
          gusts[i].x < world_l - 180.0 ||
          gusts[i].x > world_r + 180.0 ||
          gusts[i].y < world_t - 180.0 ||
          gusts[i].y > world_b + 180.0 {
          gusts[i].active = false
        }
      }

      // Update fireworks
      for i = 0; i < fireworks.length(); i = i + 1 {
        if not(fireworks[i].active) {
          continue
        }
        fireworks[i].life = fireworks[i].life - dt
        fireworks[i].burst_t = fireworks[i].burst_t - dt
        fireworks[i].x = fireworks[i].x + fireworks[i].vx * dt
        fireworks[i].y = fireworks[i].y + fireworks[i].vy * dt
        fireworks[i].vy = fireworks[i].vy + dt * 54.0

        if fireworks[i].burst_t <= 0.0 {
          fireworks[i].active = false
          for _j = 0; _j < 20; _j = _j + 1 {
            spawn_particle(
              parts,
              fireworks[i].x,
              fireworks[i].y,
              randf(-180.0, 180.0),
              randf(-180.0, 180.0),
              randf(0.4, 1.1),
              randf(2.0, 5.0),
              2,
            )
          }
        }

        if fireworks[i].life <= 0.0 {
          fireworks[i].active = false
        }
      }

      // Update drones
      let mut active_count : Int = 0
      for i = 0; i < drones.length(); i = i + 1 {
        if not(drones[i].active) {
          continue
        }

        let target : Vec2f = pattern_target(
          current_pattern,
          i,
          drones.length(),
          stage_cx,
          stage_cy,
          pattern_phase,
        )
        let dx : Float = target.x - drones[i].x
        let dy : Float = target.y - drones[i].y

        let mut attract : Float = 2.8
        if director.sync_t > 0.0 {
          attract = attract + 2.2
        }
        if drones[i].state == 1 {
          attract = attract * 0.72
        } else if drones[i].state == 2 {
          attract = attract * 0.44
        }

        drones[i].vx = drones[i].vx + dx * dt * attract
        drones[i].vy = drones[i].vy + dy * dt * attract

        for g = 0; g < gusts.length(); g = g + 1 {
          if not(gusts[g].active) {
            continue
          }
          let d2v : Float = dist2(
            drones[i].x,
            drones[i].y,
            gusts[g].x,
            gusts[g].y,
          )
          let rr : Float = gusts[g].radius
          if d2v <= rr * rr {
            let dd : Float = d2v.sqrt()
            let fall : Float = 1.0 - dd / rr
            let nx : Float = if dd <= 0.001 {
              0.0
            } else {
              (drones[i].x - gusts[g].x) / dd
            }
            let ny : Float = if dd <= 0.001 {
              0.0
            } else {
              (drones[i].y - gusts[g].y) / dd
            }
            drones[i].vx = drones[i].vx +
              (gusts[g].vx * 0.4 + nx * gusts[g].strength) * dt * fall
            drones[i].vy = drones[i].vy +
              (gusts[g].vy * 0.4 + ny * gusts[g].strength) * dt * fall
            drones[i].temp = drones[i].temp + dt * (0.8 + fall * 1.3)
          }
        }

        drones[i].flash_t = drones[i].flash_t + dt * 4.6
        drones[i].vx = drones[i].vx * (1.0 - dt * 1.6)
        drones[i].vy = drones[i].vy * (1.0 - dt * 1.6)
        drones[i].x = drones[i].x + drones[i].vx * dt
        drones[i].y = drones[i].y + drones[i].vy * dt

        if drones[i].x < world_l + 12.0 {
          drones[i].x = world_l + 12.0
          drones[i].vx = absf(drones[i].vx) * 0.32
        }
        if drones[i].x > world_r - 12.0 {
          drones[i].x = world_r - 12.0
          drones[i].vx = -absf(drones[i].vx) * 0.32
        }
        if drones[i].y < world_t + 12.0 {
          drones[i].y = world_t + 12.0
          drones[i].vy = absf(drones[i].vy) * 0.32
        }
        if drones[i].y > world_b - 12.0 {
          drones[i].y = world_b - 12.0
          drones[i].vy = -absf(drones[i].vy) * 0.32
        }

        let speed : Float = (drones[i].vx * drones[i].vx +
        drones[i].vy * drones[i].vy).sqrt()
        drones[i].battery = drones[i].battery - dt * (0.28 + speed * 0.013)
        drones[i].temp = drones[i].temp +
          dt * (0.14 + speed * 0.01 + storm_pressure * 0.08)

        if drones[i].battery < 24.0 {
          drones[i].state = 1
        }
        if drones[i].temp > 82.0 {
          drones[i].state = 2
        }
        if drones[i].battery > 34.0 && drones[i].temp < 76.0 {
          drones[i].state = 0
        }

        if drones[i].battery <= 0.0 || drones[i].temp >= 116.0 {
          drones[i].active = false
          drone_losses = drone_losses + 1
          rep = rep - 5.8
          combo = 0
          burst_particles(parts, drones[i].x, drones[i].y, 16, 1)
        }

        if drones[i].active {
          active_count = active_count + 1
        }
      }

      quality = formation_quality(
        drones, current_pattern, stage_cx, stage_cy, pattern_phase,
      )

      // Requests update
      let queue_pressure : Float = Float::from_int(
          active_requests_count(requests),
        ) *
        0.06
      for i = 0; i < requests.length(); i = i + 1 {
        if not(requests[i].active) {
          continue
        }

        requests[i].pulse = requests[i].pulse + dt * 4.2
        requests[i].deadline = requests[i].deadline -
          dt * (1.0 + queue_pressure + storm_pressure * 0.45)

        if current_pattern == requests[i].pattern &&
          quality >= requests[i].min_quality {
          let gain_rate : Float = 9.0 +
            (quality - requests[i].min_quality) * 0.7 +
            Float::from_int(combo) * 0.6
          requests[i].progress = requests[i].progress + dt * gain_rate
        } else {
          requests[i].progress = requests[i].progress - dt * 5.0
        }
        requests[i].progress = clampf(requests[i].progress, 0.0, 100.0)

        if requests[i].progress >= 100.0 {
          let urgency_bonus : Int = (requests[i].deadline * 2.3).to_int()
          let gain : Int = requests[i].reward + urgency_bonus + combo * 12
          score = score + gain
          served = served + 1
          combo = mini(30, combo + 1)
          rep = minf(100.0, rep + 2.6 + Float::from_int(combo) * 0.08)
          requests[i].active = false
          msg = "Served \{pattern_short(current_pattern)} request +\{gain}"
          msg_t = 1.2
          burst_particles(parts, stage_cx, stage_cy - 140.0, 14, 2)
          continue
        }

        if requests[i].deadline <= 0.0 {
          requests[i].active = false
          failed = failed + 1
          combo = 0
          rep = rep - 8.4
          msg = "Audience request failed!"
          msg_t = 1.0
          burst_particles(parts, stage_cx, stage_cy - 140.0, 12, 1)
        }
      }

      // reputation drift
      rep = rep -
        dt *
        (0.025 + storm_pressure * 0.03 + Float::from_int(drone_losses) * 0.0008)
      rep = clampf(rep, 0.0, 100.0)

      // passive motion particles
      if director.vx != 0.0 || director.vy != 0.0 {
        spawn_particle(
          parts,
          director.x + randf(-4.0, 4.0),
          director.y + 15.0,
          -director.vx * 0.16 + randf(-12.0, 12.0),
          -director.vy * 0.16 + randf(-12.0, 12.0),
          randf(0.2, 0.5),
          randf(1.4, 2.6),
          0,
        )
      }

      // lose/win checks
      if rep <= 0.0 {
        state = 3
        msg = "Reputation collapsed."
      } else if active_count <= 8 {
        state = 3
        msg = "Too many drones lost."
      } else if timer <= 0.0 {
        if score >= score_target && rep >= 40.0 {
          state = 2
          msg = "Show ended with standing ovation."
        } else {
          state = 3
          msg = "Show time ended below target."
        }
      } else if score >= score_target && rep >= 62.0 && served >= 16 {
        state = 2
        msg = "Show target cleared early."
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
      draw_background(world_x, world_y, world_w, world_h, scene_t)
      draw_stage(stage_cx, stage_cy, stage_r, scene_t)
      draw_targets(
        drones, current_pattern, stage_cx, stage_cy, pattern_phase, scene_t,
      )
      draw_stations(stations, director, scene_t)
      draw_gusts(gusts, scene_t)
      draw_fireworks(fireworks)
      draw_drones(drones, scene_t)
      draw_particles(parts)
      draw_director(director, scene_t)

      let mut heat_sum_draw : Float = 0.0
      let mut active_count_draw : Int = 0
      for i = 0; i < drones.length(); i = i + 1 {
        if drones[i].active {
          active_count_draw = active_count_draw + 1
          heat_sum_draw = heat_sum_draw + drones[i].temp
        }
      }
      let heat_avg_draw : Float = if active_count_draw <= 0 {
        100.0
      } else {
        heat_sum_draw / Float::from_int(active_count_draw)
      }

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
        quality,
        director.energy,
        heat_avg_draw,
        active_count_draw,
        drone_losses,
        combo,
        current_pattern,
        if msg_t > 0.0 {
          msg
        } else {
          ""
        },
      )
      draw_requests_panel(
        panel_x, panel_y, panel_w2, requests, current_pattern, quality, scene_t,
      )
      draw_touch_controls(sw, sh, mouse.x, mouse.y, hold, touch_count)

      if state == 2 || state == 3 {
        draw_end(
          sw,
          sh,
          state == 2,
          score,
          score_target,
          rep,
          served,
          failed,
          drone_losses,
        )
      }
    }

    @raylib.end_drawing()
  }
}
