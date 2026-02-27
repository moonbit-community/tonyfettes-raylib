///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let ground_y : Float = 710.0

///|
let wagon_n : Int = 6

///|
let sheriff_n : Int = 18

///|
let bullet_n : Int = 320

///|
let particle_n : Int = 620

///|
struct Rider {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Int
  mut stamina : Float
  mut ammo : Int
  mut shoot_cd : Float
  mut reload_t : Float
  mut dash_t : Float
  mut loot_cd : Float
  mut hit_cd : Float
  mut flash_t : Float
}

///|
struct Wagon {
  mut x : Float
  mut len : Float
  mut roof_y : Float
  mut loot : Int
}

///|
struct Sheriff {
  mut wagon_idx : Int
  mut rel_x : Float
  mut hp : Int
  mut shoot_cd : Float
  mut hit_cd : Float
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
fn inside_rect(
  px : Float,
  py : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  px >= Float::from_int(rx) &&
  px <= Float::from_int(rx + rw) &&
  py >= Float::from_int(ry) &&
  py <= Float::from_int(ry + rh)
}

///|
fn clear_sheriffs(ss : Array[Sheriff]) -> Unit {
  for i = 0; i < ss.length(); i = i + 1 {
    ss[i].wagon_idx = 0
    ss[i].rel_x = 0.0
    ss[i].hp = 0
    ss[i].shoot_cd = 0.0
    ss[i].hit_cd = 0.0
    ss[i].active = false
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
      ps[i].ttl = Float::from_int(@raylib.get_random_value(12, 64)) /
        Float::from_int(100)
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
  n : Int,
  speed : Float,
  kind : Int,
) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    spawn_particle(ps, x, y, speed, kind)
  }
}

///|
fn spawn_bullet(
  bs : Array[Bullet],
  x : Float,
  y : Float,
  dx : Float,
  dy : Float,
  owner : Int,
  speed : Float,
) -> Unit {
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
      bs[i].ttl = 1.7
      done = true
    }
  }
}

///|
fn rightmost_wagon_x(wagons : Array[Wagon]) -> Float {
  let mut r : Float = -1000.0
  for i = 0; i < wagons.length(); i = i + 1 {
    let x : Float = wagons[i].x + wagons[i].len
    if x > r {
      r = x
    }
  }
  r
}

///|
fn init_wagons(wagons : Array[Wagon]) -> Unit {
  let mut x : Float = -40.0
  for i = 0; i < wagons.length(); i = i + 1 {
    let len = Float::from_int(@raylib.get_random_value(176, 228))
    let roof = Float::from_int(@raylib.get_random_value(500, 560))
    let loot = @raylib.get_random_value(1, 3)

    wagons[i].x = x
    wagons[i].len = len
    wagons[i].roof_y = roof
    wagons[i].loot = loot

    x = x + len + Float::from_int(@raylib.get_random_value(24, 58))
  }
}

///|
fn reset_player(p : Rider) -> Unit {
  p.x = 164.0
  p.y = ground_y
  p.vx = 0.0
  p.vy = 0.0
  p.hp = 6
  p.stamina = 100.0
  p.ammo = 7
  p.shoot_cd = 0.0
  p.reload_t = 0.0
  p.dash_t = 0.0
  p.loot_cd = 0.0
  p.hit_cd = 0.0
  p.flash_t = 0.0
}

///|
fn setup_level(
  level : Int,
  player : Rider,
  wagons : Array[Wagon],
  sheriffs : Array[Sheriff],
  bullets : Array[Bullet],
  particles : Array[Particle],
) -> (Int, Float, Float, Float) {
  reset_player(player)
  init_wagons(wagons)
  clear_sheriffs(sheriffs)
  clear_bullets(bullets)
  clear_particles(particles)

  if level == 1 {
    (9, 128.0, -122.0, 1.18)
  } else if level == 2 {
    (13, 142.0, -144.0, 0.94)
  } else {
    (18, 156.0, -168.0, 0.72)
  }
}

///|
fn spawn_sheriff(
  sheriffs : Array[Sheriff],
  wagons : Array[Wagon],
  level : Int,
) -> Unit {
  let idx = @raylib.get_random_value(0, wagons.length() - 1)

  let mut done = false
  for i = 0; i < sheriffs.length(); i = i + 1 {
    if done {
      continue
    }

    if not(sheriffs[i].active) {
      sheriffs[i].active = true
      sheriffs[i].wagon_idx = idx
      sheriffs[i].rel_x = Float::from_int(
        @raylib.get_random_value(24, (wagons[idx].len - 24.0).to_int()),
      )
      sheriffs[i].hp = if level == 1 { 2 } else if level == 2 { 3 } else { 4 }
      sheriffs[i].shoot_cd = Float::from_int(@raylib.get_random_value(50, 120)) /
        Float::from_int(100)
      sheriffs[i].hit_cd = 0.0
      done = true
    }
  }
}

///|
fn player_support_wagon(player : Rider, wagons : Array[Wagon]) -> Int {
  let mut idx = -1
  for i = 0; i < wagons.length(); i = i + 1 {
    let left = wagons[i].x + 10.0
    let right = wagons[i].x + wagons[i].len - 10.0
    if player.x >= left &&
      player.x <= right &&
      absf(player.y - wagons[i].roof_y) <= 6.0 {
      idx = i
    }
  }
  idx
}

///|
fn main {
  @raylib.init_window(sw, sh, "Desert Train Robbery 2026")
  @raylib.set_target_fps(60)

  let player : Rider = {
    x: 164.0,
    y: ground_y,
    vx: 0.0,
    vy: 0.0,
    hp: 6,
    stamina: 100.0,
    ammo: 7,
    shoot_cd: 0.0,
    reload_t: 0.0,
    dash_t: 0.0,
    loot_cd: 0.0,
    hit_cd: 0.0,
    flash_t: 0.0,
  }

  let wagons : Array[Wagon] = Array::makei(wagon_n, fn(_i) {
    { x: 0.0, len: 180.0, roof_y: 520.0, loot: 1 }
  })

  let sheriffs : Array[Sheriff] = Array::makei(sheriff_n, fn(_i) {
    {
      wagon_idx: 0,
      rel_x: 0.0,
      hp: 0,
      shoot_cd: 0.0,
      hit_cd: 0.0,
      active: false,
    }
  })

  let bullets : Array[Bullet] = Array::makei(bullet_n, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ttl: 0.0, owner: 0, active: false }
  })

  let particles : Array[Particle] = Array::makei(particle_n, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ttl: 0.0, kind: 0, active: false }
  })

  let mut level = 1
  let mut target_loot = 0
  let mut timer : Float = 0.0
  let mut train_speed : Float = 0.0
  let mut sheriff_base_cd : Float = 0.0

  let (t, tm, spd, scd) = setup_level(
    level, player, wagons, sheriffs, bullets, particles,
  )
  target_loot = t
  timer = tm
  train_speed = spd
  sheriff_base_cd = scd

  let mut looted = 0
  let mut score = 0
  let mut stars = 0

  let mut sheriff_cd : Float = 0.9
  let mut wave_t : Float = 0.0
  let mut transition_t : Float = 0.0
  let mut flash_t : Float = 0.0
  let mut shake_t : Float = 0.0

  let mut over = false
  let mut won = false
  let mut msg = "A/D move, W jump, J shoot, K dash, L loot"

  let pad_x = 16
  let pad_y = sh - 186
  let shoot_x = sw - 332
  let shoot_y = sh - 170
  let dash_x = sw - 216
  let dash_y = sh - 170
  let loot_x = sw - 104
  let loot_y = sh - 170

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    wave_t = wave_t + dt

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      let (rt, rtm, rspd, rscd) = setup_level(
        level, player, wagons, sheriffs, bullets, particles,
      )
      target_loot = rt
      timer = rtm
      train_speed = rspd
      sheriff_base_cd = rscd

      looted = 0
      score = 0
      stars = 0

      sheriff_cd = 0.9
      transition_t = 0.0
      flash_t = 0.0
      shake_t = 0.0

      over = false
      won = false
      msg = "Robbery reset"
    }

    if transition_t > 0.0 {
      transition_t = transition_t - dt
      if transition_t <= 0.0 {
        transition_t = 0.0
        if level < 3 {
          level = level + 1
          let (nt, ntm, nspd, nscd) = setup_level(
            level, player, wagons, sheriffs, bullets, particles,
          )
          target_loot = nt
          timer = ntm
          train_speed = nspd
          sheriff_base_cd = nscd
          looted = 0
          sheriff_cd = 0.9
          msg = "Chapter \{level} starts"
        } else {
          over = true
          won = true
          msg = "Heist complete"
        }
      }
    }

    if player.shoot_cd > 0.0 {
      player.shoot_cd = player.shoot_cd - dt
      if player.shoot_cd < 0.0 {
        player.shoot_cd = 0.0
      }
    }

    if player.reload_t > 0.0 {
      player.reload_t = player.reload_t - dt
      if player.reload_t < 0.0 {
        player.reload_t = 0.0
      }
      if player.reload_t <= 0.0 {
        player.ammo = 7
        msg = "Reloaded"
      }
    }

    if player.dash_t > 0.0 {
      player.dash_t = player.dash_t - dt
      if player.dash_t < 0.0 {
        player.dash_t = 0.0
      }
    }

    if player.loot_cd > 0.0 {
      player.loot_cd = player.loot_cd - dt
      if player.loot_cd < 0.0 {
        player.loot_cd = 0.0
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
        msg = "Escape window closed"
      }

      // Move wagons and recycle off-screen ones.
      for i = 0; i < wagons.length(); i = i + 1 {
        wagons[i].x = wagons[i].x + train_speed * dt

        if wagons[i].x + wagons[i].len < -100.0 {
          let rightmost = rightmost_wagon_x(wagons)
          wagons[i].len = Float::from_int(@raylib.get_random_value(176, 228))
          wagons[i].roof_y = Float::from_int(@raylib.get_random_value(496, 562))
          wagons[i].loot = @raylib.get_random_value(1, 3)
          wagons[i].x = rightmost +
            Float::from_int(@raylib.get_random_value(22, 56))

          for s = 0; s < sheriffs.length(); s = s + 1 {
            if sheriffs[s].active && sheriffs[s].wagon_idx == i {
              sheriffs[s].active = false
            }
          }
        }
      }

      sheriff_cd = sheriff_cd - dt
      if sheriff_cd <= 0.0 {
        spawn_sheriff(sheriffs, wagons, level)
        let jitter = Float::from_int(@raylib.get_random_value(80, 132)) /
          Float::from_int(100)
        sheriff_cd = sheriff_base_cd * jitter
      }

      let mut move_l = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut jump = @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyUp) ||
        @raylib.is_key_pressed(@raylib.KeySpace)
      let mut shoot = @raylib.is_key_pressed(@raylib.KeyJ)
      let mut dash = @raylib.is_key_pressed(@raylib.KeyK) ||
        @raylib.is_key_pressed(@raylib.KeyLeftShift)
      let mut loot = @raylib.is_key_pressed(@raylib.KeyL)

      let m = @raylib.get_mouse_position()

      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, pad_x, pad_y + 54, 72, 54) {
          move_l = true
        }
        if inside_rect(m.x, m.y, pad_x + 152, pad_y + 54, 72, 54) {
          move_r = true
        }
      }

      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, pad_x + 76, pad_y, 72, 54) {
          jump = true
        }
        if inside_rect(m.x, m.y, shoot_x, shoot_y, 104, 154) {
          shoot = true
        }
        if inside_rect(m.x, m.y, dash_x, dash_y, 104, 154) {
          dash = true
        }
        if inside_rect(m.x, m.y, loot_x, loot_y, 94, 154) {
          loot = true
        }
      }

      let support_idx = player_support_wagon(player, wagons)
      if support_idx >= 0 && absf(player.vy) < 80.0 {
        player.x = player.x + train_speed * dt
      }

      if dash && player.dash_t <= 0.0 && player.stamina >= 22.0 {
        player.dash_t = 0.20
        player.stamina = player.stamina - 22.0
        burst(particles, player.x, player.y - 20.0, 16, 0.34, 1)
      }

      let accel : Float = if player.dash_t > 0.0 { 1380.0 } else { 1020.0 }
      let max_speed : Float = if player.dash_t > 0.0 { 418.0 } else { 294.0 }

      if move_l {
        player.vx = player.vx - accel * dt
      }
      if move_r {
        player.vx = player.vx + accel * dt
      }
      if not(move_l) && not(move_r) {
        player.vx = player.vx * (Float::from_int(1) - dt * 7.0)
      }

      player.vx = clampf(player.vx, -max_speed, max_speed)

      if jump {
        if support_idx >= 0 || absf(player.y - ground_y) <= 4.0 {
          player.vy = -596.0
        }
      }

      player.vy = player.vy + 1180.0 * dt
      player.vy = clampf(player.vy, -980.0, 960.0)

      let old_y = player.y
      player.x = player.x + player.vx * dt
      player.y = player.y + player.vy * dt

      let mut landed = false

      if player.y >= ground_y {
        player.y = ground_y
        if player.vy > 0.0 {
          player.vy = 0.0
        }
        landed = true
      }

      for i = 0; i < wagons.length(); i = i + 1 {
        let left = wagons[i].x + 10.0
        let right = wagons[i].x + wagons[i].len - 10.0
        let roof = wagons[i].roof_y

        if player.x >= left && player.x <= right {
          if old_y <= roof && player.y >= roof && player.vy > 0.0 {
            player.y = roof
            player.vy = 0.0
            landed = true
          }
        }
      }

      if not(landed) && player.y > ground_y {
        player.y = ground_y
        player.vy = 0.0
      }

      player.x = clampf(player.x, 26.0, Float::from_int(sw - 26))

      if player.reload_t <= 0.0 && player.ammo <= 0 {
        player.reload_t = 1.5
      }

      player.stamina = player.stamina + 22.0 * dt
      if player.dash_t > 0.0 {
        player.stamina = player.stamina - 18.0 * dt
      }
      player.stamina = clampf(player.stamina, 0.0, 100.0)

      if shoot &&
        player.shoot_cd <= 0.0 &&
        player.reload_t <= 0.0 &&
        player.ammo > 0 {
        let aim_x : Float = if move_l { -1.0 } else { 1.0 }
        let aim_y : Float = if @raylib.is_key_down(@raylib.KeyUp) {
          -0.22
        } else {
          -0.06
        }
        spawn_bullet(
          bullets,
          player.x + aim_x * 20.0,
          player.y - 38.0,
          aim_x,
          aim_y,
          1,
          760.0,
        )
        player.ammo = player.ammo - 1
        player.shoot_cd = 0.14
        burst(particles, player.x + aim_x * 20.0, player.y - 38.0, 6, 0.20, 1)
      }

      if loot && player.loot_cd <= 0.0 {
        let mut looted_any = false
        for i = 0; i < wagons.length(); i = i + 1 {
          let cx = wagons[i].x + wagons[i].len * 0.5
          let cy = wagons[i].roof_y - 12.0
          if wagons[i].loot > 0 &&
            sqdist(player.x, player.y - 18.0, cx, cy) <= 42.0 * 42.0 {
            wagons[i].loot = wagons[i].loot - 1
            looted = looted + 1
            score = score + 62
            stars = stars + 1
            looted_any = true
            msg = "Loot secured"
            burst(particles, cx, cy, 14, 0.30, 3)
          }
        }
        if looted_any {
          player.loot_cd = 0.30
        }
      }

      for i = 0; i < sheriffs.length(); i = i + 1 {
        if not(sheriffs[i].active) {
          continue
        }

        if sheriffs[i].hit_cd > 0.0 {
          sheriffs[i].hit_cd = sheriffs[i].hit_cd - dt
          if sheriffs[i].hit_cd < 0.0 {
            sheriffs[i].hit_cd = 0.0
          }
        }

        if sheriffs[i].shoot_cd > 0.0 {
          sheriffs[i].shoot_cd = sheriffs[i].shoot_cd - dt
          if sheriffs[i].shoot_cd < 0.0 {
            sheriffs[i].shoot_cd = 0.0
          }
        }

        let wi = sheriffs[i].wagon_idx
        if wi < 0 || wi >= wagons.length() {
          sheriffs[i].active = false
          continue
        }

        let wx = wagons[wi].x
        let wl = wagons[wi].len
        let roof = wagons[wi].roof_y

        let target_rel = clampf(player.x - wx, 18.0, wl - 18.0)
        if target_rel < sheriffs[i].rel_x {
          sheriffs[i].rel_x = sheriffs[i].rel_x -
            Float::from_int(74 + level * 14) * dt
        } else if target_rel > sheriffs[i].rel_x {
          sheriffs[i].rel_x = sheriffs[i].rel_x +
            Float::from_int(74 + level * 14) * dt
        }

        sheriffs[i].rel_x = clampf(sheriffs[i].rel_x, 18.0, wl - 18.0)

        let sx = wx + sheriffs[i].rel_x
        let sy = roof - 16.0

        if sheriffs[i].shoot_cd <= 0.0 {
          let dx = player.x - sx
          let dy = player.y - 24.0 - sy
          let d2 = dx * dx + dy * dy
          if d2 <= 340.0 * 340.0 {
            spawn_bullet(
              bullets,
              sx + (if dx > 0.0 { 14.0 } else { -14.0 }),
              sy - 8.0,
              dx,
              dy,
              2,
              520.0,
            )
            sheriffs[i].shoot_cd = Float::from_int(
                @raylib.get_random_value(72, 136),
              ) /
              Float::from_int(100)
          }
        }

        if sqdist(player.x, player.y - 20.0, sx, sy) <= 34.0 * 34.0 &&
          player.hit_cd <= 0.0 {
          player.hp = player.hp - 1
          player.hit_cd = 0.95
          player.flash_t = 0.30
          flash_t = 0.24
          shake_t = 0.20
          msg = "Sheriff clash"
          burst(particles, player.x, player.y - 20.0, 20, 0.52, 0)
          if player.hp <= 0 {
            over = true
            won = false
            msg = "Outlaw defeated"
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

        if bullets[i].ttl <= 0.0 ||
          bullets[i].x < -60.0 ||
          bullets[i].x > Float::from_int(sw + 60) ||
          bullets[i].y < 80.0 ||
          bullets[i].y > Float::from_int(sh + 60) {
          bullets[i].active = false
          continue
        }

        let mut hit = false

        if bullets[i].owner == 1 {
          for s = 0; s < sheriffs.length(); s = s + 1 {
            if not(sheriffs[s].active) {
              continue
            }

            let wi = sheriffs[s].wagon_idx
            if wi < 0 || wi >= wagons.length() {
              continue
            }

            let sx = wagons[wi].x + sheriffs[s].rel_x
            let sy = wagons[wi].roof_y - 16.0
            if sqdist(bullets[i].x, bullets[i].y, sx, sy) <= 20.0 * 20.0 {
              sheriffs[s].hp = sheriffs[s].hp - 1
              sheriffs[s].hit_cd = 0.22
              bullets[i].active = false
              hit = true
              burst(particles, sx, sy, 10, 0.26, 1)
              if sheriffs[s].hp <= 0 {
                sheriffs[s].active = false
                score = score + 78
                stars = stars + 1
                burst(particles, sx, sy, 20, 0.52, 2)
              }
              break
            }
          }
        } else if sqdist(bullets[i].x, bullets[i].y, player.x, player.y - 22.0) <=
          22.0 * 22.0 {
          bullets[i].active = false
          hit = true
          if player.hit_cd <= 0.0 {
            player.hp = player.hp - 1
            player.hit_cd = 0.95
            player.flash_t = 0.30
            flash_t = 0.24
            shake_t = 0.20
            msg = "Shot by sheriff"
            burst(particles, player.x, player.y - 20.0, 20, 0.52, 0)
            if player.hp <= 0 {
              over = true
              won = false
              msg = "Outlaw defeated"
            }
          }
        }

        if hit {
          continue
        }
      }

      if looted >= target_loot {
        transition_t = 2.0
        msg = "Chapter complete"
      }
    }

    let mut shake_x : Float = 0.0
    if shake_t > 0.0 {
      shake_x = Float::from_int(@raylib.get_random_value(-5, 5))
    }

    @raylib.begin_drawing()

    if flash_t > 0.0 {
      @raylib.clear_background(@raylib.Color::new(34, 20, 20, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(18, 20, 34, 255))
    }

    let pulse = (wave_t * 3.0).to_int() % 180
    let glow = if pulse < 90 { pulse } else { 180 - pulse }

    @raylib.draw_rectangle(
      0,
      0,
      sw,
      sh,
      @raylib.Color::new(30, 36 + glow / 12, 58 + glow / 7, 255),
    )
    @raylib.draw_rectangle(0, 0, sw, 280, @raylib.Color::new(236, 148, 86, 255))
    @raylib.draw_rectangle(
      0,
      0,
      sw,
      164,
      @raylib.Color::new(248, 196, 126, 255),
    )

    for i = 0; i < 46; i = i + 1 {
      let x = (i * 66 + (wave_t * 70.0).to_int()) % (sw + 180) - 90
      let h = 60 + i * 23 % 170
      @raylib.draw_triangle(
        @raylib.Vector2::new(Float::from_int(x), ground_y + 16.0),
        @raylib.Vector2::new(Float::from_int(x + 120), ground_y + 16.0),
        @raylib.Vector2::new(
          Float::from_int(x + 58),
          ground_y - Float::from_int(h),
        ),
        @raylib.Color::new(172, 114, 76, 180),
      )
    }

    @raylib.draw_rectangle(
      0,
      ground_y.to_int(),
      sw,
      sh - ground_y.to_int(),
      @raylib.Color::new(194, 142, 86, 255),
    )

    @raylib.draw_line(0, 736, sw, 736, @raylib.Color::new(90, 70, 60, 255))
    @raylib.draw_line(0, 752, sw, 752, @raylib.Color::new(90, 70, 60, 255))

    for s = 0; s < 54; s = s + 1 {
      let x = (s * 44 + (wave_t * 200.0).to_int()) % (sw + 80) - 40
      @raylib.draw_rectangle(
        x,
        730,
        24,
        28,
        @raylib.Color::new(120, 90, 68, 255),
      )
    }

    for i = 0; i < wagons.length(); i = i + 1 {
      let wx = wagons[i].x + shake_x
      let wy = wagons[i].roof_y
      let len = wagons[i].len

      @raylib.draw_rectangle(
        wx.to_int(),
        (wy - 50.0).to_int(),
        len.to_int(),
        52,
        @raylib.Color::new(96, 62, 48, 255),
      )
      @raylib.draw_rectangle(
        (wx + 8.0).to_int(),
        (wy - 42.0).to_int(),
        (len - 16.0).to_int(),
        30,
        @raylib.Color::new(126, 84, 62, 255),
      )
      @raylib.draw_line(
        wx.to_int(),
        wy.to_int(),
        (wx + len).to_int(),
        wy.to_int(),
        @raylib.Color::new(238, 232, 226, 255),
      )

      @raylib.draw_circle(
        (wx + 28.0).to_int(),
        (wy + 8.0).to_int(),
        14.0,
        @raylib.Color::new(38, 30, 28, 255),
      )
      @raylib.draw_circle(
        (wx + len - 28.0).to_int(),
        (wy + 8.0).to_int(),
        14.0,
        @raylib.Color::new(38, 30, 28, 255),
      )

      if wagons[i].loot > 0 {
        let cx = (wx + len * 0.5).to_int()
        let cy = (wy - 14.0).to_int()
        @raylib.draw_rectangle(
          cx - 12,
          cy - 10,
          24,
          20,
          @raylib.Color::new(142, 102, 60, 255),
        )
        @raylib.draw_text(
          "\{wagons[i].loot}",
          cx - 5,
          cy - 10,
          18,
          @raylib.Color::new(246, 230, 186, 255),
        )
      }
    }

    for i = 0; i < sheriffs.length(); i = i + 1 {
      if not(sheriffs[i].active) {
        continue
      }

      let wi = sheriffs[i].wagon_idx
      if wi < 0 || wi >= wagons.length() {
        continue
      }

      let sx = (wagons[wi].x + sheriffs[i].rel_x + shake_x).to_int()
      let sy = (wagons[wi].roof_y - 16.0).to_int()

      let col = if sheriffs[i].hit_cd > 0.0 {
        @raylib.Color::new(252, 234, 146, 255)
      } else {
        @raylib.Color::new(238, 108, 90, 255)
      }

      @raylib.draw_circle(
        sx,
        sy - 22,
        10.0,
        @raylib.Color::new(242, 230, 214, 255),
      )
      @raylib.draw_rectangle(sx - 10, sy - 12, 20, 24, col)
      @raylib.draw_line(sx - 8, sy + 12, sx - 12, sy + 28, col)
      @raylib.draw_line(sx + 8, sy + 12, sx + 12, sy + 28, col)

      @raylib.draw_rectangle(
        sx - 12,
        sy - 32,
        24,
        4,
        @raylib.Color::new(82, 52, 38, 255),
      )
    }

    let p_col = if player.flash_t > 0.0 {
      @raylib.Color::new(252, 238, 148, 255)
    } else {
      @raylib.Color::new(102, 224, 246, 255)
    }

    let px = (player.x + shake_x).to_int()
    let py = player.y.to_int()

    @raylib.draw_circle(
      px,
      py - 52,
      12.0,
      @raylib.Color::new(240, 236, 228, 255),
    )
    @raylib.draw_rectangle(px - 12, py - 40, 24, 30, p_col)
    @raylib.draw_line(px - 10, py - 30, px - 22, py - 18, p_col)
    @raylib.draw_line(px + 10, py - 30, px + 22, py - 18, p_col)
    @raylib.draw_line(px - 8, py - 10, px - 12, py + 16, p_col)
    @raylib.draw_line(px + 8, py - 10, px + 12, py + 16, p_col)

    if player.dash_t > 0.0 {
      @raylib.draw_line(
        px - 38,
        py - 36,
        px - 12,
        py - 36,
        @raylib.Color::new(250, 226, 124, 255),
      )
      @raylib.draw_line(
        px - 46,
        py - 24,
        px - 20,
        py - 24,
        @raylib.Color::new(250, 226, 124, 255),
      )
      @raylib.draw_line(
        px - 38,
        py - 12,
        px - 12,
        py - 12,
        @raylib.Color::new(250, 226, 124, 255),
      )
    }

    for i = 0; i < bullets.length(); i = i + 1 {
      if not(bullets[i].active) {
        continue
      }

      let col = if bullets[i].owner == 1 {
        @raylib.Color::new(126, 240, 252, 255)
      } else {
        @raylib.Color::new(252, 132, 116, 255)
      }

      @raylib.draw_line(
        (bullets[i].x + shake_x).to_int(),
        bullets[i].y.to_int(),
        (bullets[i].x - bullets[i].vx * 0.02 + shake_x).to_int(),
        (bullets[i].y - bullets[i].vy * 0.02).to_int(),
        col,
      )
    }

    for i = 0; i < particles.length(); i = i + 1 {
      if not(particles[i].active) {
        continue
      }

      let col = if particles[i].kind == 0 {
        @raylib.Color::new(252, 126, 126, 255)
      } else if particles[i].kind == 1 {
        @raylib.Color::new(252, 228, 124, 255)
      } else if particles[i].kind == 2 {
        @raylib.Color::new(232, 164, 252, 255)
      } else {
        @raylib.Color::new(120, 228, 246, 255)
      }

      @raylib.draw_circle(
        (particles[i].x + shake_x).to_int(),
        particles[i].y.to_int(),
        2.0,
        col,
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 112, @raylib.Color::new(6, 10, 18, 232))
    @raylib.draw_text(
      "DESERT TRAIN ROBBERY 2026",
      16,
      16,
      34,
      @raylib.Color::new(236, 246, 255, 255),
    )

    @raylib.draw_text(
      "Chapter \{level}/3",
      448,
      22,
      30,
      @raylib.Color::new(248, 226, 142, 255),
    )
    @raylib.draw_text(
      "Loot \{looted}/\{target_loot}",
      652,
      22,
      30,
      @raylib.Color::new(216, 236, 252, 255),
    )
    @raylib.draw_text(
      "Score \{score}",
      952,
      22,
      30,
      @raylib.Color::new(216, 236, 252, 255),
    )

    @raylib.draw_text(
      "HP \{player.hp}",
      20,
      74,
      24,
      @raylib.Color::new(220, 236, 252, 255),
    )
    @raylib.draw_text(
      "Stamina \{player.stamina.to_int()}%",
      128,
      74,
      24,
      @raylib.Color::new(220, 236, 252, 255),
    )
    @raylib.draw_text(
      "Ammo \{player.ammo}",
      388,
      74,
      24,
      @raylib.Color::new(220, 236, 252, 255),
    )
    @raylib.draw_text(
      "Timer \{timer.to_int()}",
      536,
      74,
      24,
      @raylib.Color::new(252, 222, 150, 255),
    )
    @raylib.draw_text(
      "Stars \{stars}",
      704,
      74,
      24,
      @raylib.Color::new(252, 232, 132, 255),
    )

    @raylib.draw_rectangle(20, 102, 160, 8, @raylib.Color::new(20, 26, 36, 255))
    @raylib.draw_rectangle(
      20,
      102,
      (Float::from_int(player.hp) / 6.0 * 160.0).to_int(),
      8,
      @raylib.Color::new(112, 220, 146, 255),
    )

    @raylib.draw_rectangle(
      194,
      102,
      210,
      8,
      @raylib.Color::new(20, 26, 36, 255),
    )
    @raylib.draw_rectangle(
      194,
      102,
      (player.stamina / 100.0 * 210.0).to_int(),
      8,
      @raylib.Color::new(96, 198, 246, 255),
    )

    let loot_ratio = clampf(
      Float::from_int(looted) / Float::from_int(target_loot),
      0.0,
      1.0,
    )
    @raylib.draw_rectangle(
      420,
      102,
      220,
      8,
      @raylib.Color::new(20, 26, 36, 255),
    )
    @raylib.draw_rectangle(
      420,
      102,
      (loot_ratio * 220.0).to_int(),
      8,
      @raylib.Color::new(242, 188, 98, 255),
    )

    @raylib.draw_rectangle(
      8,
      sh - 194,
      236,
      186,
      @raylib.Color::new(8, 14, 28, 220),
    )
    @raylib.draw_text("Touch", 90, sh - 186, 20, @raylib.white)

    @raylib.draw_rectangle(
      pad_x + 76,
      pad_y,
      72,
      54,
      @raylib.Color::new(54, 72, 102, 255),
    )
    @raylib.draw_text("JMP", pad_x + 86, pad_y + 16, 22, @raylib.white)
    @raylib.draw_rectangle(
      pad_x,
      pad_y + 54,
      72,
      54,
      @raylib.Color::new(54, 72, 102, 255),
    )
    @raylib.draw_text("LT", pad_x + 20, pad_y + 70, 24, @raylib.white)
    @raylib.draw_rectangle(
      pad_x + 152,
      pad_y + 54,
      72,
      54,
      @raylib.Color::new(54, 72, 102, 255),
    )
    @raylib.draw_text("RT", pad_x + 172, pad_y + 70, 24, @raylib.white)

    @raylib.draw_rectangle(
      shoot_x,
      shoot_y,
      104,
      154,
      @raylib.Color::new(214, 110, 82, 255),
    )
    @raylib.draw_text("SHOOT", shoot_x + 8, shoot_y + 58, 26, @raylib.white)
    @raylib.draw_rectangle(
      dash_x,
      dash_y,
      104,
      154,
      @raylib.Color::new(98, 162, 220, 255),
    )
    @raylib.draw_text("DASH", dash_x + 18, dash_y + 58, 26, @raylib.white)
    @raylib.draw_rectangle(
      loot_x,
      loot_y,
      94,
      154,
      @raylib.Color::new(92, 180, 114, 255),
    )
    @raylib.draw_text("LOOT", loot_x + 14, loot_y + 58, 26, @raylib.white)

    @raylib.draw_rectangle(
      250,
      sh - 58,
      sw - 516,
      42,
      @raylib.Color::new(6, 10, 18, 220),
    )
    @raylib.draw_text(
      msg,
      262,
      sh - 50,
      24,
      @raylib.Color::new(224, 236, 248, 255),
    )

    if transition_t > 0.0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 112))
      @raylib.draw_text(
        "CHAPTER CLEAR",
        sw / 2 - 186,
        sh / 2 - 28,
        54,
        @raylib.Color::new(250, 236, 146, 255),
      )
    }

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 132))
      @raylib.draw_rectangle(
        sw / 2 - 360,
        sh / 2 - 112,
        720,
        224,
        @raylib.Color::new(16, 24, 42, 244),
      )
      @raylib.draw_text(
        if won {
          "LEGENDARY HEIST"
        } else {
          "HEIST FAILED"
        },
        sw / 2 - 270,
        sh / 2 - 32,
        64,
        if won {
          @raylib.Color::new(252, 238, 148, 255)
        } else {
          @raylib.Color::new(252, 140, 140, 255)
        },
      )
      @raylib.draw_text(
        "Press R to restart",
        sw / 2 - 124,
        sh / 2 + 48,
        34,
        @raylib.Color::new(224, 238, 252, 255),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
