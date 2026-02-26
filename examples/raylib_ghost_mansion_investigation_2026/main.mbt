///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let max_ghosts : Int = 26

///|
let max_clues : Int = 42

///|
let max_particles : Int = 560

///|
struct Investigator {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut fx : Float
  mut fy : Float
  mut hp : Int
  mut sanity : Float
  mut battery : Float
  mut pulse_cd : Float
  mut hit_cd : Float
  mut flash_t : Float
}

///|
struct Ghost {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut speed : Float
  mut radius : Float
  mut wander_t : Float
  mut stun_t : Float
  mut alert_t : Float
  mut kind : Int
  mut active : Bool
}

///|
struct Clue {
  mut x : Float
  mut y : Float
  mut kind : Int
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
fn blocked(x : Float, y : Float, r : Float, level : Int) -> Bool {
  if x - r < 28.0 || x + r > Float::from_int(sw - 28) || y - r < 132.0 || y + r > Float::from_int(sh - 28) {
    return true
  }

  if circle_hits_rect(x, y, r, 294.0, 156.0, 40.0, 430.0) {
    return true
  }
  if circle_hits_rect(x, y, r, 294.0, 156.0, 472.0, 40.0) {
    return true
  }
  if circle_hits_rect(x, y, r, 546.0, 318.0, 204.0, 146.0) {
    return true
  }
  if circle_hits_rect(x, y, r, 902.0, 208.0, 126.0, 312.0) {
    return true
  }
  if circle_hits_rect(x, y, r, 280.0, 618.0, 540.0, 60.0) {
    return true
  }

  if level >= 2 && circle_hits_rect(x, y, r, 116.0, 322.0, 132.0, 184.0) {
    return true
  }

  if level >= 3 && circle_hits_rect(x, y, r, 760.0, 500.0, 180.0, 124.0) {
    return true
  }

  false
}

///|
fn clear_ghosts(gs : Array[Ghost]) -> Unit {
  for i = 0; i < gs.length(); i = i + 1 {
    gs[i].x = 0.0
    gs[i].y = 0.0
    gs[i].vx = 0.0
    gs[i].vy = 0.0
    gs[i].speed = 0.0
    gs[i].radius = 18.0
    gs[i].wander_t = 0.0
    gs[i].stun_t = 0.0
    gs[i].alert_t = 0.0
    gs[i].kind = 0
    gs[i].active = false
  }
}

///|
fn clear_clues(cs : Array[Clue]) -> Unit {
  for i = 0; i < cs.length(); i = i + 1 {
    cs[i].x = 0.0
    cs[i].y = 0.0
    cs[i].kind = 0
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
      ps[i].ttl = Float::from_int(@raylib.get_random_value(12, 62)) / Float::from_int(100)
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
fn reset_player(p : Investigator) -> Unit {
  p.x = 86.0
  p.y = 734.0
  p.vx = 0.0
  p.vy = 0.0
  p.fx = 1.0
  p.fy = 0.0
  p.hp = 6
  p.sanity = 100.0
  p.battery = 100.0
  p.pulse_cd = 0.0
  p.hit_cd = 0.0
  p.flash_t = 0.0
}

///|
fn set_clue(cs : Array[Clue], idx : Int, x : Float, y : Float, kind : Int) -> Unit {
  cs[idx].x = x
  cs[idx].y = y
  cs[idx].kind = kind
  cs[idx].active = true
}

///|
fn init_clues(level : Int, cs : Array[Clue]) -> Int {
  clear_clues(cs)

  set_clue(cs, 0, 118.0, 208.0, 0)
  set_clue(cs, 1, 208.0, 282.0, 1)
  set_clue(cs, 2, 174.0, 412.0, 2)
  set_clue(cs, 3, 118.0, 590.0, 0)
  set_clue(cs, 4, 430.0, 266.0, 1)
  set_clue(cs, 5, 478.0, 548.0, 2)
  set_clue(cs, 6, 664.0, 244.0, 0)
  set_clue(cs, 7, 834.0, 290.0, 1)
  set_clue(cs, 8, 816.0, 562.0, 2)
  set_clue(cs, 9, 1036.0, 622.0, 0)
  set_clue(cs, 10, 1080.0, 260.0, 1)
  set_clue(cs, 11, 944.0, 706.0, 2)
  set_clue(cs, 12, 642.0, 706.0, 0)
  set_clue(cs, 13, 364.0, 734.0, 1)
  set_clue(cs, 14, 250.0, 680.0, 2)

  if level >= 2 {
    set_clue(cs, 15, 154.0, 352.0, 1)
    set_clue(cs, 16, 232.0, 480.0, 2)
    set_clue(cs, 17, 1044.0, 452.0, 0)
    set_clue(cs, 18, 988.0, 178.0, 1)
    set_clue(cs, 19, 740.0, 394.0, 2)
  }

  if level >= 3 {
    set_clue(cs, 20, 786.0, 548.0, 0)
    set_clue(cs, 21, 892.0, 660.0, 1)
    set_clue(cs, 22, 1038.0, 706.0, 2)
    set_clue(cs, 23, 362.0, 180.0, 0)
    set_clue(cs, 24, 500.0, 180.0, 1)
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
fn spawn_ghost(gs : Array[Ghost], level : Int) -> Unit {
  let mut done = false
  for i = 0; i < gs.length(); i = i + 1 {
    if done {
      continue
    }

    if not(gs[i].active) {
      gs[i].active = true
      gs[i].kind = @raylib.get_random_value(0, 2)
      gs[i].radius = if gs[i].kind == 2 { 20.0 } else { 18.0 }
      gs[i].speed = Float::from_int(@raylib.get_random_value(84 + level * 12, 130 + level * 18))
      gs[i].stun_t = 0.0
      gs[i].alert_t = 0.0
      gs[i].wander_t = Float::from_int(@raylib.get_random_value(80, 240)) / Float::from_int(100)

      let mut placed = false
      while not(placed) {
        let x = Float::from_int(@raylib.get_random_value(70, sw - 70))
        let y = Float::from_int(@raylib.get_random_value(152, sh - 70))
        if not(blocked(x, y, gs[i].radius, level)) {
          gs[i].x = x
          gs[i].y = y
          placed = true
        }
      }

      gs[i].vx = Float::from_int(@raylib.get_random_value(-70, 70))
      gs[i].vy = Float::from_int(@raylib.get_random_value(-70, 70))
      done = true
    }
  }
}

///|
fn setup_level(level : Int, player : Investigator, ghosts : Array[Ghost], clues : Array[Clue], particles : Array[Particle]) -> (Int, Float, Float) {
  reset_player(player)
  clear_ghosts(ghosts)
  clear_particles(particles)

  let target = init_clues(level, clues)

  if level == 1 {
    (target, 132.0, 1.16)
  } else if level == 2 {
    (target, 146.0, 0.88)
  } else {
    (target, 162.0, 0.66)
  }
}

///|
fn in_lantern(player : Investigator, gx : Float, gy : Float) -> Bool {
  if player.battery <= 4.0 {
    return false
  }

  let range : Float = if player.battery > 30.0 { 260.0 } else { 190.0 }
  let dx = gx - player.x
  let dy = gy - player.y
  let d2 = dx * dx + dy * dy
  if d2 > range * range {
    return false
  }

  let d : Float = if d2 < 0.0001 { 1.0 } else { d2.sqrt() }
  let nx = dx / d
  let ny = dy / d
  let dot = nx * player.fx + ny * player.fy
  dot >= 0.42
}

///|
fn main {
  @raylib.init_window(sw, sh, "Ghost Mansion Investigation 2026")
  @raylib.set_target_fps(60)

  let player : Investigator = {
    x: 86.0,
    y: 734.0,
    vx: 0.0,
    vy: 0.0,
    fx: 1.0,
    fy: 0.0,
    hp: 6,
    sanity: 100.0,
    battery: 100.0,
    pulse_cd: 0.0,
    hit_cd: 0.0,
    flash_t: 0.0,
  }

  let ghosts : Array[Ghost] = Array::makei(max_ghosts, fn(_i) {
    {
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      speed: 0.0,
      radius: 18.0,
      wander_t: 0.0,
      stun_t: 0.0,
      alert_t: 0.0,
      kind: 0,
      active: false,
    }
  })

  let clues : Array[Clue] = Array::makei(max_clues, fn(_i) {
    {
      x: 0.0,
      y: 0.0,
      kind: 0,
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
  let mut ghost_spawn_base : Float = 0.0

  let (t, tm, gs) = setup_level(level, player, ghosts, clues, particles)
  target = t
  timer = tm
  ghost_spawn_base = gs

  let mut collected = 0
  let mut score = 0
  let mut stars = 0

  let mut ghost_cd : Float = 0.8
  let mut wave_t : Float = 0.0

  let mut transition_t : Float = 0.0
  let mut flash_t : Float = 0.0
  let mut shake_t : Float = 0.0

  let mut over = false
  let mut won = false
  let mut msg = "WASD move, J sprint, K pulse"

  let pad_x = 16
  let pad_y = sh - 186
  let sprint_x = sw - 250
  let sprint_y = sh - 170
  let pulse_x = sw - 122
  let pulse_y = sh - 170

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    wave_t = wave_t + dt

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      let (rt, rtm, rgs) = setup_level(level, player, ghosts, clues, particles)
      target = rt
      timer = rtm
      ghost_spawn_base = rgs

      collected = 0
      score = 0
      stars = 0

      ghost_cd = 0.8

      transition_t = 0.0
      flash_t = 0.0
      shake_t = 0.0

      over = false
      won = false
      msg = "Investigation restarted"
    }

    if transition_t > 0.0 {
      transition_t = transition_t - dt
      if transition_t <= 0.0 {
        transition_t = 0.0
        if level < 3 {
          level = level + 1
          let (nt, ntm, ngs) = setup_level(level, player, ghosts, clues, particles)
          target = nt
          timer = ntm
          ghost_spawn_base = ngs
          collected = 0
          ghost_cd = 0.8
          msg = "Floor \{level} unlocked"
        } else {
          over = true
          won = true
          msg = "Case solved"
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

    if player.pulse_cd > 0.0 {
      player.pulse_cd = player.pulse_cd - dt
      if player.pulse_cd < 0.0 {
        player.pulse_cd = 0.0
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

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }
      particles[i].x = particles[i].x + particles[i].vx * dt
      particles[i].y = particles[i].y + particles[i].vy * dt
      particles[i].vy = particles[i].vy + 240.0 * dt
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
        msg = "Time expired"
      }

      let mut move_l = @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r = @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u = @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d = @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown)
      let mut sprint = @raylib.is_key_down(@raylib.KeyJ) || @raylib.is_key_down(@raylib.KeyLeftShift)
      let mut pulse = @raylib.is_key_pressed(@raylib.KeyK)

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
        if inside_rect(m.x, m.y, sprint_x, sprint_y, 116, 154) {
          sprint = true
        }
      }

      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, pulse_x, pulse_y, 104, 154) {
          pulse = true
        }
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

      if ax != 0.0 || ay != 0.0 {
        let d2 = ax * ax + ay * ay
        let d : Float = if d2 < 1.0 { 1.0 } else { d2.sqrt() }
        player.fx = ax / d
        player.fy = ay / d
      }

      let sprint_on = sprint && player.battery > 8.0
      if sprint_on {
        ax = ax * 1.34
        ay = ay * 1.34
      }

      player.vx = player.vx + ax * dt
      player.vy = player.vy + ay * dt

      player.vx = player.vx * (Float::from_int(1) - dt * 2.5)
      player.vy = player.vy * (Float::from_int(1) - dt * 2.5)

      let max_speed : Float = if sprint_on { 346.0 } else { 258.0 }
      player.vx = clampf(player.vx, -max_speed, max_speed)
      player.vy = clampf(player.vy, -max_speed, max_speed)

      let old_x = player.x
      let old_y = player.y
      player.x = player.x + player.vx * dt
      player.y = player.y + player.vy * dt

      if blocked(player.x, player.y, 18.0, level) {
        player.x = old_x
        player.y = old_y
        player.vx = player.vx * 0.2
        player.vy = player.vy * 0.2
      }

      player.battery = player.battery + 14.0 * dt
      if sprint_on {
        player.battery = player.battery - 26.0 * dt
      }
      player.battery = clampf(player.battery, 0.0, 100.0)

      if pulse && player.pulse_cd <= 0.0 && player.battery >= 24.0 {
        player.pulse_cd = 2.6
        player.battery = player.battery - 24.0
        msg = "EM pulse"
        burst(particles, player.x, player.y, 24, 0.52, 2)

        for i = 0; i < ghosts.length(); i = i + 1 {
          if not(ghosts[i].active) {
            continue
          }
          if sqdist(player.x, player.y, ghosts[i].x, ghosts[i].y) <= 172.0 * 172.0 {
            ghosts[i].stun_t = Float::from_int(@raylib.get_random_value(160, 250)) / Float::from_int(100)
            ghosts[i].alert_t = 0.0
            burst(particles, ghosts[i].x, ghosts[i].y, 10, 0.30, 3)
          }
        }
      }

      ghost_cd = ghost_cd - dt
      if ghost_cd <= 0.0 {
        spawn_ghost(ghosts, level)
        let jitter = Float::from_int(@raylib.get_random_value(78, 132)) / Float::from_int(100)
        ghost_cd = ghost_spawn_base * jitter
      }

      let mut nearby_terror : Float = 0.0

      for i = 0; i < ghosts.length(); i = i + 1 {
        if not(ghosts[i].active) {
          continue
        }

        if ghosts[i].stun_t > 0.0 {
          ghosts[i].stun_t = ghosts[i].stun_t - dt
          if ghosts[i].stun_t < 0.0 {
            ghosts[i].stun_t = 0.0
          }
        }

        if ghosts[i].alert_t > 0.0 {
          ghosts[i].alert_t = ghosts[i].alert_t - dt
          if ghosts[i].alert_t < 0.0 {
            ghosts[i].alert_t = 0.0
          }
        }

        let dx = player.x - ghosts[i].x
        let dy = player.y - ghosts[i].y
        let d2 = dx * dx + dy * dy
        let d : Float = if d2 < 1.0 { 1.0 } else { d2.sqrt() }

        if d < 180.0 {
          nearby_terror = nearby_terror + (Float::from_int(180) - d) / 180.0
        }

        if ghosts[i].stun_t > 0.0 {
          ghosts[i].vx = ghosts[i].vx * (Float::from_int(1) - dt * 4.4)
          ghosts[i].vy = ghosts[i].vy * (Float::from_int(1) - dt * 4.4)
        } else {
          let mut target_vx = ghosts[i].vx
          let mut target_vy = ghosts[i].vy

          let detect_r : Float = Float::from_int(220 + level * 40 + ghosts[i].kind * 22)
          if d < detect_r {
            ghosts[i].alert_t = 1.1
            let mut chase = ghosts[i].speed
            if in_lantern(player, ghosts[i].x, ghosts[i].y) {
              chase = chase * 0.46
            }
            target_vx = dx / d * chase
            target_vy = dy / d * chase
          } else {
            ghosts[i].wander_t = ghosts[i].wander_t - dt
            if ghosts[i].wander_t <= 0.0 {
              ghosts[i].wander_t = Float::from_int(@raylib.get_random_value(80, 220)) / Float::from_int(100)
              target_vx = Float::from_int(@raylib.get_random_value(-120, 120))
              target_vy = Float::from_int(@raylib.get_random_value(-120, 120))
            }
          }

          ghosts[i].vx = ghosts[i].vx * (Float::from_int(1) - dt * 2.8) + target_vx * dt * 2.8
          ghosts[i].vy = ghosts[i].vy * (Float::from_int(1) - dt * 2.8) + target_vy * dt * 2.8
        }

        let old_x = ghosts[i].x
        let old_y = ghosts[i].y
        ghosts[i].x = ghosts[i].x + ghosts[i].vx * dt
        ghosts[i].y = ghosts[i].y + ghosts[i].vy * dt

        if blocked(ghosts[i].x, ghosts[i].y, ghosts[i].radius, level) {
          ghosts[i].x = old_x
          ghosts[i].y = old_y
          ghosts[i].vx = -ghosts[i].vx * 0.46
          ghosts[i].vy = -ghosts[i].vy * 0.46
          ghosts[i].wander_t = 0.0
        }

        let hit_r = ghosts[i].radius + 16.0
        if d2 <= hit_r * hit_r && player.hit_cd <= 0.0 {
          player.hp = player.hp - 1
          player.sanity = player.sanity - 14.0
          player.hit_cd = 1.0
          player.flash_t = 0.28
          flash_t = 0.28
          shake_t = 0.22
          msg = "Ghost contact"
          burst(particles, player.x, player.y, 24, 0.58, 0)

          if player.hp <= 0 {
            over = true
            won = false
            msg = "Investigator down"
          }
        }
      }

      player.sanity = player.sanity - nearby_terror * 4.6 * dt
      if player.sanity < 0.0 {
        player.sanity = 0.0
      }

      if player.sanity <= 0.0 {
        over = true
        won = false
        msg = "Sanity collapsed"
      }

      for i = 0; i < clues.length(); i = i + 1 {
        if not(clues[i].active) {
          continue
        }

        if sqdist(player.x, player.y, clues[i].x, clues[i].y) <= 28.0 * 28.0 {
          clues[i].active = false
          collected = collected + 1
          score = score + 95 + clues[i].kind * 18
          stars = stars + 1 + clues[i].kind
          player.battery = player.battery + Float::from_int(8 + clues[i].kind * 4)
          if player.battery > 100.0 {
            player.battery = 100.0
          }
          msg = "Clue recovered"
          burst(particles, clues[i].x, clues[i].y, 16, 0.34, 1)
        }
      }

      if collected >= target && inside_rect(player.x, player.y, 1108, 150, 146, 116) {
        transition_t = 2.1
        msg = "Floor report complete"
      }
    }

    let mut shake_x : Float = 0.0
    if shake_t > 0.0 {
      shake_x = Float::from_int(@raylib.get_random_value(-5, 5))
    }

    @raylib.begin_drawing()

    if flash_t > 0.0 {
      @raylib.clear_background(@raylib.Color::new(28, 18, 28, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(10, 12, 24, 255))
    }

    let pulse = (wave_t * 2.4).to_int() % 160
    let glow = if pulse < 80 { pulse } else { 160 - pulse }

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(12, 16 + glow / 12, 30 + glow / 5, 255))
    @raylib.draw_rectangle(0, 0, sw, 250, @raylib.Color::new(16, 24 + glow / 10, 52 + glow / 5, 255))

    @raylib.draw_rectangle(20, 132, sw - 40, sh - 162, @raylib.Color::new(48, 48, 56, 255))
    @raylib.draw_rectangle(28, 140, sw - 56, sh - 178, @raylib.Color::new(62, 62, 72, 255))

    @raylib.draw_rectangle(294, 156, 40, 430, @raylib.Color::new(96, 88, 92, 255))
    @raylib.draw_rectangle(294, 156, 472, 40, @raylib.Color::new(96, 88, 92, 255))
    @raylib.draw_rectangle(546, 318, 204, 146, @raylib.Color::new(96, 88, 92, 255))
    @raylib.draw_rectangle(902, 208, 126, 312, @raylib.Color::new(96, 88, 92, 255))
    @raylib.draw_rectangle(280, 618, 540, 60, @raylib.Color::new(96, 88, 92, 255))

    if level >= 2 {
      @raylib.draw_rectangle(116, 322, 132, 184, @raylib.Color::new(96, 88, 92, 255))
    }
    if level >= 3 {
      @raylib.draw_rectangle(760, 500, 180, 124, @raylib.Color::new(96, 88, 92, 255))
    }

    let exit_col = if collected >= target {
      @raylib.Color::new(120, 220, 146, 185)
    } else {
      @raylib.Color::new(110, 134, 166, 122)
    }
    @raylib.draw_rectangle(1108, 150, 146, 116, exit_col)
    @raylib.draw_text("EXIT", 1140, 188, 34, @raylib.Color::new(234, 246, 236, 255))

    for i = 0; i < clues.length(); i = i + 1 {
      if not(clues[i].active) {
        continue
      }

      let cx = (clues[i].x + shake_x).to_int()
      let cy = clues[i].y.to_int()
      let col = if clues[i].kind == 0 {
        @raylib.Color::new(242, 212, 132, 255)
      } else if clues[i].kind == 1 {
        @raylib.Color::new(132, 214, 242, 255)
      } else {
        @raylib.Color::new(224, 156, 250, 255)
      }
      @raylib.draw_circle(cx, cy, 10.0, col)
      @raylib.draw_circle(cx, cy, 5.0, @raylib.Color::new(252, 248, 236, 255))
    }

    for i = 0; i < ghosts.length(); i = i + 1 {
      if not(ghosts[i].active) {
        continue
      }

      let gx = (ghosts[i].x + shake_x).to_int()
      let gy = ghosts[i].y.to_int()

      let col = if ghosts[i].stun_t > 0.0 {
        @raylib.Color::new(132, 236, 248, 255)
      } else if ghosts[i].kind == 2 {
        @raylib.Color::new(252, 164, 196, 255)
      } else if ghosts[i].kind == 1 {
        @raylib.Color::new(232, 182, 252, 255)
      } else {
        @raylib.Color::new(212, 206, 244, 255)
      }

      @raylib.draw_circle(gx, gy - 6, ghosts[i].radius, col)
      @raylib.draw_rectangle(gx - ghosts[i].radius.to_int(), gy - 2, (ghosts[i].radius * 2.0).to_int(), 28, col)
      @raylib.draw_circle(gx - 6, gy - 8, 3.0, @raylib.Color::new(22, 30, 38, 255))
      @raylib.draw_circle(gx + 6, gy - 8, 3.0, @raylib.Color::new(22, 30, 38, 255))

      if ghosts[i].alert_t > 0.0 {
        @raylib.draw_circle_lines(gx, gy, 96.0, @raylib.Color::new(252, 140, 140, 130))
      }
    }

    let lantern_range : Float = if player.battery > 30.0 { 250.0 } else { 180.0 }
    let px = player.x + shake_x
    let py = player.y
    let perp_x = -player.fy
    let perp_y = player.fx
    let lx = px + player.fx * lantern_range + perp_x * lantern_range * 0.42
    let ly = py + player.fy * lantern_range + perp_y * lantern_range * 0.42
    let rx = px + player.fx * lantern_range - perp_x * lantern_range * 0.42
    let ry = py + player.fy * lantern_range - perp_y * lantern_range * 0.42

    let lantern_alpha = if player.battery > 8.0 { 76 } else { 36 }
    @raylib.draw_triangle(
      @raylib.Vector2::new(px, py),
      @raylib.Vector2::new(lx, ly),
      @raylib.Vector2::new(rx, ry),
      @raylib.Color::new(246, 236, 168, lantern_alpha),
    )

    let p_col = if player.flash_t > 0.0 {
      @raylib.Color::new(252, 238, 148, 255)
    } else {
      @raylib.Color::new(102, 224, 246, 255)
    }

    @raylib.draw_circle((px - 2.0).to_int(), (py - 20.0).to_int(), 12.0, @raylib.Color::new(236, 242, 252, 255))
    @raylib.draw_rectangle((px - 12.0).to_int(), (py - 10.0).to_int(), 24, 32, p_col)
    @raylib.draw_line((px - 10.0).to_int(), (py - 2.0).to_int(), (px - 22.0).to_int(), (py + 10.0).to_int(), p_col)
    @raylib.draw_line((px + 10.0).to_int(), (py - 2.0).to_int(), (px + 22.0).to_int(), (py + 10.0).to_int(), p_col)
    @raylib.draw_line((px - 8.0).to_int(), (py + 22.0).to_int(), (px - 12.0).to_int(), (py + 44.0).to_int(), p_col)
    @raylib.draw_line((px + 8.0).to_int(), (py + 22.0).to_int(), (px + 12.0).to_int(), (py + 44.0).to_int(), p_col)

    if player.pulse_cd > 2.2 {
      @raylib.draw_circle_lines(px.to_int(), py.to_int(), 170.0, @raylib.Color::new(162, 136, 252, 220))
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let c = if particles[i].kind == 0 {
        @raylib.Color::new(252, 128, 128, 255)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 228, 132, 255)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(222, 156, 252, 255)
      } else {
        @raylib.Color::new(120, 226, 246, 255)
      }

      @raylib.draw_circle((particles[i].x + shake_x).to_int(), particles[i].y.to_int(), 2.0, c)
    }

    @raylib.draw_rectangle(0, 0, sw, 116, @raylib.Color::new(6, 10, 18, 232))
    @raylib.draw_text("GHOST MANSION INVESTIGATION 2026", 16, 16, 34, @raylib.Color::new(236, 246, 255, 255))

    @raylib.draw_text("Floor \{level}/3", 468, 24, 30, @raylib.Color::new(248, 226, 142, 255))
    @raylib.draw_text("Clues \{collected}/\{target}", 652, 24, 30, @raylib.Color::new(216, 236, 252, 255))
    @raylib.draw_text("Score \{score}", 956, 24, 30, @raylib.Color::new(216, 236, 252, 255))

    @raylib.draw_text("HP \{player.hp}", 20, 76, 24, @raylib.Color::new(220, 236, 252, 255))
    @raylib.draw_text("Sanity \{player.sanity.to_int()}%", 120, 76, 24, @raylib.Color::new(220, 236, 252, 255))
    @raylib.draw_text("Battery \{player.battery.to_int()}%", 360, 76, 24, @raylib.Color::new(220, 236, 252, 255))
    @raylib.draw_text("Timer \{timer.to_int()}", 596, 76, 24, @raylib.Color::new(252, 222, 150, 255))
    @raylib.draw_text("Stars \{stars}", 772, 76, 24, @raylib.Color::new(252, 232, 132, 255))

    @raylib.draw_rectangle(20, 104, 160, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(20, 104, (Float::from_int(player.hp) / 6.0 * 160.0).to_int(), 8, @raylib.Color::new(112, 220, 146, 255))

    @raylib.draw_rectangle(194, 104, 180, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(194, 104, (player.sanity / 100.0 * 180.0).to_int(), 8, @raylib.Color::new(122, 192, 248, 255))

    @raylib.draw_rectangle(388, 104, 180, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(388, 104, (player.battery / 100.0 * 180.0).to_int(), 8, @raylib.Color::new(236, 190, 112, 255))

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

    @raylib.draw_rectangle(sprint_x, sprint_y, 116, 154, @raylib.Color::new(214, 110, 82, 255))
    @raylib.draw_text("SPRINT", sprint_x + 8, sprint_y + 58, 26, @raylib.white)
    @raylib.draw_rectangle(pulse_x, pulse_y, 104, 154, @raylib.Color::new(100, 162, 220, 255))
    @raylib.draw_text("PULSE", pulse_x + 12, pulse_y + 58, 26, @raylib.white)

    @raylib.draw_rectangle(250, sh - 58, sw - 516, 42, @raylib.Color::new(6, 10, 18, 220))
    @raylib.draw_text(msg, 262, sh - 50, 24, @raylib.Color::new(224, 236, 248, 255))

    if transition_t > 0.0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 110))
      @raylib.draw_text("FLOOR CLEAR", sw / 2 - 164, sh / 2 - 28, 54, @raylib.Color::new(250, 236, 146, 255))
    }

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 130))
      @raylib.draw_rectangle(sw / 2 - 360, sh / 2 - 112, 720, 224, @raylib.Color::new(16, 24, 42, 244))
      @raylib.draw_text(
        if won { "CASE CLOSED" } else { "CASE FAILED" },
        sw / 2 - 212,
        sh / 2 - 34,
        66,
        if won { @raylib.Color::new(252, 238, 148, 255) } else { @raylib.Color::new(252, 140, 140, 255) },
      )
      @raylib.draw_text("Press R to restart", sw / 2 - 124, sh / 2 + 48, 34, @raylib.Color::new(224, 238, 252, 255))
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
