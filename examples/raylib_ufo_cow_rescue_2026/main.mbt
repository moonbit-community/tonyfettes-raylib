///|
let sw : Int = 1280

///|
let sh : Int = 760

///|
let ground_y : Float = 648.0

///|
let world_w : Float = 1280.0

///|
let world_h : Float = 760.0

///|
let max_cows : Int = 96

///|
let max_farmers : Int = 72

///|
let max_bullets : Int = 420

///|
let max_pickups : Int = 80

///|
let max_particles : Int = 960

///|
struct Ufo {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Float
  mut energy : Float
  mut beam_t : Float
  mut beam_heat : Float
  mut dash_t : Float
  mut dash_cd : Float
  mut emp_cd : Float
  mut flash_t : Float
  mut score : Int
  mut combo : Int
  mut rescued : Int
}

///|
struct Cow {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut state : Int
  mut t : Float
  mut panic_t : Float
}

///|
struct Farmer {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut hp : Float
  mut fire_cd : Float
  mut panic_t : Float
}

///|
struct Bullet {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut dmg : Float
  mut life : Float
}

///|
struct Pickup {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut kind : Int
  mut t : Float
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
  let dx : Float = ax - bx
  let dy : Float = ay - by
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
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn clear_cows(cows : Array[Cow]) -> Unit {
  for i = 0; i < cows.length(); i = i + 1 {
    cows[i].active = false
    cows[i].x = 0.0
    cows[i].y = 0.0
    cows[i].vx = 0.0
    cows[i].state = 0
    cows[i].t = 0.0
    cows[i].panic_t = 0.0
  }
}

///|
fn clear_farmers(farmers : Array[Farmer]) -> Unit {
  for i = 0; i < farmers.length(); i = i + 1 {
    farmers[i].active = false
    farmers[i].x = 0.0
    farmers[i].y = 0.0
    farmers[i].vx = 0.0
    farmers[i].hp = 0.0
    farmers[i].fire_cd = 0.0
    farmers[i].panic_t = 0.0
  }
}

///|
fn clear_bullets(bullets : Array[Bullet]) -> Unit {
  for i = 0; i < bullets.length(); i = i + 1 {
    bullets[i].active = false
    bullets[i].x = 0.0
    bullets[i].y = 0.0
    bullets[i].vx = 0.0
    bullets[i].vy = 0.0
    bullets[i].dmg = 0.0
    bullets[i].life = 0.0
  }
}

///|
fn clear_pickups(items : Array[Pickup]) -> Unit {
  for i = 0; i < items.length(); i = i + 1 {
    items[i].active = false
    items[i].x = 0.0
    items[i].y = 0.0
    items[i].kind = 0
    items[i].t = 0.0
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
    parts[i].size = 0.0
    parts[i].t = 0.0
    parts[i].life = 0.0
    parts[i].kind = 0
  }
}

///|
fn spawn_particle(
  parts : Array[Particle],
  x : Float,
  y : Float,
  speed : Float,
  kind : Int,
) -> Unit {
  let mut done = false
  for i = 0; i < parts.length(); i = i + 1 {
    if done {
      continue
    }
    if not(parts[i].active) {
      parts[i].active = true
      parts[i].x = x
      parts[i].y = y
      parts[i].vx = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      parts[i].vy = Float::from_int(@raylib.get_random_value(-260, 260)) * speed
      parts[i].size = Float::from_int(@raylib.get_random_value(2, 7))
      parts[i].t = 0.0
      parts[i].life = Float::from_int(@raylib.get_random_value(18, 74)) / 100.0
      parts[i].kind = kind
      done = true
    }
  }
}

///|
fn burst(
  parts : Array[Particle],
  x : Float,
  y : Float,
  count : Int,
  speed : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < count; i = i + 1 {
    ignore(i)
    spawn_particle(parts, x, y, speed, kind)
  }
}

///|
fn spawn_cow(cows : Array[Cow]) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < cows.length(); i = i + 1 {
    if slot < 0 && not(cows[i].active) {
      slot = i
    }
  }

  if slot < 0 {
    false
  } else {
    cows[slot].active = true
    cows[slot].x = randf(80.0, world_w - 80.0)
    cows[slot].y = ground_y + randf(-12.0, 8.0)
    cows[slot].vx = randf(-24.0, 24.0)
    cows[slot].state = 0
    cows[slot].t = randf(0.0, 1.0)
    cows[slot].panic_t = 0.0
    true
  }
}

///|
fn spawn_farmer(farmers : Array[Farmer], level : Int) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < farmers.length(); i = i + 1 {
    if slot < 0 && not(farmers[i].active) {
      slot = i
    }
  }

  if slot < 0 {
    false
  } else {
    farmers[slot].active = true
    farmers[slot].x = randf(60.0, world_w - 60.0)
    farmers[slot].y = ground_y
    farmers[slot].vx = randf(-32.0, 32.0)
    farmers[slot].hp = 42.0 + Float::from_int(level - 1) * 5.0
    farmers[slot].fire_cd = randf(0.4, 1.2)
    farmers[slot].panic_t = 0.0
    true
  }
}

///|
fn spawn_enemy_bullet(
  bullets : Array[Bullet],
  x : Float,
  y : Float,
  tx : Float,
  ty : Float,
  dmg : Float,
) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < bullets.length(); i = i + 1 {
    if slot < 0 && not(bullets[i].active) {
      slot = i
    }
  }

  if slot < 0 {
    false
  } else {
    let dx = tx - x
    let dy = ty - y
    let d2 = dx * dx + dy * dy
    let d = if d2 < Float::from_int(1) { Float::from_int(1) } else { d2.sqrt() }

    bullets[slot].active = true
    bullets[slot].x = x
    bullets[slot].y = y
    bullets[slot].vx = dx / d * 320.0
    bullets[slot].vy = dy / d * 320.0
    bullets[slot].dmg = dmg
    bullets[slot].life = 2.3
    true
  }
}

///|
fn spawn_pickup(items : Array[Pickup]) -> Bool {
  let mut slot : Int = -1
  for i = 0; i < items.length(); i = i + 1 {
    if slot < 0 && not(items[i].active) {
      slot = i
    }
  }

  if slot < 0 {
    false
  } else {
    let roll = @raylib.get_random_value(0, 99)
    let kind : Int = if roll < 60 { 0 } else if roll < 90 { 1 } else { 2 }

    items[slot].active = true
    items[slot].x = randf(60.0, world_w - 60.0)
    items[slot].y = ground_y + randf(-16.0, 10.0)
    items[slot].kind = kind
    items[slot].t = randf(0.0, 1.0)
    true
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "UFO Cow Rescue 2026")
  @raylib.set_target_fps(60)

  let ufo : Ufo = {
    x: 640.0,
    y: 210.0,
    vx: 0.0,
    vy: 0.0,
    hp: 220.0,
    energy: 100.0,
    beam_t: 0.0,
    beam_heat: 0.0,
    dash_t: 0.0,
    dash_cd: 0.0,
    emp_cd: 0.0,
    flash_t: 0.0,
    score: 0,
    combo: 0,
    rescued: 0,
  }

  let cows : Array[Cow] = Array::makei(max_cows, fn(_i) {
    { active: false, x: 0.0, y: 0.0, vx: 0.0, state: 0, t: 0.0, panic_t: 0.0 }
  })

  let farmers : Array[Farmer] = Array::makei(max_farmers, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      hp: 0.0,
      fire_cd: 0.0,
      panic_t: 0.0,
    }
  })

  let bullets : Array[Bullet] = Array::makei(max_bullets, fn(_i) {
    { active: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, dmg: 0.0, life: 0.0 }
  })

  let pickups : Array[Pickup] = Array::makei(max_pickups, fn(_i) {
    { active: false, x: 0.0, y: 0.0, kind: 0, t: 0.0 }
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

  let mut state : Int = 0
  let mut level : Int = 1
  let mut timer : Float = 224.0
  let mut target : Int = 22
  let mut kills : Int = 0
  let mut missed : Int = 0

  let mut spawn_cow_cd : Float = 0.45
  let mut spawn_farmer_cd : Float = 0.72
  let mut spawn_pickup_cd : Float = 3.6

  let mut ship_x : Float = 640.0
  let mut ship_vx : Float = 88.0

  let mut msg : String = "Abduct cows, avoid farmers"
  let mut msg_t : Float = 3.0

  let reset_run = fn() {
    ufo.x = 640.0
    ufo.y = 210.0
    ufo.vx = 0.0
    ufo.vy = 0.0
    ufo.hp = 220.0
    ufo.energy = 100.0
    ufo.beam_t = 0.0
    ufo.beam_heat = 0.0
    ufo.dash_t = 0.0
    ufo.dash_cd = 0.0
    ufo.emp_cd = 0.0
    ufo.flash_t = 0.0
    ufo.score = 0
    ufo.combo = 0
    ufo.rescued = 0

    level = 1
    timer = 224.0
    target = 22
    kills = 0
    missed = 0

    spawn_cow_cd = 0.45
    spawn_farmer_cd = 0.72
    spawn_pickup_cd = 3.6

    ship_x = 640.0
    ship_vx = 88.0

    msg = "Night farm operation"
    msg_t = 2.2

    clear_cows(cows)
    clear_farmers(farmers)
    clear_bullets(bullets)
    clear_pickups(pickups)
    clear_particles(particles)

    for i = 0; i < 18; i = i + 1 {
      ignore(i)
      ignore(spawn_cow(cows))
    }
    for i = 0; i < 7; i = i + 1 {
      ignore(i)
      ignore(spawn_farmer(farmers, level))
    }
    for i = 0; i < 4; i = i + 1 {
      ignore(i)
      ignore(spawn_pickup(pickups))
    }
  }

  let on_hit = fn(dmg : Float, text : String) {
    ufo.hp = ufo.hp - dmg
    ufo.flash_t = 0.18
    ufo.combo = 0
    msg = text
    msg_t = 0.66
    burst(particles, ufo.x, ufo.y, 14, 0.24, 3)
  }

  reset_run()

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

    if ufo.flash_t > 0.0 {
      ufo.flash_t = ufo.flash_t - dt
      if ufo.flash_t < 0.0 {
        ufo.flash_t = 0.0
      }
    }

    if state == 0 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 1
        reset_run()
      }
    } else if state == 1 {
      timer = timer - dt

      ufo.dash_t = ufo.dash_t - dt
      if ufo.dash_t < 0.0 {
        ufo.dash_t = 0.0
      }
      ufo.dash_cd = ufo.dash_cd - dt
      if ufo.dash_cd < 0.0 {
        ufo.dash_cd = 0.0
      }
      ufo.emp_cd = ufo.emp_cd - dt
      if ufo.emp_cd < 0.0 {
        ufo.emp_cd = 0.0
      }

      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)

      let mut beam_down : Bool = @raylib.is_key_down(@raylib.KeyJ)
      let mut dash_press : Bool = @raylib.is_key_pressed(@raylib.KeyK)
      let mut emp_press : Bool = @raylib.is_key_pressed(@raylib.KeyL)

      let pad_x : Int = 20
      let pad_y : Int = sh - 198
      let btn_x : Int = sw - 274
      let btn_y : Int = sh - 236

      if touching {
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 58, 78, 58) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 160, pad_y + 58, 78, 58) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y, 78, 58) {
          move_u = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 80, pad_y + 116, 78, 58) {
          move_d = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x, btn_y + 8, 118, 88) {
          beam_down = true
        }
      }

      if pressed {
        if inside_rect(mouse.x, mouse.y, btn_x + 128, btn_y + 8, 118, 88) {
          dash_press = true
        }
        if inside_rect(mouse.x, mouse.y, btn_x + 64, btn_y + 106, 166, 98) {
          emp_press = true
        }
      }

      let mut ax : Float = 0.0
      let mut ay : Float = 0.0
      if move_l {
        ax = ax - 540.0
      }
      if move_r {
        ax = ax + 540.0
      }
      if move_u {
        ay = ay - 540.0
      }
      if move_d {
        ay = ay + 540.0
      }

      if ufo.dash_t > 0.0 {
        ax = ax * 1.7
        ay = ay * 1.7
      }

      ufo.vx = ufo.vx + ax * dt
      ufo.vy = ufo.vy + ay * dt
      ufo.vx = ufo.vx * (Float::from_int(1) - dt * 2.6)
      ufo.vy = ufo.vy * (Float::from_int(1) - dt * 2.6)

      let max_speed : Float = if ufo.dash_t > 0.0 { 420.0 } else { 270.0 }
      if ufo.vx > max_speed {
        ufo.vx = max_speed
      }
      if ufo.vx < -max_speed {
        ufo.vx = -max_speed
      }
      if ufo.vy > max_speed {
        ufo.vy = max_speed
      }
      if ufo.vy < -max_speed {
        ufo.vy = -max_speed
      }

      ufo.x = ufo.x + ufo.vx * dt
      ufo.y = ufo.y + ufo.vy * dt
      ufo.x = clampf(ufo.x, 34.0, world_w - 34.0)
      ufo.y = clampf(ufo.y, 70.0, 420.0)

      ufo.energy = ufo.energy + dt * 13.0
      if ufo.energy > 100.0 {
        ufo.energy = 100.0
      }

      if dash_press && ufo.dash_cd <= 0.0 && ufo.energy >= 18.0 {
        ufo.dash_t = 0.26
        ufo.dash_cd = 1.45
        ufo.energy = ufo.energy - 18.0
        burst(particles, ufo.x, ufo.y, 16, 0.20, 1)
      }

      if emp_press && ufo.emp_cd <= 0.0 && ufo.energy >= 28.0 {
        ufo.emp_cd = 2.2
        ufo.energy = ufo.energy - 28.0
        msg = "EMP pulse"
        msg_t = 0.7
        burst(particles, ufo.x, ufo.y, 28, 0.30, 2)

        for i = 0; i < farmers.length(); i = i + 1 {
          if farmers[i].active &&
            dist2(ufo.x, ufo.y, farmers[i].x, farmers[i].y) <= 180.0 * 180.0 {
            farmers[i].hp = farmers[i].hp -
              (36.0 + Float::from_int(level) * 2.0)
            farmers[i].panic_t = 1.1
            if farmers[i].hp <= 0.0 {
              farmers[i].active = false
              kills = kills + 1
              ufo.score = ufo.score + 86 + ufo.combo * 4
              ufo.combo = ufo.combo + 1
            }
          }
        }

        for i = 0; i < bullets.length(); i = i + 1 {
          if bullets[i].active &&
            dist2(ufo.x, ufo.y, bullets[i].x, bullets[i].y) <= 170.0 * 170.0 {
            bullets[i].active = false
          }
        }
      }

      let beam_on : Bool = beam_down && ufo.energy > 0.0
      if beam_on {
        ufo.energy = ufo.energy - dt * 24.0
        if ufo.energy < 0.0 {
          ufo.energy = 0.0
        }
        ufo.beam_t = ufo.beam_t + dt
      } else {
        ufo.beam_t = ufo.beam_t - dt
        if ufo.beam_t < 0.0 {
          ufo.beam_t = 0.0
        }
      }

      ship_x = ship_x + ship_vx * dt
      if ship_x < 220.0 {
        ship_x = 220.0
        ship_vx = absf(ship_vx)
      }
      if ship_x > 1060.0 {
        ship_x = 1060.0
        ship_vx = -absf(ship_vx)
      }

      level = ufo.rescued / 4 + 1

      spawn_cow_cd = spawn_cow_cd - dt
      if spawn_cow_cd <= 0.0 {
        ignore(spawn_cow(cows))
        spawn_cow_cd = randf(0.72, 1.44)
      }

      spawn_farmer_cd = spawn_farmer_cd - dt
      if spawn_farmer_cd <= 0.0 {
        ignore(spawn_farmer(farmers, level))
        spawn_farmer_cd = randf(0.8, 1.6)
      }

      spawn_pickup_cd = spawn_pickup_cd - dt
      if spawn_pickup_cd <= 0.0 {
        ignore(spawn_pickup(pickups))
        spawn_pickup_cd = randf(4.0, 7.0)
      }

      for i = 0; i < cows.length(); i = i + 1 {
        if not(cows[i].active) {
          continue
        }

        cows[i].t = cows[i].t + dt
        cows[i].panic_t = cows[i].panic_t - dt
        if cows[i].panic_t < 0.0 {
          cows[i].panic_t = 0.0
        }

        if cows[i].state == 0 {
          let drift : Float = if (cows[i].t * 3.0).to_int() % 2 == 0 {
            -1.0
          } else {
            1.0
          }
          cows[i].vx = cows[i].vx + drift * dt * 8.0
          cows[i].vx = clampf(cows[i].vx, -34.0, 34.0)
          cows[i].x = cows[i].x + cows[i].vx * dt
          cows[i].x = clampf(cows[i].x, 40.0, world_w - 40.0)

          if beam_on &&
            dist2(cows[i].x, cows[i].y, ufo.x, ufo.y + 100.0) <= 120.0 * 120.0 {
            cows[i].state = 1
            cows[i].panic_t = 0.8
          }
        } else if cows[i].state == 1 {
          let tx = ufo.x
          let ty = ufo.y + 42.0
          let dx = tx - cows[i].x
          let dy = ty - cows[i].y
          cows[i].x = cows[i].x + dx * dt * 4.0
          cows[i].y = cows[i].y + dy * dt * 4.0

          if absf(dx) < 10.0 && absf(dy) < 10.0 {
            cows[i].state = 2
          }

          if not(beam_on) {
            cows[i].state = 0
            cows[i].y = ground_y
          }
        } else {
          cows[i].x = ufo.x
          cows[i].y = ufo.y + 42.0

          if not(beam_on) {
            cows[i].state = 0
            cows[i].y = ground_y
            cows[i].vx = randf(-20.0, 20.0)
          } else if absf(ufo.x - ship_x) < 96.0 && ufo.y < 116.0 {
            cows[i].active = false
            ufo.rescued = ufo.rescued + 1
            ufo.combo = ufo.combo + 1
            let pts = 120 + ufo.combo * 8
            ufo.score = ufo.score + pts
            msg = "Rescue +\{pts}"
            msg_t = 0.7
            burst(particles, ship_x, 84.0, 18, 0.22, 1)
          }
        }
      }

      for i = 0; i < farmers.length(); i = i + 1 {
        if not(farmers[i].active) {
          continue
        }

        farmers[i].panic_t = farmers[i].panic_t - dt
        if farmers[i].panic_t < 0.0 {
          farmers[i].panic_t = 0.0
        }

        farmers[i].fire_cd = farmers[i].fire_cd - dt
        if farmers[i].fire_cd < 0.0 {
          farmers[i].fire_cd = 0.0
        }

        let mut tx = ufo.x
        let mut found_cow = false
        for c = 0; c < cows.length(); c = c + 1 {
          if cows[c].active && cows[c].state == 0 {
            if absf(cows[c].x - farmers[i].x) < 180.0 {
              tx = cows[c].x
              found_cow = true
            }
          }
        }

        if beam_on {
          tx = ufo.x
          farmers[i].panic_t = 0.7
        } else if not(found_cow) {
          tx = ufo.x
        }

        if tx < farmers[i].x - 6.0 {
          farmers[i].vx = farmers[i].vx - dt * 64.0
        } else if tx > farmers[i].x + 6.0 {
          farmers[i].vx = farmers[i].vx + dt * 64.0
        }
        farmers[i].vx = clampf(farmers[i].vx, -96.0, 96.0)

        let panic_drag : Float = if farmers[i].panic_t > 0.0 {
          4.6
        } else {
          2.5
        }
        farmers[i].vx = farmers[i].vx * (Float::from_int(1) - dt * panic_drag)

        farmers[i].x = farmers[i].x + farmers[i].vx * dt
        farmers[i].x = clampf(farmers[i].x, 30.0, world_w - 30.0)

        // Farmers can seize nearby ground cows; this counts as missed.
        for c = 0; c < cows.length(); c = c + 1 {
          if cows[c].active &&
            cows[c].state == 0 &&
            absf(cows[c].x - farmers[i].x) < 18.0 {
            cows[c].active = false
            missed = missed + 1
            ufo.combo = 0
            msg = "Farmer seized a cow"
            msg_t = 0.55
            burst(particles, cows[c].x, cows[c].y - 18.0, 6, 0.18, 3)
            break
          }
        }

        if farmers[i].fire_cd <= 0.0 &&
          absf(farmers[i].x - ufo.x) < 260.0 &&
          ufo.y < 340.0 {
          farmers[i].fire_cd = randf(0.86, 1.5)
          ignore(
            spawn_enemy_bullet(
              bullets,
              farmers[i].x,
              farmers[i].y - 18.0,
              ufo.x,
              ufo.y,
              11.0 + Float::from_int(level) * 1.4,
            ),
          )
        }
      }

      for i = 0; i < bullets.length(); i = i + 1 {
        if not(bullets[i].active) {
          continue
        }

        bullets[i].life = bullets[i].life - dt
        if bullets[i].life <= 0.0 {
          bullets[i].active = false
          continue
        }

        bullets[i].x = bullets[i].x + bullets[i].vx * dt
        bullets[i].y = bullets[i].y + bullets[i].vy * dt

        if bullets[i].x < -40.0 ||
          bullets[i].x > world_w + 40.0 ||
          bullets[i].y < -40.0 ||
          bullets[i].y > world_h + 40.0 {
          bullets[i].active = false
          continue
        }

        if dist2(bullets[i].x, bullets[i].y, ufo.x, ufo.y) <= 20.0 * 20.0 {
          bullets[i].active = false
          on_hit(bullets[i].dmg, "Laser hit")
        }
      }

      for i = 0; i < pickups.length(); i = i + 1 {
        if not(pickups[i].active) {
          continue
        }
        pickups[i].t = pickups[i].t + dt

        if dist2(pickups[i].x, pickups[i].y, ufo.x, ufo.y + 80.0) <= 34.0 * 34.0 {
          if pickups[i].kind == 0 {
            ufo.energy = ufo.energy + 26.0
            if ufo.energy > 100.0 {
              ufo.energy = 100.0
            }
            msg = "Battery"
          } else if pickups[i].kind == 1 {
            ufo.hp = ufo.hp + 24.0
            if ufo.hp > 220.0 {
              ufo.hp = 220.0
            }
            msg = "Repair"
          } else {
            ufo.score = ufo.score + 64
            ufo.combo = ufo.combo + 1
            msg = "Data cache +64"
          }
          msg_t = 0.64
          pickups[i].active = false
          burst(particles, ufo.x, ufo.y, 10, 0.20, 0)
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
          particles[i].vx = particles[i].vx * (Float::from_int(1) - dt * 2.0)
          particles[i].vy = particles[i].vy + 260.0 * dt
        }
      }

      if ufo.rescued >= target {
        state = 2
      } else if ufo.hp <= 0.0 || timer <= 0.0 {
        state = 3
      }
    } else {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || pressed {
        state = 0
      }
      if @raylib.is_key_pressed(@raylib.KeyR) {
        state = 1
        reset_run()
      }
    }

    @raylib.begin_drawing()

    let mut bg_col = @raylib.Color::new(12, 14, 24, 255)
    if state == 2 {
      bg_col = @raylib.Color::new(16, 26, 28, 255)
    } else if state == 3 {
      bg_col = @raylib.Color::new(26, 14, 20, 255)
    }
    @raylib.clear_background(bg_col)

    @raylib.draw_rectangle(0, 0, sw, 188, @raylib.Color::new(20, 30, 52, 255))
    for i = 0; i < 26; i = i + 1 {
      let sx = i * 52 + (timer * 20.0).to_int() % 52
      @raylib.draw_circle(
        sx,
        52 + i * 13 % 78,
        2.0,
        @raylib.Color::new(196, 222, 250, 200),
      )
    }

    for i = 0; i < 18; i = i + 1 {
      let x = i * 72 + (timer * 14.0).to_int() % 72
      let h = 120 + i * 17 % 210
      @raylib.draw_rectangle(
        x,
        sh - h - 40,
        56,
        h,
        @raylib.Color::new(26, 32, 52, 255),
      )
      @raylib.draw_rectangle(
        x + 12,
        sh - h + 6 - 40,
        8,
        h - 18,
        @raylib.Color::new(90, 168, 246, 150),
      )
    }

    @raylib.draw_rectangle(
      0,
      ground_y.to_int(),
      sw,
      sh - ground_y.to_int(),
      @raylib.Color::new(52, 68, 44, 255),
    )
    @raylib.draw_rectangle(
      0,
      (ground_y - 8.0).to_int(),
      sw,
      8,
      @raylib.Color::new(68, 92, 54, 255),
    )

    @raylib.draw_rectangle(
      (ship_x - 120.0).to_int(),
      22,
      240,
      28,
      @raylib.Color::new(122, 176, 234, 255),
    )
    @raylib.draw_rectangle(
      (ship_x - 88.0).to_int(),
      50,
      176,
      18,
      @raylib.Color::new(84, 136, 196, 255),
    )

    for i = 0; i < pickups.length(); i = i + 1 {
      if not(pickups[i].active) {
        continue
      }
      let blink : Int = if (pickups[i].t * 8.0).to_int() % 2 == 0 {
        255
      } else {
        180
      }
      let col = if pickups[i].kind == 0 {
        @raylib.Color::new(128, 220, 250, blink)
      } else if pickups[i].kind == 1 {
        @raylib.Color::new(252, 142, 158, blink)
      } else {
        @raylib.Color::new(240, 220, 126, blink)
      }
      @raylib.draw_circle(
        pickups[i].x.to_int(),
        pickups[i].y.to_int(),
        10.0,
        col,
      )
      @raylib.draw_circle_lines(
        pickups[i].x.to_int(),
        pickups[i].y.to_int(),
        16.0,
        @raylib.Color::new(246, 250, 255, blink),
      )
    }

    for i = 0; i < cows.length(); i = i + 1 {
      if not(cows[i].active) {
        continue
      }

      let mut col = @raylib.Color::new(238, 228, 216, 255)
      if cows[i].panic_t > 0.0 {
        col = @raylib.Color::new(250, 198, 182, 255)
      }

      @raylib.draw_circle(cows[i].x.to_int(), cows[i].y.to_int(), 13.0, col)
      @raylib.draw_circle(
        (cows[i].x - 6.0).to_int(),
        (cows[i].y - 3.0).to_int(),
        2.0,
        @raylib.Color::new(38, 36, 34, 255),
      )
      @raylib.draw_circle(
        (cows[i].x + 6.0).to_int(),
        (cows[i].y - 3.0).to_int(),
        2.0,
        @raylib.Color::new(38, 36, 34, 255),
      )
    }

    for i = 0; i < farmers.length(); i = i + 1 {
      if not(farmers[i].active) {
        continue
      }
      let mut col = @raylib.Color::new(178, 96, 86, 255)
      if farmers[i].panic_t > 0.0 {
        col = @raylib.Color::new(232, 142, 124, 255)
      }
      @raylib.draw_rectangle(
        (farmers[i].x - 10.0).to_int(),
        (farmers[i].y - 22.0).to_int(),
        20,
        24,
        col,
      )
      @raylib.draw_rectangle(
        (farmers[i].x - 4.0).to_int(),
        (farmers[i].y - 14.0).to_int(),
        8,
        12,
        @raylib.Color::new(30, 34, 52, 255),
      )
    }

    for i = 0; i < bullets.length(); i = i + 1 {
      if not(bullets[i].active) {
        continue
      }
      @raylib.draw_circle(
        bullets[i].x.to_int(),
        bullets[i].y.to_int(),
        4.0,
        @raylib.Color::new(246, 132, 152, 255),
      )
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }
      let k = particles[i].t / particles[i].life
      let a : Int = ((Float::from_int(1) - k) * 220.0).to_int()
      let mut c = @raylib.Color::new(124, 224, 252, a)
      if particles[i].kind == 1 {
        c = @raylib.Color::new(142, 246, 182, a)
      } else if particles[i].kind == 2 {
        c = @raylib.Color::new(252, 192, 106, a)
      } else if particles[i].kind == 3 {
        c = @raylib.Color::new(236, 96, 118, a)
      }
      @raylib.draw_circle(
        particles[i].x.to_int(),
        particles[i].y.to_int(),
        particles[i].size,
        c,
      )
    }

    let mut ufo_col = @raylib.Color::new(144, 214, 252, 255)
    if ufo.flash_t > 0.0 {
      ufo_col = @raylib.Color::new(255, 240, 220, 255)
    }

    @raylib.draw_circle(ufo.x.to_int(), ufo.y.to_int(), 22.0, ufo_col)
    @raylib.draw_rectangle(
      (ufo.x - 30.0).to_int(),
      (ufo.y + 12.0).to_int(),
      60,
      12,
      @raylib.Color::new(82, 122, 176, 255),
    )
    @raylib.draw_circle(
      (ufo.x - 10.0).to_int(),
      (ufo.y + 14.0).to_int(),
      3.0,
      @raylib.Color::new(248, 236, 186, 255),
    )
    @raylib.draw_circle(
      (ufo.x + 10.0).to_int(),
      (ufo.y + 14.0).to_int(),
      3.0,
      @raylib.Color::new(248, 236, 186, 255),
    )

    if ufo.beam_t > 0.0 {
      let beam_alpha : Int = (ufo.beam_t * 240.0).to_int()
      @raylib.draw_triangle(
        @raylib.Vector2::new(ufo.x - 24.0, ufo.y + 18.0),
        @raylib.Vector2::new(ufo.x + 24.0, ufo.y + 18.0),
        @raylib.Vector2::new(ufo.x, ground_y + 18.0),
        @raylib.Color::new(132, 228, 252, beam_alpha),
      )
    }

    if ufo.dash_t > 0.0 {
      @raylib.draw_circle_lines(
        ufo.x.to_int(),
        ufo.y.to_int(),
        34.0,
        @raylib.Color::new(134, 228, 252, 220),
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 74, @raylib.Color::new(8, 12, 22, 226))
    @raylib.draw_text(
      "UFO COW RESCUE 2026",
      20,
      14,
      30,
      @raylib.Color::new(236, 244, 255, 255),
    )
    @raylib.draw_text(
      "WASD move  J beam  K dash  L EMP",
      20,
      48,
      18,
      @raylib.Color::new(178, 204, 236, 255),
    )

    @raylib.draw_text(
      "Score \{ufo.score}",
      540,
      16,
      28,
      @raylib.Color::new(246, 216, 118, 255),
    )
    @raylib.draw_text(
      "Rescued \{ufo.rescued}/\{target}",
      710,
      16,
      28,
      @raylib.Color::new(170, 238, 194, 255),
    )
    @raylib.draw_text(
      "Level \{level}",
      958,
      16,
      28,
      @raylib.Color::new(180, 226, 252, 255),
    )
    @raylib.draw_text(
      "Time \{timer.to_int()}s",
      1090,
      16,
      28,
      @raylib.Color::new(248, 188, 132, 255),
    )

    @raylib.draw_rectangle(20, 82, 220, 10, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(
      20,
      82,
      (ufo.hp / 220.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(108, 224, 154, 255),
    )
    @raylib.draw_text("HP", 20, 96, 16, @raylib.Color::new(182, 208, 230, 255))

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
      (ufo.energy / 100.0 * 220.0).to_int(),
      10,
      @raylib.Color::new(116, 198, 248, 255),
    )
    @raylib.draw_text(
      "ENERGY",
      254,
      96,
      16,
      @raylib.Color::new(182, 208, 230, 255),
    )

    @raylib.draw_text(
      "Combo \{ufo.combo}",
      500,
      84,
      20,
      @raylib.Color::new(246, 222, 152, 255),
    )
    @raylib.draw_text(
      "Kills \{kills}",
      620,
      84,
      20,
      @raylib.Color::new(172, 236, 198, 255),
    )
    @raylib.draw_text(
      "Missed cows \{missed}",
      740,
      84,
      20,
      @raylib.Color::new(242, 162, 172, 255),
    )

    @raylib.draw_rectangle(
      12,
      sh - 214,
      246,
      202,
      @raylib.Color::new(8, 12, 20, 210),
    )
    let p0x = 20
    let p0y = sh - 198
    @raylib.draw_rectangle(
      p0x,
      p0y + 58,
      78,
      58,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "L",
      p0x + 30,
      p0y + 76,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 160,
      p0y + 58,
      78,
      58,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "R",
      p0x + 190,
      p0y + 76,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 80,
      p0y,
      78,
      58,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "U",
      p0x + 110,
      p0y + 18,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )
    @raylib.draw_rectangle(
      p0x + 80,
      p0y + 116,
      78,
      58,
      @raylib.Color::new(58, 82, 114, 255),
    )
    @raylib.draw_text(
      "D",
      p0x + 110,
      p0y + 134,
      24,
      @raylib.Color::new(214, 232, 255, 255),
    )

    @raylib.draw_rectangle(
      sw - 282,
      sh - 244,
      266,
      232,
      @raylib.Color::new(8, 12, 20, 210),
    )
    let p1x = sw - 274
    let p1y = sh - 236
    @raylib.draw_rectangle(
      p1x,
      p1y + 8,
      118,
      88,
      @raylib.Color::new(88, 156, 228, 255),
    )
    @raylib.draw_text(
      "BEAM",
      p1x + 22,
      p1y + 42,
      26,
      @raylib.Color::new(236, 246, 255, 255),
    )
    @raylib.draw_rectangle(
      p1x + 128,
      p1y + 8,
      118,
      88,
      @raylib.Color::new(214, 112, 94, 255),
    )
    @raylib.draw_text(
      "DASH",
      p1x + 154,
      p1y + 42,
      26,
      @raylib.Color::new(252, 236, 228, 255),
    )
    @raylib.draw_rectangle(
      p1x + 64,
      p1y + 106,
      166,
      98,
      @raylib.Color::new(112, 178, 126, 255),
    )
    @raylib.draw_text(
      "EMP",
      p1x + 124,
      p1y + 142,
      34,
      @raylib.Color::new(236, 246, 240, 255),
    )

    @raylib.draw_rectangle(
      sw / 2 - 320,
      sh - 54,
      640,
      40,
      @raylib.Color::new(8, 10, 16, 214),
    )
    @raylib.draw_text(
      msg,
      sw / 2 - 302,
      sh - 44,
      24,
      @raylib.Color::new(236, 240, 250, if msg_t > 0.0 { 255 } else { 160 }),
    )

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 132))
      @raylib.draw_rectangle(
        sw / 2 - 448,
        sh / 2 - 196,
        896,
        392,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "UFO COW RESCUE",
        sw / 2 - 250,
        sh / 2 - 132,
        60,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Beam up cows before dawn. Farmers will fight back.",
        sw / 2 - 302,
        sh / 2 - 30,
        30,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "Mobile: left pad moves, right pad beam/dash/EMP",
        sw / 2 - 324,
        sh / 2 + 14,
        28,
        @raylib.Color::new(182, 214, 246, 255),
      )
      @raylib.draw_text(
        "Rescue 22 cows to win",
        sw / 2 - 150,
        sh / 2 + 54,
        32,
        @raylib.Color::new(250, 212, 132, 255),
      )
      @raylib.draw_text(
        "ENTER or tap to start",
        sw / 2 - 166,
        sh / 2 + 114,
        40,
        @raylib.Color::new(255, 204, 112, 255),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 148))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "MISSION COMPLETE",
        sw / 2 - 232,
        sh / 2 - 132,
        60,
        @raylib.Color::new(248, 236, 186, 255),
      )
      @raylib.draw_text(
        "Score: \{ufo.score}",
        sw / 2 - 148,
        sh / 2 - 36,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Rescued: \{ufo.rescued}  Kills: \{kills}",
        sw / 2 - 206,
        sh / 2 + 18,
        34,
        @raylib.Color::new(170, 236, 198, 255),
      )
      @raylib.draw_text(
        "Missed cows: \{missed}",
        sw / 2 - 160,
        sh / 2 + 60,
        34,
        @raylib.Color::new(236, 172, 182, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 178,
        sh / 2 + 122,
        34,
        @raylib.Color::new(252, 202, 112, 255),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 156))
      @raylib.draw_rectangle(
        sw / 2 - 430,
        sh / 2 - 190,
        860,
        380,
        @raylib.Color::new(14, 20, 32, 246),
      )
      @raylib.draw_text(
        "MISSION FAILED",
        sw / 2 - 206,
        sh / 2 - 132,
        60,
        @raylib.Color::new(246, 140, 154, 255),
      )
      @raylib.draw_text(
        "Score: \{ufo.score}",
        sw / 2 - 148,
        sh / 2 - 36,
        44,
        @raylib.Color::new(236, 244, 255, 255),
      )
      @raylib.draw_text(
        "Rescued: \{ufo.rescued} / \{target}",
        sw / 2 - 180,
        sh / 2 + 18,
        34,
        @raylib.Color::new(172, 236, 202, 255),
      )
      @raylib.draw_text(
        "Time left: \{timer.to_int()}s",
        sw / 2 - 166,
        sh / 2 + 60,
        34,
        @raylib.Color::new(236, 172, 182, 255),
      )
      @raylib.draw_text(
        "R replay   ENTER menu",
        sw / 2 - 178,
        sh / 2 + 122,
        34,
        @raylib.Color::new(252, 202, 112, 255),
      )
    }

    @raylib.end_drawing()

    if state == 2 || state == 3 {
      if @raylib.is_key_pressed(@raylib.KeyR) {
        state = 1
        reset_run()
      }
    }
  }

  @raylib.close_window()
}
