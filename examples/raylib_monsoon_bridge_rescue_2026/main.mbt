///|
struct RescueBoat {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut heading : Float
  mut hull : Float
  hull_max : Float
  mut fuel : Float
  fuel_max : Float
  mut kits : Int
  kit_max : Int
  mut passengers : Int
  capacity : Int
  mut action_cd : Float
  mut siren_cd : Float
  mut siren_t : Float
  mut boost_heat : Float
  mut wake_t : Float
}

///|
struct SupplyDock {
  x : Float
  y : Float
  w : Int
  h : Int
}

///|
struct EvacCamp {
  x : Float
  y : Float
  w : Int
  h : Int
}

///|
struct BridgeSpan {
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut integrity : Float
  mut stress : Float
  mut alarm_t : Float
  id : Int
}

///|
struct CurrentCell {
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut vx : Float
  mut vy : Float
  mut pulse : Float
  id : Int
}

///|
struct FlowSample {
  vx : Float
  vy : Float
  turbulence : Float
}

///|
struct RaftGroup {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut survivors : Int
  mut panic : Float
  mut flare_t : Float
  mut id : Int
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
struct LightningStrike {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut radius : Float
  mut telegraph : Float
  mut life : Float
  mut power : Float
  mut pulse : Float
}

///|
struct SupplyCrate {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut kind : Int
  mut amount : Int
  mut blink : Float
}

///|
struct RainDrop {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vy : Float
  mut len : Float
  mut life : Float
  mut alpha : Int
}

///|
struct WakeParticle {
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
fn point_in_circle(
  px : Float,
  py : Float,
  cx : Float,
  cy : Float,
  r : Float,
) -> Bool {
  dist2(px, py, cx, cy) <= r * r
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

  if mouse_hold && point_in_circle(mouse_x, mouse_y, cx, cy, r) {
    hit = true
  }

  if not(hit) {
    for i = 0; i < touch_count; i = i + 1 {
      let p = @raylib.get_touch_position(i)
      if point_in_circle(p.x, p.y, cx, cy, r) {
        hit = true
      }
    }
  }

  hit
}

///|
fn clear_rafts(rafts : Array[RaftGroup]) -> Unit {
  for i = 0; i < rafts.length(); i = i + 1 {
    rafts[i].active = false
    rafts[i].x = 0.0
    rafts[i].y = 0.0
    rafts[i].vx = 0.0
    rafts[i].vy = 0.0
    rafts[i].survivors = 0
    rafts[i].panic = 0.0
    rafts[i].flare_t = 0.0
    rafts[i].id = i + 1
  }
}

///|
fn clear_debris(obstacles : Array[Debris]) -> Unit {
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
fn clear_lightning(strikes : Array[LightningStrike]) -> Unit {
  for i = 0; i < strikes.length(); i = i + 1 {
    strikes[i].active = false
    strikes[i].x = 0.0
    strikes[i].y = 0.0
    strikes[i].radius = 0.0
    strikes[i].telegraph = 0.0
    strikes[i].life = 0.0
    strikes[i].power = 0.0
    strikes[i].pulse = 0.0
  }
}

///|
fn clear_supplies(supplies : Array[SupplyCrate]) -> Unit {
  for i = 0; i < supplies.length(); i = i + 1 {
    supplies[i].active = false
    supplies[i].x = 0.0
    supplies[i].y = 0.0
    supplies[i].vx = 0.0
    supplies[i].vy = 0.0
    supplies[i].kind = 0
    supplies[i].amount = 0
    supplies[i].blink = 0.0
  }
}

///|
fn clear_rain(rain : Array[RainDrop]) -> Unit {
  for i = 0; i < rain.length(); i = i + 1 {
    rain[i].active = false
    rain[i].x = 0.0
    rain[i].y = 0.0
    rain[i].vy = 0.0
    rain[i].len = 0.0
    rain[i].life = 0.0
    rain[i].alpha = 0
  }
}

///|
fn clear_wakes(wakes : Array[WakeParticle]) -> Unit {
  for i = 0; i < wakes.length(); i = i + 1 {
    wakes[i].active = false
    wakes[i].x = 0.0
    wakes[i].y = 0.0
    wakes[i].vx = 0.0
    wakes[i].vy = 0.0
    wakes[i].life = 0.0
    wakes[i].size = 0.0
    wakes[i].kind = 0
  }
}

///|
fn init_currents(
  cells : Array[CurrentCell],
  world_x : Int,
  world_y : Int,
  world_w : Int,
  world_h : Int,
) -> Unit {
  let cols : Int = 4
  let rows : Int = 3
  let cw : Float = Float::from_int(world_w) / Float::from_int(cols)
  let ch : Float = Float::from_int(world_h) / Float::from_int(rows)

  for i = 0; i < cells.length(); i = i + 1 {
    let c : Int = i % cols
    let r : Int = i / cols
    cells[i].x = Float::from_int(world_x) + Float::from_int(c) * cw
    cells[i].y = Float::from_int(world_y) + Float::from_int(r) * ch
    cells[i].w = cw
    cells[i].h = ch

    let base_vx : Float = -34.0 - Float::from_int(c) * 7.0
    let sway : Float = if r == 0 { -20.0 } else if r == 1 { 8.0 } else { 24.0 }

    cells[i].vx = base_vx + randf(-6.0, 6.0)
    cells[i].vy = sway + randf(-8.0, 8.0)
    cells[i].pulse = randf(0.0, 18.0)
  }
}

///|
fn init_bridge(
  spans : Array[BridgeSpan],
  world_x : Int,
  world_y : Int,
  world_w : Int,
  world_h : Int,
) -> Unit {
  let cx : Float = Float::from_int(world_x + world_w / 2)
  let step : Float = Float::from_int(world_h - 170) /
    Float::from_int(spans.length())
  for i = 0; i < spans.length(); i = i + 1 {
    spans[i].x = cx - 54.0 + randf(-10.0, 10.0)
    spans[i].y = Float::from_int(world_y) + 84.0 + Float::from_int(i) * step
    spans[i].w = 108.0
    spans[i].h = 42.0
    spans[i].integrity = randf(58.0, 76.0)
    spans[i].stress = 0.0
    spans[i].alarm_t = 0.0
  }
}

///|
fn refill_rain(
  rain : Array[RainDrop],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
) -> Unit {
  for i = 0; i < rain.length(); i = i + 1 {
    rain[i].active = true
    rain[i].x = randf(world_l, world_r)
    rain[i].y = randf(world_t, world_b)
    rain[i].vy = randf(420.0, 760.0)
    rain[i].len = randf(8.0, 26.0)
    rain[i].life = randf(0.4, 2.2)
    rain[i].alpha = randi(32, 104)
  }
}

///|
fn find_flow(
  cells : Array[CurrentCell],
  x : Float,
  y : Float,
  storm : Float,
) -> FlowSample {
  let mut out_vx : Float = -24.0
  let mut out_vy : Float = 0.0
  let mut out_t : Float = 0.0

  for i = 0; i < cells.length(); i = i + 1 {
    if inside_rectf(x, y, cells[i].x, cells[i].y, cells[i].w, cells[i].h) {
      let wave : Float = sinf(cells[i].pulse + x * 0.0017 + y * 0.0023)
      out_vx = cells[i].vx + wave * (6.0 + storm * 7.0)
      out_vy = cells[i].vy + wave * (4.0 + storm * 5.0)
      out_t = absf(wave) * (0.2 + storm * 0.5)
    }
  }

  { vx: out_vx, vy: out_vy, turbulence: out_t }
}

///|
fn spawn_raft(
  rafts : Array[RaftGroup],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  serial : Int,
) -> Bool {
  let mut placed : Bool = false

  for i = 0; i < rafts.length(); i = i + 1 {
    if rafts[i].active {
      continue
    }

    let lane : Int = randi(0, 2)
    let py : Float = if lane == 0 {
      randf(world_t + 24.0, world_t + (world_b - world_t) * 0.3)
    } else if lane == 1 {
      randf(
        world_t + (world_b - world_t) * 0.35,
        world_t + (world_b - world_t) * 0.65,
      )
    } else {
      randf(world_t + (world_b - world_t) * 0.7, world_b - 24.0)
    }

    rafts[i].active = true
    rafts[i].x = randf(world_r - 110.0, world_r - 22.0)
    rafts[i].y = py
    rafts[i].vx = randf(-28.0, -15.0)
    rafts[i].vy = randf(-12.0, 12.0)
    rafts[i].survivors = randi(2, 9)
    rafts[i].panic = randf(0.08, 0.32)
    rafts[i].flare_t = randf(0.0, 4.0)
    rafts[i].id = serial
    placed = true
    break
  }

  placed
}

///|
fn spawn_debris(
  debris : Array[Debris],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  storm : Float,
) -> Bool {
  let mut placed : Bool = false

  for i = 0; i < debris.length(); i = i + 1 {
    if debris[i].active {
      continue
    }
    debris[i].active = true
    debris[i].x = world_r + randf(20.0, 120.0)
    debris[i].y = randf(world_t + 16.0, world_b - 16.0)
    debris[i].vx = -randf(68.0, 152.0) - storm * randf(8.0, 38.0)
    debris[i].vy = randf(-42.0, 42.0)
    debris[i].size = randf(10.0, 30.0)
    debris[i].hard = randf(0.6, 1.8)
    debris[i].spin = randf(-6.0, 6.0)
    placed = true
    break
  }

  placed
}

///|
fn spawn_lightning(
  strikes : Array[LightningStrike],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  storm : Float,
) -> Bool {
  let mut placed : Bool = false

  for i = 0; i < strikes.length(); i = i + 1 {
    if strikes[i].active {
      continue
    }
    strikes[i].active = true
    strikes[i].x = randf(world_l + 80.0, world_r - 80.0)
    strikes[i].y = randf(world_t + 80.0, world_b - 80.0)
    strikes[i].radius = randf(52.0, 88.0) + storm * randf(4.0, 24.0)
    strikes[i].telegraph = randf(0.9, 1.75)
    strikes[i].life = randf(0.16, 0.44)
    strikes[i].power = randf(7.0, 14.0) + storm * randf(2.0, 8.0)
    strikes[i].pulse = randf(0.0, 15.0)
    placed = true
    break
  }

  placed
}

///|
fn spawn_supply(
  supplies : Array[SupplyCrate],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
) -> Bool {
  let mut placed : Bool = false

  for i = 0; i < supplies.length(); i = i + 1 {
    if supplies[i].active {
      continue
    }
    supplies[i].active = true
    supplies[i].x = randf(world_l + 120.0, world_r - 120.0)
    supplies[i].y = randf(world_t + 90.0, world_b - 90.0)
    supplies[i].vx = randf(-20.0, 20.0)
    supplies[i].vy = randf(-16.0, 16.0)
    supplies[i].kind = if randi(0, 1) == 0 { 0 } else { 1 }
    supplies[i].amount = if supplies[i].kind == 0 {
      randi(1, 3)
    } else {
      randi(10, 24)
    }
    supplies[i].blink = randf(0.0, 8.0)
    placed = true
    break
  }

  placed
}

///|
fn spawn_wake(
  wakes : Array[WakeParticle],
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  speed : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < wakes.length(); i = i + 1 {
    if wakes[i].active {
      continue
    }
    wakes[i].active = true
    wakes[i].x = x + randf(-5.0, 5.0)
    wakes[i].y = y + randf(-5.0, 5.0)
    wakes[i].vx = -vx * 0.12 + randf(-22.0, 22.0)
    wakes[i].vy = -vy * 0.12 + randf(-20.0, 20.0)
    wakes[i].life = randf(0.28, 0.76) + speed * 0.003
    wakes[i].size = randf(2.0, 5.6) + speed * 0.01
    wakes[i].kind = kind
    break
  }
}

///|
fn update_wakes(wakes : Array[WakeParticle], dt : Float) -> Unit {
  for i = 0; i < wakes.length(); i = i + 1 {
    if not(wakes[i].active) {
      continue
    }
    wakes[i].life = wakes[i].life - dt
    if wakes[i].life <= 0.0 {
      wakes[i].active = false
      continue
    }
    wakes[i].x = wakes[i].x + wakes[i].vx * dt
    wakes[i].y = wakes[i].y + wakes[i].vy * dt
    wakes[i].vx = wakes[i].vx * (1.0 - dt * 2.1)
    wakes[i].vy = wakes[i].vy * (1.0 - dt * 2.1)
  }
}

///|
fn update_rain(
  rain : Array[RainDrop],
  dt : Float,
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
  wind_x : Float,
) -> Unit {
  for i = 0; i < rain.length(); i = i + 1 {
    if not(rain[i].active) {
      continue
    }
    rain[i].life = rain[i].life - dt
    rain[i].x = rain[i].x + wind_x * dt * 0.22
    rain[i].y = rain[i].y + rain[i].vy * dt

    let offscreen : Bool = rain[i].y > world_b + 30.0 ||
      rain[i].x < world_l - 30.0 ||
      rain[i].x > world_r + 30.0

    if rain[i].life <= 0.0 || offscreen {
      rain[i].x = randf(world_l, world_r)
      rain[i].y = randf(world_t - 120.0, world_t - 20.0)
      rain[i].vy = randf(430.0, 780.0)
      rain[i].len = randf(8.0, 28.0)
      rain[i].life = randf(0.7, 2.2)
      rain[i].alpha = randi(28, 116)
    }
  }
}

///|
fn calm_rafts(
  rafts : Array[RaftGroup],
  x : Float,
  y : Float,
  radius : Float,
  dt : Float,
) -> Unit {
  let r2 : Float = radius * radius
  for i = 0; i < rafts.length(); i = i + 1 {
    if not(rafts[i].active) {
      continue
    }
    let d2 : Float = dist2(x, y, rafts[i].x, rafts[i].y)
    if d2 <= r2 {
      let falloff : Float = 1.0 - d2.sqrt() / radius
      rafts[i].panic = rafts[i].panic - dt * (0.26 + falloff * 0.54)
      if rafts[i].panic < 0.0 {
        rafts[i].panic = 0.0
      }
    }
  }
}

///|
fn nearest_span_index(
  spans : Array[BridgeSpan],
  x : Float,
  y : Float,
  radius : Float,
) -> Int {
  let mut found : Int = -1
  let mut best : Float = radius * radius
  for i = 0; i < spans.length(); i = i + 1 {
    let cx : Float = spans[i].x + spans[i].w * 0.5
    let cy : Float = spans[i].y + spans[i].h * 0.5
    let d2 : Float = dist2(x, y, cx, cy)
    if d2 <= best {
      best = d2
      found = i
    }
  }
  found
}

///|
fn min_bridge_integrity(spans : Array[BridgeSpan]) -> Float {
  let mut out : Float = 100.0
  for i = 0; i < spans.length(); i = i + 1 {
    out = minf(out, spans[i].integrity)
  }
  out
}

///|
fn draw_river(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  scene_t : Float,
  storm : Float,
) -> Unit {
  let base_top = @raylib.Color::new(18, 58, 96, 255)
  let base_bottom = @raylib.Color::new(10, 34, 62, 255)
  @raylib.draw_rectangle_gradient_v(x, y, w, h, base_top, base_bottom)

  let stripe_count : Int = 46
  let seg_h : Float = Float::from_int(h) / Float::from_int(stripe_count)
  for i = 0; i < stripe_count; i = i + 1 {
    let py : Float = Float::from_int(y) + Float::from_int(i) * seg_h
    let wave : Float = sinf(scene_t * 2.4 + Float::from_int(i) * 0.42)
    let shift : Int = (wave * 18.0).to_int()
    let alpha : Int = 18 +
      ((wave + 1.0) * 10.0).to_int() +
      (storm * 26.0).to_int()
    @raylib.draw_rectangle(
      x + shift,
      py.to_int(),
      w - 8,
      maxi(1, (seg_h + 1.0).to_int()),
      @raylib.Color::new(108, 164, 214, alpha),
    )
  }
}

///|
fn draw_current_grid(cells : Array[CurrentCell], storm : Float) -> Unit {
  for i = 0; i < cells.length(); i = i + 1 {
    let wave : Float = sinf(cells[i].pulse)
    let tone : Int = 34 +
      ((wave + 1.0) * 28.0).to_int() +
      (storm * 34.0).to_int()
    @raylib.draw_rectangle_lines(
      cells[i].x.to_int(),
      cells[i].y.to_int(),
      cells[i].w.to_int(),
      cells[i].h.to_int(),
      @raylib.Color::new(72, 126, 168, tone),
    )

    let cx : Float = cells[i].x + cells[i].w * 0.5
    let cy : Float = cells[i].y + cells[i].h * 0.5
    let tip_x : Float = cx + cells[i].vx * 0.3
    let tip_y : Float = cy + cells[i].vy * 0.3
    @raylib.draw_line_ex(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(tip_x, tip_y),
      2.2,
      @raylib.Color::new(126, 206, 244, 114),
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(tip_x, tip_y),
      3.0,
      @raylib.Color::new(168, 232, 255, 144),
    )
  }
}

///|
fn draw_spans(spans : Array[BridgeSpan], scene_t : Float) -> Unit {
  for i = 0; i < spans.length(); i = i + 1 {
    let p : Float = clampf(spans[i].integrity / 100.0, 0.0, 1.0)
    let red : Int = 210 - (p * 100.0).to_int()
    let green : Int = 34 + (p * 180.0).to_int()
    let pulse : Float = sinf(scene_t * 4.6 + Float::from_int(i) * 0.7) * 0.5 +
      0.5

    @raylib.draw_rectangle(
      spans[i].x.to_int(),
      spans[i].y.to_int(),
      spans[i].w.to_int(),
      spans[i].h.to_int(),
      @raylib.Color::new(36, 40, 46, 230),
    )
    @raylib.draw_rectangle(
      (spans[i].x + 5.0).to_int(),
      (spans[i].y + 6.0).to_int(),
      ((spans[i].w - 10.0) * p).to_int(),
      (spans[i].h - 12.0).to_int(),
      @raylib.Color::new(red, green, 56, 228),
    )
    @raylib.draw_rectangle_lines(
      spans[i].x.to_int(),
      spans[i].y.to_int(),
      spans[i].w.to_int(),
      spans[i].h.to_int(),
      @raylib.Color::new(224, 228, 236, 216),
    )

    if spans[i].integrity < 44.0 {
      let ax : Float = spans[i].x + spans[i].w * 0.5
      let ay : Float = spans[i].y - 14.0
      let rr : Float = 9.0 + pulse * 5.0
      @raylib.draw_circle_v(
        @raylib.Vector2::new(ax, ay),
        rr,
        @raylib.Color::new(255, 68, 46, 128),
      )
      @raylib.draw_text(
        "!",
        (ax - 4.0).to_int(),
        (ay - 10.0).to_int(),
        18,
        @raylib.white,
      )
    }
  }
}

///|
fn draw_rafts(rafts : Array[RaftGroup], scene_t : Float) -> Unit {
  for i = 0; i < rafts.length(); i = i + 1 {
    if not(rafts[i].active) {
      continue
    }
    let panic_col : Int = 90 +
      (clampf(rafts[i].panic, 0.0, 1.0) * 130.0).to_int()
    @raylib.draw_circle_v(
      @raylib.Vector2::new(rafts[i].x, rafts[i].y),
      17.0,
      @raylib.Color::new(138, 108, 70, 242),
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(rafts[i].x, rafts[i].y),
      10.0,
      @raylib.Color::new(208, panic_col, 98, 238),
    )

    let blink : Float = sinf(scene_t * 7.0 + rafts[i].flare_t) * 0.5 + 0.5
    @raylib.draw_circle_v(
      @raylib.Vector2::new(rafts[i].x, rafts[i].y - 22.0),
      5.0 + blink * 3.0,
      @raylib.Color::new(255, 110, 72, 180),
    )
    @raylib.draw_text(
      "\{rafts[i].survivors}",
      (rafts[i].x - 8.0).to_int(),
      (rafts[i].y - 7.0).to_int(),
      18,
      @raylib.white,
    )
  }
}

///|
fn draw_debris_field(debris : Array[Debris]) -> Unit {
  for i = 0; i < debris.length(); i = i + 1 {
    if not(debris[i].active) {
      continue
    }
    let w : Float = debris[i].size * 1.8
    let h : Float = debris[i].size * 0.9
    @raylib.draw_rectangle(
      (debris[i].x - w * 0.5).to_int(),
      (debris[i].y - h * 0.5).to_int(),
      w.to_int(),
      h.to_int(),
      @raylib.Color::new(88, 62, 38, 226),
    )
    @raylib.draw_rectangle_lines(
      (debris[i].x - w * 0.5).to_int(),
      (debris[i].y - h * 0.5).to_int(),
      w.to_int(),
      h.to_int(),
      @raylib.Color::new(170, 144, 102, 210),
    )
  }
}

///|
fn draw_strikes(strikes : Array[LightningStrike], scene_t : Float) -> Unit {
  for i = 0; i < strikes.length(); i = i + 1 {
    if not(strikes[i].active) {
      continue
    }

    if strikes[i].telegraph > 0.0 {
      let blink : Float = sinf(scene_t * 8.0 + strikes[i].pulse) * 0.5 + 0.5
      @raylib.draw_circle_lines(
        strikes[i].x.to_int(),
        strikes[i].y.to_int(),
        strikes[i].radius * (0.88 + blink * 0.2),
        @raylib.Color::new(255, 238, 126, 200),
      )
      @raylib.draw_circle_v(
        @raylib.Vector2::new(strikes[i].x, strikes[i].y),
        5.0 + blink * 6.0,
        @raylib.Color::new(255, 244, 186, 170),
      )
    } else {
      let flash : Float = clampf(strikes[i].life * 5.0, 0.0, 1.0)
      let rr : Float = strikes[i].radius * (1.0 + flash * 0.25)
      @raylib.draw_circle_v(
        @raylib.Vector2::new(strikes[i].x, strikes[i].y),
        rr,
        @raylib.Color::new(255, 245, 220, (flash * 160.0).to_int()),
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(strikes[i].x, strikes[i].y - rr),
        @raylib.Vector2::new(strikes[i].x, strikes[i].y + rr),
        4.0 + flash * 3.5,
        @raylib.Color::new(255, 250, 236, 200),
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(strikes[i].x - rr * 0.55, strikes[i].y),
        @raylib.Vector2::new(strikes[i].x + rr * 0.55, strikes[i].y),
        3.2 + flash * 2.8,
        @raylib.Color::new(255, 236, 192, 180),
      )
    }
  }
}

///|
fn draw_supplies(supplies : Array[SupplyCrate], scene_t : Float) -> Unit {
  for i = 0; i < supplies.length(); i = i + 1 {
    if not(supplies[i].active) {
      continue
    }
    let blink : Float = sinf(scene_t * 6.2 + supplies[i].blink) * 0.5 + 0.5
    let col = if supplies[i].kind == 0 {
      @raylib.Color::new(104, 222, 132, 212)
    } else {
      @raylib.Color::new(112, 190, 248, 212)
    }
    @raylib.draw_rectangle(
      (supplies[i].x - 12.0).to_int(),
      (supplies[i].y - 12.0).to_int(),
      24,
      24,
      col,
    )
    @raylib.draw_rectangle_lines(
      (supplies[i].x - 12.0).to_int(),
      (supplies[i].y - 12.0).to_int(),
      24,
      24,
      @raylib.Color::new(248, 252, 255, 230),
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(supplies[i].x, supplies[i].y),
      18.0 + blink * 8.0,
      @raylib.Color::new(236, 248, 255, (blink * 70.0).to_int()),
    )
    @raylib.draw_text(
      if supplies[i].kind == 0 {
        "K"
      } else {
        "F"
      },
      (supplies[i].x - 5.0).to_int(),
      (supplies[i].y - 8.0).to_int(),
      16,
      @raylib.Color::new(20, 28, 40, 255),
    )
  }
}

///|
fn draw_rain(rain : Array[RainDrop], wind_x : Float) -> Unit {
  for i = 0; i < rain.length(); i = i + 1 {
    if not(rain[i].active) {
      continue
    }
    let x0 : Float = rain[i].x
    let y0 : Float = rain[i].y
    let x1 : Float = rain[i].x + wind_x * 0.012
    let y1 : Float = rain[i].y + rain[i].len
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x0, y0),
      @raylib.Vector2::new(x1, y1),
      1.0,
      @raylib.Color::new(210, 232, 248, rain[i].alpha),
    )
  }
}

///|
fn draw_wakes(wakes : Array[WakeParticle]) -> Unit {
  for i = 0; i < wakes.length(); i = i + 1 {
    if not(wakes[i].active) {
      continue
    }
    let alpha : Int = clampf(wakes[i].life * 255.0, 0.0, 255.0).to_int()
    let color = if wakes[i].kind == 0 {
      @raylib.Color::new(188, 226, 244, alpha)
    } else {
      @raylib.Color::new(248, 252, 255, alpha)
    }
    @raylib.draw_circle_v(
      @raylib.Vector2::new(wakes[i].x, wakes[i].y),
      wakes[i].size,
      color,
    )
  }
}

///|
fn draw_boat(boat : RescueBoat, scene_t : Float) -> Unit {
  let bob : Float = sinf(scene_t * 7.2) * 1.4
  let x : Float = boat.x
  let y : Float = boat.y + bob
  @raylib.draw_triangle(
    @raylib.Vector2::new(x + 25.0, y),
    @raylib.Vector2::new(x - 20.0, y - 14.0),
    @raylib.Vector2::new(x - 20.0, y + 14.0),
    @raylib.Color::new(252, 124, 78, 246),
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(x + 13.0, y),
    @raylib.Vector2::new(x - 14.0, y - 8.0),
    @raylib.Vector2::new(x - 14.0, y + 8.0),
    @raylib.Color::new(250, 212, 160, 242),
  )
  @raylib.draw_circle_v(
    @raylib.Vector2::new(x - 4.0, y),
    5.0,
    @raylib.Color::new(40, 46, 62, 238),
  )

  let heat_alpha : Int = clampf(boat.boost_heat * 160.0, 0.0, 170.0).to_int()
  if heat_alpha > 0 {
    @raylib.draw_circle_v(
      @raylib.Vector2::new(x - 21.0, y),
      8.0 + boat.boost_heat * 5.0,
      @raylib.Color::new(255, 146, 62, heat_alpha),
    )
  }
}

///|
fn draw_world_panels(
  dock : SupplyDock,
  camp : EvacCamp,
  scene_t : Float,
) -> Unit {
  @raylib.draw_rectangle(
    dock.x.to_int(),
    dock.y.to_int(),
    dock.w,
    dock.h,
    @raylib.Color::new(38, 66, 58, 228),
  )
  @raylib.draw_rectangle_lines(
    dock.x.to_int(),
    dock.y.to_int(),
    dock.w,
    dock.h,
    @raylib.Color::new(154, 238, 190, 220),
  )
  @raylib.draw_text(
    "SUPPLY DOCK",
    dock.x.to_int() + 14,
    dock.y.to_int() + 12,
    20,
    @raylib.Color::new(220, 248, 234, 240),
  )

  @raylib.draw_rectangle(
    camp.x.to_int(),
    camp.y.to_int(),
    camp.w,
    camp.h,
    @raylib.Color::new(62, 72, 40, 228),
  )
  @raylib.draw_rectangle_lines(
    camp.x.to_int(),
    camp.y.to_int(),
    camp.w,
    camp.h,
    @raylib.Color::new(240, 242, 148, 220),
  )
  @raylib.draw_text(
    "EVAC CAMP",
    camp.x.to_int() + 16,
    camp.y.to_int() + 12,
    20,
    @raylib.Color::new(250, 250, 208, 240),
  )

  let pulse : Float = sinf(scene_t * 3.6) * 0.5 + 0.5
  @raylib.draw_circle_v(
    @raylib.Vector2::new(
      dock.x + Float::from_int(dock.w) * 0.5,
      dock.y + Float::from_int(dock.h) * 0.5,
    ),
    20.0 + pulse * 6.0,
    @raylib.Color::new(154, 244, 212, 70),
  )
  @raylib.draw_circle_v(
    @raylib.Vector2::new(
      camp.x + Float::from_int(camp.w) * 0.5,
      camp.y + Float::from_int(camp.h) * 0.5,
    ),
    20.0 + pulse * 6.0,
    @raylib.Color::new(244, 236, 154, 70),
  )
}

///|
fn draw_hud_meter(
  title : String,
  value : Float,
  max_value : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  fg : @raylib.Color,
) -> Unit {
  let p : Float = if max_value <= 0.001 {
    0.0
  } else {
    clampf(value / max_value, 0.0, 1.0)
  }

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(20, 26, 38, 244))
  @raylib.draw_rectangle(
    x + 2,
    y + 2,
    (Float::from_int(w - 4) * p).to_int(),
    h - 4,
    fg,
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(224, 232, 244, 186),
  )
  @raylib.draw_text(
    title,
    x,
    y - 22,
    20,
    @raylib.Color::new(224, 234, 246, 236),
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

  fn draw_pad(x : Int, y : Int, label : String, active : Bool) -> Unit {
    @raylib.draw_rectangle(
      x,
      y,
      cell - 4,
      cell - 4,
      if active {
        @raylib.Color::new(98, 176, 238, 176)
      } else {
        @raylib.Color::new(36, 50, 72, 138)
      },
    )
    @raylib.draw_rectangle_lines(
      x,
      y,
      cell - 4,
      cell - 4,
      @raylib.Color::new(188, 214, 236, 170),
    )
    @raylib.draw_text(
      label,
      x + (cell - 4) / 2 - @raylib.measure_text(label, 26) / 2,
      y + (cell - 4) / 2 - 13,
      26,
      @raylib.Color::new(232, 240, 248, 236),
    )
  }

  draw_pad(pad_x + cell, pad_y, "W", up)
  draw_pad(pad_x, pad_y + cell, "A", left)
  draw_pad(pad_x + cell * 2, pad_y + cell, "D", right)
  draw_pad(pad_x + cell, pad_y + cell * 2, "S", down)

  let boost_x : Float = Float::from_int(sw - 298)
  let boost_y : Float = Float::from_int(sh - 162)
  let action_x : Float = Float::from_int(sw - 188)
  let action_y : Float = Float::from_int(sh - 236)
  let siren_x : Float = Float::from_int(sw - 94)
  let siren_y : Float = Float::from_int(sh - 142)

  let boost = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, boost_x, boost_y, 56.0,
  )
  let action = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, action_x, action_y, 45.0,
  )
  let siren = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, siren_x, siren_y, 42.0,
  )

  fn draw_button(
    cx : Float,
    cy : Float,
    r : Float,
    label : String,
    active : Bool,
    cr : Int,
    cg : Int,
    cb : Int,
  ) -> Unit {
    @raylib.draw_circle_v(
      @raylib.Vector2::new(cx, cy),
      r,
      if active {
        @raylib.Color::new(cr, cg, cb, 224)
      } else {
        @raylib.Color::new(cr, cg, cb, 128)
      },
    )
    @raylib.draw_circle_lines(
      cx.to_int(),
      cy.to_int(),
      r,
      @raylib.Color::new(224, 238, 250, 210),
    )
    @raylib.draw_text(
      label,
      (cx - Float::from_int(@raylib.measure_text(label, 22) / 2)).to_int(),
      (cy - 11.0).to_int(),
      22,
      @raylib.Color::new(250, 252, 255, 240),
    )
  }

  draw_button(boost_x, boost_y, 56.0, "BOOST", boost, 66, 174, 242)
  draw_button(action_x, action_y, 45.0, "ACT", action, 74, 204, 154)
  draw_button(siren_x, siren_y, 42.0, "PING", siren, 246, 176, 78)
}

///|
fn draw_panel(
  panel_x : Int,
  panel_y : Int,
  panel_w : Int,
  panel_h : Int,
  boat : RescueBoat,
  rescued : Int,
  rescue_target : Int,
  lost : Int,
  lost_limit : Int,
  min_integrity : Float,
  bridge_goal : Float,
  timer : Float,
  wave : Int,
  msg : String,
) -> Unit {
  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(16, 20, 32, 248),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(168, 186, 214, 196),
  )

  @raylib.draw_text(
    "MONSOON BRIDGE RESCUE",
    panel_x + 18,
    panel_y + 16,
    30,
    @raylib.Color::new(232, 242, 255, 242),
  )
  @raylib.draw_text(
    "Keep bridge alive, rescue survivors, outrun storm",
    panel_x + 18,
    panel_y + 56,
    20,
    @raylib.Color::new(172, 194, 216, 224),
  )

  draw_hud_meter(
    "HULL",
    boat.hull,
    boat.hull_max,
    panel_x + 20,
    panel_y + 104,
    panel_w - 40,
    24,
    @raylib.Color::new(230, 96, 80, 232),
  )
  draw_hud_meter(
    "FUEL",
    boat.fuel,
    boat.fuel_max,
    panel_x + 20,
    panel_y + 154,
    panel_w - 40,
    24,
    @raylib.Color::new(70, 176, 236, 232),
  )
  draw_hud_meter(
    "BRIDGE MIN INTEGRITY",
    min_integrity,
    100.0,
    panel_x + 20,
    panel_y + 204,
    panel_w - 40,
    24,
    @raylib.Color::new(98, 214, 124, 232),
  )

  @raylib.draw_text(
    "Kits \{boat.kits}/\{boat.kit_max}  |  Onboard \{boat.passengers}/\{boat.capacity}",
    panel_x + 20,
    panel_y + 246,
    24,
    @raylib.Color::new(232, 242, 252, 236),
  )
  @raylib.draw_text(
    "Rescued \{rescued}/\{rescue_target}",
    panel_x + 20,
    panel_y + 282,
    28,
    @raylib.Color::new(244, 250, 184, 238),
  )
  @raylib.draw_text(
    "Lost \{lost}/\{lost_limit}",
    panel_x + 20,
    panel_y + 320,
    24,
    @raylib.Color::new(248, 162, 144, 236),
  )
  @raylib.draw_text(
    "Bridge goal >= \{bridge_goal.to_int()}%",
    panel_x + 20,
    panel_y + 354,
    24,
    @raylib.Color::new(194, 232, 198, 236),
  )

  let mm : Int = timer.to_int() / 60
  let ss : Int = timer.to_int() % 60
  let ss_txt : String = if ss < 10 { "0\{ss}" } else { "\{ss}" }
  @raylib.draw_text(
    "Time \{mm}:\{ss_txt}  |  Storm Wave \{wave}",
    panel_x + 20,
    panel_y + 390,
    24,
    @raylib.Color::new(232, 244, 250, 238),
  )

  @raylib.draw_rectangle(
    panel_x + 16,
    panel_y + panel_h - 174,
    panel_w - 32,
    156,
    @raylib.Color::new(22, 30, 44, 236),
  )
  @raylib.draw_rectangle_lines(
    panel_x + 16,
    panel_y + panel_h - 174,
    panel_w - 32,
    156,
    @raylib.Color::new(118, 146, 182, 194),
  )
  @raylib.draw_text(
    "Controls",
    panel_x + 26,
    panel_y + panel_h - 164,
    24,
    @raylib.Color::new(236, 246, 255, 236),
  )
  @raylib.draw_text(
    "Move: WASD/Arrows\nBoost: Space/J\nAct: L/U\nPing Siren: K/H",
    panel_x + 26,
    panel_y + panel_h - 126,
    22,
    @raylib.Color::new(188, 214, 244, 228),
  )

  @raylib.draw_text(
    msg,
    panel_x + 20,
    panel_y + 434,
    22,
    @raylib.Color::new(252, 226, 164, 240),
  )
}

///|
fn draw_menu(sw : Int, sh : Int, scene_t : Float) -> Unit {
  @raylib.clear_background(@raylib.Color::new(9, 16, 26, 255))
  for i = 0; i < 26; i = i + 1 {
    let yy : Float = Float::from_int(i) / 26.0
    let wave : Float = sinf(scene_t * 1.2 + yy * 6.0) * 0.5 + 0.5
    let alpha : Int = 20 + (wave * 54.0).to_int()
    @raylib.draw_rectangle(
      0,
      (yy * Float::from_int(sh)).to_int(),
      sw,
      sh / 24 + 2,
      @raylib.Color::new(24, 56, 92, alpha),
    )
  }

  @raylib.draw_text(
    "MONSOON BRIDGE RESCUE 2026",
    sw / 2 - @raylib.measure_text("MONSOON BRIDGE RESCUE 2026", 66) / 2,
    180,
    66,
    @raylib.Color::new(236, 246, 255, 248),
  )
  @raylib.draw_text(
    "Pilot through river currents, rescue rafts, and keep bridge spans above collapse threshold.",
    sw / 2 -
    @raylib.measure_text(
      "Pilot through river currents, rescue rafts, and keep bridge spans above collapse threshold.",
      28,
    ) /
    2,
    286,
    28,
    @raylib.Color::new(182, 206, 228, 240),
  )

  @raylib.draw_text(
    "Dock refuels and restocks kits | Evac camp unloads survivors | Siren calms panic",
    sw / 2 -
    @raylib.measure_text(
      "Dock refuels and restocks kits | Evac camp unloads survivors | Siren calms panic",
      26,
    ) /
    2,
    330,
    26,
    @raylib.Color::new(168, 208, 188, 230),
  )

  let pulse : Float = sinf(scene_t * 3.7) * 0.5 + 0.5
  let bw : Int = 460
  let bh : Int = 92
  let bx : Int = sw / 2 - bw / 2
  let by : Int = 470
  @raylib.draw_rectangle(
    bx,
    by,
    bw,
    bh,
    @raylib.Color::new(60, 120, 204, 156 + (pulse * 76.0).to_int()),
  )
  @raylib.draw_rectangle_lines(
    bx,
    by,
    bw,
    bh,
    @raylib.Color::new(216, 236, 255, 226),
  )
  @raylib.draw_text(
    "PRESS ENTER / TAP TO START",
    sw / 2 - @raylib.measure_text("PRESS ENTER / TAP TO START", 36) / 2,
    by + bh / 2 - 18,
    36,
    @raylib.Color::new(246, 252, 255, 246),
  )

  @raylib.draw_text(
    "Mobile: use on-screen D-pad + BOOST / ACT / PING",
    sw / 2 -
    @raylib.measure_text("Mobile: use on-screen D-pad + BOOST / ACT / PING", 24) /
    2,
    610,
    24,
    @raylib.Color::new(188, 214, 236, 228),
  )
}

///|
fn draw_end_screen(
  sw : Int,
  sh : Int,
  win : Bool,
  rescued : Int,
  target : Int,
  min_integrity : Float,
  goal : Float,
  lost : Int,
  timer : Float,
) -> Unit {
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(10, 14, 22, 222))
  let title : String = if win { "MISSION SUCCESS" } else { "MISSION FAILED" }
  let title_col = if win {
    @raylib.Color::new(164, 246, 196, 246)
  } else {
    @raylib.Color::new(250, 148, 132, 246)
  }

  @raylib.draw_text(
    title,
    sw / 2 - @raylib.measure_text(title, 72) / 2,
    210,
    72,
    title_col,
  )

  @raylib.draw_text(
    "Rescued: \{rescued}/\{target}",
    sw / 2 - @raylib.measure_text("Rescued: \{rescued}/\{target}", 36) / 2,
    326,
    36,
    @raylib.Color::new(236, 244, 255, 240),
  )
  @raylib.draw_text(
    "Bridge min integrity: \{min_integrity.to_int()}% (goal \{goal.to_int()}%)",
    sw / 2 -
    @raylib.measure_text(
      "Bridge min integrity: \{min_integrity.to_int()}% (goal \{goal.to_int()}%)",
      32,
    ) /
    2,
    372,
    32,
    @raylib.Color::new(216, 232, 250, 232),
  )
  @raylib.draw_text(
    "Lost: \{lost} | Time left: \{timer.to_int()}s",
    sw / 2 -
    @raylib.measure_text("Lost: \{lost} | Time left: \{timer.to_int()}s", 30) /
    2,
    414,
    30,
    @raylib.Color::new(202, 218, 238, 224),
  )

  @raylib.draw_text(
    "Press Enter / R to play again",
    sw / 2 - @raylib.measure_text("Press Enter / R to play again", 32) / 2,
    520,
    32,
    @raylib.Color::new(244, 250, 255, 236),
  )
}

///|
fn main {
  let sw : Int = 1700
  let sh : Int = 960
  @raylib.init_window(sw, sh, "raylib [game] monsoon bridge rescue 2026")
  defer @raylib.close_window()
  @raylib.set_target_fps(120)

  let world_x : Int = 24
  let world_y : Int = 24
  let panel_w : Int = 432
  let world_w : Int = sw - panel_w - 48
  let world_h : Int = sh - 48

  let world_l : Float = Float::from_int(world_x)
  let world_t : Float = Float::from_int(world_y)
  let world_r : Float = Float::from_int(world_x + world_w)
  let world_b : Float = Float::from_int(world_y + world_h)

  let dock : SupplyDock = {
    x: world_l + 18.0,
    y: world_b - 178.0,
    w: 192,
    h: 142,
  }
  let camp : EvacCamp = {
    x: world_r - 222.0,
    y: world_t + 38.0,
    w: 198,
    h: 148,
  }

  let spans : Array[BridgeSpan] = Array::makei(5, fn(i) {
    {
      x: 0.0,
      y: 0.0,
      w: 0.0,
      h: 0.0,
      integrity: 70.0,
      stress: 0.0,
      alarm_t: 0.0,
      id: i + 1,
    }
  })

  let currents : Array[CurrentCell] = Array::makei(12, fn(i) {
    { x: 0.0, y: 0.0, w: 0.0, h: 0.0, vx: 0.0, vy: 0.0, pulse: 0.0, id: i + 1 }
  })

  let rafts : Array[RaftGroup] = Array::makei(36, fn(i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      survivors: 0,
      panic: 0.0,
      flare_t: 0.0,
      id: i + 1,
    }
  })

  let debris : Array[Debris] = Array::makei(170, fn(_i) {
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

  let strikes : Array[LightningStrike] = Array::makei(28, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      radius: 0.0,
      telegraph: 0.0,
      life: 0.0,
      power: 0.0,
      pulse: 0.0,
    }
  })

  let supplies : Array[SupplyCrate] = Array::makei(26, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      kind: 0,
      amount: 0,
      blink: 0.0,
    }
  })

  let rain : Array[RainDrop] = Array::makei(760, fn(_i) {
    { active: false, x: 0.0, y: 0.0, vy: 0.0, len: 0.0, life: 0.0, alpha: 0 }
  })

  let wakes : Array[WakeParticle] = Array::makei(980, fn(_i) {
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

  let boat : RescueBoat = {
    x: dock.x + Float::from_int(dock.w) * 0.5,
    y: dock.y + Float::from_int(dock.h) * 0.5,
    vx: 0.0,
    vy: 0.0,
    heading: 0.0,
    hull: 100.0,
    hull_max: 100.0,
    fuel: 100.0,
    fuel_max: 100.0,
    kits: 8,
    kit_max: 8,
    passengers: 0,
    capacity: 20,
    action_cd: 0.0,
    siren_cd: 0.0,
    siren_t: 0.0,
    boost_heat: 0.0,
    wake_t: 0.0,
  }

  let mut state : Int = 0 // 0 menu, 1 play, 2 win, 3 lose
  let mut timer : Float = 460.0
  let mut scene_t : Float = 0.0
  let mut msg : String = ""
  let mut msg_t : Float = 0.0
  let mut rescued_total : Int = 0
  let mut rescue_target : Int = 160
  let mut lost_total : Int = 0
  let mut lost_limit : Int = 190
  let mut bridge_goal : Float = 84.0
  let mut raft_serial : Int = 1
  let mut wave : Int = 1

  let mut raft_spawn_cd : Float = 2.0
  let mut debris_spawn_cd : Float = 0.28
  let mut lightning_cd : Float = 6.5
  let mut supply_cd : Float = 13.0
  let mut unload_cd : Float = 0.0

  fn reset_run() -> Unit {
    init_currents(currents, world_x, world_y, world_w, world_h)
    init_bridge(spans, world_x, world_y, world_w, world_h)
    clear_rafts(rafts)
    clear_debris(debris)
    clear_lightning(strikes)
    clear_supplies(supplies)
    clear_rain(rain)
    clear_wakes(wakes)
    refill_rain(rain, world_l, world_t, world_r, world_b)

    boat.x = dock.x + Float::from_int(dock.w) * 0.5
    boat.y = dock.y + Float::from_int(dock.h) * 0.5
    boat.vx = 0.0
    boat.vy = 0.0
    boat.heading = 0.0
    boat.hull = 100.0
    boat.fuel = 100.0
    boat.kits = 8
    boat.passengers = 0
    boat.action_cd = 0.0
    boat.siren_cd = 0.0
    boat.siren_t = 0.0
    boat.boost_heat = 0.0
    boat.wake_t = 0.0

    timer = 460.0
    scene_t = 0.0
    msg = "Escort survivors and keep bridge spans above collapse."
    msg_t = 4.0
    rescued_total = 0
    rescue_target = 160
    lost_total = 0
    lost_limit = 190
    bridge_goal = 84.0
    raft_serial = 1
    wave = 1

    raft_spawn_cd = 2.0
    debris_spawn_cd = 0.28
    lightning_cd = 6.5
    supply_cd = 13.0
    unload_cd = 0.0
  }

  reset_run()

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
    if boat.action_cd > 0.0 {
      boat.action_cd = boat.action_cd - dt
      if boat.action_cd < 0.0 {
        boat.action_cd = 0.0
      }
    }
    if boat.siren_cd > 0.0 {
      boat.siren_cd = boat.siren_cd - dt
      if boat.siren_cd < 0.0 {
        boat.siren_cd = 0.0
      }
    }
    if boat.siren_t > 0.0 {
      boat.siren_t = boat.siren_t - dt
      if boat.siren_t < 0.0 {
        boat.siren_t = 0.0
      }
    }
    if unload_cd > 0.0 {
      unload_cd = unload_cd - dt
      if unload_cd < 0.0 {
        unload_cd = 0.0
      }
    }

    for i = 0; i < currents.length(); i = i + 1 {
      currents[i].pulse = currents[i].pulse +
        dt * (0.9 + Float::from_int(i % 3) * 0.35)
    }

    update_wakes(wakes, dt)

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

      let storm : Float = clampf(1.0 - timer / 460.0, 0.0, 1.0)
      let storm_surge : Float = sinf(scene_t * 1.3) * 0.5 + 0.5
      let storm_level : Float = clampf(
        storm * 0.8 + storm_surge * 0.38,
        0.0,
        1.4,
      )
      let wind_x : Float = -140.0 - storm_level * 120.0
      wave = 1 + rescued_total / 30
      if wave > 12 {
        wave = 12
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
      let mut siren_press : Bool = @raylib.is_key_pressed(@raylib.KeyK) ||
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
          Float::from_int(sw - 298),
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
          45.0,
        ) {
        action_press = true
      }
      if pointer_on_circle(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          Float::from_int(sw - 94),
          Float::from_int(sh - 142),
          42.0,
        ) {
        siren_press = true
      }

      // Player motion under current + steering
      let flow : FlowSample = find_flow(currents, boat.x, boat.y, storm_level)
      let mut move_x : Float = 0.0
      let mut move_y : Float = 0.0
      if move_l {
        move_x = move_x - 1.0
      }
      if move_r {
        move_x = move_x + 1.0
      }
      if move_u {
        move_y = move_y - 1.0
      }
      if move_d {
        move_y = move_y + 1.0
      }

      let norm : Float = (move_x * move_x + move_y * move_y).sqrt()
      if norm > 0.001 {
        move_x = move_x / norm
        move_y = move_y / norm
      }

      let mut accel : Float = 340.0
      let mut fuel_drain : Float = 2.1 + norm * 2.4 + flow.turbulence * 2.8

      if boost_hold && boat.fuel > 0.4 {
        accel = 540.0
        fuel_drain = fuel_drain + 7.6 + boat.boost_heat * 3.6
        boat.boost_heat = clampf(boat.boost_heat + dt * 0.82, 0.0, 1.0)
      } else {
        boat.boost_heat = clampf(boat.boost_heat - dt * 0.54, 0.0, 1.0)
      }

      if boat.fuel <= 0.0 {
        accel = 210.0
      }

      boat.vx = boat.vx + move_x * accel * dt
      boat.vy = boat.vy + move_y * accel * dt
      boat.vx = boat.vx + flow.vx * dt * 0.9
      boat.vy = boat.vy + flow.vy * dt * 0.9

      let drag : Float = 2.6 + flow.turbulence * 2.3
      boat.vx = boat.vx * (1.0 - dt * drag)
      boat.vy = boat.vy * (1.0 - dt * drag)

      let speed : Float = (boat.vx * boat.vx + boat.vy * boat.vy).sqrt()
      let boost_bonus : Float = if boost_hold { 120.0 } else { 0.0 }
      let max_speed : Float = 280.0 + boost_bonus
      if speed > max_speed {
        let k : Float = max_speed / speed
        boat.vx = boat.vx * k
        boat.vy = boat.vy * k
      }

      boat.x = boat.x + boat.vx * dt
      boat.y = boat.y + boat.vy * dt
      boat.heading = boat.heading + dt * (boat.vx * 0.004 + boat.vy * 0.002)

      if boat.x < world_l + 14.0 {
        boat.x = world_l + 14.0
        boat.vx = absf(boat.vx) * 0.3
      }
      if boat.x > world_r - 14.0 {
        boat.x = world_r - 14.0
        boat.vx = -absf(boat.vx) * 0.3
      }
      if boat.y < world_t + 14.0 {
        boat.y = world_t + 14.0
        boat.vy = absf(boat.vy) * 0.3
      }
      if boat.y > world_b - 14.0 {
        boat.y = world_b - 14.0
        boat.vy = -absf(boat.vy) * 0.3
      }

      boat.fuel = boat.fuel - dt * fuel_drain
      boat.fuel = clampf(boat.fuel, 0.0, boat.fuel_max)

      boat.wake_t = boat.wake_t + dt
      let wake_period : Float = if speed > 220.0 {
        0.014
      } else if speed > 120.0 {
        0.021
      } else {
        0.032
      }
      while boat.wake_t >= wake_period {
        boat.wake_t = boat.wake_t - wake_period
        spawn_wake(
          wakes,
          boat.x - boat.vx * 0.02 - 18.0,
          boat.y - boat.vy * 0.02,
          boat.vx,
          boat.vy,
          speed,
          if boost_hold {
            1
          } else {
            0
          },
        )
      }

      if siren_press && boat.siren_cd <= 0.0 && boat.fuel >= 6.0 {
        boat.siren_t = 3.6
        boat.siren_cd = 8.8
        boat.fuel = boat.fuel - 6.0
        msg = "Siren pulse active: nearby rafts panic slower."
        msg_t = 2.2
        for _i = 0; _i < 24; _i = _i + 1 {
          spawn_wake(
            wakes,
            boat.x,
            boat.y,
            randf(-120.0, 120.0),
            randf(-120.0, 120.0),
            180.0,
            1,
          )
        }
      }
      if boat.siren_t > 0.0 {
        calm_rafts(rafts, boat.x, boat.y, 220.0, dt)
      }

      // Spawns
      raft_spawn_cd = raft_spawn_cd - dt
      if raft_spawn_cd <= 0.0 {
        ignore(
          spawn_raft(rafts, world_l, world_t, world_r, world_b, raft_serial),
        )
        raft_serial = raft_serial + 1
        raft_spawn_cd = maxf(
          0.58,
          2.2 - storm_level * 0.9 - Float::from_int(wave) * 0.05,
        )
      }

      debris_spawn_cd = debris_spawn_cd - dt
      if debris_spawn_cd <= 0.0 {
        ignore(
          spawn_debris(debris, world_l, world_t, world_r, world_b, storm_level),
        )
        debris_spawn_cd = maxf(0.08, 0.36 - storm_level * 0.12)
      }

      lightning_cd = lightning_cd - dt
      if lightning_cd <= 0.0 {
        ignore(
          spawn_lightning(
            strikes, world_l, world_t, world_r, world_b, storm_level,
          ),
        )
        lightning_cd = maxf(1.8, 6.6 - storm_level * 4.1)
      }

      supply_cd = supply_cd - dt
      if supply_cd <= 0.0 {
        ignore(spawn_supply(supplies, world_l, world_t, world_r, world_b))
        supply_cd = randf(10.0, 19.0)
      }

      // Bridge erosion
      for i = 0; i < spans.length(); i = i + 1 {
        let decay : Float = dt *
          (0.78 + storm_level * 1.62 + spans[i].stress * 0.26)
        spans[i].integrity = spans[i].integrity - decay
        spans[i].stress = clampf(spans[i].stress - dt * 0.44, 0.0, 4.0)
        if spans[i].alarm_t > 0.0 {
          spans[i].alarm_t = spans[i].alarm_t - dt
          if spans[i].alarm_t < 0.0 {
            spans[i].alarm_t = 0.0
          }
        }
      }

      // Raft updates
      for i = 0; i < rafts.length(); i = i + 1 {
        if not(rafts[i].active) {
          continue
        }
        let raft_flow : FlowSample = find_flow(
          currents,
          rafts[i].x,
          rafts[i].y,
          storm_level,
        )
        rafts[i].vx = rafts[i].vx * (1.0 - dt * 0.9) + raft_flow.vx * dt * 0.64
        rafts[i].vy = rafts[i].vy * (1.0 - dt * 0.9) + raft_flow.vy * dt * 0.64
        rafts[i].x = rafts[i].x + rafts[i].vx * dt
        rafts[i].y = rafts[i].y + rafts[i].vy * dt
        rafts[i].flare_t = rafts[i].flare_t + dt * (2.0 + storm_level * 1.2)
        rafts[i].panic = rafts[i].panic + dt * (0.034 + storm_level * 0.056)

        if dist2(boat.x, boat.y, rafts[i].x, rafts[i].y) <= 92.0 * 92.0 {
          let calm_bonus : Float = if boat.siren_t > 0.0 { 0.3 } else { 0.0 }
          rafts[i].panic = rafts[i].panic - dt * (0.13 + calm_bonus)
        }
        rafts[i].panic = clampf(rafts[i].panic, 0.0, 1.6)

        let out_of_world : Bool = rafts[i].x < world_l - 40.0 ||
          rafts[i].x > world_r + 40.0 ||
          rafts[i].y < world_t - 40.0 ||
          rafts[i].y > world_b + 40.0
        if out_of_world || rafts[i].panic >= 1.36 {
          lost_total = lost_total + rafts[i].survivors
          rafts[i].active = false
        }
      }

      // Debris updates + collisions
      for i = 0; i < debris.length(); i = i + 1 {
        if not(debris[i].active) {
          continue
        }
        let debris_flow : FlowSample = find_flow(
          currents,
          debris[i].x,
          debris[i].y,
          storm_level,
        )
        debris[i].vx = debris[i].vx + debris_flow.vx * dt * 0.46
        debris[i].vy = debris[i].vy + debris_flow.vy * dt * 0.46
        debris[i].x = debris[i].x + debris[i].vx * dt
        debris[i].y = debris[i].y + debris[i].vy * dt
        debris[i].spin = debris[i].spin + dt * randf(-3.2, 3.2)

        if debris[i].x < world_l - 120.0 ||
          debris[i].x > world_r + 120.0 ||
          debris[i].y < world_t - 120.0 ||
          debris[i].y > world_b + 120.0 {
          debris[i].active = false
          continue
        }

        let rr : Float = debris[i].size + 14.0
        if dist2(boat.x, boat.y, debris[i].x, debris[i].y) <= rr * rr {
          let hit_dmg : Float = debris[i].hard * (5.0 + storm_level * 2.4)
          boat.hull = boat.hull - hit_dmg
          boat.vx = boat.vx - debris[i].vx * 0.23
          boat.vy = boat.vy - debris[i].vy * 0.23
          debris[i].active = false
          msg = "Debris hit! Hull damage."
          msg_t = 1.2
          for _j = 0; _j < 10; _j = _j + 1 {
            spawn_wake(
              wakes,
              boat.x + randf(-4.0, 4.0),
              boat.y + randf(-4.0, 4.0),
              randf(-180.0, 180.0),
              randf(-180.0, 180.0),
              220.0,
              1,
            )
          }
        }
      }

      // Lightning updates + effects
      for i = 0; i < strikes.length(); i = i + 1 {
        if not(strikes[i].active) {
          continue
        }
        strikes[i].pulse = strikes[i].pulse + dt * 7.2
        if strikes[i].telegraph > 0.0 {
          strikes[i].telegraph = strikes[i].telegraph - dt
        } else if strikes[i].life > 0.0 {
          strikes[i].life = strikes[i].life - dt
          let rr : Float = strikes[i].radius *
            (0.72 + clampf(strikes[i].life * 2.8, 0.0, 1.0) * 0.38)

          if dist2(boat.x, boat.y, strikes[i].x, strikes[i].y) <= rr * rr {
            boat.hull = boat.hull - dt * strikes[i].power * 9.0
            boat.vx = boat.vx + randf(-40.0, 40.0) * dt
            boat.vy = boat.vy + randf(-40.0, 40.0) * dt
          }

          for s = 0; s < spans.length(); s = s + 1 {
            let sx : Float = spans[s].x + spans[s].w * 0.5
            let sy : Float = spans[s].y + spans[s].h * 0.5
            if dist2(sx, sy, strikes[i].x, strikes[i].y) <=
              (rr + 60.0) * (rr + 60.0) {
              spans[s].integrity = spans[s].integrity -
                dt * strikes[i].power * 4.2
              spans[s].stress = clampf(spans[s].stress + dt * 1.8, 0.0, 4.0)
              spans[s].alarm_t = 0.5
            }
          }
        } else {
          strikes[i].active = false
        }
      }

      // Supplies
      for i = 0; i < supplies.length(); i = i + 1 {
        if not(supplies[i].active) {
          continue
        }
        let sup_flow : FlowSample = find_flow(
          currents,
          supplies[i].x,
          supplies[i].y,
          storm_level,
        )
        supplies[i].vx = supplies[i].vx * (1.0 - dt * 0.8) +
          sup_flow.vx * dt * 0.28
        supplies[i].vy = supplies[i].vy * (1.0 - dt * 0.8) +
          sup_flow.vy * dt * 0.28
        supplies[i].x = supplies[i].x + supplies[i].vx * dt
        supplies[i].y = supplies[i].y + supplies[i].vy * dt
        supplies[i].blink = supplies[i].blink + dt * 3.2

        if dist2(boat.x, boat.y, supplies[i].x, supplies[i].y) <= 29.0 * 29.0 {
          if supplies[i].kind == 0 {
            boat.kits = mini(boat.kit_max, boat.kits + supplies[i].amount)
            msg = "Collected repair kits +\{supplies[i].amount}"
          } else {
            boat.fuel = minf(
              boat.fuel_max,
              boat.fuel + Float::from_int(supplies[i].amount),
            )
            msg = "Collected fuel +\{supplies[i].amount}"
          }
          msg_t = 1.3
          supplies[i].active = false
        }
      }

      update_rain(rain, dt, world_l, world_t, world_r, world_b, wind_x)

      // Station effects
      let at_dock : Bool = inside_rectf(
        boat.x,
        boat.y,
        dock.x,
        dock.y,
        Float::from_int(dock.w),
        Float::from_int(dock.h),
      )
      let at_camp : Bool = inside_rectf(
        boat.x,
        boat.y,
        camp.x,
        camp.y,
        Float::from_int(camp.w),
        Float::from_int(camp.h),
      )

      if at_dock {
        boat.fuel = minf(boat.fuel_max, boat.fuel + dt * 24.0)
        if action_press && boat.action_cd <= 0.0 {
          boat.kits = boat.kit_max
          boat.fuel = minf(boat.fuel_max, boat.fuel + 26.0)
          boat.action_cd = 0.35
          msg = "Dock service: kits restocked, fuel topped."
          msg_t = 1.4
        }
      }

      if at_camp && boat.passengers > 0 {
        if unload_cd <= 0.0 {
          boat.passengers = boat.passengers - 1
          rescued_total = rescued_total + 1
          unload_cd = 0.11
        }
      }

      // Action interaction
      if action_press && boat.action_cd <= 0.0 {
        let mut did_action : Bool = false

        // Pick up from nearest raft
        let mut nearest_raft : Int = -1
        let mut best_d2 : Float = 54.0 * 54.0
        for i = 0; i < rafts.length(); i = i + 1 {
          if not(rafts[i].active) {
            continue
          }
          let d2 : Float = dist2(boat.x, boat.y, rafts[i].x, rafts[i].y)
          if d2 <= best_d2 {
            best_d2 = d2
            nearest_raft = i
          }
        }
        if nearest_raft >= 0 {
          let can_take : Int = boat.capacity - boat.passengers
          if can_take > 0 {
            let taken : Int = mini(
              can_take,
              mini(rafts[nearest_raft].survivors, 5),
            )
            boat.passengers = boat.passengers + taken
            rafts[nearest_raft].survivors = rafts[nearest_raft].survivors -
              taken
            rafts[nearest_raft].panic = maxf(
              0.0,
              rafts[nearest_raft].panic - 0.2,
            )
            did_action = true
            msg = "Loaded \{taken} survivors."
            msg_t = 1.0
            if rafts[nearest_raft].survivors <= 0 {
              rafts[nearest_raft].active = false
            }
          } else {
            msg = "Boat full. Unload at evac camp."
            msg_t = 1.0
          }
        }

        // Repair nearest span
        if not(did_action) {
          let si : Int = nearest_span_index(spans, boat.x, boat.y, 68.0)
          if si >= 0 && boat.kits > 0 {
            let repair : Float = randf(8.0, 14.0)
            spans[si].integrity = minf(100.0, spans[si].integrity + repair)
            spans[si].stress = maxf(0.0, spans[si].stress - 0.8)
            boat.kits = boat.kits - 1
            did_action = true
            msg = "Bridge span #\{spans[si].id} repaired +\{repair.to_int()}%"
            msg_t = 1.2
          }
        }

        if did_action {
          boat.action_cd = 0.24
        }
      }

      // Failure checks
      boat.hull = clampf(boat.hull, 0.0, boat.hull_max)
      let min_integrity : Float = min_bridge_integrity(spans)
      if boat.hull <= 0.0 {
        state = 3
        msg = "Boat destroyed in storm."
      } else if min_integrity <= 0.0 {
        state = 3
        msg = "Bridge collapsed."
      } else if lost_total >= lost_limit {
        state = 3
        msg = "Too many survivors lost."
      } else if timer <= 0.0 {
        if rescued_total >= rescue_target && min_integrity >= bridge_goal {
          state = 2
          msg = "Rescue mission complete."
        } else {
          state = 3
          msg = "Objectives not met before storm window closed."
        }
      } else if rescued_total >= rescue_target && min_integrity >= bridge_goal {
        state = 2
        msg = "All objectives stabilized early. Convoy safe."
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
      let storm_for_draw : Float = if state == 1 {
        clampf(1.0 - timer / 460.0, 0.0, 1.0)
      } else {
        clampf(1.0 - timer / 460.0, 0.0, 1.0)
      }
      let wind_x : Float = -140.0 - storm_for_draw * 120.0

      draw_river(world_x, world_y, world_w, world_h, scene_t, storm_for_draw)
      draw_current_grid(currents, storm_for_draw)
      draw_world_panels(dock, camp, scene_t)
      draw_spans(spans, scene_t)
      draw_supplies(supplies, scene_t)
      draw_debris_field(debris)
      draw_rafts(rafts, scene_t)
      draw_wakes(wakes)
      draw_strikes(strikes, scene_t)
      draw_boat(boat, scene_t)
      draw_rain(rain, wind_x)

      if boat.siren_t > 0.0 {
        let p : Float = sinf(boat.siren_t * 8.0) * 0.5 + 0.5
        @raylib.draw_circle_lines(
          boat.x.to_int(),
          boat.y.to_int(),
          120.0 + p * 100.0,
          @raylib.Color::new(248, 194, 106, 190),
        )
      }

      let min_integrity : Float = min_bridge_integrity(spans)
      draw_panel(
        world_x + world_w + 10,
        world_y,
        panel_w - 10,
        world_h,
        boat,
        rescued_total,
        rescue_target,
        lost_total,
        lost_limit,
        min_integrity,
        bridge_goal,
        timer,
        wave,
        if msg_t > 0.0 {
          msg
        } else {
          ""
        },
      )
      draw_touch_controls(sw, sh, mouse.x, mouse.y, hold, touch_count)

      if state == 2 || state == 3 {
        draw_end_screen(
          sw,
          sh,
          state == 2,
          rescued_total,
          rescue_target,
          min_integrity,
          bridge_goal,
          lost_total,
          timer,
        )
      }
    }

    @raylib.end_drawing()
  }
}
