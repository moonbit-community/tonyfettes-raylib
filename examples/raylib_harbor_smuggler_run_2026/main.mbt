///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let water_top : Float = 122.0

///|
let water_bottom : Float = 760.0

///|
let max_patrol : Int = 24

///|
let max_crates : Int = 56

///|
let max_particles : Int = 520

///|
struct Smuggler {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Int
  mut fuel : Float
  mut cargo : Int
  mut dash_t : Float
  mut stealth_t : Float
  mut hit_cd : Float
  mut flash_t : Float
  mut deliver_cd : Float
}

///|
struct Patrol {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut speed : Float
  mut radius : Float
  mut kind : Int
  mut alert_t : Float
  mut active : Bool
}

///|
struct Crate {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut value : Int
  mut active : Bool
}

///|
struct Particle {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut kind : Int
  mut active : Bool
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
fn sqdist(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
}

///|
fn inside_rect(px : Float, py : Float, rx : Int, ry : Int, rw : Int, rh : Int) -> Bool {
  px >= Float::from_int(rx) && px <= Float::from_int(rx + rw) && py >= Float::from_int(ry) && py <= Float::from_int(ry + rh)
}

///|
fn clear_patrols(ps : Array[Patrol]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    ps[i].x = 0.0
    ps[i].y = 0.0
    ps[i].vx = 0.0
    ps[i].vy = 0.0
    ps[i].speed = 0.0
    ps[i].radius = 0.0
    ps[i].kind = 0
    ps[i].alert_t = 0.0
    ps[i].active = false
  }
}

///|
fn clear_crates(cs : Array[Crate]) -> Unit {
  for i = 0; i < cs.length(); i = i + 1 {
    cs[i].x = 0.0
    cs[i].y = 0.0
    cs[i].vx = 0.0
    cs[i].vy = 0.0
    cs[i].value = 0
    cs[i].active = false
  }
}

///|
fn clear_particles(ps : Array[Particle]) -> Unit {
  for i = 0; i < ps.length(); i = i + 1 {
    ps[i].x = 0.0
    ps[i].y = 0.0
    ps[i].vx = 0.0
    ps[i].vy = 0.0
    ps[i].ttl = 0.0
    ps[i].kind = 0
    ps[i].active = false
  }
}

///|
fn spawn_particle(ps : Array[Particle], x : Float, y : Float, speed : Float, kind : Int) -> Unit {
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
      ps[i].ttl = Float::from_int(@raylib.get_random_value(12, 60)) / Float::from_int(100)
      ps[i].kind = kind
      done = true
    }
  }
}

///|
fn burst(ps : Array[Particle], x : Float, y : Float, n : Int, speed : Float, kind : Int) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    spawn_particle(ps, x, y, speed, kind)
  }
}

///|
fn reset_player(p : Smuggler) -> Unit {
  p.x = 174.0
  p.y = 442.0
  p.vx = 0.0
  p.vy = 0.0
  p.hp = 6
  p.fuel = 100.0
  p.cargo = 0
  p.dash_t = 0.0
  p.stealth_t = 0.0
  p.hit_cd = 0.0
  p.flash_t = 0.0
  p.deliver_cd = 0.0
}

///|
fn spawn_patrol(ps : Array[Patrol], level : Int, wave_t : Float) -> Unit {
  let side = @raylib.get_random_value(0, 1)
  let y = Float::from_int(@raylib.get_random_value((water_top + 40.0).to_int(), (water_bottom - 40.0).to_int()))
  let kind = @raylib.get_random_value(0, 2)

  let mut done = false
  for i = 0; i < ps.length(); i = i + 1 {
    if done {
      continue
    }

    if not(ps[i].active) {
      ps[i].active = true
      ps[i].kind = kind
      ps[i].radius = if kind == 2 { 20.0 } else { 18.0 }
      ps[i].speed = Float::from_int(@raylib.get_random_value(86 + level * 14, 126 + level * 22))
      ps[i].alert_t = 0.0

      let jitter = Float::from_int(((wave_t * 100.0).to_int() % 60) - 30)
      if side == 0 {
        ps[i].x = -80.0 + jitter
        ps[i].vx = ps[i].speed
      } else {
        ps[i].x = Float::from_int(sw + 80) + jitter
        ps[i].vx = -ps[i].speed
      }
      ps[i].y = y
      ps[i].vy = Float::from_int(@raylib.get_random_value(-38, 38))
      done = true
    }
  }
}

///|
fn spawn_crate(cs : Array[Crate], level : Int, wave_t : Float) -> Unit {
  let lane = @raylib.get_random_value(0, 4)
  let y : Float = if lane == 0 {
    202.0
  } else if lane == 1 {
    302.0
  } else if lane == 2 {
    412.0
  } else if lane == 3 {
    530.0
  } else {
    648.0
  }

  let value = if level >= 3 && @raylib.get_random_value(0, 100) < 24 {
    3
  } else if @raylib.get_random_value(0, 100) < 48 {
    2
  } else {
    1
  }

  let mut done = false
  for i = 0; i < cs.length(); i = i + 1 {
    if done {
      continue
    }

    if not(cs[i].active) {
      let drift = Float::from_int(@raylib.get_random_value(-16, 16))
      cs[i].active = true
      cs[i].x = Float::from_int(@raylib.get_random_value(110, 920)) + drift
      cs[i].y = y + Float::from_int(((wave_t * 120.0).to_int() % 40) - 20)
      cs[i].vx = Float::from_int(@raylib.get_random_value(-18, 18))
      cs[i].vy = Float::from_int(@raylib.get_random_value(-10, 10))
      cs[i].value = value
      done = true
    }
  }
}

///|
fn setup_level(level : Int, player : Smuggler, patrols : Array[Patrol], crates : Array[Crate], particles : Array[Particle]) -> (Int, Float, Float, Float) {
  reset_player(player)
  clear_patrols(patrols)
  clear_crates(crates)
  clear_particles(particles)

  if level == 1 {
    (8, 118.0, 1.05, 0.48)
  } else if level == 2 {
    (12, 132.0, 0.84, 0.40)
  } else {
    (16, 146.0, 0.66, 0.34)
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Harbor Smuggler Run 2026")
  @raylib.set_target_fps(60)

  let player : Smuggler = {
    x: 174.0,
    y: 442.0,
    vx: 0.0,
    vy: 0.0,
    hp: 6,
    fuel: 100.0,
    cargo: 0,
    dash_t: 0.0,
    stealth_t: 0.0,
    hit_cd: 0.0,
    flash_t: 0.0,
    deliver_cd: 0.0,
  }

  let patrols : Array[Patrol] = Array::makei(max_patrol, fn(_i) {
    {
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      speed: 0.0,
      radius: 0.0,
      kind: 0,
      alert_t: 0.0,
      active: false,
    }
  })

  let crates : Array[Crate] = Array::makei(max_crates, fn(_i) {
    {
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      value: 0,
      active: false,
    }
  })

  let particles : Array[Particle] = Array::makei(max_particles, fn(_i) {
    {
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      ttl: 0.0,
      kind: 0,
      active: false,
    }
  })

  let mut level = 1
  let mut target = 0
  let mut timer : Float = 0.0
  let mut patrol_base_cd : Float = 0.0
  let mut crate_base_cd : Float = 0.0

  let (t, tm, pcd, ccd) = setup_level(level, player, patrols, crates, particles)
  target = t
  timer = tm
  patrol_base_cd = pcd
  crate_base_cd = ccd

  let mut delivered = 0
  let mut score = 0
  let mut stars = 0

  let mut patrol_cd : Float = 0.7
  let mut crate_cd : Float = 0.2

  let mut wave_t : Float = 0.0
  let mut transition_t : Float = 0.0
  let mut flash_t : Float = 0.0
  let mut shake_t : Float = 0.0

  let mut over = false
  let mut won = false

  let mut msg = "W/A/S/D steer, J boost, K stealth cloak"

  let pad_x = 16
  let pad_y = sh - 186
  let dash_x = sw - 250
  let dash_y = sh - 170
  let stealth_x = sw - 122
  let stealth_y = sh - 170

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    wave_t = wave_t + dt

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      let (rt, rtm, rpcd, rccd) = setup_level(level, player, patrols, crates, particles)
      target = rt
      timer = rtm
      patrol_base_cd = rpcd
      crate_base_cd = rccd

      delivered = 0
      score = 0
      stars = 0

      patrol_cd = 0.7
      crate_cd = 0.2

      transition_t = 0.0
      flash_t = 0.0
      shake_t = 0.0

      over = false
      won = false
      msg = "Night route reset"
    }

    if transition_t > 0.0 {
      transition_t = transition_t - dt
      if transition_t <= 0.0 {
        transition_t = 0.0
        if level < 3 {
          level = level + 1
          let (nt, ntm, npcd, nccd) = setup_level(level, player, patrols, crates, particles)
          target = nt
          timer = ntm
          patrol_base_cd = npcd
          crate_base_cd = nccd

          delivered = 0
          patrol_cd = 0.7
          crate_cd = 0.2
          msg = "Night \{level} starts"
        } else {
          over = true
          won = true
          msg = "Smuggling campaign complete"
        }
      }
    }

    if flash_t > 0.0 {
      flash_t = flash_t - dt
      if flash_t < 0.0 {
        flash_t = 0.0
      }
    }

    if shake_t > 0.0 {
      shake_t = shake_t - dt
      if shake_t < 0.0 {
        shake_t = 0.0
      }
    }

    if player.dash_t > 0.0 {
      player.dash_t = player.dash_t - dt
      if player.dash_t < 0.0 {
        player.dash_t = 0.0
      }
    }

    if player.stealth_t > 0.0 {
      player.stealth_t = player.stealth_t - dt
      if player.stealth_t < 0.0 {
        player.stealth_t = 0.0
      }
    }

    if player.hit_cd > 0.0 {
      player.hit_cd = player.hit_cd - dt
      if player.hit_cd < 0.0 {
        player.hit_cd = 0.0
      }
    }

    if player.flash_t > 0.0 {
      player.flash_t = player.flash_t - dt
      if player.flash_t < 0.0 {
        player.flash_t = 0.0
      }
    }

    if player.deliver_cd > 0.0 {
      player.deliver_cd = player.deliver_cd - dt
      if player.deliver_cd < 0.0 {
        player.deliver_cd = 0.0
      }
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      particles[i].x = particles[i].x + particles[i].vx * dt
      particles[i].y = particles[i].y + particles[i].vy * dt
      particles[i].vy = particles[i].vy + 220.0 * dt
      particles[i].ttl = particles[i].ttl - dt

      if particles[i].ttl <= 0.0 {
        particles[i].active = false
      }
    }

    if not(over) && transition_t <= 0.0 {
      timer = timer - dt
      if timer <= 0.0 {
        timer = 0.0
        over = true
        won = false
        msg = "Dawn arrived before quota"
      }

      let mut move_l = @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r = @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u = @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d = @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown)
      let mut dash = @raylib.is_key_pressed(@raylib.KeyJ) || @raylib.is_key_pressed(@raylib.KeySpace)
      let mut stealth = @raylib.is_key_pressed(@raylib.KeyK)

      let m = @raylib.get_mouse_position()

      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, pad_x + 76, pad_y, 72, 54) {
          move_u = true
        }
        if inside_rect(m.x, m.y, pad_x + 76, pad_y + 108, 72, 54) {
          move_d = true
        }
        if inside_rect(m.x, m.y, pad_x, pad_y + 54, 72, 54) {
          move_l = true
        }
        if inside_rect(m.x, m.y, pad_x + 152, pad_y + 54, 72, 54) {
          move_r = true
        }
      }

      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, dash_x, dash_y, 116, 154) {
          dash = true
        }
        if inside_rect(m.x, m.y, stealth_x, stealth_y, 104, 154) {
          stealth = true
        }
      }

      if dash && player.dash_t <= 0.0 && player.fuel >= 16.0 {
        player.dash_t = 0.22
        player.fuel = player.fuel - 16.0
        msg = "Turbo burst"
        burst(particles, player.x, player.y, 16, 0.34, 1)
      }

      if stealth && player.stealth_t <= 0.0 && player.fuel >= 22.0 {
        player.stealth_t = 2.4
        player.fuel = player.fuel - 22.0
        msg = "Stealth cloak online"
        burst(particles, player.x, player.y, 18, 0.36, 2)
      }

      let mut ax : Float = 0.0
      let mut ay : Float = 0.0

      if move_l {
        ax = ax - 440.0
      }
      if move_r {
        ax = ax + 440.0
      }
      if move_u {
        ay = ay - 440.0
      }
      if move_d {
        ay = ay + 440.0
      }

      if player.dash_t > 0.0 {
        ax = ax * 1.32
        ay = ay * 1.32
      }

      player.vx = player.vx + ax * dt
      player.vy = player.vy + ay * dt

      player.vx = player.vx * (Float::from_int(1) - dt * 2.2)
      player.vy = player.vy * (Float::from_int(1) - dt * 2.2)

      let max_speed : Float = if player.dash_t > 0.0 { 360.0 } else { 272.0 }
      player.vx = clampf(player.vx, -max_speed, max_speed)
      player.vy = clampf(player.vy, -max_speed, max_speed)

      player.x = player.x + player.vx * dt
      player.y = player.y + player.vy * dt

      player.x = clampf(player.x, 34.0, Float::from_int(sw - 34))
      player.y = clampf(player.y, water_top + 24.0, water_bottom - 24.0)

      player.fuel = player.fuel + 16.0 * dt
      if player.dash_t > 0.0 {
        player.fuel = player.fuel - 22.0 * dt
      }
      if player.stealth_t > 0.0 {
        player.fuel = player.fuel - 10.0 * dt
      }
      player.fuel = clampf(player.fuel, 0.0, 100.0)

      patrol_cd = patrol_cd - dt
      if patrol_cd <= 0.0 {
        spawn_patrol(patrols, level, wave_t)
        let jitter = Float::from_int(@raylib.get_random_value(80, 130)) / Float::from_int(100)
        patrol_cd = patrol_base_cd * jitter
      }

      crate_cd = crate_cd - dt
      if crate_cd <= 0.0 {
        spawn_crate(crates, level, wave_t)
        let jitter = Float::from_int(@raylib.get_random_value(72, 138)) / Float::from_int(100)
        crate_cd = crate_base_cd * jitter
      }

      for i = 0; i < crates.length(); i = i + 1 {
        if not(crates[i].active) {
          continue
        }

        crates[i].x = crates[i].x + crates[i].vx * dt
        crates[i].y = crates[i].y + crates[i].vy * dt

        if crates[i].x < 60.0 {
          crates[i].x = 60.0
          crates[i].vx = absf(crates[i].vx)
        }
        if crates[i].x > Float::from_int(sw - 220) {
          crates[i].x = Float::from_int(sw - 220)
          crates[i].vx = -absf(crates[i].vx)
        }
        if crates[i].y < water_top + 20.0 {
          crates[i].y = water_top + 20.0
          crates[i].vy = absf(crates[i].vy)
        }
        if crates[i].y > water_bottom - 20.0 {
          crates[i].y = water_bottom - 20.0
          crates[i].vy = -absf(crates[i].vy)
        }

        if player.cargo < 7 && sqdist(player.x, player.y, crates[i].x, crates[i].y) <= 42.0 * 42.0 {
          player.cargo = player.cargo + crates[i].value
          score = score + crates[i].value * 10
          msg = "Cargo loaded +\{crates[i].value}"
          burst(particles, crates[i].x, crates[i].y, 10, 0.26, 3)
          crates[i].active = false
        }
      }

      let delivery_zone = player.x >= 1110.0 && player.x <= Float::from_int(sw - 24) && player.y >= 188.0 && player.y <= 694.0

      if delivery_zone && player.cargo > 0 && player.deliver_cd <= 0.0 {
        delivered = delivered + player.cargo
        score = score + player.cargo * 58
        stars = stars + player.cargo
        msg = "Delivered \{player.cargo} crates"
        burst(particles, player.x, player.y, 22, 0.46, 1)
        player.cargo = 0
        player.deliver_cd = 0.45

        if delivered >= target {
          transition_t = 2.0
          msg = "Night quota complete"
        }
      }

      for i = 0; i < patrols.length(); i = i + 1 {
        if not(patrols[i].active) {
          continue
        }

        patrols[i].x = patrols[i].x + patrols[i].vx * dt
        patrols[i].y = patrols[i].y + patrols[i].vy * dt

        if patrols[i].x < 26.0 {
          patrols[i].x = 26.0
          patrols[i].vx = absf(patrols[i].vx)
        }
        if patrols[i].x > Float::from_int(sw - 26) {
          patrols[i].x = Float::from_int(sw - 26)
          patrols[i].vx = -absf(patrols[i].vx)
        }
        if patrols[i].y < water_top + 26.0 {
          patrols[i].y = water_top + 26.0
          patrols[i].vy = absf(patrols[i].vy)
        }
        if patrols[i].y > water_bottom - 26.0 {
          patrols[i].y = water_bottom - 26.0
          patrols[i].vy = -absf(patrols[i].vy)
        }

        if patrols[i].alert_t > 0.0 {
          patrols[i].alert_t = patrols[i].alert_t - dt
          if patrols[i].alert_t < 0.0 {
            patrols[i].alert_t = 0.0
          }
        }

        let mut detect_r = Float::from_int(160 + level * 24)
        if patrols[i].kind == 1 {
          detect_r = detect_r + 34.0
        }
        if player.stealth_t > 0.0 {
          detect_r = detect_r * 0.42
        }

        let d2 = sqdist(player.x, player.y, patrols[i].x, patrols[i].y)
        if d2 <= detect_r * detect_r {
          patrols[i].alert_t = 1.2

          let dx = player.x - patrols[i].x
          let dy = player.y - patrols[i].y
          let nd2 = dx * dx + dy * dy
          let nd : Float = if nd2 < 1.0 { 1.0 } else { nd2.sqrt() }

          let chase = patrols[i].speed * (if patrols[i].kind == 2 { 1.24 } else { 1.0 })
          patrols[i].vx = patrols[i].vx * (Float::from_int(1) - dt * 2.8) + dx / nd * chase * dt * 2.8
          patrols[i].vy = patrols[i].vy * (Float::from_int(1) - dt * 2.8) + dy / nd * chase * dt * 2.8
        } else {
          let drift_x = Float::from_int(@raylib.get_random_value(-36, 36)) * dt
          let drift_y = Float::from_int(@raylib.get_random_value(-36, 36)) * dt
          patrols[i].vx = patrols[i].vx + drift_x
          patrols[i].vy = patrols[i].vy + drift_y
        }

        let patrol_max = patrols[i].speed * 1.25
        patrols[i].vx = clampf(patrols[i].vx, -patrol_max, patrol_max)
        patrols[i].vy = clampf(patrols[i].vy, -patrol_max, patrol_max)

        let hit_r = patrols[i].radius + 18.0
        if d2 <= hit_r * hit_r {
          if player.dash_t > 0.0 && absf(player.vx) + absf(player.vy) > 220.0 {
            patrols[i].active = false
            score = score + 44
            msg = "Patrol disabled"
            burst(particles, patrols[i].x, patrols[i].y, 22, 0.54, 2)
          } else if player.hit_cd <= 0.0 {
            player.hp = player.hp - 1
            if player.cargo > 0 {
              player.cargo = player.cargo - 1
            }
            player.hit_cd = 1.05
            player.flash_t = 0.30
            flash_t = 0.24
            shake_t = 0.22
            msg = "Intercepted! HP -1"
            burst(particles, player.x, player.y, 24, 0.58, 0)

            if player.hp <= 0 {
              over = true
              won = false
              msg = "Boat destroyed"
            }
          }
        }
      }
    }

    let mut shake_x : Float = 0.0
    if shake_t > 0.0 {
      shake_x = Float::from_int(@raylib.get_random_value(-5, 5))
    }

    @raylib.begin_drawing()

    if flash_t > 0.0 {
      @raylib.clear_background(@raylib.Color::new(30, 18, 24, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(10, 14, 26, 255))
    }

    let pulse = (wave_t * 3.0).to_int() % 180
    let glow = if pulse < 90 { pulse } else { 180 - pulse }

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(14, 18 + glow / 10, 36 + glow / 4, 255))
    @raylib.draw_rectangle(0, 0, sw, 280, @raylib.Color::new(18, 28 + glow / 9, 58 + glow / 4, 255))

    for i = 0; i < 88; i = i + 1 {
      let x = ((i * 102 + (wave_t * 62.0).to_int()) % (sw + 200)) - 100
      let h = 120 + (i * 41 % 300)
      let w = 40 + (i * 13 % 76)
      let c = 20 + (i * 11 % 58)
      @raylib.draw_rectangle(x, sh - h, w, h, @raylib.Color::new(c, c + 10, c + 34, 255))
      if i % 2 == 0 {
        @raylib.draw_rectangle(x + 8, sh - h + 24, 8, h - 34, @raylib.Color::new(92, 210, 248, 190))
      }
      if i % 3 == 0 {
        @raylib.draw_rectangle(x + 24, sh - h + 36, 8, h - 46, @raylib.Color::new(248, 146, 226, 184))
      }
    }

    @raylib.draw_rectangle(0, water_top.to_int(), sw, (water_bottom - water_top).to_int(), @raylib.Color::new(26, 74, 112, 255))
    @raylib.draw_rectangle(0, water_top.to_int(), sw, 44, @raylib.Color::new(36, 108, 154, 255))

    let wave_shift = (wave_t * 120.0).to_int()
    for i = 0; i < 44; i = i + 1 {
      let y = (water_top + 16.0 + Float::from_int(i * 14)).to_int()
      let phase = (i * 41 + wave_shift) % 90
      let alpha = 24 + phase
      @raylib.draw_line(0, y, sw, y, @raylib.Color::new(120, 190, 228, alpha))
    }

    @raylib.draw_rectangle(0, 172, 106, 522, @raylib.Color::new(98, 102, 114, 255))
    @raylib.draw_rectangle(0, 196, 86, 84, @raylib.Color::new(138, 132, 118, 255))
    @raylib.draw_rectangle(0, 304, 86, 84, @raylib.Color::new(138, 132, 118, 255))
    @raylib.draw_rectangle(0, 412, 86, 84, @raylib.Color::new(138, 132, 118, 255))
    @raylib.draw_rectangle(0, 520, 86, 84, @raylib.Color::new(138, 132, 118, 255))
    @raylib.draw_rectangle(0, 628, 86, 84, @raylib.Color::new(138, 132, 118, 255))

    let zone_col = if player.cargo > 0 {
      @raylib.Color::new(126, 220, 146, 170)
    } else {
      @raylib.Color::new(108, 138, 164, 110)
    }
    @raylib.draw_rectangle(1110, 188, 160, 506, zone_col)
    @raylib.draw_text("DROP", 1138, 156, 34, @raylib.Color::new(224, 246, 234, 255))

    for i = 0; i < crates.length(); i = i + 1 {
      if not(crates[i].active) {
        continue
      }

      let cx = (crates[i].x + shake_x).to_int()
      let cy = crates[i].y.to_int()

      @raylib.draw_rectangle(cx - 14, cy - 12, 28, 24, @raylib.Color::new(160, 112, 72, 255))
      @raylib.draw_rectangle(cx - 10, cy - 8, 20, 16, @raylib.Color::new(190, 146, 94, 255))
      @raylib.draw_text("\{crates[i].value}", cx - 5, cy - 10, 18, @raylib.Color::new(248, 232, 186, 255))
    }

    for i = 0; i < patrols.length(); i = i + 1 {
      if not(patrols[i].active) {
        continue
      }

      let px = (patrols[i].x + shake_x).to_int()
      let py = patrols[i].y.to_int()
      let hull_col = if patrols[i].kind == 2 {
        @raylib.Color::new(248, 104, 102, 255)
      } else if patrols[i].kind == 1 {
        @raylib.Color::new(236, 124, 98, 255)
      } else {
        @raylib.Color::new(220, 92, 82, 255)
      }

      @raylib.draw_triangle(
        @raylib.Vector2::new(patrols[i].x + 22.0 + shake_x, patrols[i].y),
        @raylib.Vector2::new(patrols[i].x - 20.0 + shake_x, patrols[i].y - 14.0),
        @raylib.Vector2::new(patrols[i].x - 20.0 + shake_x, patrols[i].y + 14.0),
        hull_col,
      )
      @raylib.draw_rectangle(px - 10, py - 8, 16, 16, @raylib.Color::new(238, 206, 182, 255))

      if patrols[i].alert_t > 0.0 {
        let ring = Float::from_int(130 + patrols[i].kind * 20)
        @raylib.draw_circle_lines(px, py, ring, @raylib.Color::new(252, 152, 142, 140))
      }
    }

    let boat_col = if player.flash_t > 0.0 {
      @raylib.Color::new(252, 238, 142, 255)
    } else {
      @raylib.Color::new(106, 228, 244, 255)
    }

    @raylib.draw_triangle(
      @raylib.Vector2::new(player.x + 26.0 + shake_x, player.y),
      @raylib.Vector2::new(player.x - 22.0 + shake_x, player.y - 16.0),
      @raylib.Vector2::new(player.x - 22.0 + shake_x, player.y + 16.0),
      boat_col,
    )
    @raylib.draw_rectangle((player.x - 12.0 + shake_x).to_int(), (player.y - 8.0).to_int(), 18, 16, @raylib.Color::new(198, 248, 254, 255))

    if player.dash_t > 0.0 {
      @raylib.draw_line((player.x - 46.0 + shake_x).to_int(), (player.y - 10.0).to_int(), (player.x - 18.0 + shake_x).to_int(), (player.y - 10.0).to_int(), @raylib.Color::new(248, 226, 124, 255))
      @raylib.draw_line((player.x - 56.0 + shake_x).to_int(), player.y.to_int(), (player.x - 28.0 + shake_x).to_int(), player.y.to_int(), @raylib.Color::new(248, 226, 124, 255))
      @raylib.draw_line((player.x - 46.0 + shake_x).to_int(), (player.y + 10.0).to_int(), (player.x - 18.0 + shake_x).to_int(), (player.y + 10.0).to_int(), @raylib.Color::new(248, 226, 124, 255))
    }

    if player.stealth_t > 0.0 {
      let a = 110 + ((player.stealth_t * 40.0).to_int() % 100)
      @raylib.draw_circle_lines((player.x + shake_x).to_int(), player.y.to_int(), 34.0, @raylib.Color::new(182, 132, 252, a))
      @raylib.draw_circle_lines((player.x + shake_x).to_int(), player.y.to_int(), 46.0, @raylib.Color::new(146, 94, 236, a / 2))
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let c = if particles[i].kind == 0 {
        @raylib.Color::new(254, 124, 126, 255)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 228, 126, 255)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(238, 156, 254, 255)
      } else {
        @raylib.Color::new(118, 226, 246, 255)
      }
      @raylib.draw_circle((particles[i].x + shake_x).to_int(), particles[i].y.to_int(), 2.0, c)
    }

    @raylib.draw_rectangle(0, 0, sw, 112, @raylib.Color::new(6, 10, 18, 232))
    @raylib.draw_text("HARBOR SMUGGLER RUN 2026", 16, 16, 34, @raylib.Color::new(236, 246, 255, 255))

    @raylib.draw_text("Night \{level}/3", 440, 22, 30, @raylib.Color::new(250, 226, 142, 255))
    @raylib.draw_text("Delivered \{delivered}/\{target}", 620, 22, 30, @raylib.Color::new(214, 236, 252, 255))
    @raylib.draw_text("Score \{score}", 948, 22, 30, @raylib.Color::new(214, 236, 252, 255))

    @raylib.draw_text("HP \{player.hp}", 20, 74, 24, @raylib.Color::new(220, 236, 252, 255))
    @raylib.draw_text("Fuel \{player.fuel.to_int()}%", 132, 74, 24, @raylib.Color::new(220, 236, 252, 255))
    @raylib.draw_text("Cargo \{player.cargo}", 330, 74, 24, @raylib.Color::new(220, 236, 252, 255))
    @raylib.draw_text("Timer \{timer.to_int()}", 510, 74, 24, @raylib.Color::new(252, 222, 150, 255))
    @raylib.draw_text("Stars \{stars}", 694, 74, 24, @raylib.Color::new(252, 232, 132, 255))

    @raylib.draw_text(
      if player.stealth_t > 0.0 { "Stealth ON" } else { "Stealth OFF" },
      862,
      74,
      24,
      if player.stealth_t > 0.0 { @raylib.Color::new(196, 156, 252, 255) } else { @raylib.Color::new(138, 150, 170, 255) },
    )

    @raylib.draw_rectangle(20, 102, 170, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(20, 102, (Float::from_int(player.hp) / 6.0 * 170.0).to_int(), 8, @raylib.Color::new(108, 220, 142, 255))

    @raylib.draw_rectangle(202, 102, 210, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(202, 102, (player.fuel / 100.0 * 210.0).to_int(), 8, @raylib.Color::new(96, 198, 246, 255))

    let progress = clampf(Float::from_int(delivered) / Float::from_int(target), 0.0, 1.0)
    @raylib.draw_rectangle(430, 102, 220, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(430, 102, (progress * 220.0).to_int(), 8, @raylib.Color::new(242, 188, 98, 255))

    @raylib.draw_rectangle(8, sh - 194, 236, 186, @raylib.Color::new(8, 14, 28, 220))
    @raylib.draw_text("Touch", 90, sh - 186, 20, @raylib.white)
    @raylib.draw_rectangle(pad_x + 76, pad_y, 72, 54, @raylib.Color::new(54, 72, 102, 255))
    @raylib.draw_text("UP", pad_x + 92, pad_y + 16, 24, @raylib.white)
    @raylib.draw_rectangle(pad_x, pad_y + 54, 72, 54, @raylib.Color::new(54, 72, 102, 255))
    @raylib.draw_text("LT", pad_x + 20, pad_y + 70, 24, @raylib.white)
    @raylib.draw_rectangle(pad_x + 152, pad_y + 54, 72, 54, @raylib.Color::new(54, 72, 102, 255))
    @raylib.draw_text("RT", pad_x + 172, pad_y + 70, 24, @raylib.white)
    @raylib.draw_rectangle(pad_x + 76, pad_y + 108, 72, 54, @raylib.Color::new(54, 72, 102, 255))
    @raylib.draw_text("DN", pad_x + 90, pad_y + 124, 24, @raylib.white)

    @raylib.draw_rectangle(dash_x, dash_y, 116, 154, @raylib.Color::new(214, 110, 82, 255))
    @raylib.draw_text("BOOST", dash_x + 8, dash_y + 58, 28, @raylib.white)
    @raylib.draw_rectangle(stealth_x, stealth_y, 104, 154, @raylib.Color::new(98, 156, 218, 255))
    @raylib.draw_text("STEALTH", stealth_x + 6, stealth_y + 58, 22, @raylib.white)

    @raylib.draw_rectangle(250, sh - 58, sw - 516, 42, @raylib.Color::new(6, 10, 18, 220))
    @raylib.draw_text(msg, 262, sh - 50, 24, @raylib.Color::new(224, 236, 248, 255))

    if transition_t > 0.0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 112))
      @raylib.draw_text("NIGHT CLEAR", sw / 2 - 162, sh / 2 - 28, 56, @raylib.Color::new(250, 236, 146, 255))
    }

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 132))
      @raylib.draw_rectangle(sw / 2 - 360, sh / 2 - 112, 720, 224, @raylib.Color::new(16, 24, 42, 244))
      @raylib.draw_text(
        if won { "OPERATION SUCCESS" } else { "OPERATION FAILED" },
        sw / 2 - 270,
        sh / 2 - 32,
        64,
        if won { @raylib.Color::new(252, 238, 148, 255) } else { @raylib.Color::new(252, 140, 140, 255) },
      )
      @raylib.draw_text("Press R to restart", sw / 2 - 124, sh / 2 + 48, 34, @raylib.Color::new(224, 238, 252, 255))
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
