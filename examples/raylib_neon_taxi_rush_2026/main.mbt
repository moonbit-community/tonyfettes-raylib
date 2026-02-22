///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let world_w : Float = 1280.0

///|
let world_h : Float = 760.0

///|
let max_traffic : Int = 120

///|
let max_passengers : Int = 36

///|
let max_fuels : Int = 24

///|
let max_particles : Int = 760

///|
let max_markers : Int = 32

///|
struct Taxi {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Float
  mut fuel : Float
  mut cash : Int
  mut combo : Int
  mut rating : Float
  mut flash_t : Float
  mut boost_t : Float
  mut boost_cd : Float
  mut horn_cd : Float
  mut carry_idx : Int
  mut drop_x : Float
  mut drop_y : Float
  mut meter : Float
}

///|
struct Traffic {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut speed : Float
  mut lane : Int
  mut size : Float
  mut hp : Float
  mut horn_t : Float
}

///|
struct Passenger {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut dx : Float
  mut dy : Float
  mut fare : Int
  mut wait_t : Float
  mut state : Int
  mut pulse_t : Float
}

///|
struct FuelPickup {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut amount : Float
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
  mut size : Float
  mut t : Float
  mut life : Float
  mut kind : Int
}

///|
struct Marker {
  mut x : Float
  mut y : Float
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
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
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
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)
  px >= x0 && px <= x1 && py >= y0 && py <= y1
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn rating_str(r : Float) -> String {
  let v : Int = (r * 10.0).to_int()
  "\{v / 10}.\{v % 10}"
}

///|
fn road_hit(x : Float, y : Float) -> Bool {
  let mut on_h : Bool = false
  let mut on_v : Bool = false

  if absf(y - 140.0) <= 40.0 ||
    absf(y - 300.0) <= 40.0 ||
    absf(y - 460.0) <= 40.0 ||
    absf(y - 620.0) <= 40.0 {
    on_h = true
  }

  if absf(x - 180.0) <= 40.0 ||
    absf(x - 380.0) <= 40.0 ||
    absf(x - 640.0) <= 40.0 ||
    absf(x - 900.0) <= 40.0 ||
    absf(x - 1100.0) <= 40.0 {
    on_v = true
  }

  on_h || on_v
}

///|
fn clear_traffic(ts : Array[Traffic]) -> Unit {
  for i = 0; i < ts.length(); i = i + 1 {
    ts[i].active = false
    ts[i].x = 0.0
    ts[i].y = 0.0
    ts[i].vx = 0.0
    ts[i].vy = 0.0
    ts[i].speed = 0.0
    ts[i].lane = 0
    ts[i].size = 0.0
    ts[i].hp = 0.0
    ts[i].horn_t = 0.0
  }
}

///|
fn clear_passengers(ps : Array[Passenger]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    ps[i].active = false
    ps[i].x = 0.0
    ps[i].y = 0.0
    ps[i].dx = 0.0
    ps[i].dy = 0.0
    ps[i].fare = 0
    ps[i].wait_t = 0.0
    ps[i].state = 0
    ps[i].pulse_t = 0.0
  }
}

///|
fn clear_fuels(fs : Array[FuelPickup]) -> Unit {
  for i = 0; i < fs.length(); i = i + 1 {
    fs[i].active = false
    fs[i].x = 0.0
    fs[i].y = 0.0
    fs[i].amount = 0.0
    fs[i].t = 0.0
    fs[i].life = 0.0
  }
}

///|
fn clear_particles(ps : Array[Particle]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    ps[i].active = false
    ps[i].x = 0.0
    ps[i].y = 0.0
    ps[i].vx = 0.0
    ps[i].vy = 0.0
    ps[i].size = 0.0
    ps[i].t = 0.0
    ps[i].life = 0.0
    ps[i].kind = 0
  }
}

///|
fn clear_markers(ms : Array[Marker]) -> Unit {
  for i = 0; i < ms.length(); i = i + 1 {
    ms[i].x = 0.0
    ms[i].y = 0.0
  }
}

///|
fn spawn_particle(
  ps : Array[Particle],
  x : Float,
  y : Float,
  speed : Float,
  kind : Int,
) -> Unit {
  let mut done = false
  for i = 0; i < ps.length(); i = i + 1 {
    if done {
      continue
    }

    if not(ps[i].active) {
      ps[i].active = true
      ps[i].x = x
      ps[i].y = y
      ps[i].vx = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      ps[i].vy = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      ps[i].size = Float::from_int(@raylib.get_random_value(2, 6))
      ps[i].t = 0.0
      ps[i].life = Float::from_int(@raylib.get_random_value(16, 72)) / 100.0
      ps[i].kind = kind
      done = true
    }
  }
}

///|
fn burst(
  ps : Array[Particle],
  x : Float,
  y : Float,
  count : Int,
  speed : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < count; i = i + 1 {
    ignore(i)
    spawn_particle(ps, x, y, speed, kind)
  }
}

///|
fn setup_markers(ms : Array[Marker]) -> Int {
  clear_markers(ms)
  let mut n = 0

  for yi = 0; yi < 4; yi = yi + 1 {
    let y : Float = if yi == 0 {
      Float::from_int(140)
    } else if yi == 1 {
      Float::from_int(300)
    } else if yi == 2 {
      Float::from_int(460)
    } else {
      Float::from_int(620)
    }

    for xi = 0; xi < 5; xi = xi + 1 {
      let x : Float = if xi == 0 {
        Float::from_int(180)
      } else if xi == 1 {
        Float::from_int(380)
      } else if xi == 2 {
        Float::from_int(640)
      } else if xi == 3 {
        Float::from_int(900)
      } else {
        Float::from_int(1100)
      }

      if n < ms.length() {
        ms[n].x = x
        ms[n].y = y
        n = n + 1
      }
    }
  }

  n
}

///|
fn spawn_traffic(ts : Array[Traffic], wave : Int) -> Bool {
  let mut slot = -1
  for i = 0; i < ts.length(); i = i + 1 {
    if slot < 0 && not(ts[i].active) {
      slot = i
    }
  }

  if slot < 0 {
    false
  } else {
    let lane = @raylib.get_random_value(0, 8)
    let mut x : Float = 0.0
    let mut y : Float = 0.0
    let mut vx : Float = 0.0
    let mut vy : Float = 0.0

    if lane == 0 {
      x = -50.0
      y = 140.0 + Float::from_int(@raylib.get_random_value(-18, 18))
      vx = 1.0
      vy = 0.0
    } else if lane == 1 {
      x = world_w + 50.0
      y = 300.0 + Float::from_int(@raylib.get_random_value(-18, 18))
      vx = -1.0
      vy = 0.0
    } else if lane == 2 {
      x = -50.0
      y = 460.0 + Float::from_int(@raylib.get_random_value(-18, 18))
      vx = 1.0
      vy = 0.0
    } else if lane == 3 {
      x = world_w + 50.0
      y = 620.0 + Float::from_int(@raylib.get_random_value(-18, 18))
      vx = -1.0
      vy = 0.0
    } else if lane == 4 {
      x = 180.0 + Float::from_int(@raylib.get_random_value(-18, 18))
      y = -50.0
      vx = 0.0
      vy = 1.0
    } else if lane == 5 {
      x = 380.0 + Float::from_int(@raylib.get_random_value(-18, 18))
      y = world_h + 50.0
      vx = 0.0
      vy = -1.0
    } else if lane == 6 {
      x = 640.0 + Float::from_int(@raylib.get_random_value(-18, 18))
      y = -50.0
      vx = 0.0
      vy = 1.0
    } else if lane == 7 {
      x = 900.0 + Float::from_int(@raylib.get_random_value(-18, 18))
      y = world_h + 50.0
      vx = 0.0
      vy = -1.0
    } else {
      x = 1100.0 + Float::from_int(@raylib.get_random_value(-18, 18))
      y = -50.0
      vx = 0.0
      vy = 1.0
    }

    let base_speed : Float = 94.0 + Float::from_int(wave - 1) * 5.0

    ts[slot].active = true
    ts[slot].x = x
    ts[slot].y = y
    ts[slot].vx = vx
    ts[slot].vy = vy
    ts[slot].speed = base_speed +
      Float::from_int(@raylib.get_random_value(-18, 22))
    ts[slot].lane = lane
    ts[slot].size = Float::from_int(@raylib.get_random_value(16, 24))
    ts[slot].hp = 60.0
    ts[slot].horn_t = 0.0
    true
  }
}

///|
fn spawn_passenger(
  ps : Array[Passenger],
  markers : Array[Marker],
  marker_count : Int,
  wave : Int,
) -> Bool {
  let mut slot = -1
  for i = 0; i < ps.length(); i = i + 1 {
    if slot < 0 && not(ps[i].active) {
      slot = i
    }
  }

  if slot < 0 {
    false
  } else {
    let start = @raylib.get_random_value(0, marker_count - 1)
    let mut dest = @raylib.get_random_value(0, marker_count - 1)
    if dest == start {
      dest = (dest + 1) % marker_count
    }

    let sx = markers[start].x
    let sy = markers[start].y
    let dx = markers[dest].x
    let dy = markers[dest].y

    let fare_base = 28 + wave * 3
    let far_bonus = if dist2(sx, sy, dx, dy) > 380.0 * 380.0 { 22 } else { 8 }

    ps[slot].active = true
    ps[slot].x = sx
    ps[slot].y = sy
    ps[slot].dx = dx
    ps[slot].dy = dy
    ps[slot].fare = fare_base + far_bonus
    ps[slot].wait_t = 46.0
    ps[slot].state = 0
    ps[slot].pulse_t = randf(0.0, 1.0)
    true
  }
}

///|
fn spawn_fuel(
  fs : Array[FuelPickup],
  markers : Array[Marker],
  marker_count : Int,
) -> Bool {
  let mut slot = -1
  for i = 0; i < fs.length(); i = i + 1 {
    if slot < 0 && not(fs[i].active) {
      slot = i
    }
  }

  if slot < 0 {
    false
  } else {
    let idx = @raylib.get_random_value(0, marker_count - 1)
    fs[slot].active = true
    fs[slot].x = markers[idx].x + randf(-14.0, 14.0)
    fs[slot].y = markers[idx].y + randf(-14.0, 14.0)
    fs[slot].amount = randf(18.0, 34.0)
    fs[slot].t = 0.0
    fs[slot].life = 36.0
    true
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Neon Taxi Rush 2026")
  @raylib.set_target_fps(60)

  let traffic : Array[Traffic] = Array::makei(max_traffic, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      speed: 0.0,
      lane: 0,
      size: 0.0,
      hp: 0.0,
      horn_t: 0.0,
    }
  })

  let passengers : Array[Passenger] = Array::makei(max_passengers, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      dx: 0.0,
      dy: 0.0,
      fare: 0,
      wait_t: 0.0,
      state: 0,
      pulse_t: 0.0,
    }
  })

  let fuels : Array[FuelPickup] = Array::makei(max_fuels, fn(_i) {
    { active: false, x: 0.0, y: 0.0, amount: 0.0, t: 0.0, life: 0.0 }
  })

  let particles : Array[Particle] = Array::makei(max_particles, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      size: 0.0,
      t: 0.0,
      life: 0.0,
      kind: 0,
    }
  })

  let markers : Array[Marker] = Array::makei(max_markers, fn(_i) {
    { x: 0.0, y: 0.0 }
  })

  let marker_count = setup_markers(markers)

  let taxi : Taxi = {
    x: 640.0,
    y: 380.0,
    vx: 0.0,
    vy: 0.0,
    hp: 220.0,
    fuel: 100.0,
    cash: 0,
    combo: 0,
    rating: 4.2,
    flash_t: 0.0,
    boost_t: 0.0,
    boost_cd: 0.0,
    horn_cd: 0.0,
    carry_idx: -1,
    drop_x: 0.0,
    drop_y: 0.0,
    meter: 0.0,
  }

  let mut state : Int = 0
  let mut wave : Int = 1
  let mut timer : Float = 210.0
  let mut target_cash : Int = 1600
  let mut msg : String = "Pick up passengers and beat city traffic"
  let mut msg_t : Float = 3.0

  let mut traffic_cd : Float = 0.18
  let mut passenger_cd : Float = 1.4
  let mut fuel_cd : Float = 5.2

  let mut served : Int = 0
  let mut misses : Int = 0

  let reset_game = fn() {
    taxi.x = 640.0
    taxi.y = 380.0
    taxi.vx = 0.0
    taxi.vy = 0.0
    taxi.hp = 220.0
    taxi.fuel = 100.0
    taxi.cash = 0
    taxi.combo = 0
    taxi.rating = 4.2
    taxi.flash_t = 0.0
    taxi.boost_t = 0.0
    taxi.boost_cd = 0.0
    taxi.horn_cd = 0.0
    taxi.carry_idx = -1
    taxi.drop_x = 0.0
    taxi.drop_y = 0.0
    taxi.meter = 0.0

    wave = 1
    timer = 210.0
    target_cash = 1600

    msg = "Shift started"
    msg_t = 2.4

    traffic_cd = 0.18
    passenger_cd = 1.4
    fuel_cd = 5.2

    served = 0
    misses = 0

    clear_traffic(traffic)
    clear_passengers(passengers)
    clear_fuels(fuels)
    clear_particles(particles)

    for i = 0; i < 8; i = i + 1 {
      ignore(i)
      ignore(spawn_passenger(passengers, markers, marker_count, wave))
    }

    for i = 0; i < 4; i = i + 1 {
      ignore(i)
      ignore(spawn_fuel(fuels, markers, marker_count))
    }
  }

  reset_game()

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    let mouse = @raylib.get_mouse_position()
    let touching : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    let pressed : Bool = @raylib.is_mouse_button_pressed(
      @raylib.MouseButtonLeft,
    )

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    if taxi.flash_t > 0.0 {
      taxi.flash_t = taxi.flash_t - dt
      if taxi.flash_t < 0.0 {
        taxi.flash_t = 0.0
      }
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_game()
      }
    } else if state == 1 {
      timer = timer - dt

      taxi.boost_t = taxi.boost_t - dt
      if taxi.boost_t < 0.0 {
        taxi.boost_t = 0.0
      }
      taxi.boost_cd = taxi.boost_cd - dt
      if taxi.boost_cd < 0.0 {
        taxi.boost_cd = 0.0
      }
      taxi.horn_cd = taxi.horn_cd - dt
      if taxi.horn_cd < 0.0 {
        taxi.horn_cd = 0.0
      }

      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)

      let mut boost_press : Bool = @raylib.is_key_pressed(@raylib.KeyJ) ||
        @raylib.is_key_pressed(@raylib.KeySpace)
      let mut horn_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
      let mut pick_press : Bool = @raylib.is_key_pressed(@raylib.KeyL) ||
        @raylib.is_key_pressed(@raylib.KeyEnter)

      let pad_x : Int = 22
      let pad_y : Int = sh - 194
      let btx : Int = sw - 240
      let bty : Int = sh - 222

      if touching {
        if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y, 72, 56) {
          move_u = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y + 112, 72, 56) {
          move_d = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 56, 72, 56) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 160, pad_y + 56, 72, 56) {
          move_r = true
        }
      }

      if pressed {
        if inside_rect(mouse.x, mouse.y, btx, bty, 102, 80) {
          boost_press = true
        }
        if inside_rect(mouse.x, mouse.y, btx + 112, bty, 102, 80) {
          horn_press = true
        }
        if inside_rect(mouse.x, mouse.y, btx + 56, bty + 92, 144, 104) {
          pick_press = true
        }
      }

      let mut ax : Float = 0.0
      let mut ay : Float = 0.0
      if move_l {
        ax = ax - 580.0
      }
      if move_r {
        ax = ax + 580.0
      }
      if move_u {
        ay = ay - 580.0
      }
      if move_d {
        ay = ay + 580.0
      }

      if taxi.boost_t > 0.0 {
        ax = ax * 1.65
        ay = ay * 1.65
      }

      taxi.vx = taxi.vx + ax * dt
      taxi.vy = taxi.vy + ay * dt

      let mut drag : Float = 2.7
      if not(road_hit(taxi.x, taxi.y)) {
        drag = 4.3
      }
      taxi.vx = taxi.vx * (Float::from_int(1) - dt * drag)
      taxi.vy = taxi.vy * (Float::from_int(1) - dt * drag)

      let max_speed : Float = if taxi.boost_t > 0.0 { 470.0 } else { 305.0 }
      taxi.vx = clampf(taxi.vx, -max_speed, max_speed)
      taxi.vy = clampf(taxi.vy, -max_speed, max_speed)

      taxi.x = taxi.x + taxi.vx * dt
      taxi.y = taxi.y + taxi.vy * dt
      taxi.x = clampf(taxi.x, 24.0, 1256.0)
      taxi.y = clampf(taxi.y, 84.0, 736.0)

      let speed_mag = (taxi.vx * taxi.vx + taxi.vy * taxi.vy).sqrt()
      taxi.fuel = taxi.fuel - dt * (1.6 + speed_mag / 180.0)
      if taxi.boost_t > 0.0 {
        taxi.fuel = taxi.fuel - dt * 12.0
      }
      if taxi.fuel < 0.0 {
        taxi.fuel = 0.0
      }

      if boost_press && taxi.boost_cd <= 0.0 && taxi.fuel >= 12.0 {
        taxi.boost_t = 0.36
        taxi.boost_cd = 1.2
        taxi.fuel = taxi.fuel - 12.0
        burst(particles, taxi.x, taxi.y, 18, 0.30, 0)
      }

      if horn_press && taxi.horn_cd <= 0.0 {
        taxi.horn_cd = 2.1
        msg = "HONK"
        msg_t = 0.5
        burst(particles, taxi.x, taxi.y, 16, 0.26, 2)

        for i = 0; i < traffic.length(); i = i + 1 {
          if not(traffic[i].active) {
            continue
          }

          let d2 = dist2(taxi.x, taxi.y, traffic[i].x, traffic[i].y)
          if d2 <= 110.0 * 110.0 {
            let dx = traffic[i].x - taxi.x
            let dy = traffic[i].y - taxi.y
            let n2 = dx * dx + dy * dy
            let n = if n2 < Float::from_int(1) {
              Float::from_int(1)
            } else {
              n2.sqrt()
            }
            traffic[i].vx = traffic[i].vx + dx / n * 200.0
            traffic[i].vy = traffic[i].vy + dy / n * 200.0
            traffic[i].horn_t = 0.9
          }
        }
      }

      traffic_cd = traffic_cd - dt
      if traffic_cd <= 0.0 {
        ignore(spawn_traffic(traffic, wave))
        let jitter = Float::from_int(@raylib.get_random_value(70, 136)) / 100.0
        traffic_cd = (0.26 - Float::from_int(wave - 1) * 0.014) * jitter
        if traffic_cd < 0.08 {
          traffic_cd = 0.08
        }
      }

      passenger_cd = passenger_cd - dt
      if passenger_cd <= 0.0 {
        ignore(spawn_passenger(passengers, markers, marker_count, wave))
        passenger_cd = randf(1.4, 2.8)
      }

      fuel_cd = fuel_cd - dt
      if fuel_cd <= 0.0 {
        ignore(spawn_fuel(fuels, markers, marker_count))
        fuel_cd = randf(6.4, 10.0)
      }

      for i = 0; i < traffic.length(); i = i + 1 {
        if not(traffic[i].active) {
          continue
        }

        traffic[i].x = traffic[i].x + traffic[i].vx * traffic[i].speed * dt
        traffic[i].y = traffic[i].y + traffic[i].vy * traffic[i].speed * dt

        if traffic[i].horn_t > 0.0 {
          traffic[i].horn_t = traffic[i].horn_t - dt
          if traffic[i].horn_t < 0.0 {
            traffic[i].horn_t = 0.0
          }
        }

        if traffic[i].x < -70.0 ||
          traffic[i].x > world_w + 70.0 ||
          traffic[i].y < -70.0 ||
          traffic[i].y > world_h + 70.0 {
          traffic[i].active = false
          continue
        }

        if dist2(taxi.x, taxi.y, traffic[i].x, traffic[i].y) <=
          (traffic[i].size + 20.0) * (traffic[i].size + 20.0) {
          let dx = taxi.x - traffic[i].x
          let dy = taxi.y - traffic[i].y
          let n2 = dx * dx + dy * dy
          let n = if n2 < Float::from_int(1) {
            Float::from_int(1)
          } else {
            n2.sqrt()
          }

          taxi.vx = taxi.vx + dx / n * 180.0
          taxi.vy = taxi.vy + dy / n * 180.0
          traffic[i].vx = traffic[i].vx - dx / n * 0.65
          traffic[i].vy = traffic[i].vy - dy / n * 0.65

          taxi.hp = taxi.hp - 17.0
          taxi.flash_t = 0.18
          taxi.combo = 0
          msg = "Crash!"
          msg_t = 0.6
          burst(particles, taxi.x, taxi.y, 14, 0.24, 3)
        }
      }

      for i = 0; i < passengers.length(); i = i + 1 {
        if not(passengers[i].active) {
          continue
        }

        passengers[i].pulse_t = passengers[i].pulse_t + dt

        if passengers[i].state == 0 {
          passengers[i].wait_t = passengers[i].wait_t - dt
          if passengers[i].wait_t <= 0.0 {
            passengers[i].active = false
            misses = misses + 1
            taxi.combo = 0
            taxi.rating = taxi.rating - 0.05
            if taxi.rating < 1.0 {
              taxi.rating = 1.0
            }
            continue
          }

          if pick_press &&
            taxi.carry_idx < 0 &&
            dist2(taxi.x, taxi.y, passengers[i].x, passengers[i].y) <=
            28.0 * 28.0 {
            taxi.carry_idx = i
            taxi.drop_x = passengers[i].dx
            taxi.drop_y = passengers[i].dy
            taxi.meter = 0.0
            passengers[i].state = 1
            msg = "Passenger aboard"
            msg_t = 0.8
            burst(particles, passengers[i].x, passengers[i].y, 10, 0.20, 1)
          }
        } else if taxi.carry_idx == i {
          passengers[i].x = taxi.x
          passengers[i].y = taxi.y
          taxi.meter = taxi.meter + dt

          if dist2(taxi.x, taxi.y, taxi.drop_x, taxi.drop_y) <= 34.0 * 34.0 &&
            pick_press {
            let ride_bonus = (taxi.meter * 4.0).to_int()
            let combo_bonus = taxi.combo * 9
            let payout = passengers[i].fare + ride_bonus + combo_bonus
            taxi.cash = taxi.cash + payout
            taxi.combo = taxi.combo + 1
            taxi.rating = taxi.rating + 0.08
            if taxi.rating > 5.0 {
              taxi.rating = 5.0
            }

            served = served + 1
            msg = "+\{payout} drop-off"
            msg_t = 1.1
            burst(particles, taxi.drop_x, taxi.drop_y, 20, 0.26, 1)

            passengers[i].active = false
            taxi.carry_idx = -1

            if taxi.combo % 3 == 0 {
              wave = wave + 1
              target_cash = target_cash + 280
              msg = "Rush hour \{wave}!"
              msg_t = 1.1
            }
          }
        }
      }

      for i = 0; i < fuels.length(); i = i + 1 {
        if not(fuels[i].active) {
          continue
        }

        fuels[i].t = fuels[i].t + dt
        fuels[i].life = fuels[i].life - dt
        if fuels[i].life <= 0.0 {
          fuels[i].active = false
          continue
        }

        if dist2(taxi.x, taxi.y, fuels[i].x, fuels[i].y) <= 26.0 * 26.0 {
          taxi.fuel = taxi.fuel + fuels[i].amount
          if taxi.fuel > 100.0 {
            taxi.fuel = 100.0
          }
          fuels[i].active = false
          msg = "Refuel +\{fuels[i].amount.to_int()}"
          msg_t = 0.8
          burst(particles, taxi.x, taxi.y, 10, 0.22, 0)
        }
      }

      for i = 0; i < particles.length(); i = i + 1 {
        if not(particles[i].active) {
          continue
        }

        particles[i].t = particles[i].t + dt
        if particles[i].t >= particles[i].life {
          particles[i].active = false
        } else {
          particles[i].x = particles[i].x + particles[i].vx * dt
          particles[i].y = particles[i].y + particles[i].vy * dt
          particles[i].vx = particles[i].vx * (Float::from_int(1) - dt * 1.8)
          particles[i].vy = particles[i].vy + 200.0 * dt
        }
      }

      if taxi.fuel <= 0.0 {
        taxi.hp = taxi.hp - dt * 16.0
      }

      if taxi.cash >= target_cash {
        state = 2
      }

      if timer <= 0.0 || taxi.hp <= 0.0 {
        state = 3
      }
    } else {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 0
      }
      if @raylib.is_key_pressed(@raylib.KeyR) {
        state = 1
        reset_game()
      }
    }

    @raylib.begin_drawing()

    let mut bg = @raylib.Color::new(10, 12, 22, 255)
    if state == 2 {
      bg = @raylib.Color::new(14, 22, 26, 255)
    } else if state == 3 {
      bg = @raylib.Color::new(24, 10, 16, 255)
    }
    @raylib.clear_background(bg)

    @raylib.draw_rectangle(0, 0, sw, 74, @raylib.Color::new(8, 10, 16, 228))

    let road_col = @raylib.Color::new(44, 48, 64, 255)
    let lane_col = @raylib.Color::new(116, 124, 152, 180)

    for i = 0; i < 4; i = i + 1 {
      let y = if i == 0 {
        140
      } else if i == 1 {
        300
      } else if i == 2 {
        460
      } else {
        620
      }
      @raylib.draw_rectangle(0, y - 40, sw, 80, road_col)
      for dash = 0; dash < 22; dash = dash + 1 {
        @raylib.draw_rectangle(
          dash * 64 + (@raylib.get_time() * 120.0).to_int() % 64,
          y - 2,
          34,
          4,
          lane_col,
        )
      }
    }

    for i = 0; i < 5; i = i + 1 {
      let x = if i == 0 {
        180
      } else if i == 1 {
        380
      } else if i == 2 {
        640
      } else if i == 3 {
        900
      } else {
        1100
      }
      @raylib.draw_rectangle(x - 40, 74, 80, sh - 74, road_col)
      for dash = 0; dash < 14; dash = dash + 1 {
        @raylib.draw_rectangle(
          x - 2,
          dash * 64 + 90 + (@raylib.get_time() * 90.0).to_int() % 64,
          4,
          34,
          lane_col,
        )
      }
    }

    for i = 0; i < fuels.length(); i = i + 1 {
      if not(fuels[i].active) {
        continue
      }
      let blink = if (fuels[i].t * 6.0).to_int() % 2 == 0 { 255 } else { 180 }
      @raylib.draw_circle(
        fuels[i].x.to_int(),
        fuels[i].y.to_int(),
        10.0,
        @raylib.Color::new(88, 222, 162, blink),
      )
      @raylib.draw_rectangle(
        (fuels[i].x - 4.0).to_int(),
        (fuels[i].y - 6.0).to_int(),
        8,
        12,
        @raylib.Color::new(12, 40, 30, 240),
      )
    }

    for i = 0; i < passengers.length(); i = i + 1 {
      if not(passengers[i].active) {
        continue
      }

      if passengers[i].state == 0 {
        let pulse : Float = if (passengers[i].pulse_t * 5.0).to_int() % 2 == 0 {
          6.0
        } else {
          3.0
        }
        @raylib.draw_circle(
          passengers[i].x.to_int(),
          passengers[i].y.to_int(),
          10.0,
          @raylib.Color::new(248, 210, 116, 255),
        )
        @raylib.draw_circle_lines(
          passengers[i].x.to_int(),
          passengers[i].y.to_int(),
          16.0 + pulse,
          @raylib.Color::new(250, 236, 182, 190),
        )
      }
    }

    if taxi.carry_idx >= 0 {
      @raylib.draw_circle(
        taxi.drop_x.to_int(),
        taxi.drop_y.to_int(),
        16.0,
        @raylib.Color::new(96, 204, 246, 255),
      )
      @raylib.draw_circle_lines(
        taxi.drop_x.to_int(),
        taxi.drop_y.to_int(),
        24.0,
        @raylib.Color::new(162, 228, 255, 220),
      )
    }

    for i = 0; i < traffic.length(); i = i + 1 {
      if not(traffic[i].active) {
        continue
      }

      let mut c = @raylib.Color::new(164, 128, 234, 255)
      if traffic[i].lane % 3 == 0 {
        c = @raylib.Color::new(246, 128, 142, 255)
      } else if traffic[i].lane % 3 == 1 {
        c = @raylib.Color::new(114, 206, 248, 255)
      }
      if traffic[i].horn_t > 0.0 {
        c = @raylib.Color::new(255, 240, 190, 255)
      }

      @raylib.draw_rectangle(
        (traffic[i].x - traffic[i].size).to_int(),
        (traffic[i].y - traffic[i].size * 0.62).to_int(),
        (traffic[i].size * 2.0).to_int(),
        (traffic[i].size * 1.24).to_int(),
        c,
      )
      @raylib.draw_rectangle(
        (traffic[i].x - traffic[i].size * 0.5).to_int(),
        (traffic[i].y - traffic[i].size * 0.42).to_int(),
        traffic[i].size.to_int(),
        (traffic[i].size * 0.84).to_int(),
        @raylib.Color::new(22, 24, 40, 220),
      )
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let k = particles[i].t / particles[i].life
      let a : Int = ((Float::from_int(1) - k) * 220.0).to_int()
      let mut c = @raylib.Color::new(120, 230, 252, a)
      if particles[i].kind == 1 {
        c = @raylib.Color::new(136, 248, 176, a)
      } else if particles[i].kind == 2 {
        c = @raylib.Color::new(248, 180, 96, a)
      } else if particles[i].kind == 3 {
        c = @raylib.Color::new(236, 88, 108, a)
      }
      @raylib.draw_circle(
        particles[i].x.to_int(),
        particles[i].y.to_int(),
        particles[i].size,
        c,
      )
    }

    let mut taxi_col = @raylib.Color::new(248, 210, 88, 255)
    if taxi.flash_t > 0.0 {
      taxi_col = @raylib.Color::new(255, 242, 228, 255)
    }

    @raylib.draw_rectangle(
      (taxi.x - 20.0).to_int(),
      (taxi.y - 12.0).to_int(),
      40,
      24,
      taxi_col,
    )
    @raylib.draw_rectangle(
      (taxi.x - 8.0).to_int(),
      (taxi.y - 10.0).to_int(),
      16,
      20,
      @raylib.Color::new(28, 34, 52, 255),
    )

    if taxi.boost_t > 0.0 {
      @raylib.draw_rectangle(
        (taxi.x - 26.0).to_int(),
        (taxi.y - 4.0).to_int(),
        6,
        8,
        @raylib.Color::new(112, 216, 250, 255),
      )
      @raylib.draw_rectangle(
        (taxi.x + 20.0).to_int(),
        (taxi.y - 4.0).to_int(),
        6,
        8,
        @raylib.Color::new(112, 216, 250, 255),
      )
    }

    @raylib.draw_text(
      "NEON TAXI RUSH 2026",
      20,
      14,
      30,
      @raylib.Color::new(236, 242, 255, 255),
    )
    @raylib.draw_text(
      "WASD move  J boost  K horn  L pick/drop",
      20,
      48,
      18,
      @raylib.Color::new(184, 204, 236, 255),
    )

    @raylib.draw_text(
      "Cash \{taxi.cash} / \{target_cash}",
      520,
      16,
      28,
      @raylib.Color::new(246, 212, 118, 255),
    )
    @raylib.draw_text(
      "Time \{timer.to_int()}s",
      802,
      16,
      28,
      @raylib.Color::new(198, 228, 248, 255),
    )
    @raylib.draw_text(
      "Served \{served}",
      1000,
      16,
      28,
      @raylib.Color::new(172, 238, 194, 255),
    )

    @raylib.draw_text(
      "Wave \{wave}",
      520,
      48,
      22,
      @raylib.Color::new(210, 232, 248, 255),
    )
    @raylib.draw_text(
      "Combo \{taxi.combo}",
      640,
      48,
      22,
      @raylib.Color::new(250, 194, 102, 255),
    )
    @raylib.draw_text(
      "Rating \{rating_str(taxi.rating)}",
      776,
      48,
      22,
      @raylib.Color::new(162, 238, 202, 255),
    )
    @raylib.draw_text(
      "Missed \{misses}",
      978,
      48,
      22,
      @raylib.Color::new(236, 146, 152, 255),
    )

    @raylib.draw_rectangle(20, 82, 220, 10, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(
      20,
      82,
      (taxi.hp / 220.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(112, 220, 160, 255),
    )
    @raylib.draw_text(
      "CAB HP",
      20,
      96,
      16,
      @raylib.Color::new(182, 208, 230, 255),
    )

    @raylib.draw_rectangle(
      254,
      82,
      220,
      10,
      @raylib.Color::new(20, 26, 36, 255),
    )
    @raylib.draw_rectangle(
      254,
      82,
      (taxi.fuel / 100.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(108, 196, 248, 255),
    )
    @raylib.draw_text(
      "FUEL",
      254,
      96,
      16,
      @raylib.Color::new(182, 208, 230, 255),
    )

    if taxi.carry_idx >= 0 {
      @raylib.draw_text(
        "Passenger onboard",
        520,
        82,
        22,
        @raylib.Color::new(248, 240, 200, 255),
      )
    } else {
      @raylib.draw_text(
        "No passenger",
        520,
        82,
        22,
        @raylib.Color::new(170, 184, 204, 255),
      )
    }

    @raylib.draw_rectangle(
      12,
      sh - 214,
      244,
      204,
      @raylib.Color::new(8, 12, 20, 208),
    )
    let p0x = 22
    let p0y = sh - 194
    @raylib.draw_rectangle(
      p0x + 80,
      p0y,
      72,
      56,
      @raylib.Color::new(58, 80, 112, 255),
    )
    @raylib.draw_text(
      "U",
      p0x + 108,
      p0y + 16,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x,
      p0y + 56,
      72,
      56,
      @raylib.Color::new(58, 80, 112, 255),
    )
    @raylib.draw_text(
      "L",
      p0x + 28,
      p0y + 72,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 160,
      p0y + 56,
      72,
      56,
      @raylib.Color::new(58, 80, 112, 255),
    )
    @raylib.draw_text(
      "R",
      p0x + 188,
      p0y + 72,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 80,
      p0y + 112,
      72,
      56,
      @raylib.Color::new(58, 80, 112, 255),
    )
    @raylib.draw_text(
      "D",
      p0x + 108,
      p0y + 128,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )

    let p1x = sw - 240
    let p1y = sh - 222
    @raylib.draw_rectangle(
      p1x - 8,
      p1y - 12,
      230,
      216,
      @raylib.Color::new(8, 12, 20, 208),
    )
    @raylib.draw_rectangle(
      p1x,
      p1y,
      102,
      80,
      @raylib.Color::new(88, 160, 228, 255),
    )
    @raylib.draw_text(
      "BOOST",
      p1x + 12,
      p1y + 28,
      26,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_rectangle(
      p1x + 112,
      p1y,
      102,
      80,
      @raylib.Color::new(216, 114, 92, 255),
    )
    @raylib.draw_text(
      "HORN",
      p1x + 132,
      p1y + 28,
      26,
      @raylib.Color::new(252, 238, 230, 255),
    )
    @raylib.draw_rectangle(
      p1x + 56,
      p1y + 92,
      144,
      104,
      @raylib.Color::new(118, 178, 124, 255),
    )
    @raylib.draw_text(
      "PICK/DROP",
      p1x + 68,
      p1y + 132,
      24,
      @raylib.Color::new(236, 246, 240, 255),
    )

    @raylib.draw_rectangle(
      sw / 2 - 300,
      sh - 54,
      600,
      40,
      @raylib.Color::new(8, 10, 16, 214),
    )
    @raylib.draw_text(
      msg,
      sw / 2 - 282,
      sh - 44,
      24,
      @raylib.Color::new(236, 240, 250, if msg_t > 0.0 { 255 } else { 156 }),
    )

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 132))
      @raylib.draw_rectangle(
        sw / 2 - 420,
        sh / 2 - 190,
        840,
        380,
        @raylib.Color::new(14, 20, 32, 244),
      )
      @raylib.draw_text(
        "NEON TAXI RUSH",
        sw / 2 - 232,
        sh / 2 - 126,
        62,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Pick riders, weave traffic, chain fast deliveries",
        sw / 2 - 266,
        sh / 2 - 34,
        30,
        @raylib.Color::new(178, 210, 244, 255),
      )
      @raylib.draw_text(
        "Mobile: left pad move, right buttons boost/horn/pick",
        sw / 2 - 302,
        sh / 2 + 10,
        28,
        @raylib.Color::new(178, 210, 244, 255),
      )
      @raylib.draw_text(
        "ENTER or tap to start",
        sw / 2 - 166,
        sh / 2 + 102,
        40,
        @raylib.Color::new(255, 204, 112, 255),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 146))
      @raylib.draw_rectangle(
        sw / 2 - 440,
        sh / 2 - 194,
        880,
        388,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "SHIFT COMPLETE",
        sw / 2 - 206,
        sh / 2 - 132,
        60,
        @raylib.Color::new(248, 236, 188, 255),
      )
      @raylib.draw_text(
        "Cash: \{taxi.cash}",
        sw / 2 - 128,
        sh / 2 - 36,
        42,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Served: \{served}  Rating: \{rating_str(taxi.rating)}",
        sw / 2 - 246,
        sh / 2 + 18,
        34,
        @raylib.Color::new(174, 236, 202, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 182,
        sh / 2 + 116,
        34,
        @raylib.Color::new(252, 202, 112, 255),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 156))
      @raylib.draw_rectangle(
        sw / 2 - 440,
        sh / 2 - 194,
        880,
        388,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "SHIFT FAILED",
        sw / 2 - 172,
        sh / 2 - 132,
        60,
        @raylib.Color::new(248, 140, 152, 255),
      )
      @raylib.draw_text(
        "Cash: \{taxi.cash}",
        sw / 2 - 128,
        sh / 2 - 36,
        42,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Missed riders: \{misses}",
        sw / 2 - 168,
        sh / 2 + 18,
        34,
        @raylib.Color::new(236, 172, 182, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 182,
        sh / 2 + 116,
        34,
        @raylib.Color::new(252, 202, 112, 255),
      )
    }

    @raylib.end_drawing()

    if state == 2 || state == 3 {
      if @raylib.is_key_pressed(@raylib.KeyR) {
        state = 1
        reset_game()
      }
    }
  }

  @raylib.close_window()
}
