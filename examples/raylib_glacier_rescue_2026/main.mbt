///|
let sw : Int = 1280

///|
let sh : Int = 800

///|
let world_w : Float = 4200.0

///|
let world_h : Float = 2800.0

///|
let max_survivors : Int = 44

///|
let max_hazards : Int = 52

///|
let max_particles : Int = 1100

///|
let max_flares : Int = 8

///|
let max_avalanches : Int = 10

///|
let base_x : Float = 280.0

///|
let base_y : Float = world_h - 260.0

///|
struct Helicopter {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut tilt : Float
  mut rotor : Float
  mut fuel : Float
  mut hull : Float
  mut cold : Float
  mut boost_t : Float
  mut boost_cd : Float
  mut flare_cd : Float
  mut shake_t : Float
  mut flash_t : Float
  mut onboard : Int
  mut rescued : Int
  mut lost : Int
  mut score : Int
}

///|
struct Survivor {
  mut active : Bool
  mut saved : Bool
  mut carried : Bool
  mut x : Float
  mut y : Float
  mut panic_t : Float
  mut freeze : Float
  mut beacon_t : Float
  mut offset_x : Float
  mut offset_y : Float
}

///|
struct Hazard {
  mut active : Bool
  kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  r : Float
  mut spin : Float
  mut life : Float
}

///|
struct Avalanche {
  mut active : Bool
  mut x : Float
  y : Float
  w : Float
  speed : Float
  mut life : Float
}

///|
struct Flare {
  mut active : Bool
  x : Float
  y : Float
  mut r : Float
  mut t : Float
  mut life : Float
}

///|
struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  size : Float
  mut t : Float
  life : Float
  kind : Int
}

///|
struct Storm {
  mut wind_x : Float
  mut wind_y : Float
  mut shift_t : Float
  mut gust_t : Float
  mut whiteout_t : Float
  mut severity : Float
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
fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn sinf(x : Float) -> Float {
  @math.sinf(x)
}

///|
fn cosf(x : Float) -> Float {
  @math.cosf(x)
}

///|
fn dist2(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
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
  let x0 = Float::from_int(x)
  let y0 = Float::from_int(y)
  let x1 = Float::from_int(x + w)
  let y1 = Float::from_int(y + h)
  px >= x0 && px <= x1 && py >= y0 && py <= y1
}

///|
fn emit_particle(
  particles : FixedArray[Particle],
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  size : Float,
  life : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < particles.length(); i = i + 1 {
    if not(particles[i].active) {
      particles[i] = { active: true, x, y, vx, vy, size, t: 0.0, life, kind }
      break
    }
  }
}

///|
fn burst_particles(
  particles : FixedArray[Particle],
  x : Float,
  y : Float,
  count : Int,
  power : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < count; i = i + 1 {
    let ang = randf(0.0, 6.283)
    let spd = randf(power * 0.35, power)
    emit_particle(
      particles,
      x,
      y,
      cosf(ang) * spd,
      sinf(ang) * spd,
      randf(2.0, 6.0),
      randf(0.25, 0.95),
      kind,
    )
  }
}

///|
fn spawn_survivors(survivors : FixedArray[Survivor], level : Int) -> Unit {
  let total = clampf(
    Float::from_int(20 + level * 4),
    20.0,
    Float::from_int(max_survivors),
  ).to_int()
  for i = 0; i < survivors.length(); i = i + 1 {
    if i < total {
      let lane = i % 6
      let col = i / 6
      let px : Float = 640.0 + Float::from_int(col) * 260.0 + randf(-72.0, 72.0)
      let py : Float = 300.0 +
        Float::from_int(lane) * 380.0 +
        randf(-64.0, 64.0)
      survivors[i] = {
        active: true,
        saved: false,
        carried: false,
        x: clampf(px, 220.0, world_w - 120.0),
        y: clampf(py, 140.0, world_h - 120.0),
        panic_t: randf(0.0, 2.0),
        freeze: randf(5.0, 24.0),
        beacon_t: randf(0.0, 1.0),
        offset_x: randf(-12.0, 12.0),
        offset_y: randf(-8.0, 8.0),
      }
    } else {
      survivors[i].active = false
      survivors[i].saved = false
      survivors[i].carried = false
    }
  }
}

///|
fn spawn_hazards(hazards : FixedArray[Hazard], level : Int) -> Unit {
  let total = clampf(
    Float::from_int(18 + level * 5),
    18.0,
    Float::from_int(max_hazards),
  ).to_int()
  for i = 0; i < hazards.length(); i = i + 1 {
    if i < total {
      let kind = if i % 3 == 0 { 1 } else { 0 }
      let r = if kind == 0 { randf(20.0, 34.0) } else { randf(28.0, 42.0) }
      let speed = if kind == 0 { randf(22.0, 54.0) } else { randf(38.0, 82.0) }
      let ang = randf(0.0, 6.283)
      hazards[i] = {
        active: true,
        kind,
        x: randf(420.0, world_w - 120.0),
        y: randf(120.0, world_h - 120.0),
        vx: cosf(ang) * speed,
        vy: sinf(ang) * speed,
        r,
        spin: randf(-2.5, 2.5),
        life: randf(8.0, 18.0),
      }
    } else {
      hazards[i].active = false
    }
  }
}

///|
fn spawn_avalanche(avalanches : FixedArray[Avalanche], level : Int) -> Unit {
  for i = 0; i < avalanches.length(); i = i + 1 {
    if not(avalanches[i].active) {
      let y = randf(160.0, world_h - 240.0)
      let wide = randf(260.0, 520.0)
      avalanches[i] = {
        active: true,
        x: -wide,
        y,
        w: wide,
        speed: 220.0 + Float::from_int(level) * 38.0 + randf(-24.0, 32.0),
        life: randf(8.0, 12.0),
      }
      break
    }
  }
}

///|
fn spawn_flare(flares : FixedArray[Flare], x : Float, y : Float) -> Unit {
  for i = 0; i < flares.length(); i = i + 1 {
    if not(flares[i].active) {
      flares[i] = { active: true, x, y, r: 36.0, t: 0.0, life: 3.8 }
      break
    }
  }
}

///|
fn draw_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  ratio : Float,
  fg : @raylib.Color,
  bg : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, bg)
  let fill = clampf(ratio, 0.0, 1.0)
  @raylib.draw_rectangle(
    x + 2,
    y + 2,
    (Float::from_int(w - 4) * fill).to_int(),
    h - 4,
    fg,
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(232, 238, 248, 180),
  )
}

///|
fn draw_touch_controls(show : Bool) -> Unit {
  if not(show) {
    return
  }

  let cx = 24
  let cy = sh - 230
  let right = sw - 214

  @raylib.draw_rectangle(
    cx,
    cy + 62,
    78,
    78,
    @raylib.Color::new(80, 108, 142, 84),
  )
  @raylib.draw_text(
    "L",
    cx + 30,
    cy + 90,
    26,
    @raylib.Color::new(238, 244, 250, 210),
  )

  @raylib.draw_rectangle(
    cx + 168,
    cy + 62,
    78,
    78,
    @raylib.Color::new(80, 108, 142, 84),
  )
  @raylib.draw_text(
    "R",
    cx + 198,
    cy + 90,
    26,
    @raylib.Color::new(238, 244, 250, 210),
  )

  @raylib.draw_rectangle(
    cx + 84,
    cy,
    78,
    78,
    @raylib.Color::new(80, 108, 142, 84),
  )
  @raylib.draw_text(
    "U",
    cx + 113,
    cy + 28,
    26,
    @raylib.Color::new(238, 244, 250, 210),
  )

  @raylib.draw_rectangle(
    cx + 84,
    cy + 124,
    78,
    78,
    @raylib.Color::new(80, 108, 142, 84),
  )
  @raylib.draw_text(
    "D",
    cx + 112,
    cy + 151,
    26,
    @raylib.Color::new(238, 244, 250, 210),
  )

  @raylib.draw_rectangle(
    right,
    cy + 18,
    174,
    78,
    @raylib.Color::new(196, 110, 92, 94),
  )
  @raylib.draw_text(
    "BOOST",
    right + 42,
    cy + 45,
    28,
    @raylib.Color::new(252, 240, 228, 220),
  )

  @raylib.draw_rectangle(
    right,
    cy + 116,
    174,
    78,
    @raylib.Color::new(110, 146, 212, 94),
  )
  @raylib.draw_text(
    "FLARE",
    right + 48,
    cy + 143,
    28,
    @raylib.Color::new(242, 248, 255, 220),
  )
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [moonbit] example - glacier rescue 2026")
  defer @raylib.close_window()

  @raylib.set_target_fps(60)

  let survivors = FixedArray::make(max_survivors, {
    active: false,
    saved: false,
    carried: false,
    x: 0.0,
    y: 0.0,
    panic_t: 0.0,
    freeze: 0.0,
    beacon_t: 0.0,
    offset_x: 0.0,
    offset_y: 0.0,
  })

  let hazards = FixedArray::make(max_hazards, {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    r: 0.0,
    spin: 0.0,
    life: 0.0,
  })

  let avalanches = FixedArray::make(max_avalanches, {
    active: false,
    x: 0.0,
    y: 0.0,
    w: 0.0,
    speed: 0.0,
    life: 0.0,
  })

  let flares = FixedArray::make(max_flares, {
    active: false,
    x: 0.0,
    y: 0.0,
    r: 0.0,
    t: 0.0,
    life: 0.0,
  })

  let particles = FixedArray::make(max_particles, {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    size: 0.0,
    t: 0.0,
    life: 0.0,
    kind: 0,
  })

  let heli = {
    x: base_x + 28.0,
    y: base_y,
    vx: 0.0,
    vy: 0.0,
    tilt: 0.0,
    rotor: 0.0,
    fuel: 100.0,
    hull: 100.0,
    cold: 12.0,
    boost_t: 0.0,
    boost_cd: 0.0,
    flare_cd: 0.0,
    shake_t: 0.0,
    flash_t: 0.0,
    onboard: 0,
    rescued: 0,
    lost: 0,
    score: 0,
  }

  let storm = {
    wind_x: 38.0,
    wind_y: -12.0,
    shift_t: 0.0,
    gust_t: 1.4,
    whiteout_t: 0.0,
    severity: 0.36,
  }

  let mut level : Int = 1
  let mut mission_target : Int = 12
  let mut mission_time : Float = 230.0
  let mut avalanche_cd : Float = 5.0
  let mut announce_t : Float = 0.0
  let mut state : Int = 0

  let reset_round = fn(new_level : Int) {
    level = new_level
    mission_target = 12 + (level - 1) * 4
    mission_time = 236.0 - Float::from_int(level - 1) * 16.0
    if mission_time < 130.0 {
      mission_time = 130.0
    }

    heli.x = base_x + 28.0
    heli.y = base_y
    heli.vx = 0.0
    heli.vy = 0.0
    heli.tilt = 0.0
    heli.rotor = 0.0
    heli.fuel = 100.0
    heli.hull = 100.0
    heli.cold = 12.0
    heli.boost_t = 0.0
    heli.boost_cd = 0.0
    heli.flare_cd = 0.0
    heli.shake_t = 0.0
    heli.flash_t = 0.0
    heli.onboard = 0
    heli.rescued = 0
    heli.lost = 0
    heli.score = 0

    storm.wind_x = 34.0 + Float::from_int(level) * 8.0
    storm.wind_y = -12.0
    storm.shift_t = 0.0
    storm.gust_t = 1.0
    storm.whiteout_t = 0.0
    storm.severity = 0.34 + Float::from_int(level - 1) * 0.12
    storm.severity = clampf(storm.severity, 0.34, 0.92)

    avalanche_cd = 5.0
    announce_t = 2.8

    for i = 0; i < avalanches.length(); i = i + 1 {
      avalanches[i].active = false
    }
    for i = 0; i < flares.length(); i = i + 1 {
      flares[i].active = false
    }
    for i = 0; i < particles.length(); i = i + 1 {
      particles[i].active = false
    }

    spawn_survivors(survivors, level)
    spawn_hazards(hazards, level)
  }

  reset_round(level)

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    let mouse = @raylib.get_mouse_position()
    let touching = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)

    let mut move_l = @raylib.is_key_down(@raylib.KeyA) ||
      @raylib.is_key_down(@raylib.KeyLeft)
    let mut move_r = @raylib.is_key_down(@raylib.KeyD) ||
      @raylib.is_key_down(@raylib.KeyRight)
    let mut move_u = @raylib.is_key_down(@raylib.KeyW) ||
      @raylib.is_key_down(@raylib.KeyUp)
    let mut move_d = @raylib.is_key_down(@raylib.KeyS) ||
      @raylib.is_key_down(@raylib.KeyDown)
    let mut boost_down = @raylib.is_key_down(@raylib.KeyLeftShift) ||
      @raylib.is_key_down(@raylib.KeySpace)
    let mut flare_press = @raylib.is_key_pressed(@raylib.KeyE)

    let pad_x = 24
    let pad_y = sh - 230
    let act_x = sw - 214

    if touching {
      if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 62, 78, 78) {
        move_l = true
      }
      if inside_rect(mouse.x, mouse.y, pad_x + 168, pad_y + 62, 78, 78) {
        move_r = true
      }
      if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y, 78, 78) {
        move_u = true
      }
      if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y + 124, 78, 78) {
        move_d = true
      }
      if inside_rect(mouse.x, mouse.y, act_x, pad_y + 18, 174, 78) {
        boost_down = true
      }
      if inside_rect(mouse.x, mouse.y, act_x, pad_y + 116, 174, 78) {
        flare_press = true
      }
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_round(level)
      state = 1
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeySpace) {
        state = 1
        reset_round(level)
      }
    } else if state == 2 || state == 3 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeySpace) {
        if state == 2 {
          level = level + 1
          if level > 5 {
            level = 5
          }
        }
        state = 1
        reset_round(level)
      }
    } else {
      mission_time = mission_time - dt
      if mission_time < 0.0 {
        mission_time = 0.0
      }

      storm.shift_t = storm.shift_t + dt
      storm.gust_t = storm.gust_t - dt
      if storm.gust_t <= 0.0 {
        storm.gust_t = randf(1.2, 2.6)
        storm.wind_x = lerpf(storm.wind_x, randf(-88.0, 108.0), 0.4)
        storm.wind_y = lerpf(storm.wind_y, randf(-62.0, 62.0), 0.4)
        if @raylib.get_random_value(0, 100) < 16 + level * 6 {
          storm.whiteout_t = randf(1.6, 2.8)
        }
      }
      if storm.whiteout_t > 0.0 {
        storm.whiteout_t = storm.whiteout_t - dt
        if storm.whiteout_t < 0.0 {
          storm.whiteout_t = 0.0
        }
      }

      if heli.boost_t > 0.0 {
        heli.boost_t = heli.boost_t - dt
        if heli.boost_t < 0.0 {
          heli.boost_t = 0.0
        }
      }
      if heli.boost_cd > 0.0 {
        heli.boost_cd = heli.boost_cd - dt
        if heli.boost_cd < 0.0 {
          heli.boost_cd = 0.0
        }
      }
      if heli.flare_cd > 0.0 {
        heli.flare_cd = heli.flare_cd - dt
        if heli.flare_cd < 0.0 {
          heli.flare_cd = 0.0
        }
      }
      if heli.shake_t > 0.0 {
        heli.shake_t = heli.shake_t - dt
        if heli.shake_t < 0.0 {
          heli.shake_t = 0.0
        }
      }
      if heli.flash_t > 0.0 {
        heli.flash_t = heli.flash_t - dt
        if heli.flash_t < 0.0 {
          heli.flash_t = 0.0
        }
      }
      if announce_t > 0.0 {
        announce_t = announce_t - dt
        if announce_t < 0.0 {
          announce_t = 0.0
        }
      }

      if boost_down && heli.boost_cd <= 0.0 && heli.fuel > 8.0 {
        heli.boost_t = 1.4
        heli.boost_cd = 3.4
        burst_particles(particles, heli.x, heli.y, 20, 108.0, 2)
      }

      if flare_press && heli.flare_cd <= 0.0 && heli.fuel > 4.0 {
        heli.flare_cd = 5.2
        heli.fuel = heli.fuel - 4.0
        spawn_flare(flares, heli.x, heli.y)
        burst_particles(particles, heli.x, heli.y, 28, 86.0, 1)
      }

      let mut ix : Float = 0.0
      let mut iy : Float = 0.0
      if move_l {
        ix = ix - 1.0
      }
      if move_r {
        ix = ix + 1.0
      }
      if move_u {
        iy = iy - 1.0
      }
      if move_d {
        iy = iy + 1.0
      }

      let mag2 : Float = ix * ix + iy * iy
      if mag2 > 1.0 {
        let inv : Float = 1.0 / mag2.sqrt()
        ix = ix * inv
        iy = iy * inv
      }

      let near_base = dist2(heli.x, heli.y, base_x, base_y) < 150.0 * 150.0
      let accel : Float = if heli.boost_t > 0.0 { 620.0 } else { 430.0 }
      let max_speed : Float = if heli.boost_t > 0.0 { 420.0 } else { 268.0 }
      let drag : Float = if heli.boost_t > 0.0 { 1.45 } else { 2.1 }
      let wind_mul : Float = 0.35 + storm.severity * 0.35

      if heli.fuel <= 0.0 {
        ix = 0.0
        iy = 0.0
      }

      heli.vx = heli.vx +
        (ix * accel + storm.wind_x * wind_mul - heli.vx * drag) * dt
      heli.vy = heli.vy +
        (iy * accel + storm.wind_y * wind_mul - heli.vy * drag) * dt

      let speed2 : Float = heli.vx * heli.vx + heli.vy * heli.vy
      let speed : Float = speed2.sqrt()
      if speed > max_speed {
        let inv : Float = max_speed / speed
        heli.vx = heli.vx * inv
        heli.vy = heli.vy * inv
      }

      heli.x = heli.x + heli.vx * dt
      heli.y = heli.y + heli.vy * dt

      if heli.x < 46.0 {
        heli.x = 46.0
        heli.vx = heli.vx.abs() * 0.28
      }
      if heli.x > world_w - 46.0 {
        heli.x = world_w - 46.0
        heli.vx = -heli.vx.abs() * 0.28
      }
      if heli.y < 46.0 {
        heli.y = 46.0
        heli.vy = heli.vy.abs() * 0.28
      }
      if heli.y > world_h - 46.0 {
        heli.y = world_h - 46.0
        heli.vy = -heli.vy.abs() * 0.28
      }

      heli.tilt = clampf(heli.vx * 0.12, -24.0, 24.0)
      let rotor_speed : Float = if heli.boost_t > 0.0 { 880.0 } else { 620.0 }
      heli.rotor = heli.rotor + dt * rotor_speed

      let mut fuel_drain : Float = 1.8 + speed * 0.004 + storm.severity * 0.9
      if heli.boost_t > 0.0 {
        fuel_drain = fuel_drain + 8.5
      }
      if ix == 0.0 && iy == 0.0 {
        fuel_drain = fuel_drain * 0.56
      }
      heli.fuel = heli.fuel - fuel_drain * dt

      if near_base && speed < 72.0 {
        heli.fuel = heli.fuel + 26.0 * dt
        heli.cold = heli.cold - 22.0 * dt
        heli.hull = heli.hull + 6.5 * dt
      }

      heli.fuel = clampf(heli.fuel, 0.0, 100.0)
      heli.hull = clampf(heli.hull, 0.0, 100.0)

      let mut cold_rate : Float = 5.0 + storm.severity * 10.0
      if near_base {
        cold_rate = cold_rate - 8.0
      }
      if heli.boost_t > 0.0 {
        cold_rate = cold_rate + 3.2
      }
      for i = 0; i < flares.length(); i = i + 1 {
        if not(flares[i].active) {
          continue
        }
        let d2 = dist2(heli.x, heli.y, flares[i].x, flares[i].y)
        if d2 < flares[i].r * flares[i].r {
          cold_rate = cold_rate - 10.0
        }
      }
      heli.cold = heli.cold + cold_rate * dt
      heli.cold = clampf(heli.cold, 0.0, 140.0)

      if heli.cold > 100.0 {
        heli.hull = heli.hull - (heli.cold - 100.0) * 0.11 * dt
      }

      avalanche_cd = avalanche_cd - dt
      if avalanche_cd <= 0.0 {
        spawn_avalanche(avalanches, level)
        avalanche_cd = randf(8.2, 12.8) - Float::from_int(level) * 0.65
        if avalanche_cd < 4.0 {
          avalanche_cd = 4.0
        }
      }

      let mut impact = false
      for i = 0; i < hazards.length(); i = i + 1 {
        if not(hazards[i].active) {
          continue
        }

        hazards[i].life = hazards[i].life - dt
        if hazards[i].life <= 0.0 {
          hazards[i].life = randf(8.0, 18.0)
          let a = randf(0.0, 6.283)
          let spd = if hazards[i].kind == 0 {
            randf(22.0, 54.0)
          } else {
            randf(42.0, 92.0)
          }
          hazards[i].vx = cosf(a) * spd
          hazards[i].vy = sinf(a) * spd
        }

        hazards[i].x = hazards[i].x + (hazards[i].vx + storm.wind_x * 0.16) * dt
        hazards[i].y = hazards[i].y + (hazards[i].vy + storm.wind_y * 0.16) * dt
        let spin_speed : Float = if hazards[i].kind == 0 { 2.2 } else { 3.8 }
        hazards[i].spin = hazards[i].spin + dt * spin_speed

        if hazards[i].x < 80.0 {
          hazards[i].x = 80.0
          hazards[i].vx = hazards[i].vx.abs()
        }
        if hazards[i].x > world_w - 80.0 {
          hazards[i].x = world_w - 80.0
          hazards[i].vx = -hazards[i].vx.abs()
        }
        if hazards[i].y < 80.0 {
          hazards[i].y = 80.0
          hazards[i].vy = hazards[i].vy.abs()
        }
        if hazards[i].y > world_h - 80.0 {
          hazards[i].y = world_h - 80.0
          hazards[i].vy = -hazards[i].vy.abs()
        }

        let rr = hazards[i].r + 17.0
        if dist2(heli.x, heli.y, hazards[i].x, hazards[i].y) < rr * rr {
          impact = true
          let dx = heli.x - hazards[i].x
          let dy = heli.y - hazards[i].y
          let d2 = dx * dx + dy * dy
          let inv : Float = if d2 < 1.0 { 0.0 } else { 1.0 / d2.sqrt() }
          heli.vx = heli.vx + dx * inv * 140.0
          heli.vy = heli.vy + dy * inv * 140.0
          hazards[i].vx = hazards[i].vx - dx * inv * 120.0
          hazards[i].vy = hazards[i].vy - dy * inv * 120.0
          burst_particles(particles, heli.x, heli.y, 18, 102.0, 2)
        }
      }

      for i = 0; i < avalanches.length(); i = i + 1 {
        if not(avalanches[i].active) {
          continue
        }

        avalanches[i].x = avalanches[i].x + avalanches[i].speed * dt
        avalanches[i].life = avalanches[i].life - dt

        if avalanches[i].x > world_w + avalanches[i].w ||
          avalanches[i].life <= 0.0 {
          avalanches[i].active = false
          continue
        }

        let inside_x = heli.x >= avalanches[i].x &&
          heli.x <= avalanches[i].x + avalanches[i].w
        let inside_y = (heli.y - avalanches[i].y).abs() <= 34.0
        if inside_x && inside_y {
          impact = true
          heli.vx = heli.vx + 210.0 * dt
          heli.vy = heli.vy + randf(-70.0, 70.0) * dt
          burst_particles(particles, heli.x, heli.y, 12, 118.0, 0)
        }
      }

      if impact {
        heli.hull = heli.hull - (6.0 + storm.severity * 4.0) * dt * 30.0
        heli.shake_t = 0.24
        heli.flash_t = 0.18
      }

      let mut carrying_now : Int = 0
      for i = 0; i < survivors.length(); i = i + 1 {
        if not(survivors[i].active) {
          continue
        }

        survivors[i].panic_t = survivors[i].panic_t + dt
        survivors[i].beacon_t = survivors[i].beacon_t +
          dt * (1.2 + storm.severity)

        if not(survivors[i].carried) {
          let mut freeze_rate : Float = 2.4 + storm.severity * 4.1
          for j = 0; j < flares.length(); j = j + 1 {
            if not(flares[j].active) {
              continue
            }
            let d2 = dist2(
              survivors[i].x,
              survivors[i].y,
              flares[j].x,
              flares[j].y,
            )
            if d2 < flares[j].r * flares[j].r {
              freeze_rate = freeze_rate - 4.2
            }
          }
          if freeze_rate < 0.7 {
            freeze_rate = 0.7
          }
          survivors[i].freeze = survivors[i].freeze + freeze_rate * dt

          if survivors[i].freeze >= 100.0 {
            survivors[i].active = false
            survivors[i].saved = false
            heli.lost = heli.lost + 1
            burst_particles(
              particles,
              survivors[i].x,
              survivors[i].y,
              16,
              52.0,
              0,
            )
            continue
          }

          let pickup_r : Float = 34.0
          if heli.onboard < 4 &&
            dist2(heli.x, heli.y, survivors[i].x, survivors[i].y) <=
            pickup_r * pickup_r {
            survivors[i].carried = true
            survivors[i].offset_x = randf(-18.0, 18.0)
            survivors[i].offset_y = randf(-12.0, 18.0)
            heli.onboard = heli.onboard + 1
            heli.score = heli.score + 90
            burst_particles(
              particles,
              survivors[i].x,
              survivors[i].y,
              8,
              42.0,
              1,
            )
          }
        }

        if survivors[i].carried {
          carrying_now = carrying_now + 1
          let slot = carrying_now - 1
          let row = slot / 2
          let col = slot % 2
          let tx = heli.x + Float::from_int(col * 26 - 13)
          let ty = heli.y + 34.0 + Float::from_int(row * 20)
          survivors[i].x = lerpf(survivors[i].x, tx, dt * 8.2)
          survivors[i].y = lerpf(survivors[i].y, ty, dt * 8.2)
          survivors[i].freeze = survivors[i].freeze - 5.8 * dt
          if survivors[i].freeze < 0.0 {
            survivors[i].freeze = 0.0
          }
        }
      }

      if near_base && speed < 86.0 && heli.onboard > 0 {
        for i = 0; i < survivors.length(); i = i + 1 {
          if not(survivors[i].active) || not(survivors[i].carried) {
            continue
          }
          survivors[i].active = false
          survivors[i].saved = true
          survivors[i].carried = false
          heli.rescued = heli.rescued + 1
          heli.onboard = heli.onboard - 1
          heli.score = heli.score + 220
          burst_particles(
            particles,
            base_x + randf(-30.0, 30.0),
            base_y + randf(-22.0, 22.0),
            10,
            55.0,
            1,
          )
        }
      }

      for i = 0; i < flares.length(); i = i + 1 {
        if not(flares[i].active) {
          continue
        }
        flares[i].t = flares[i].t + dt
        flares[i].r = flares[i].r + dt * 148.0
        if flares[i].r > 320.0 {
          flares[i].r = 320.0
        }
        flares[i].life = flares[i].life - dt
        if flares[i].life <= 0.0 {
          flares[i].active = false
        }
      }

      let mut snow_count = 2 + level
      if storm.whiteout_t > 0.0 {
        snow_count = snow_count + 4
      }
      for i = 0; i < snow_count; i = i + 1 {
        let ang = randf(0.0, 6.283)
        emit_particle(
          particles,
          heli.x + randf(-380.0, 380.0),
          heli.y + randf(-260.0, 260.0),
          storm.wind_x * 0.6 + cosf(ang) * randf(6.0, 28.0),
          storm.wind_y * 0.6 + sinf(ang) * randf(6.0, 22.0),
          randf(1.0, 3.8),
          randf(0.4, 1.2),
          0,
        )
      }

      if speed > 80.0 {
        emit_particle(
          particles,
          heli.x - heli.vx * 0.05,
          heli.y - heli.vy * 0.05,
          -heli.vx * 0.18 + randf(-20.0, 20.0),
          -heli.vy * 0.18 + randf(-20.0, 20.0),
          randf(2.0, 4.5),
          randf(0.15, 0.32),
          2,
        )
      }

      for i = 0; i < particles.length(); i = i + 1 {
        if not(particles[i].active) {
          continue
        }
        particles[i].t = particles[i].t + dt
        if particles[i].t >= particles[i].life {
          particles[i].active = false
          continue
        }
        particles[i].x = particles[i].x + particles[i].vx * dt
        particles[i].y = particles[i].y + particles[i].vy * dt
        particles[i].vx = particles[i].vx * (1.0 - dt * 0.35)
        particles[i].vy = particles[i].vy * (1.0 - dt * 0.35)
      }

      if heli.hull <= 0.0 {
        heli.hull = 0.0
        state = 3
      } else if mission_time <= 0.0 {
        state = 3
      } else if heli.rescued >= mission_target {
        state = 2
        heli.score = heli.score +
          mission_time.to_int() * 8 +
          (mission_target - heli.lost) * 60
      }
    }

    let mut cam_x = heli.x - Float::from_int(sw) * 0.5
    let mut cam_y = heli.y - Float::from_int(sh) * 0.5
    if cam_x < 0.0 {
      cam_x = 0.0
    }
    if cam_y < 0.0 {
      cam_y = 0.0
    }
    if cam_x > world_w - Float::from_int(sw) {
      cam_x = world_w - Float::from_int(sw)
    }
    if cam_y > world_h - Float::from_int(sh) {
      cam_y = world_h - Float::from_int(sh)
    }

    let shake_x = if heli.shake_t > 0.0 {
      randf(-5.0, 5.0) * (heli.shake_t * 4.0)
    } else {
      0.0
    }
    let shake_y = if heli.shake_t > 0.0 {
      randf(-4.0, 4.0) * (heli.shake_t * 4.0)
    } else {
      0.0
    }

    @raylib.begin_drawing()
    defer @raylib.end_drawing()

    @raylib.clear_background(@raylib.Color::new(10, 20, 34, 255))

    let grid_col = @raylib.Color::new(34, 56, 78, 70)
    let mut gx : Float = 0.0
    while gx <= world_w {
      let x = (gx - cam_x + shake_x).to_int()
      if x >= -4 && x <= sw + 4 {
        @raylib.draw_line(x, 0, x, sh, grid_col)
      }
      gx = gx + 140.0
    }
    let mut gy : Float = 0.0
    while gy <= world_h {
      let y = (gy - cam_y + shake_y).to_int()
      if y >= -4 && y <= sh + 4 {
        @raylib.draw_line(0, y, sw, y, grid_col)
      }
      gy = gy + 140.0
    }

    for i = 0; i < avalanches.length(); i = i + 1 {
      if not(avalanches[i].active) {
        continue
      }
      let sx = (avalanches[i].x - cam_x + shake_x).to_int()
      let sy = (avalanches[i].y - cam_y + shake_y).to_int()
      @raylib.draw_rectangle(
        sx,
        sy - 24,
        avalanches[i].w.to_int(),
        48,
        @raylib.Color::new(232, 244, 252, 88),
      )
      @raylib.draw_rectangle(
        sx,
        sy - 8,
        avalanches[i].w.to_int(),
        16,
        @raylib.Color::new(252, 252, 255, 142),
      )
    }

    for i = 0; i < hazards.length(); i = i + 1 {
      if not(hazards[i].active) {
        continue
      }
      let hx = hazards[i].x - cam_x + shake_x
      let hy = hazards[i].y - cam_y + shake_y
      if hx < -80.0 ||
        hy < -80.0 ||
        hx > Float::from_int(sw + 80) ||
        hy > Float::from_int(sh + 80) {
        continue
      }

      if hazards[i].kind == 0 {
        @raylib.draw_circle(
          hx.to_int(),
          hy.to_int(),
          hazards[i].r,
          @raylib.Color::new(122, 154, 178, 235),
        )
        @raylib.draw_circle(
          hx.to_int(),
          hy.to_int(),
          hazards[i].r * 0.58,
          @raylib.Color::new(178, 210, 232, 230),
        )
      } else {
        @raylib.draw_circle(
          hx.to_int(),
          hy.to_int(),
          hazards[i].r,
          @raylib.Color::new(112, 128, 150, 245),
        )
        @raylib.draw_line(
          (hx - hazards[i].r * 0.8).to_int(),
          hy.to_int(),
          (hx + hazards[i].r * 0.8).to_int(),
          hy.to_int(),
          @raylib.Color::new(236, 244, 252, 180),
        )
        @raylib.draw_line(
          hx.to_int(),
          (hy - hazards[i].r * 0.8).to_int(),
          hx.to_int(),
          (hy + hazards[i].r * 0.8).to_int(),
          @raylib.Color::new(236, 244, 252, 180),
        )
      }
    }

    for i = 0; i < flares.length(); i = i + 1 {
      if not(flares[i].active) {
        continue
      }
      let fx = flares[i].x - cam_x + shake_x
      let fy = flares[i].y - cam_y + shake_y
      if fx < -360.0 ||
        fy < -360.0 ||
        fx > Float::from_int(sw + 360) ||
        fy > Float::from_int(sh + 360) {
        continue
      }
      let flare_ratio : Float = 1.0 - flares[i].t / flares[i].life
      let alpha = (Float::from_int(120) * flare_ratio).to_int()
      let aa = if alpha < 0 { 0 } else { alpha }
      @raylib.draw_circle_lines(
        fx.to_int(),
        fy.to_int(),
        flares[i].r,
        @raylib.Color::new(252, 214, 120, aa),
      )
      @raylib.draw_circle_lines(
        fx.to_int(),
        fy.to_int(),
        flares[i].r * 0.6,
        @raylib.Color::new(252, 156, 102, aa + 20),
      )
    }

    @raylib.draw_circle(
      (base_x - cam_x + shake_x).to_int(),
      (base_y - cam_y + shake_y).to_int(),
      76.0,
      @raylib.Color::new(70, 96, 132, 255),
    )
    @raylib.draw_circle(
      (base_x - cam_x + shake_x).to_int(),
      (base_y - cam_y + shake_y).to_int(),
      52.0,
      @raylib.Color::new(112, 182, 236, 255),
    )
    @raylib.draw_text(
      "BASE",
      (base_x - cam_x - 28.0 + shake_x).to_int(),
      (base_y - cam_y - 8.0 + shake_y).to_int(),
      24,
      @raylib.Color::new(14, 28, 42, 250),
    )

    for i = 0; i < survivors.length(); i = i + 1 {
      if not(survivors[i].active) {
        continue
      }

      let sx = survivors[i].x - cam_x + shake_x
      let sy = survivors[i].y - cam_y + shake_y
      if sx < -40.0 ||
        sy < -40.0 ||
        sx > Float::from_int(sw + 40) ||
        sy > Float::from_int(sh + 40) {
        continue
      }

      let tone_f : Float = 220.0 - survivors[i].freeze * 1.4
      let tone = tone_f.to_int()
      let tr = clampf(Float::from_int(tone), 90.0, 235.0).to_int()
      let col = if survivors[i].carried {
        @raylib.Color::new(248, 214, 132, 255)
      } else {
        @raylib.Color::new(tr, tr, 252, 255)
      }

      @raylib.draw_circle(sx.to_int(), sy.to_int(), 10.0, col)
      @raylib.draw_rectangle(
        (sx - 8.0).to_int(),
        (sy + 8.0).to_int(),
        16,
        18,
        @raylib.Color::new(92, 136, 198, 255),
      )

      if survivors[i].beacon_t > 0.65 {
        survivors[i].beacon_t = survivors[i].beacon_t - 0.65
        burst_particles(particles, survivors[i].x, survivors[i].y, 4, 26.0, 1)
      }

      if not(survivors[i].carried) {
        @raylib.draw_circle_lines(
          sx.to_int(),
          sy.to_int(),
          18.0 + sinf(survivors[i].panic_t * 4.0).abs() * 6.0,
          @raylib.Color::new(152, 206, 252, 126),
        )
      }
    }

    let hx = heli.x - cam_x + shake_x
    let hy = heli.y - cam_y + shake_y

    let heli_col = if heli.flash_t > 0.0 {
      @raylib.Color::new(254, 242, 186, 255)
    } else {
      @raylib.Color::new(126, 218, 242, 255)
    }

    @raylib.draw_rectangle(
      (hx - 20.0).to_int(),
      (hy - 14.0).to_int(),
      40,
      28,
      heli_col,
    )
    @raylib.draw_circle(
      hx.to_int(),
      hy.to_int(),
      12.0,
      @raylib.Color::new(42, 68, 92, 255),
    )
    @raylib.draw_rectangle(
      (hx - 30.0).to_int(),
      (hy + 12.0).to_int(),
      60,
      5,
      @raylib.Color::new(60, 88, 122, 255),
    )
    @raylib.draw_line(
      (hx - 46.0).to_int(),
      (hy - 24.0).to_int(),
      (hx + 46.0).to_int(),
      (hy - 24.0).to_int(),
      @raylib.Color::new(236, 240, 246, 240),
    )

    let blade : Float = sinf(heli.rotor * 0.03) * 52.0
    @raylib.draw_line(
      (hx - blade).to_int(),
      (hy - 24.0).to_int(),
      (hx + blade).to_int(),
      (hy - 24.0).to_int(),
      @raylib.Color::new(210, 226, 236, 200),
    )

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }
      let px = particles[i].x - cam_x + shake_x
      let py = particles[i].y - cam_y + shake_y
      if px < -20.0 ||
        py < -20.0 ||
        px > Float::from_int(sw + 20) ||
        py > Float::from_int(sh + 20) {
        continue
      }

      let life_r : Float = 1.0 - particles[i].t / particles[i].life
      let a = clampf(life_r * 210.0, 0.0, 210.0).to_int()
      let col = if particles[i].kind == 0 {
        @raylib.Color::new(238, 246, 255, a)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 198, 126, a)
      } else {
        @raylib.Color::new(164, 220, 252, a)
      }
      @raylib.draw_circle(
        px.to_int(),
        py.to_int(),
        particles[i].size * life_r,
        col,
      )
    }

    if storm.whiteout_t > 0.0 {
      let alpha = clampf(96.0 + storm.whiteout_t * 52.0, 0.0, 160.0).to_int()
      @raylib.draw_rectangle(
        0,
        0,
        sw,
        sh,
        @raylib.Color::new(228, 236, 248, alpha),
      )
    }

    @raylib.draw_rectangle(
      18,
      16,
      502,
      184,
      @raylib.Color::new(14, 24, 38, 196),
    )
    @raylib.draw_rectangle_lines(
      18,
      16,
      502,
      184,
      @raylib.Color::new(222, 232, 246, 136),
    )

    @raylib.draw_text(
      "GLACIER RESCUE 2026",
      32,
      28,
      34,
      @raylib.Color::new(228, 238, 252, 245),
    )
    @raylib.draw_text(
      "Move: WASD/Arrows  Boost: Shift/Space  Flare: E",
      34,
      66,
      22,
      @raylib.Color::new(188, 206, 232, 240),
    )

    draw_bar(
      34,
      98,
      220,
      20,
      heli.fuel / 100.0,
      @raylib.Color::new(108, 222, 160, 255),
      @raylib.Color::new(54, 78, 72, 230),
    )
    @raylib.draw_text(
      "Fuel",
      260,
      96,
      22,
      @raylib.Color::new(214, 230, 246, 240),
    )

    draw_bar(
      34,
      126,
      220,
      20,
      heli.hull / 100.0,
      @raylib.Color::new(232, 144, 118, 255),
      @raylib.Color::new(78, 52, 52, 230),
    )
    @raylib.draw_text(
      "Hull",
      260,
      124,
      22,
      @raylib.Color::new(214, 230, 246, 240),
    )

    draw_bar(
      34,
      154,
      220,
      20,
      1.0 - heli.cold / 100.0,
      @raylib.Color::new(120, 182, 246, 255),
      @raylib.Color::new(56, 70, 92, 230),
    )
    @raylib.draw_text(
      "Core Temp",
      260,
      152,
      22,
      @raylib.Color::new(214, 230, 246, 240),
    )

    @raylib.draw_text(
      "Rescued \{heli.rescued}/\{mission_target}   Onboard \{heli.onboard}   Lost \{heli.lost}",
      34,
      180,
      24,
      @raylib.Color::new(242, 244, 250, 246),
    )

    @raylib.draw_text(
      "Time \{mission_time.to_int()}s   Level \{level}   Score \{heli.score}",
      sw - 430,
      24,
      28,
      @raylib.Color::new(246, 236, 210, 246),
    )

    let boost_txt = if heli.boost_cd <= 0.0 {
      "Boost READY"
    } else {
      "Boost CD \{heli.boost_cd.to_int()}"
    }
    let flare_txt = if heli.flare_cd <= 0.0 {
      "Flare READY"
    } else {
      "Flare CD \{heli.flare_cd.to_int()}"
    }
    @raylib.draw_text(
      boost_txt,
      sw - 430,
      62,
      24,
      @raylib.Color::new(242, 208, 164, 236),
    )
    @raylib.draw_text(
      flare_txt,
      sw - 430,
      88,
      24,
      @raylib.Color::new(178, 210, 246, 236),
    )

    if announce_t > 0.0 {
      let a = clampf(announce_t * 90.0, 0.0, 220.0).to_int()
      @raylib.draw_text(
        "Rescue mission live. Extract survivors to BASE.",
        sw / 2 - 300,
        216,
        34,
        @raylib.Color::new(246, 248, 252, a),
      )
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 220))
      @raylib.draw_text(
        "GLACIER RESCUE",
        sw / 2 - 260,
        sh / 2 - 112,
        76,
        @raylib.Color::new(236, 246, 252, 255),
      )
      @raylib.draw_text(
        "Pilot through storm fronts, pick up survivors, and return to BASE.",
        sw / 2 - 412,
        sh / 2 - 20,
        32,
        @raylib.Color::new(186, 214, 238, 245),
      )
      @raylib.draw_text(
        "BOOST burns fuel fast. FLARE reveals and warms survivors.",
        sw / 2 - 362,
        sh / 2 + 22,
        32,
        @raylib.Color::new(220, 228, 240, 238),
      )
      @raylib.draw_text(
        "Press ENTER to start",
        sw / 2 - 182,
        sh / 2 + 86,
        44,
        @raylib.Color::new(252, 236, 176, 255),
      )
    }

    if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(10, 24, 20, 188))
      @raylib.draw_text(
        "MISSION COMPLETE",
        sw / 2 - 280,
        sh / 2 - 82,
        72,
        @raylib.Color::new(214, 252, 210, 255),
      )
      @raylib.draw_text(
        "Score \{heli.score}  |  Saved \{heli.rescued}  |  Lost \{heli.lost}",
        sw / 2 - 250,
        sh / 2 + 6,
        36,
        @raylib.Color::new(236, 246, 238, 248),
      )
      @raylib.draw_text(
        "Press ENTER for next mission",
        sw / 2 - 250,
        sh / 2 + 64,
        38,
        @raylib.Color::new(252, 238, 176, 255),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(22, 8, 8, 198))
      @raylib.draw_text(
        "MISSION FAILED",
        sw / 2 - 230,
        sh / 2 - 82,
        72,
        @raylib.Color::new(254, 194, 186, 255),
      )
      @raylib.draw_text(
        "Rescued \{heli.rescued}/\{mission_target}  Lost \{heli.lost}",
        sw / 2 - 240,
        sh / 2 + 6,
        38,
        @raylib.Color::new(246, 226, 218, 248),
      )
      @raylib.draw_text(
        "Press ENTER to retry",
        sw / 2 - 184,
        sh / 2 + 64,
        40,
        @raylib.Color::new(252, 230, 174, 255),
      )
    }

    draw_touch_controls(true)
  }
}
