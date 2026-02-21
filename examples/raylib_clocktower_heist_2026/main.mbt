///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let max_guards : Int = 28

///|
let max_keycards : Int = 24

///|
let max_bullets : Int = 320

///|
let max_particles : Int = 640

///|
struct Thief {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut fx : Float
  mut fy : Float
  mut hp : Int
  mut stamina : Float
  mut pulse_cd : Float
  mut cloak_t : Float
  mut hit_cd : Float
  mut flash_t : Float
}

///|
struct Guard {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ax : Float
  mut ay : Float
  mut bx : Float
  mut by : Float
  mut to_b : Bool
  mut speed : Float
  mut detect_r : Float
  mut shoot_cd : Float
  mut stun_t : Float
  mut alert_t : Float
  mut active : Bool
}

///|
struct Keycard {
  mut x : Float
  mut y : Float
  mut kind : Int
  mut active : Bool
}

///|
struct Bullet {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut owner : Int
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
fn circle_hits_rect(cx : Float, cy : Float, cr : Float, rx : Float, ry : Float, rw : Float, rh : Float) -> Bool {
  let nx = clampf(cx, rx, rx + rw)
  let ny = clampf(cy, ry, ry + rh)
  sqdist(cx, cy, nx, ny) <= cr * cr
}

///|
fn blocked(level : Int, x : Float, y : Float, r : Float) -> Bool {
  if x - r < 24.0 || x + r > Float::from_int(sw - 24) || y - r < 132.0 || y + r > Float::from_int(sh - 24) {
    return true
  }

  if circle_hits_rect(x, y, r, 252.0, 148.0, 40.0, 470.0) {
    return true
  }
  if circle_hits_rect(x, y, r, 252.0, 148.0, 496.0, 40.0) {
    return true
  }
  if circle_hits_rect(x, y, r, 546.0, 148.0, 42.0, 380.0) {
    return true
  }
  if circle_hits_rect(x, y, r, 588.0, 490.0, 402.0, 42.0) {
    return true
  }
  if circle_hits_rect(x, y, r, 960.0, 148.0, 40.0, 280.0) {
    return true
  }
  if circle_hits_rect(x, y, r, 790.0, 314.0, 180.0, 38.0) {
    return true
  }

  if level >= 2 && circle_hits_rect(x, y, r, 118.0, 326.0, 122.0, 170.0) {
    return true
  }

  if level >= 3 && circle_hits_rect(x, y, r, 702.0, 556.0, 178.0, 114.0) {
    return true
  }

  false
}

///|
fn clear_guards(gs : Array[Guard]) -> Unit {
  for i = 0; i < gs.length(); i = i + 1 {
    gs[i].x = 0.0
    gs[i].y = 0.0
    gs[i].vx = 0.0
    gs[i].vy = 0.0
    gs[i].ax = 0.0
    gs[i].ay = 0.0
    gs[i].bx = 0.0
    gs[i].by = 0.0
    gs[i].to_b = true
    gs[i].speed = 0.0
    gs[i].detect_r = 0.0
    gs[i].shoot_cd = 0.0
    gs[i].stun_t = 0.0
    gs[i].alert_t = 0.0
    gs[i].active = false
  }
}

///|
fn clear_keycards(cards : Array[Keycard]) -> Unit {
  for i = 0; i < cards.length(); i = i + 1 {
    cards[i].x = 0.0
    cards[i].y = 0.0
    cards[i].kind = 0
    cards[i].active = false
  }
}

///|
fn clear_bullets(bs : Array[Bullet]) -> Unit {
  for i = 0; i < bs.length(); i = i + 1 {
    bs[i].x = 0.0
    bs[i].y = 0.0
    bs[i].vx = 0.0
    bs[i].vy = 0.0
    bs[i].ttl = 0.0
    bs[i].owner = 0
    bs[i].active = false
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
      ps[i].ttl = Float::from_int(@raylib.get_random_value(10, 58)) / Float::from_int(100)
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
fn spawn_bullet(bs : Array[Bullet], x : Float, y : Float, dx : Float, dy : Float, owner : Int, speed : Float) -> Unit {
  let d2 = dx * dx + dy * dy
  if d2 <= 0.0001 {
    return
  }
  let d : Float = d2.sqrt()

  let mut done = false
  for i = 0; i < bs.length(); i = i + 1 {
    if done {
      continue
    }
    if not(bs[i].active) {
      bs[i].active = true
      bs[i].owner = owner
      bs[i].x = x
      bs[i].y = y
      bs[i].vx = dx / d * speed
      bs[i].vy = dy / d * speed
      bs[i].ttl = 1.6
      done = true
    }
  }
}

///|
fn reset_player(p : Thief) -> Unit {
  p.x = 84.0
  p.y = 734.0
  p.vx = 0.0
  p.vy = 0.0
  p.fx = 1.0
  p.fy = 0.0
  p.hp = 6
  p.stamina = 100.0
  p.pulse_cd = 0.0
  p.cloak_t = 0.0
  p.hit_cd = 0.0
  p.flash_t = 0.0
}

///|
fn set_keycard(cards : Array[Keycard], idx : Int, x : Float, y : Float, kind : Int) -> Unit {
  cards[idx].x = x
  cards[idx].y = y
  cards[idx].kind = kind
  cards[idx].active = true
}

///|
fn init_keycards(level : Int, cards : Array[Keycard]) -> Int {
  clear_keycards(cards)

  set_keycard(cards, 0, 136.0, 190.0, 0)
  set_keycard(cards, 1, 200.0, 286.0, 1)
  set_keycard(cards, 2, 360.0, 250.0, 2)
  set_keycard(cards, 3, 462.0, 190.0, 0)
  set_keycard(cards, 4, 418.0, 378.0, 1)
  set_keycard(cards, 5, 690.0, 208.0, 2)
  set_keycard(cards, 6, 842.0, 250.0, 0)
  set_keycard(cards, 7, 910.0, 520.0, 1)
  set_keycard(cards, 8, 1110.0, 238.0, 2)
  set_keycard(cards, 9, 1092.0, 664.0, 0)
  set_keycard(cards, 10, 682.0, 654.0, 1)
  set_keycard(cards, 11, 420.0, 726.0, 2)
  set_keycard(cards, 12, 192.0, 690.0, 0)

  if level >= 2 {
    set_keycard(cards, 13, 138.0, 364.0, 1)
    set_keycard(cards, 14, 208.0, 476.0, 2)
    set_keycard(cards, 15, 828.0, 420.0, 0)
    set_keycard(cards, 16, 934.0, 182.0, 1)
    set_keycard(cards, 17, 1018.0, 350.0, 2)
  }

  if level >= 3 {
    set_keycard(cards, 18, 736.0, 594.0, 0)
    set_keycard(cards, 19, 842.0, 640.0, 1)
    set_keycard(cards, 20, 948.0, 706.0, 2)
    set_keycard(cards, 21, 590.0, 570.0, 0)
    set_keycard(cards, 22, 324.0, 176.0, 1)
  }

  if level == 1 {
    8
  } else if level == 2 {
    12
  } else {
    16
  }
}

///|
fn set_guard(gs : Array[Guard], i : Int, ax : Float, ay : Float, bx : Float, by : Float, speed : Float, detect_r : Float) -> Unit {
  gs[i].active = true
  gs[i].x = ax
  gs[i].y = ay
  gs[i].vx = 0.0
  gs[i].vy = 0.0
  gs[i].ax = ax
  gs[i].ay = ay
  gs[i].bx = bx
  gs[i].by = by
  gs[i].to_b = true
  gs[i].speed = speed
  gs[i].detect_r = detect_r
  gs[i].shoot_cd = Float::from_int(@raylib.get_random_value(48, 120)) / Float::from_int(100)
  gs[i].stun_t = 0.0
  gs[i].alert_t = 0.0
}

///|
fn init_guards(level : Int, gs : Array[Guard]) -> Unit {
  clear_guards(gs)

  set_guard(gs, 0, 156.0, 210.0, 224.0, 286.0, 108.0, 250.0)
  set_guard(gs, 1, 374.0, 214.0, 498.0, 214.0, 102.0, 250.0)
  set_guard(gs, 2, 434.0, 360.0, 434.0, 556.0, 96.0, 240.0)
  set_guard(gs, 3, 650.0, 210.0, 740.0, 286.0, 112.0, 250.0)
  set_guard(gs, 4, 826.0, 248.0, 922.0, 248.0, 106.0, 248.0)
  set_guard(gs, 5, 1020.0, 214.0, 1112.0, 300.0, 112.0, 250.0)
  set_guard(gs, 6, 664.0, 704.0, 838.0, 704.0, 102.0, 250.0)
  set_guard(gs, 7, 240.0, 704.0, 448.0, 704.0, 98.0, 238.0)

  if level >= 2 {
    set_guard(gs, 8, 158.0, 352.0, 206.0, 474.0, 106.0, 250.0)
    set_guard(gs, 9, 942.0, 356.0, 942.0, 500.0, 104.0, 250.0)
    set_guard(gs, 10, 618.0, 356.0, 736.0, 356.0, 102.0, 245.0)
    set_guard(gs, 11, 1098.0, 636.0, 934.0, 636.0, 110.0, 252.0)
  }

  if level >= 3 {
    set_guard(gs, 12, 742.0, 586.0, 860.0, 648.0, 116.0, 260.0)
    set_guard(gs, 13, 562.0, 584.0, 632.0, 642.0, 116.0, 260.0)
    set_guard(gs, 14, 330.0, 182.0, 512.0, 182.0, 118.0, 262.0)
    set_guard(gs, 15, 1064.0, 204.0, 1064.0, 334.0, 116.0, 258.0)
  }
}

///|
fn setup_level(level : Int, player : Thief, guards : Array[Guard], cards : Array[Keycard], bullets : Array[Bullet], particles : Array[Particle]) -> (Int, Float) {
  reset_player(player)
  init_guards(level, guards)
  clear_bullets(bullets)
  clear_particles(particles)

  let target = init_keycards(level, cards)

  if level == 1 {
    (target, 138.0)
  } else if level == 2 {
    (target, 152.0)
  } else {
    (target, 166.0)
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Clocktower Heist 2026")
  @raylib.set_target_fps(60)

  let player : Thief = {
    x: 84.0,
    y: 734.0,
    vx: 0.0,
    vy: 0.0,
    fx: 1.0,
    fy: 0.0,
    hp: 6,
    stamina: 100.0,
    pulse_cd: 0.0,
    cloak_t: 0.0,
    hit_cd: 0.0,
    flash_t: 0.0,
  }

  let guards : Array[Guard] = Array::makei(max_guards, fn(_i) {
    {
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      ax: 0.0,
      ay: 0.0,
      bx: 0.0,
      by: 0.0,
      to_b: true,
      speed: 0.0,
      detect_r: 0.0,
      shoot_cd: 0.0,
      stun_t: 0.0,
      alert_t: 0.0,
      active: false,
    }
  })

  let cards : Array[Keycard] = Array::makei(max_keycards, fn(_i) {
    {
      x: 0.0,
      y: 0.0,
      kind: 0,
      active: false,
    }
  })

  let bullets : Array[Bullet] = Array::makei(max_bullets, fn(_i) {
    {
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      ttl: 0.0,
      owner: 0,
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
  let mut target_cards = 0
  let mut timer : Float = 0.0

  let (t, tm) = setup_level(level, player, guards, cards, bullets, particles)
  target_cards = t
  timer = tm

  let mut collected = 0
  let mut score = 0
  let mut stars = 0

  let mut hack_progress : Float = 0.0
  let mut vault_open = false

  let mut wave_t : Float = 0.0
  let mut transition_t : Float = 0.0
  let mut flash_t : Float = 0.0
  let mut shake_t : Float = 0.0

  let mut over = false
  let mut won = false
  let mut msg = "WASD move, J sprint, K pulse, L cloak"

  let pad_x = 16
  let pad_y = sh - 186
  let sprint_x = sw - 332
  let sprint_y = sh - 170
  let pulse_x = sw - 216
  let pulse_y = sh - 170
  let cloak_x = sw - 104
  let cloak_y = sh - 170

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    wave_t = wave_t + dt

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      let (rt, rtm) = setup_level(level, player, guards, cards, bullets, particles)
      target_cards = rt
      timer = rtm

      collected = 0
      score = 0
      stars = 0

      hack_progress = 0.0
      vault_open = false

      transition_t = 0.0
      flash_t = 0.0
      shake_t = 0.0

      over = false
      won = false
      msg = "Heist reset"
    }

    if transition_t > 0.0 {
      transition_t = transition_t - dt
      if transition_t <= 0.0 {
        transition_t = 0.0
        if level < 3 {
          level = level + 1
          let (nt, ntm) = setup_level(level, player, guards, cards, bullets, particles)
          target_cards = nt
          timer = ntm
          collected = 0
          hack_progress = 0.0
          vault_open = false
          msg = "Floor \{level} infiltrated"
        } else {
          over = true
          won = true
          msg = "Grand heist complete"
        }
      }
    }

    if player.pulse_cd > 0.0 {
      player.pulse_cd = player.pulse_cd - dt
      if player.pulse_cd < 0.0 {
        player.pulse_cd = 0.0
      }
    }

    if player.cloak_t > 0.0 {
      player.cloak_t = player.cloak_t - dt
      if player.cloak_t < 0.0 {
        player.cloak_t = 0.0
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
        msg = "Clock hit zero"
      }

      let mut move_l = @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r = @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u = @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d = @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown)
      let mut sprint = @raylib.is_key_down(@raylib.KeyJ) || @raylib.is_key_down(@raylib.KeyLeftShift)
      let mut pulse = @raylib.is_key_pressed(@raylib.KeyK)
      let mut cloak = @raylib.is_key_pressed(@raylib.KeyL)

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
        if inside_rect(m.x, m.y, sprint_x, sprint_y, 104, 154) {
          sprint = true
        }
      }

      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, pulse_x, pulse_y, 104, 154) {
          pulse = true
        }
        if inside_rect(m.x, m.y, cloak_x, cloak_y, 94, 154) {
          cloak = true
        }
      }

      let mut ax : Float = 0.0
      let mut ay : Float = 0.0

      if move_l {
        ax = ax - 460.0
      }
      if move_r {
        ax = ax + 460.0
      }
      if move_u {
        ay = ay - 460.0
      }
      if move_d {
        ay = ay + 460.0
      }

      if ax != 0.0 || ay != 0.0 {
        let d2 = ax * ax + ay * ay
        let d : Float = if d2 < 1.0 { 1.0 } else { d2.sqrt() }
        player.fx = ax / d
        player.fy = ay / d
      }

      let sprint_on = sprint && player.stamina > 6.0
      if sprint_on {
        ax = ax * 1.30
        ay = ay * 1.30
      }

      player.vx = player.vx + ax * dt
      player.vy = player.vy + ay * dt

      player.vx = player.vx * (Float::from_int(1) - dt * 2.5)
      player.vy = player.vy * (Float::from_int(1) - dt * 2.5)

      let max_speed : Float = if sprint_on { 344.0 } else { 254.0 }
      player.vx = clampf(player.vx, -max_speed, max_speed)
      player.vy = clampf(player.vy, -max_speed, max_speed)

      let old_x = player.x
      let old_y = player.y
      player.x = player.x + player.vx * dt
      player.y = player.y + player.vy * dt

      if blocked(level, player.x, player.y, 16.0) {
        player.x = old_x
        player.y = old_y
        player.vx = player.vx * 0.2
        player.vy = player.vy * 0.2
      }

      if cloak && player.cloak_t <= 0.0 && player.stamina >= 28.0 {
        player.cloak_t = 2.6
        player.stamina = player.stamina - 28.0
        msg = "Cloak engaged"
        burst(particles, player.x, player.y, 18, 0.38, 2)
      }

      if pulse && player.pulse_cd <= 0.0 && player.stamina >= 24.0 {
        player.pulse_cd = 2.6
        player.stamina = player.stamina - 24.0
        msg = "EMP pulse"
        burst(particles, player.x, player.y, 24, 0.54, 3)

        for i = 0; i < guards.length(); i = i + 1 {
          if not(guards[i].active) {
            continue
          }
          if sqdist(player.x, player.y, guards[i].x, guards[i].y) <= 178.0 * 178.0 {
            guards[i].stun_t = Float::from_int(@raylib.get_random_value(160, 250)) / Float::from_int(100)
            guards[i].alert_t = 0.0
            burst(particles, guards[i].x, guards[i].y, 10, 0.30, 1)
          }
        }
      }

      player.stamina = player.stamina + 20.0 * dt
      if sprint_on {
        player.stamina = player.stamina - 22.0 * dt
      }
      if player.cloak_t > 0.0 {
        player.stamina = player.stamina - 8.0 * dt
      }
      player.stamina = clampf(player.stamina, 0.0, 100.0)

      for i = 0; i < guards.length(); i = i + 1 {
        if not(guards[i].active) {
          continue
        }

        if guards[i].shoot_cd > 0.0 {
          guards[i].shoot_cd = guards[i].shoot_cd - dt
          if guards[i].shoot_cd < 0.0 {
            guards[i].shoot_cd = 0.0
          }
        }

        if guards[i].stun_t > 0.0 {
          guards[i].stun_t = guards[i].stun_t - dt
          if guards[i].stun_t < 0.0 {
            guards[i].stun_t = 0.0
          }
        }

        if guards[i].alert_t > 0.0 {
          guards[i].alert_t = guards[i].alert_t - dt
          if guards[i].alert_t < 0.0 {
            guards[i].alert_t = 0.0
          }
        }

        let dx = player.x - guards[i].x
        let dy = player.y - guards[i].y
        let d2 = dx * dx + dy * dy
        let d : Float = if d2 < 1.0 { 1.0 } else { d2.sqrt() }

        let detect_r = if player.cloak_t > 0.0 { guards[i].detect_r * 0.46 } else { guards[i].detect_r }

        let mut target_x = if guards[i].to_b { guards[i].bx } else { guards[i].ax }
        let mut target_y = if guards[i].to_b { guards[i].by } else { guards[i].ay }
        let mut chase = false

        if d <= detect_r && guards[i].stun_t <= 0.0 {
          let vel2 = guards[i].vx * guards[i].vx + guards[i].vy * guards[i].vy
          let invl : Float = if vel2 < 1.0 { 0.0 } else { 1.0 / vel2.sqrt() }
          let fx : Float = if invl == 0.0 { Float::from_int(1) } else { guards[i].vx * invl }
          let fy : Float = if invl == 0.0 { Float::from_int(0) } else { guards[i].vy * invl }
          let dot : Float = (dx / d) * fx + (dy / d) * fy

          if dot >= 0.12 || guards[i].alert_t > 0.0 {
            target_x = player.x
            target_y = player.y
            guards[i].alert_t = 1.1
            chase = true
          }
        }

        let dir_x = target_x - guards[i].x
        let dir_y = target_y - guards[i].y
        let dir2 = dir_x * dir_x + dir_y * dir_y
        let dir_d : Float = if dir2 < 1.0 { 1.0 } else { dir2.sqrt() }

        if guards[i].stun_t > 0.0 {
          guards[i].vx = guards[i].vx * (Float::from_int(1) - dt * 4.2)
          guards[i].vy = guards[i].vy * (Float::from_int(1) - dt * 4.2)
        } else {
          let speed = if chase { guards[i].speed * 1.22 } else { guards[i].speed }
          let tx = dir_x / dir_d * speed
          let ty = dir_y / dir_d * speed
          guards[i].vx = guards[i].vx * (Float::from_int(1) - dt * 3.0) + tx * dt * 3.0
          guards[i].vy = guards[i].vy * (Float::from_int(1) - dt * 3.0) + ty * dt * 3.0
        }

        if not(chase) && dir_d < 20.0 {
          guards[i].to_b = not(guards[i].to_b)
        }

        let old_x = guards[i].x
        let old_y = guards[i].y
        guards[i].x = guards[i].x + guards[i].vx * dt
        guards[i].y = guards[i].y + guards[i].vy * dt

        if blocked(level, guards[i].x, guards[i].y, 16.0) {
          guards[i].x = old_x
          guards[i].y = old_y
          guards[i].vx = -guards[i].vx * 0.5
          guards[i].vy = -guards[i].vy * 0.5
          guards[i].to_b = not(guards[i].to_b)
        }

        if guards[i].shoot_cd <= 0.0 && guards[i].stun_t <= 0.0 && d <= 360.0 {
          spawn_bullet(
            bullets,
            guards[i].x,
            guards[i].y - 8.0,
            player.x - guards[i].x,
            player.y - guards[i].y,
            2,
            Float::from_int(430 + level * 36),
          )
          guards[i].shoot_cd = Float::from_int(@raylib.get_random_value(86, 152)) / Float::from_int(100)
        }

        if sqdist(player.x, player.y, guards[i].x, guards[i].y) <= 30.0 * 30.0 && player.hit_cd <= 0.0 && guards[i].stun_t <= 0.0 {
          player.hp = player.hp - 1
          player.hit_cd = 1.0
          player.flash_t = 0.30
          flash_t = 0.28
          shake_t = 0.22
          msg = "Caught by guard"
          burst(particles, player.x, player.y, 22, 0.58, 0)
          if player.hp <= 0 {
            over = true
            won = false
            msg = "Heist failed"
          }
        }
      }

      for i = 0; i < bullets.length(); i = i + 1 {
        if not(bullets[i].active) {
          continue
        }

        bullets[i].x = bullets[i].x + bullets[i].vx * dt
        bullets[i].y = bullets[i].y + bullets[i].vy * dt
        bullets[i].ttl = bullets[i].ttl - dt

        if bullets[i].ttl <= 0.0 || bullets[i].x < -40.0 || bullets[i].x > Float::from_int(sw + 40) || bullets[i].y < 110.0 || bullets[i].y > Float::from_int(sh + 40) {
          bullets[i].active = false
          continue
        }

        if blocked(level, bullets[i].x, bullets[i].y, 3.0) {
          bullets[i].active = false
          burst(particles, bullets[i].x, bullets[i].y, 5, 0.16, 2)
          continue
        }

        if bullets[i].owner == 2 && sqdist(bullets[i].x, bullets[i].y, player.x, player.y - 8.0) <= 18.0 * 18.0 {
          bullets[i].active = false
          if player.hit_cd <= 0.0 {
            player.hp = player.hp - 1
            player.hit_cd = 1.0
            player.flash_t = 0.30
            flash_t = 0.28
            shake_t = 0.22
            msg = "Hit by dart"
            burst(particles, player.x, player.y, 20, 0.54, 0)
            if player.hp <= 0 {
              over = true
              won = false
              msg = "Heist failed"
            }
          }
        }
      }

      for i = 0; i < cards.length(); i = i + 1 {
        if not(cards[i].active) {
          continue
        }

        if sqdist(player.x, player.y, cards[i].x, cards[i].y) <= 24.0 * 24.0 {
          cards[i].active = false
          collected = collected + 1
          score = score + 88 + cards[i].kind * 14
          stars = stars + 1 + cards[i].kind
          msg = "Keycard acquired"
          burst(particles, cards[i].x, cards[i].y, 14, 0.30, 1)
        }
      }

      if collected >= target_cards && not(vault_open) {
        if inside_rect(player.x, player.y, 986, 186, 218, 162) {
          hack_progress = hack_progress + dt * 34.0
          if hack_progress >= 100.0 {
            hack_progress = 100.0
            vault_open = true
            score = score + 320
            stars = stars + 4
            msg = "Vault unlocked"
            burst(particles, 1094.0, 262.0, 28, 0.56, 3)
          }
        } else {
          hack_progress = hack_progress - dt * 12.0
          if hack_progress < 0.0 {
            hack_progress = 0.0
          }
        }
      }

      if vault_open && inside_rect(player.x, player.y, 36, 654, 160, 130) {
        transition_t = 2.1
        msg = "Extraction complete"
      }
    }

    let mut shake_x : Float = 0.0
    if shake_t > 0.0 {
      shake_x = Float::from_int(@raylib.get_random_value(-5, 5))
    }

    @raylib.begin_drawing()

    if flash_t > 0.0 {
      @raylib.clear_background(@raylib.Color::new(30, 18, 28, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(10, 14, 24, 255))
    }

    let pulse = (wave_t * 2.8).to_int() % 180
    let glow = if pulse < 90 { pulse } else { 180 - pulse }

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(12, 18 + glow / 12, 34 + glow / 6, 255))
    @raylib.draw_rectangle(0, 0, sw, 250, @raylib.Color::new(18, 28 + glow / 11, 58 + glow / 6, 255))

    for i = 0; i < 84; i = i + 1 {
      let x = ((i * 98 + (wave_t * 54.0).to_int()) % (sw + 180)) - 90
      let h = 120 + (i * 37 % 250)
      let w = 40 + (i * 13 % 66)
      let c = 20 + (i * 11 % 60)
      @raylib.draw_rectangle(x, sh - h, w, h, @raylib.Color::new(c, c + 8, c + 30, 255))
      if i % 2 == 0 {
        @raylib.draw_rectangle(x + 8, sh - h + 24, 8, h - 32, @raylib.Color::new(94, 212, 248, 186))
      }
      if i % 3 == 0 {
        @raylib.draw_rectangle(x + 24, sh - h + 36, 8, h - 44, @raylib.Color::new(248, 144, 226, 176))
      }
    }

    @raylib.draw_rectangle(20, 132, sw - 40, sh - 162, @raylib.Color::new(48, 48, 56, 255))
    @raylib.draw_rectangle(28, 140, sw - 56, sh - 178, @raylib.Color::new(62, 62, 72, 255))

    @raylib.draw_rectangle(252, 148, 40, 470, @raylib.Color::new(96, 88, 92, 255))
    @raylib.draw_rectangle(252, 148, 496, 40, @raylib.Color::new(96, 88, 92, 255))
    @raylib.draw_rectangle(546, 148, 42, 380, @raylib.Color::new(96, 88, 92, 255))
    @raylib.draw_rectangle(588, 490, 402, 42, @raylib.Color::new(96, 88, 92, 255))
    @raylib.draw_rectangle(960, 148, 40, 280, @raylib.Color::new(96, 88, 92, 255))
    @raylib.draw_rectangle(790, 314, 180, 38, @raylib.Color::new(96, 88, 92, 255))

    if level >= 2 {
      @raylib.draw_rectangle(116, 326, 122, 170, @raylib.Color::new(96, 88, 92, 255))
    }

    if level >= 3 {
      @raylib.draw_rectangle(702, 556, 178, 114, @raylib.Color::new(96, 88, 92, 255))
    }

    let vault_col = if collected >= target_cards {
      if vault_open {
        @raylib.Color::new(126, 220, 146, 180)
      } else {
        @raylib.Color::new(206, 186, 112, 170)
      }
    } else {
      @raylib.Color::new(98, 112, 136, 120)
    }
    @raylib.draw_rectangle(986, 186, 218, 162, vault_col)
    @raylib.draw_text("VAULT", 1040, 146, 34, @raylib.Color::new(236, 244, 252, 255))

    @raylib.draw_rectangle(36, 654, 160, 130, if vault_open { @raylib.Color::new(126, 220, 146, 182) } else { @raylib.Color::new(108, 130, 160, 120) })
    @raylib.draw_text("EXIT", 74, 612, 34, @raylib.Color::new(236, 244, 252, 255))

    for i = 0; i < cards.length(); i = i + 1 {
      if not(cards[i].active) {
        continue
      }

      let cx = (cards[i].x + shake_x).to_int()
      let cy = cards[i].y.to_int()
      let col = if cards[i].kind == 0 {
        @raylib.Color::new(246, 212, 124, 255)
      } else if cards[i].kind == 1 {
        @raylib.Color::new(126, 218, 248, 255)
      } else {
        @raylib.Color::new(224, 156, 252, 255)
      }
      @raylib.draw_rectangle(cx - 10, cy - 8, 20, 16, col)
      @raylib.draw_rectangle(cx - 6, cy - 4, 12, 8, @raylib.Color::new(244, 246, 250, 255))
    }

    for i = 0; i < guards.length(); i = i + 1 {
      if not(guards[i].active) {
        continue
      }

      let gx = guards[i].x + shake_x
      let gy = guards[i].y
      let vel2 = guards[i].vx * guards[i].vx + guards[i].vy * guards[i].vy
      let invl : Float = if vel2 < 1.0 { 0.0 } else { 1.0 / vel2.sqrt() }
      let fx : Float = if invl == 0.0 { Float::from_int(1) } else { guards[i].vx * invl }
      let fy : Float = if invl == 0.0 { Float::from_int(0) } else { guards[i].vy * invl }

      if guards[i].stun_t <= 0.0 {
        let cone_r = if player.cloak_t > 0.0 { guards[i].detect_r * 0.46 } else { guards[i].detect_r }
        let lx = gx + fx * cone_r + (-fy) * cone_r * 0.45
        let ly = gy + fy * cone_r + fx * cone_r * 0.45
        let rx = gx + fx * cone_r - (-fy) * cone_r * 0.45
        let ry = gy + fy * cone_r - fx * cone_r * 0.45
        @raylib.draw_triangle(
          @raylib.Vector2::new(gx, gy),
          @raylib.Vector2::new(lx, ly),
          @raylib.Vector2::new(rx, ry),
          @raylib.Color::new(252, 150, 150, 46),
        )
      }

      let col = if guards[i].stun_t > 0.0 {
        @raylib.Color::new(130, 236, 248, 255)
      } else {
        @raylib.Color::new(238, 112, 96, 255)
      }

      @raylib.draw_circle((gx - 1.0).to_int(), (gy - 18.0).to_int(), 10.0, @raylib.Color::new(236, 230, 220, 255))
      @raylib.draw_rectangle((gx - 10.0).to_int(), (gy - 8.0).to_int(), 20, 24, col)
      @raylib.draw_line((gx - 8.0).to_int(), (gy + 16.0).to_int(), (gx - 12.0).to_int(), (gy + 32.0).to_int(), col)
      @raylib.draw_line((gx + 8.0).to_int(), (gy + 16.0).to_int(), (gx + 12.0).to_int(), (gy + 32.0).to_int(), col)
    }

    let pcol = if player.flash_t > 0.0 {
      @raylib.Color::new(252, 238, 148, 255)
    } else if player.cloak_t > 0.0 {
      @raylib.Color::new(168, 156, 248, 255)
    } else {
      @raylib.Color::new(100, 224, 246, 255)
    }

    let px = player.x + shake_x
    let py = player.y

    @raylib.draw_circle((px - 1.0).to_int(), (py - 20.0).to_int(), 12.0, @raylib.Color::new(236, 242, 252, 255))
    @raylib.draw_rectangle((px - 12.0).to_int(), (py - 10.0).to_int(), 24, 30, pcol)
    @raylib.draw_line((px - 10.0).to_int(), py.to_int(), (px - 22.0).to_int(), (py + 12.0).to_int(), pcol)
    @raylib.draw_line((px + 10.0).to_int(), py.to_int(), (px + 22.0).to_int(), (py + 12.0).to_int(), pcol)
    @raylib.draw_line((px - 8.0).to_int(), (py + 20.0).to_int(), (px - 12.0).to_int(), (py + 40.0).to_int(), pcol)
    @raylib.draw_line((px + 8.0).to_int(), (py + 20.0).to_int(), (px + 12.0).to_int(), (py + 40.0).to_int(), pcol)

    if player.pulse_cd > 2.3 {
      @raylib.draw_circle_lines(px.to_int(), py.to_int(), 176.0, @raylib.Color::new(162, 136, 252, 210))
    }

    for i = 0; i < bullets.length(); i = i + 1 {
      if not(bullets[i].active) {
        continue
      }
      @raylib.draw_line(
        (bullets[i].x + shake_x).to_int(),
        bullets[i].y.to_int(),
        (bullets[i].x - bullets[i].vx * 0.02 + shake_x).to_int(),
        (bullets[i].y - bullets[i].vy * 0.02).to_int(),
        @raylib.Color::new(252, 140, 124, 255),
      )
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }
      let col = if particles[i].kind == 0 {
        @raylib.Color::new(252, 128, 128, 255)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 228, 132, 255)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(222, 156, 252, 255)
      } else {
        @raylib.Color::new(120, 226, 246, 255)
      }
      @raylib.draw_circle((particles[i].x + shake_x).to_int(), particles[i].y.to_int(), 2.0, col)
    }

    @raylib.draw_rectangle(0, 0, sw, 116, @raylib.Color::new(6, 10, 18, 232))
    @raylib.draw_text("CLOCKTOWER HEIST 2026", 16, 16, 34, @raylib.Color::new(236, 246, 255, 255))
    @raylib.draw_text("Floor \{level}/3", 420, 24, 30, @raylib.Color::new(248, 226, 142, 255))
    @raylib.draw_text("Cards \{collected}/\{target_cards}", 606, 24, 30, @raylib.Color::new(216, 236, 252, 255))
    @raylib.draw_text("Score \{score}", 924, 24, 30, @raylib.Color::new(216, 236, 252, 255))

    @raylib.draw_text("HP \{player.hp}", 20, 76, 24, @raylib.Color::new(220, 236, 252, 255))
    @raylib.draw_text("Stamina \{player.stamina.to_int()}%", 122, 76, 24, @raylib.Color::new(220, 236, 252, 255))
    @raylib.draw_text("Hack \{hack_progress.to_int()}%", 372, 76, 24, @raylib.Color::new(220, 236, 252, 255))
    @raylib.draw_text("Timer \{timer.to_int()}", 564, 76, 24, @raylib.Color::new(252, 222, 150, 255))
    @raylib.draw_text("Stars \{stars}", 736, 76, 24, @raylib.Color::new(252, 232, 132, 255))

    @raylib.draw_text(
      if player.cloak_t > 0.0 { "Cloak ON" } else { "Cloak OFF" },
      886,
      76,
      24,
      if player.cloak_t > 0.0 { @raylib.Color::new(198, 158, 252, 255) } else { @raylib.Color::new(132, 146, 166, 255) },
    )

    @raylib.draw_rectangle(20, 104, 160, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(20, 104, (Float::from_int(player.hp) / 6.0 * 160.0).to_int(), 8, @raylib.Color::new(110, 220, 146, 255))

    @raylib.draw_rectangle(194, 104, 210, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(194, 104, (player.stamina / 100.0 * 210.0).to_int(), 8, @raylib.Color::new(96, 198, 246, 255))

    let card_ratio = clampf(Float::from_int(collected) / Float::from_int(target_cards), 0.0, 1.0)
    @raylib.draw_rectangle(420, 104, 220, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(420, 104, (card_ratio * 220.0).to_int(), 8, @raylib.Color::new(242, 188, 98, 255))

    @raylib.draw_rectangle(656, 104, 220, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(656, 104, (hack_progress / 100.0 * 220.0).to_int(), 8, @raylib.Color::new(154, 222, 154, 255))

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

    @raylib.draw_rectangle(sprint_x, sprint_y, 104, 154, @raylib.Color::new(214, 110, 82, 255))
    @raylib.draw_text("SPRNT", sprint_x + 6, sprint_y + 58, 24, @raylib.white)
    @raylib.draw_rectangle(pulse_x, pulse_y, 104, 154, @raylib.Color::new(100, 162, 220, 255))
    @raylib.draw_text("PULSE", pulse_x + 12, pulse_y + 58, 24, @raylib.white)
    @raylib.draw_rectangle(cloak_x, cloak_y, 94, 154, @raylib.Color::new(96, 186, 122, 255))
    @raylib.draw_text("CLOAK", cloak_x + 8, cloak_y + 58, 24, @raylib.white)

    @raylib.draw_rectangle(250, sh - 58, sw - 516, 42, @raylib.Color::new(6, 10, 18, 220))
    @raylib.draw_text(msg, 262, sh - 50, 24, @raylib.Color::new(224, 236, 248, 255))

    if transition_t > 0.0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 112))
      @raylib.draw_text("FLOOR CLEARED", sw / 2 - 188, sh / 2 - 28, 54, @raylib.Color::new(250, 236, 146, 255))
    }

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 132))
      @raylib.draw_rectangle(sw / 2 - 360, sh / 2 - 112, 720, 224, @raylib.Color::new(16, 24, 42, 244))
      @raylib.draw_text(
        if won { "HEIST MASTER" } else { "HEIST FAILED" },
        sw / 2 - 220,
        sh / 2 - 34,
        64,
        if won { @raylib.Color::new(252, 238, 148, 255) } else { @raylib.Color::new(252, 140, 140, 255) },
      )
      @raylib.draw_text("Press R to restart", sw / 2 - 124, sh / 2 + 48, 34, @raylib.Color::new(224, 238, 252, 255))
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
