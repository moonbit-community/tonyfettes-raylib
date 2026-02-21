///|
let sw : Int = 1280

///|
let sh : Int = 800

///|
let table_x : Int = 80

///|
let table_y : Int = 110

///|
let table_w : Int = 1120

///|
let table_h : Int = 620

///|
let goal_h : Int = 220

///|
let paddle_r : Float = 34.0

///|
let puck_r : Float = 14.0

///|
let max_sparks : Int = 180

///|
struct Spark {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut active : Bool
}

///|
fn absf(x : Float) -> Float {
  if x < 0.0 {
    -x
  } else {
    x
  }
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
fn inside_rect(px : Float, py : Float, rx : Int, ry : Int, rw : Int, rh : Int) -> Bool {
  px >= Float::from_int(rx) && px <= Float::from_int(rx + rw) && py >= Float::from_int(ry) && py <= Float::from_int(ry + rh)
}

///|
fn table_left() -> Float {
  Float::from_int(table_x)
}

///|
fn table_right() -> Float {
  Float::from_int(table_x + table_w)
}

///|
fn table_top() -> Float {
  Float::from_int(table_y)
}

///|
fn table_bottom() -> Float {
  Float::from_int(table_y + table_h)
}

///|
fn goal_top() -> Float {
  Float::from_int(table_y + (table_h - goal_h) / 2)
}

///|
fn goal_bottom() -> Float {
  goal_top() + Float::from_int(goal_h)
}

///|
fn clear_sparks(sparks : Array[Spark]) -> Unit {
  for i = 0; i < sparks.length(); i = i + 1 {
    sparks[i].x = 0.0
    sparks[i].y = 0.0
    sparks[i].vx = 0.0
    sparks[i].vy = 0.0
    sparks[i].ttl = 0.0
    sparks[i].active = false
  }
}

///|
fn spawn_spark(sparks : Array[Spark], x : Float, y : Float, speed_scale : Float, color_bias : Int) -> Unit {
  let mut placed = false
  for i = 0; i < sparks.length(); i = i + 1 {
    if placed {
      continue
    }
    if not(sparks[i].active) {
      sparks[i].active = true
      sparks[i].x = x
      sparks[i].y = y

      let mut vx = Float::from_int(@raylib.get_random_value(-220, 220)) * speed_scale
      let vy = Float::from_int(@raylib.get_random_value(-220, 220)) * speed_scale
      if color_bias > 0 {
        vx = vx + Float::from_int(color_bias)
      } else if color_bias < 0 {
        vx = vx - Float::from_int(-color_bias)
      }

      sparks[i].vx = vx
      sparks[i].vy = vy
      sparks[i].ttl = Float::from_int(@raylib.get_random_value(18, 45)) / Float::from_int(100)
      placed = true
    }
  }
}

///|
fn spawn_burst(sparks : Array[Spark], x : Float, y : Float, n : Int, speed_scale : Float, color_bias : Int) -> Unit {
  for i = 0; i < n; i = i + 1 {
    spawn_spark(sparks, x, y, speed_scale, color_bias)
  }
}

///|
fn reset_round() -> (Float, Float, Float, Float, Float, Float, Float, Float, Float) {
  let cx = Float::from_int(table_x + table_w / 2)
  let cy = Float::from_int(table_y + table_h / 2)
  (
    Float::from_int(table_x + table_w / 4),
    cy,
    Float::from_int(table_x + table_w * 3 / 4),
    cy,
    cx,
    cy,
    0.0,
    0.0,
    1.0,
  )
}

///|
fn goal_opening(y : Float) -> Bool {
  y >= goal_top() && y <= goal_bottom()
}

///|
fn paddle_hit(
  px : Float,
  py : Float,
  pr : Float,
  puck_x : Float,
  puck_y : Float,
) -> Bool {
  let dx = puck_x - px
  let dy = puck_y - py
  let rr = (pr + puck_r) * (pr + puck_r)
  dx * dx + dy * dy <= rr
}

///|
fn main {
  @raylib.init_window(sw, sh, "Neon Air Hockey 2026")
  @raylib.set_target_fps(60)

  let sparks : Array[Spark] = Array::makei(max_sparks, fn(_i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ttl: 0.0, active: false }
  })
  clear_sparks(sparks)

  let mut sector = 1
  let mut target_goals = 5
  let mut p_goals = 0
  let mut ai_goals = 0
  let mut p_total = 0
  let mut ai_total = 0
  let mut score = 0

  let mut px : Float = 0.0
  let mut py : Float = 0.0
  let mut aix : Float = 0.0
  let mut aiy : Float = 0.0
  let mut puck_x : Float = 0.0
  let mut puck_y : Float = 0.0
  let mut puck_vx : Float = 0.0
  let mut puck_vy : Float = 0.0
  let mut faceoff_t : Float = 0.0

  let (rpx, rpy, raix, raiy, rx, ry, rvx, rvy, rface) = reset_round()
  px = rpx
  py = rpy
  aix = raix
  aiy = raiy
  puck_x = rx
  puck_y = ry
  puck_vx = rvx
  puck_vy = rvy
  faceoff_t = rface

  let mut px_prev = px
  let mut py_prev = py
  let mut aix_prev = aix
  let mut aiy_prev = aiy

  let mut fire_cd : Float = 0.0
  let mut dash_cd : Float = 0.0

  let mut zone_t : Float = 0.0
  let mut zone_phase : Float = 0.0
  let mut zone_left = true

  let mut camera_shake : Float = 0.0
  let mut hit_flash : Float = 0.0

  let mut over = false
  let mut won = false
  let mut msg = "WASD move, arrows aim, Space/J strike. First to sector goals."

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      sector = 1
      target_goals = 5
      p_goals = 0
      ai_goals = 0
      p_total = 0
      ai_total = 0
      score = 0

      let (npx, npy, naix, naiy, nx, ny, nvx, nvy, nface) = reset_round()
      px = npx
      py = npy
      aix = naix
      aiy = naiy
      puck_x = nx
      puck_y = ny
      puck_vx = nvx
      puck_vy = nvy
      faceoff_t = nface

      px_prev = px
      py_prev = py
      aix_prev = aix
      aiy_prev = aiy

      fire_cd = 0.0
      dash_cd = 0.0
      zone_t = 0.0
      zone_phase = 0.0
      zone_left = true
      camera_shake = 0.0
      hit_flash = 0.0
      over = false
      won = false
      msg = "Match restarted."
      clear_sparks(sparks)
    }

    if fire_cd > 0.0 {
      fire_cd = fire_cd - dt
      if fire_cd < 0.0 {
        fire_cd = 0.0
      }
    }

    if dash_cd > 0.0 {
      dash_cd = dash_cd - dt
      if dash_cd < 0.0 {
        dash_cd = 0.0
      }
    }

    if camera_shake > 0.0 {
      camera_shake = camera_shake - dt
      if camera_shake < 0.0 {
        camera_shake = 0.0
      }
    }

    if hit_flash > 0.0 {
      hit_flash = hit_flash - dt
      if hit_flash < 0.0 {
        hit_flash = 0.0
      }
    }

    zone_t = zone_t + dt
    if zone_t >= 5.2 {
      zone_t = 0.0
      zone_left = not(zone_left)
    }
    zone_phase = zone_phase + dt * 0.9
    if zone_phase > 1.0 {
      zone_phase = zone_phase - 1.0
    }

    if not(over) {
      px_prev = px
      py_prev = py
      aix_prev = aix
      aiy_prev = aiy

      let mut move_x : Float = 0.0
      let mut move_y : Float = 0.0
      if @raylib.is_key_down(@raylib.KeyA) {
        move_x = move_x - 1.0
      }
      if @raylib.is_key_down(@raylib.KeyD) {
        move_x = move_x + 1.0
      }
      if @raylib.is_key_down(@raylib.KeyW) {
        move_y = move_y - 1.0
      }
      if @raylib.is_key_down(@raylib.KeyS) {
        move_y = move_y + 1.0
      }

      let ctl_x = 26
      let ctl_y = sh - 170
      let fire_x = sw - 210
      let fire_y = sh - 150
      let m = @raylib.get_mouse_position()
      let touch = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
      let mut strike_down = @raylib.is_key_down(@raylib.KeySpace) || @raylib.is_key_down(@raylib.KeyJ) || @raylib.is_key_down(@raylib.KeyK)

      if touch {
        if inside_rect(m.x, m.y, ctl_x, ctl_y, 72, 52) {
          move_x = move_x - 1.0
        }
        if inside_rect(m.x, m.y, ctl_x + 80, ctl_y, 72, 52) {
          move_x = move_x + 1.0
        }
        if inside_rect(m.x, m.y, ctl_x, ctl_y + 58, 72, 52) {
          move_y = move_y + 1.0
        }
        if inside_rect(m.x, m.y, ctl_x + 80, ctl_y + 58, 72, 52) {
          move_y = move_y - 1.0
        }
        if inside_rect(m.x, m.y, fire_x, fire_y, 170, 116) {
          strike_down = true
        }
      }

      let player_speed : Float = Float::from_int(380 + sector * 18)
      px = px + move_x * player_speed * dt
      py = py + move_y * player_speed * dt

      px = clampf(px, table_left() + paddle_r + 4.0, Float::from_int(table_x + table_w / 2 - 26))
      py = clampf(py, table_top() + paddle_r + 4.0, table_bottom() - paddle_r - 4.0)

      let ai_target_x = if puck_x > Float::from_int(table_x + table_w / 2) {
        Float::from_int(table_x + table_w * 3 / 4)
      } else {
        Float::from_int(table_x + table_w * 13 / 16)
      }
      let ai_target_y = clampf(puck_y + puck_vy * 0.14, table_top() + 50.0, table_bottom() - 50.0)
      let ai_speed : Float = Float::from_int(316 + sector * 30)

      if aix < ai_target_x {
        aix = aix + ai_speed * dt
      } else {
        aix = aix - ai_speed * dt
      }
      if aiy < ai_target_y {
        aiy = aiy + ai_speed * dt
      } else {
        aiy = aiy - ai_speed * dt
      }

      aix = clampf(aix, Float::from_int(table_x + table_w / 2 + 26), table_right() - paddle_r - 4.0)
      aiy = clampf(aiy, table_top() + paddle_r + 4.0, table_bottom() - paddle_r - 4.0)

      if faceoff_t > 0.0 {
        faceoff_t = faceoff_t - dt
        if faceoff_t <= 0.0 {
          faceoff_t = 0.0
          let dir : Float = if @raylib.get_random_value(0, 1) == 0 {
            -Float::from_int(1)
          } else {
            Float::from_int(1)
          }
          puck_vx = dir * Float::from_int(@raylib.get_random_value(220, 300))
          puck_vy = Float::from_int(@raylib.get_random_value(-170, 170))
          msg = "Faceoff!"
        } else {
          let cx = Float::from_int(table_x + table_w / 2)
          let cy = Float::from_int(table_y + table_h / 2)
          puck_x = cx
          puck_y = cy
          puck_vx = 0.0
          puck_vy = 0.0
        }
      } else {
        if strike_down && fire_cd <= 0.0 {
          let dx = puck_x - px
          let dy = puck_y - py
          let d2 = dx * dx + dy * dy
          if d2 <= 140.0 * 140.0 {
            let d = d2.sqrt()
            if d > 0.01 {
              let power : Float = if dash_cd <= 0.0 { 460.0 } else { 320.0 }
              puck_vx = puck_vx + dx / d * power
              puck_vy = puck_vy + dy / d * power
              fire_cd = 0.18
              if dash_cd <= 0.0 {
                dash_cd = 0.9
              }
              camera_shake = 0.16
              spawn_burst(sparks, puck_x, puck_y, 12, 1.0, 60)
            }
          }
        }

        let left_zone_x = Float::from_int(table_x + 210)
        let right_zone_x = Float::from_int(table_x + table_w - 210)
        let zone_y = Float::from_int(table_y + table_h / 2)
        let zone_r : Float = 70.0

        if zone_left {
          let dx = puck_x - left_zone_x
          let dy = puck_y - zone_y
          if dx * dx + dy * dy <= zone_r * zone_r {
            puck_vx = puck_vx * 1.008
            puck_vy = puck_vy * 1.008
          }
        } else {
          let dx = puck_x - right_zone_x
          let dy = puck_y - zone_y
          if dx * dx + dy * dy <= zone_r * zone_r {
            puck_vx = puck_vx * 1.008
            puck_vy = puck_vy * 1.008
          }
        }

        puck_x = puck_x + puck_vx * dt
        puck_y = puck_y + puck_vy * dt

        puck_vx = puck_vx * (Float::from_int(1) - dt * 0.30)
        puck_vy = puck_vy * (Float::from_int(1) - dt * 0.30)

        if absf(puck_vx) < 6.0 {
          puck_vx = 0.0
        }
        if absf(puck_vy) < 6.0 {
          puck_vy = 0.0
        }

        if puck_y <= table_top() + puck_r {
          puck_y = table_top() + puck_r
          puck_vy = absf(puck_vy) * 0.94
          spawn_burst(sparks, puck_x, puck_y, 4, 0.6, 0)
        }
        if puck_y >= table_bottom() - puck_r {
          puck_y = table_bottom() - puck_r
          puck_vy = -absf(puck_vy) * 0.94
          spawn_burst(sparks, puck_x, puck_y, 4, 0.6, 0)
        }

        if puck_x <= table_left() + puck_r {
          if goal_opening(puck_y) {
            ai_goals = ai_goals + 1
            ai_total = ai_total + 1
            hit_flash = 0.30
            camera_shake = 0.20
            spawn_burst(sparks, table_left() + 8.0, puck_y, 24, 1.2, -90)

            let (npx, npy, naix, naiy, nx, ny, nvx, nvy, nface) = reset_round()
            px = npx
            py = npy
            aix = naix
            aiy = naiy
            puck_x = nx
            puck_y = ny
            puck_vx = nvx
            puck_vy = nvy
            faceoff_t = nface
            msg = "Enemy scored."
          } else {
            puck_x = table_left() + puck_r
            puck_vx = absf(puck_vx) * 0.96
            spawn_burst(sparks, puck_x, puck_y, 4, 0.7, 0)
          }
        }

        if puck_x >= table_right() - puck_r {
          if goal_opening(puck_y) {
            p_goals = p_goals + 1
            p_total = p_total + 1
            score = score + 120 + sector * 30
            camera_shake = 0.20
            spawn_burst(sparks, table_right() - 8.0, puck_y, 24, 1.2, 90)

            let (npx, npy, naix, naiy, nx, ny, nvx, nvy, nface) = reset_round()
            px = npx
            py = npy
            aix = naix
            aiy = naiy
            puck_x = nx
            puck_y = ny
            puck_vx = nvx
            puck_vy = nvy
            faceoff_t = nface
            msg = "Goal!"
          } else {
            puck_x = table_right() - puck_r
            puck_vx = -absf(puck_vx) * 0.96
            spawn_burst(sparks, puck_x, puck_y, 4, 0.7, 0)
          }
        }

        if paddle_hit(px, py, paddle_r, puck_x, puck_y) {
          let dx = puck_x - px
          let dy = puck_y - py
          let d = (dx * dx + dy * dy).sqrt()
          if d > 0.01 {
            let nx = dx / d
            let ny = dy / d
            puck_x = px + nx * (paddle_r + puck_r + 1.0)
            puck_y = py + ny * (paddle_r + puck_r + 1.0)

            let p_vel_x = (px - px_prev) / dt
            let p_vel_y = (py - py_prev) / dt
            let rel = puck_vx * nx + puck_vy * ny - (p_vel_x * nx + p_vel_y * ny)
            if rel < 0.0 {
              puck_vx = puck_vx - nx * rel * 1.74 + p_vel_x * 0.22
              puck_vy = puck_vy - ny * rel * 1.74 + p_vel_y * 0.22
              camera_shake = 0.08
              spawn_burst(sparks, puck_x, puck_y, 8, 0.9, 70)
            }
          }
        }

        if paddle_hit(aix, aiy, paddle_r, puck_x, puck_y) {
          let dx = puck_x - aix
          let dy = puck_y - aiy
          let d = (dx * dx + dy * dy).sqrt()
          if d > 0.01 {
            let nx = dx / d
            let ny = dy / d
            puck_x = aix + nx * (paddle_r + puck_r + 1.0)
            puck_y = aiy + ny * (paddle_r + puck_r + 1.0)

            let ai_vel_x = (aix - aix_prev) / dt
            let ai_vel_y = (aiy - aiy_prev) / dt
            let rel = puck_vx * nx + puck_vy * ny - (ai_vel_x * nx + ai_vel_y * ny)
            if rel < 0.0 {
              puck_vx = puck_vx - nx * rel * 1.70 + ai_vel_x * 0.20
              puck_vy = puck_vy - ny * rel * 1.70 + ai_vel_y * 0.20
              camera_shake = 0.08
              spawn_burst(sparks, puck_x, puck_y, 8, 0.9, -70)
            }
          }
        }
      }

      if p_goals >= target_goals {
        sector = sector + 1
        if sector > 3 {
          over = true
          won = true
          msg = "Champion run complete."
        } else {
          p_goals = 0
          ai_goals = 0
          target_goals = 5 + sector - 1
          let (npx, npy, naix, naiy, nx, ny, nvx, nvy, nface) = reset_round()
          px = npx
          py = npy
          aix = naix
          aiy = naiy
          puck_x = nx
          puck_y = ny
          puck_vx = nvx
          puck_vy = nvy
          faceoff_t = nface
          msg = "Sector \{sector} unlocked."
        }
      }

      if ai_goals >= target_goals {
        over = true
        won = false
        msg = "AI wins this match. Press R to retry."
      }
    }

    for i = 0; i < sparks.length(); i = i + 1 {
      if not(sparks[i].active) {
        continue
      }
      sparks[i].x = sparks[i].x + sparks[i].vx * dt
      sparks[i].y = sparks[i].y + sparks[i].vy * dt
      sparks[i].vx = sparks[i].vx * (Float::from_int(1) - dt * 2.2)
      sparks[i].vy = sparks[i].vy * (Float::from_int(1) - dt * 2.2)
      sparks[i].ttl = sparks[i].ttl - dt
      if sparks[i].ttl <= 0.0 {
        sparks[i].active = false
      }
    }

    let shake = if camera_shake > 0.0 {
      Float::from_int(@raylib.get_random_value(-6, 6)) * camera_shake * 8.0
    } else {
      0.0
    }

    @raylib.begin_drawing()

    if hit_flash > 0.0 {
      @raylib.clear_background(@raylib.Color::new(46, 18, 24, 255))
    } else {
      @raylib.clear_background(@raylib.Color::new(10, 14, 24, 255))
    }

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(14, 22, 38, 255))
    @raylib.draw_rectangle(0, 0, sw, 240, @raylib.Color::new(22, 36, 62, 255))

    let tx = table_x + shake.to_int()

    @raylib.draw_rectangle(tx, table_y, table_w, table_h, @raylib.Color::new(22, 30, 48, 255))
    @raylib.draw_rectangle_lines(tx, table_y, table_w, table_h, @raylib.Color::new(84, 130, 214, 255))

    @raylib.draw_line(tx + table_w / 2, table_y, tx + table_w / 2, table_y + table_h, @raylib.Color::new(74, 108, 170, 255))
    @raylib.draw_circle_lines(tx + table_w / 2, table_y + table_h / 2, 120.0, @raylib.Color::new(74, 108, 170, 255))

    let gy = table_y + (table_h - goal_h) / 2
    @raylib.draw_rectangle(tx - 8, gy, 8, goal_h, @raylib.Color::new(242, 98, 120, 255))
    @raylib.draw_rectangle(tx + table_w, gy, 8, goal_h, @raylib.Color::new(98, 232, 170, 255))

    let pulse = (Float::from_int(1) - absf(zone_phase - 0.5) * 2.0)
    let glow = (Float::from_int(40) + pulse * 90.0).to_int()

    if zone_left {
      @raylib.draw_circle(
        (Float::from_int(tx + 210)).to_int(),
        table_y + table_h / 2,
        70.0,
        @raylib.Color::new(72, 206, 246, glow),
      )
      @raylib.draw_text("BOOST", tx + 176, table_y + table_h / 2 - 10, 20, @raylib.Color::new(210, 236, 252, 255))
    } else {
      @raylib.draw_circle(
        (Float::from_int(tx + table_w - 210)).to_int(),
        table_y + table_h / 2,
        70.0,
        @raylib.Color::new(250, 164, 96, glow),
      )
      @raylib.draw_text("BOOST", tx + table_w - 244, table_y + table_h / 2 - 10, 20, @raylib.Color::new(254, 228, 180, 255))
    }

    @raylib.draw_circle((px + shake).to_int(), py.to_int(), paddle_r, @raylib.Color::new(74, 202, 252, 255))
    @raylib.draw_circle((px + shake).to_int(), py.to_int(), paddle_r * 0.52, @raylib.Color::new(20, 44, 72, 255))

    @raylib.draw_circle((aix + shake).to_int(), aiy.to_int(), paddle_r, @raylib.Color::new(252, 126, 132, 255))
    @raylib.draw_circle((aix + shake).to_int(), aiy.to_int(), paddle_r * 0.52, @raylib.Color::new(72, 22, 30, 255))

    @raylib.draw_circle((puck_x + shake).to_int(), puck_y.to_int(), puck_r, @raylib.Color::new(240, 246, 254, 255))
    @raylib.draw_circle((puck_x + shake).to_int(), puck_y.to_int(), puck_r * 0.5, @raylib.Color::new(84, 120, 174, 255))

    for i = 0; i < sparks.length(); i = i + 1 {
      if not(sparks[i].active) {
        continue
      }
      let a = (sparks[i].ttl * 255.0).to_int()
      if a > 0 {
        @raylib.draw_circle(
          (sparks[i].x + shake).to_int(),
          sparks[i].y.to_int(),
          2.0,
          @raylib.Color::new(246, 220, 138, a),
        )
      }
    }

    @raylib.draw_rectangle(0, 0, sw, 96, @raylib.Color::new(8, 12, 20, 230))
    @raylib.draw_text("NEON AIR HOCKEY 2026", 20, 20, 34, @raylib.Color::new(232, 242, 252, 255))
    @raylib.draw_text("Sector \{sector}/3", 420, 28, 30, @raylib.Color::new(246, 230, 136, 255))
    @raylib.draw_text("Score \{score}", 604, 28, 30, @raylib.Color::new(220, 236, 250, 255))
    @raylib.draw_text("You \{p_goals} - \{ai_goals} AI", 810, 28, 30, @raylib.Color::new(182, 224, 250, 255))

    @raylib.draw_text("Total \{p_total}:\{ai_total}", 1120, 30, 24, @raylib.Color::new(210, 226, 242, 255))

    if faceoff_t > 0.0 {
      let t = (faceoff_t * 10.0).to_int() + 1
      @raylib.draw_text("Faceoff in \{t}", sw / 2 - 76, table_y + 18, 30, @raylib.Color::new(246, 236, 170, 255))
    }

    let ctl_x = 26
    let ctl_y = sh - 170
    @raylib.draw_rectangle(12, sh - 184, 154, 160, @raylib.Color::new(10, 16, 28, 220))
    @raylib.draw_text("Touch", 58, sh - 180, 20, @raylib.white)

    @raylib.draw_rectangle(ctl_x, ctl_y, 72, 52, @raylib.Color::new(46, 66, 94, 255))
    @raylib.draw_text("LEFT", ctl_x + 10, ctl_y + 16, 20, @raylib.white)
    @raylib.draw_rectangle(ctl_x + 80, ctl_y, 72, 52, @raylib.Color::new(46, 66, 94, 255))
    @raylib.draw_text("RIGHT", ctl_x + 85, ctl_y + 16, 20, @raylib.white)
    @raylib.draw_rectangle(ctl_x, ctl_y + 58, 72, 52, @raylib.Color::new(46, 66, 94, 255))
    @raylib.draw_text("DOWN", ctl_x + 8, ctl_y + 74, 20, @raylib.white)
    @raylib.draw_rectangle(ctl_x + 80, ctl_y + 58, 72, 52, @raylib.Color::new(46, 66, 94, 255))
    @raylib.draw_text("UP", ctl_x + 102, ctl_y + 74, 20, @raylib.white)

    let fire_x = sw - 210
    let fire_y = sh - 150
    @raylib.draw_rectangle(fire_x, fire_y, 170, 116, @raylib.Color::new(190, 76, 84, 255))
    @raylib.draw_text("STRIKE", fire_x + 32, fire_y + 44, 34, @raylib.white)

    if dash_cd > 0.0 {
      @raylib.draw_text("Dash CD \{dash_cd.to_int() + 1}", fire_x + 30, fire_y - 24, 22, @raylib.Color::new(254, 220, 152, 255))
    } else {
      @raylib.draw_text("Power Strike Ready", fire_x + 5, fire_y - 24, 22, @raylib.Color::new(166, 246, 184, 255))
    }

    @raylib.draw_rectangle(186, sh - 54, sw - 400, 36, @raylib.Color::new(10, 16, 24, 220))
    @raylib.draw_text(msg, 196, sh - 48, 22, @raylib.Color::new(224, 236, 246, 255))

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 126))
      @raylib.draw_rectangle(sw / 2 - 320, sh / 2 - 100, 640, 200, @raylib.Color::new(16, 24, 40, 242))
      @raylib.draw_text(
        if won { "CHAMPION" } else { "DEFEAT" },
        sw / 2 - 144,
        sh / 2 - 34,
        58,
        if won { @raylib.Color::new(248, 234, 142, 255) } else { @raylib.Color::new(250, 132, 132, 255) },
      )
      @raylib.draw_text("Press R to restart", sw / 2 - 124, sh / 2 + 40, 32, @raylib.Color::new(226, 238, 252, 255))
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
