///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let max_survivors : Int = 8

///|
let max_clouds : Int = 20

///|
struct Survivor {
  x : Float
  y : Float
  mut state : Int
}

///|
struct Cloud {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut r : Float
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
fn inside_rect(px : Float, py : Float, rx : Int, ry : Int, rw : Int, rh : Int) -> Bool {
  px >= Float::from_int(rx) && px <= Float::from_int(rx + rw) && py >= Float::from_int(ry) && py <= Float::from_int(ry + rh)
}

///|
fn ground_y(x : Float) -> Float {
  if x < 140.0 {
    700.0
  } else if x < 300.0 {
    700.0 - (x - 140.0) * 0.45
  } else if x < 470.0 {
    628.0
  } else if x < 650.0 {
    628.0 + (x - 470.0) * 0.35
  } else if x < 840.0 {
    691.0 - (x - 650.0) * 0.42
  } else if x < 1030.0 {
    611.0
  } else {
    611.0 + (x - 1030.0) * 0.30
  }
}

///|
fn clear_survivors(survivors : Array[Survivor]) -> Unit {
  for i = 0; i < survivors.length(); i = i + 1 {
    survivors[i] = { x: 0.0, y: 0.0, state: 3 }
  }
}

///|
fn set_survivor(survivors : Array[Survivor], i : Int, x : Float, y : Float) -> Unit {
  survivors[i] = { x: x, y: y, state: 0 }
}

///|
fn clear_clouds(clouds : Array[Cloud]) -> Unit {
  for i = 0; i < clouds.length(); i = i + 1 {
    clouds[i] = { x: 0.0, y: 0.0, vx: 0.0, r: 22.0, active: false }
  }
}

///|
fn spawn_cloud(clouds : Array[Cloud], level : Int) -> Unit {
  let side = @raylib.get_random_value(0, 1)
  let y = Float::from_int(@raylib.get_random_value(120, 560))
  let mut speed = Float::from_int(@raylib.get_random_value(60 + level * 16, 120 + level * 20))
  let x : Float = if side == 0 {
    -50.0
  } else {
    speed = -speed
    Float::from_int(sw + 50)
  }
  let r = Float::from_int(@raylib.get_random_value(20, 36))

  let mut done = false
  for i = 0; i < clouds.length(); i = i + 1 {
    if done {
      continue
    }
    if not(clouds[i].active) {
      clouds[i].active = true
      clouds[i].x = x
      clouds[i].y = y
      clouds[i].vx = speed
      clouds[i].r = r
      done = true
    }
  }
}

///|
fn setup_level(level : Int, survivors : Array[Survivor], clouds : Array[Cloud]) -> (Int, Int, Float, Float, Float, Float, Float, Float) {
  clear_survivors(survivors)
  clear_clouds(clouds)

  if level == 1 {
    set_survivor(survivors, 0, 470.0, ground_y(470.0) - 10.0)
    set_survivor(survivors, 1, 620.0, ground_y(620.0) - 10.0)
    set_survivor(survivors, 2, 860.0, ground_y(860.0) - 10.0)
    set_survivor(survivors, 3, 1020.0, ground_y(1020.0) - 10.0)

    let base_x : Float = 220.0
    let base_y = ground_y(base_x)
    (4, 3, base_x, base_y - 14.0, base_x, base_y, 790.0, 150.0)
  } else if level == 2 {
    set_survivor(survivors, 0, 320.0, ground_y(320.0) - 10.0)
    set_survivor(survivors, 1, 520.0, ground_y(520.0) - 10.0)
    set_survivor(survivors, 2, 730.0, ground_y(730.0) - 10.0)
    set_survivor(survivors, 3, 940.0, ground_y(940.0) - 10.0)
    set_survivor(survivors, 4, 1110.0, ground_y(1110.0) - 10.0)

    let base_x : Float = 245.0
    let base_y = ground_y(base_x)
    (5, 4, base_x, base_y - 14.0, base_x, base_y, 802.0, 165.0)
  } else {
    set_survivor(survivors, 0, 280.0, ground_y(280.0) - 10.0)
    set_survivor(survivors, 1, 430.0, ground_y(430.0) - 10.0)
    set_survivor(survivors, 2, 590.0, ground_y(590.0) - 10.0)
    set_survivor(survivors, 3, 790.0, ground_y(790.0) - 10.0)
    set_survivor(survivors, 4, 980.0, ground_y(980.0) - 10.0)
    set_survivor(survivors, 5, 1140.0, ground_y(1140.0) - 10.0)

    let base_x : Float = 260.0
    let base_y = ground_y(base_x)
    (6, 4, base_x, base_y - 14.0, base_x, base_y, 810.0, 180.0)
  }
}

///|
fn survivors_count(survivors : Array[Survivor], total : Int, state : Int) -> Int {
  let mut c = 0
  for i = 0; i < total; i = i + 1 {
    if survivors[i].state == state {
      c = c + 1
    }
  }
  c
}

///|
fn main {
  @raylib.init_window(sw, sh, "Volcano Airlift 2026")
  @raylib.set_target_fps(60)

  let survivors : Array[Survivor] = Array::makei(max_survivors, fn(_i) {
    { x: 0.0, y: 0.0, state: 3 }
  })
  let clouds : Array[Cloud] = Array::makei(max_clouds, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, r: 22.0, active: false }
  })

  let mut level = 1
  let mut total = 0
  let mut quota = 0

  let mut start_x : Float = 0.0
  let mut start_y : Float = 0.0
  let mut base_x : Float = 0.0
  let mut base_y : Float = 0.0
  let mut lava_y : Float = 0.0
  let mut timer : Float = 0.0

  let (t, q, sx, sy, bx, by, ly, tm) = setup_level(level, survivors, clouds)
  total = t
  quota = q
  start_x = sx
  start_y = sy
  base_x = bx
  base_y = by
  lava_y = ly
  timer = tm

  let mut hx = start_x
  let mut hy = start_y
  let mut hvx : Float = 0.0
  let mut hvy : Float = 0.0

  let mut fuel : Float = 100.0
  let mut hull = 5
  let mut hit_cd : Float = 0.0
  let mut spawn_cd : Float = 0.7
  let mut rotor_t : Float = 0.0

  let mut carrying = false
  let mut carry_idx = -1

  let mut score = 0
  let mut stars = 0

  let mut transition_t : Float = 0.0
  let mut flash_t : Float = 0.0
  let mut shake_t : Float = 0.0

  let mut over = false
  let mut won = false
  let mut msg = "A/D steer, W lift, S descend, Space pickup/drop."

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    rotor_t = rotor_t + dt * 20.0

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      let (rt, rq, rsx, rsy, rbx, rby, rly, rtm) = setup_level(level, survivors, clouds)
      total = rt
      quota = rq
      start_x = rsx
      start_y = rsy
      base_x = rbx
      base_y = rby
      lava_y = rly
      timer = rtm

      hx = start_x
      hy = start_y
      hvx = 0.0
      hvy = 0.0

      fuel = 100.0
      hull = 5
      hit_cd = 0.0
      spawn_cd = 0.7
      carrying = false
      carry_idx = -1

      score = 0
      stars = 0

      transition_t = 0.0
      flash_t = 0.0
      shake_t = 0.0

      over = false
      won = false
      msg = "Mission rebooted."
    }

    if hit_cd > 0.0 {
      hit_cd = hit_cd - dt
      if hit_cd < 0.0 {
        hit_cd = 0.0
      }
    }

    if transition_t > 0.0 {
      transition_t = transition_t - dt
      if transition_t <= 0.0 {
        transition_t = 0.0
        if level < 3 {
          level = level + 1
          let (nt, nq, nsx, nsy, nbx, nby, nly, ntm) = setup_level(level, survivors, clouds)
          total = nt
          quota = nq
          start_x = nsx
          start_y = nsy
          base_x = nbx
          base_y = nby
          lava_y = nly
          timer = ntm

          hx = start_x
          hy = start_y
          hvx = 0.0
          hvy = 0.0

          fuel = 100.0
          carrying = false
          carry_idx = -1
          spawn_cd = 0.7
          msg = "Sector \{level} initialized."
        } else {
          over = true
          won = true
          msg = "Airlift complete."
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

    if not(over) && transition_t <= 0.0 {
      timer = timer - dt
      if timer <= 0.0 {
        timer = 0.0
        over = true
        won = false
        msg = "Storm consumed the sector."
      }

      let rise_speed : Float = Float::from_int(8 + level * 2)
      lava_y = lava_y - rise_speed * dt
      if lava_y < 430.0 {
        lava_y = 430.0
      }

      let mut left = @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft)
      let mut right = @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight)
      let mut up = @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp)
      let mut down = @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown)
      let mut action = @raylib.is_key_pressed(@raylib.KeySpace) || @raylib.is_key_pressed(@raylib.KeyJ)

      let m = @raylib.get_mouse_position()
      let ctl_x = 20
      let ctl_y = sh - 176
      let action_x = sw - 206
      let action_y = sh - 154

      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, ctl_x, ctl_y, 74, 54) {
          left = true
        }
        if inside_rect(m.x, m.y, ctl_x + 82, ctl_y, 74, 54) {
          right = true
        }
        if inside_rect(m.x, m.y, ctl_x, ctl_y + 60, 74, 54) {
          up = true
        }
        if inside_rect(m.x, m.y, ctl_x + 82, ctl_y + 60, 74, 54) {
          down = true
        }
      }
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(m.x, m.y, action_x, action_y, 176, 120) {
          action = true
        }
      }

      let mut ax : Float = 0.0
      let mut ay : Float = 220.0

      if left {
        ax = ax - 170.0
      }
      if right {
        ax = ax + 170.0
      }
      if up && fuel > 0.0 {
        ay = ay - 420.0
        fuel = fuel - 16.0 * dt
        if fuel < 0.0 {
          fuel = 0.0
        }
      }
      if down {
        ay = ay + 120.0
      }

      hvx = hvx + ax * dt
      hvy = hvy + ay * dt

      hvx = hvx * (Float::from_int(1) - dt * 0.60)
      hvy = hvy * (Float::from_int(1) - dt * 0.30)

      hvx = clampf(hvx, -260.0, 260.0)
      hvy = clampf(hvy, -280.0, 300.0)

      hx = hx + hvx * dt
      hy = hy + hvy * dt

      hx = clampf(hx, 24.0, Float::from_int(sw - 24))
      if hy < 60.0 {
        hy = 60.0
        hvy = hvy.abs() * 0.2
      }

      let gy = ground_y(hx)
      if hy + 14.0 >= gy {
        if absf(hvy) > 110.0 || absf(hvx) > 130.0 {
          hull = hull - 1
          flash_t = 0.30
          shake_t = 0.22
          msg = "Hard crash! Hull -1"

          if carrying && carry_idx >= 0 {
            survivors[carry_idx].state = 3
            carrying = false
            carry_idx = -1
            msg = "Crash lost a survivor."
          }

          if hull <= 0 {
            hull = 0
            over = true
            won = false
            msg = "Aircraft destroyed."
          } else {
            hx = start_x
            hy = start_y
            hvx = 0.0
            hvy = 0.0
            fuel = fuel - 18.0
            if fuel < 10.0 {
              fuel = 10.0
            }
          }
        } else {
          hy = gy - 14.0
          hvy = 0.0
          hvx = hvx * 0.70
        }
      }

      if carrying && carry_idx >= 0 {
        let near_base = absf(hx - base_x) <= 74.0 && hy >= base_y - 104.0 && hy <= base_y - 18.0
        if action && near_base {
          survivors[carry_idx].state = 2
          carrying = false
          carry_idx = -1
          score = score + 120 + (timer.to_int() / 2)
          msg = "Survivor dropped at base."
          action = false
        }
      }

      if action && not(carrying) {
        for i = 0; i < total; i = i + 1 {
          if survivors[i].state != 0 {
            continue
          }
          let dx = hx - survivors[i].x
          let dy = hy - (survivors[i].y - 24.0)
          if dx * dx + dy * dy <= 36.0 * 36.0 {
            survivors[i].state = 1
            carrying = true
            carry_idx = i
            msg = "Survivor onboard."
            break
          }
        }
      }

      for i = 0; i < total; i = i + 1 {
        if survivors[i].state == 0 && survivors[i].y + 10.0 >= lava_y {
          survivors[i].state = 3
          msg = "Lava reached a survivor."
        }
      }

      spawn_cd = spawn_cd - dt
      if spawn_cd <= 0.0 {
        spawn_cloud(clouds, level)
        let mut next : Float = 0.78 - Float::from_int(level) * 0.10
        if next < 0.22 {
          next = 0.22
        }
        spawn_cd = next
      }

      for i = 0; i < clouds.length(); i = i + 1 {
        if not(clouds[i].active) {
          continue
        }

        clouds[i].x = clouds[i].x + clouds[i].vx * dt

        if clouds[i].vx > 0.0 && clouds[i].x > Float::from_int(sw + 60) {
          clouds[i].active = false
        }
        if clouds[i].vx < 0.0 && clouds[i].x < -60.0 {
          clouds[i].active = false
        }

        if hit_cd <= 0.0 {
          let dx = clouds[i].x - hx
          let dy = clouds[i].y - hy
          let rr = clouds[i].r + 14.0
          if dx * dx + dy * dy <= rr * rr {
            hull = hull - 1
            hit_cd = 1.0
            flash_t = 0.24
            shake_t = 0.18
            msg = "Ash cloud impact."
            if hull <= 0 {
              hull = 0
              over = true
              won = false
              msg = "Aircraft destroyed in storm."
            }
          }
        }
      }

      let rescued = survivors_count(survivors, total, 2)
      let lost = survivors_count(survivors, total, 3)

      if lost > total - quota {
        over = true
        won = false
        msg = "Evac quota failed."
      }

      if rescued >= quota && rescued + lost == total {
        let mut bonus = 220 + hull * 30 + fuel.to_int()
        if bonus < 80 {
          bonus = 80
        }
        score = score + bonus

        if lost == 0 {
          stars = stars + 3
        } else if lost == 1 {
          stars = stars + 2
        } else {
          stars = stars + 1
        }

        transition_t = 1.2
        msg = "Sector cleared."
      }
    }

    let rescued_now = survivors_count(survivors, total, 2)
    let lost_now = survivors_count(survivors, total, 3)
    let onboard_now = if carrying { 1 } else { 0 }

    let shake_x = if shake_t > 0.0 {
      Float::from_int(@raylib.get_random_value(-6, 6)) * shake_t * 8.0
    } else {
      0.0
    }

    @raylib.begin_drawing()

    if flash_t > 0.0 {
      @raylib.clear_background(@raylib.Color::new(42, 20, 20, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(18, 28, 44, 255))
    }

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(20, 34, 56, 255))
    @raylib.draw_rectangle(0, 0, sw, 260, @raylib.Color::new(36, 58, 92, 255))

    // Terrain
    for x = 0; x < sw; x = x + 6 {
      let gx = Float::from_int(x)
      let gy = ground_y(gx)
      @raylib.draw_rectangle(x, gy.to_int(), 7, sh - gy.to_int(), @raylib.Color::new(84, 72, 64, 255))
      if x % 24 == 0 {
        @raylib.draw_rectangle(x, gy.to_int(), 7, 6, @raylib.Color::new(112, 98, 86, 255))
      }
    }

    // Base pad
    @raylib.draw_rectangle((base_x - 62.0 + shake_x).to_int(), (base_y - 10.0).to_int(), 124, 10, @raylib.Color::new(220, 226, 232, 255))
    @raylib.draw_rectangle((base_x - 10.0 + shake_x).to_int(), (base_y - 44.0).to_int(), 20, 34, @raylib.Color::new(88, 110, 136, 255))
    @raylib.draw_text("BASE", (base_x - 34.0 + shake_x).to_int(), (base_y - 70.0).to_int(), 22, @raylib.Color::new(236, 244, 252, 255))

    // Survivors
    for i = 0; i < total; i = i + 1 {
      if survivors[i].state == 0 {
        let sx = (survivors[i].x + shake_x).to_int()
        let sy = survivors[i].y.to_int()
        @raylib.draw_circle(sx, sy - 14, 8.0, @raylib.Color::new(248, 228, 170, 255))
        @raylib.draw_rectangle(sx - 7, sy - 6, 14, 20, @raylib.Color::new(220, 96, 96, 255))
      } else if survivors[i].state == 3 {
        let sx = (survivors[i].x + shake_x).to_int()
        let sy = survivors[i].y.to_int()
        @raylib.draw_rectangle(sx - 7, sy - 6, 14, 18, @raylib.Color::new(80, 62, 54, 255))
      }
    }

    // Clouds
    for i = 0; i < clouds.length(); i = i + 1 {
      if not(clouds[i].active) {
        continue
      }
      let cx = (clouds[i].x + shake_x).to_int()
      let cy = clouds[i].y.to_int()
      @raylib.draw_circle(cx, cy, clouds[i].r, @raylib.Color::new(72, 78, 92, 255))
      @raylib.draw_circle(cx - 16, cy + 4, clouds[i].r * 0.7, @raylib.Color::new(88, 94, 108, 255))
      @raylib.draw_circle(cx + 16, cy + 5, clouds[i].r * 0.72, @raylib.Color::new(88, 94, 108, 255))
    }

    // Helicopter
    if not(over) || won {
      let hx_i = (hx + shake_x).to_int()
      let hy_i = hy.to_int()

      @raylib.draw_rectangle(hx_i - 20, hy_i - 10, 40, 20, @raylib.Color::new(90, 220, 240, 255))
      @raylib.draw_rectangle(hx_i + 16, hy_i - 6, 16, 12, @raylib.Color::new(70, 182, 214, 255))
      @raylib.draw_circle(hx_i - 8, hy_i - 2, 8.0, @raylib.Color::new(206, 244, 250, 255))

      let rotor = (rotor_t.to_int() % 14) - 7
      @raylib.draw_line(hx_i - 42 + rotor, hy_i - 18, hx_i + 42 + rotor, hy_i - 18, @raylib.Color::new(230, 240, 248, 255))

      @raylib.draw_line(hx_i - 18, hy_i + 12, hx_i - 10, hy_i + 20, @raylib.Color::new(224, 228, 236, 255))
      @raylib.draw_line(hx_i + 18, hy_i + 12, hx_i + 10, hy_i + 20, @raylib.Color::new(224, 228, 236, 255))
      @raylib.draw_line(hx_i - 20, hy_i + 20, hx_i + 20, hy_i + 20, @raylib.Color::new(224, 228, 236, 255))

      if carrying {
        @raylib.draw_line(hx_i, hy_i + 10, hx_i, hy_i + 36, @raylib.Color::new(230, 230, 230, 255))
        @raylib.draw_circle(hx_i, hy_i + 48, 8.0, @raylib.Color::new(248, 228, 170, 255))
        @raylib.draw_rectangle(hx_i - 7, hy_i + 56, 14, 18, @raylib.Color::new(220, 96, 96, 255))
      }
    }

    // Lava
    @raylib.draw_rectangle(0, lava_y.to_int(), sw, sh - lava_y.to_int(), @raylib.Color::new(236, 94, 54, 255))
    @raylib.draw_rectangle(0, lava_y.to_int(), sw, 10, @raylib.Color::new(252, 176, 80, 255))

    @raylib.draw_rectangle(0, 0, sw, 98, @raylib.Color::new(10, 14, 22, 230))
    @raylib.draw_text("VOLCANO AIRLIFT 2026", 16, 20, 34, @raylib.Color::new(236, 244, 252, 255))
    @raylib.draw_text("Sector \{level}/3", 436, 30, 30, @raylib.Color::new(246, 230, 136, 255))
    @raylib.draw_text("HP \{hull}", 616, 30, 30, @raylib.Color::new(214, 236, 252, 255))
    @raylib.draw_text("Fuel \{fuel.to_int()}", 730, 30, 30, @raylib.Color::new(214, 236, 252, 255))
    @raylib.draw_text("Score \{score}", 930, 30, 30, @raylib.Color::new(214, 236, 252, 255))

    @raylib.draw_text("Rescued \{rescued_now}/\{quota}  Lost \{lost_now}  Onboard \{onboard_now}", 20, 72, 22, @raylib.Color::new(224, 236, 246, 255))
    @raylib.draw_text("Timer \{timer.to_int()}", 1010, 72, 24, @raylib.Color::new(250, 220, 156, 255))

    @raylib.draw_rectangle(20, 104, 260, 10, @raylib.Color::new(34, 40, 52, 255))
    @raylib.draw_rectangle(20, 104, (fuel / 100.0 * 260.0).to_int(), 10, @raylib.Color::new(110, 216, 250, 255))

    let ctl_x = 20
    let ctl_y = sh - 176
    @raylib.draw_rectangle(8, sh - 190, 160, 180, @raylib.Color::new(10, 16, 28, 220))
    @raylib.draw_text("Touch", 56, sh - 186, 20, @raylib.white)

    @raylib.draw_rectangle(ctl_x, ctl_y, 74, 54, @raylib.Color::new(46, 64, 90, 255))
    @raylib.draw_text("LEFT", ctl_x + 12, ctl_y + 18, 20, @raylib.white)
    @raylib.draw_rectangle(ctl_x + 82, ctl_y, 74, 54, @raylib.Color::new(46, 64, 90, 255))
    @raylib.draw_text("RIGHT", ctl_x + 86, ctl_y + 18, 20, @raylib.white)
    @raylib.draw_rectangle(ctl_x, ctl_y + 60, 74, 54, @raylib.Color::new(46, 64, 90, 255))
    @raylib.draw_text("LIFT", ctl_x + 14, ctl_y + 78, 20, @raylib.white)
    @raylib.draw_rectangle(ctl_x + 82, ctl_y + 60, 74, 54, @raylib.Color::new(46, 64, 90, 255))
    @raylib.draw_text("DOWN", ctl_x + 86, ctl_y + 78, 20, @raylib.white)

    let action_x = sw - 206
    let action_y = sh - 154
    @raylib.draw_rectangle(action_x, action_y, 176, 120, @raylib.Color::new(188, 82, 76, 255))
    @raylib.draw_text(if carrying { "DROP" } else { "PICK" }, action_x + 48, action_y + 40, 38, @raylib.white)

    @raylib.draw_rectangle(176, sh - 52, sw - 390, 36, @raylib.Color::new(10, 16, 24, 220))
    @raylib.draw_text(msg, 186, sh - 46, 22, @raylib.Color::new(224, 236, 246, 255))

    @raylib.draw_text("Stars \{stars}", sw - 170, 116, 28, @raylib.Color::new(250, 226, 130, 255))

    if transition_t > 0.0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 18, 120))
      @raylib.draw_text("SECTOR CLEAR", sw / 2 - 174, sh / 2 - 24, 54, @raylib.Color::new(248, 236, 146, 255))
    }

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 126))
      @raylib.draw_rectangle(sw / 2 - 330, sh / 2 - 100, 660, 200, @raylib.Color::new(16, 24, 40, 242))
      @raylib.draw_text(
        if won { "MISSION COMPLETE" } else { "MISSION FAILED" },
        sw / 2 - 240,
        sh / 2 - 34,
        56,
        if won { @raylib.Color::new(248, 236, 142, 255) } else { @raylib.Color::new(250, 132, 132, 255) },
      )
      @raylib.draw_text("Press R to restart", sw / 2 - 124, sh / 2 + 40, 32, @raylib.Color::new(226, 238, 252, 255))
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
