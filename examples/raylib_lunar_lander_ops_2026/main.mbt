///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let points : Int = 17

///|
let max_meteors : Int = 24

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
fn deg2rad(angle : Float) -> Double {
  angle.to_double() * 0.017453292519943295
}

///|
fn sinf_deg(angle : Float) -> Float {
  Float::from_double(@math.sin(deg2rad(angle)))
}

///|
fn cosf_deg(angle : Float) -> Float {
  Float::from_double(@math.cos(deg2rad(angle)))
}

///|
fn sinf(x : Float) -> Float {
  Float::from_double(@math.sin(x.to_double()))
}

///|
struct Meteor {
  mut x : Float
  mut y : Float
  mut vy : Float
  mut active : Bool
}

///|
fn set_height(heights : Array[Float], i : Int, y : Float) -> Unit {
  heights[i] = y
}

///|
fn sample_height(heights : Array[Float], x : Float) -> Float {
  let segs = heights.length() - 1
  let step = Float::from_int(sw) / Float::from_int(segs)
  let px = clampf(x, 0.0, Float::from_int(sw - 1))
  let mut i = (px / step).to_int()
  if i < 0 {
    i = 0
  }
  if i >= segs {
    i = segs - 1
  }
  let x0 = Float::from_int(i) * step
  let t = (px - x0) / step
  heights[i] + (heights[i + 1] - heights[i]) * t
}

///|
fn clear_meteors(meteors : Array[Meteor]) -> Unit {
  for i = 0; i < meteors.length(); i = i + 1 {
    meteors[i].x = 0.0
    meteors[i].y = 0.0
    meteors[i].vy = 0.0
    meteors[i].active = false
  }
}

///|
fn spawn_meteor(meteors : Array[Meteor], level : Int) -> Unit {
  let mut placed = false
  for i = 0; i < meteors.length(); i = i + 1 {
    if placed {
      continue
    }
    if not(meteors[i].active) {
      meteors[i].active = true
      meteors[i].x = Float::from_int(@raylib.get_random_value(20, sw - 20))
      meteors[i].y = -18.0
      meteors[i].vy = Float::from_int(
        @raylib.get_random_value(170 + level * 20, 260 + level * 30),
      )
      placed = true
    }
  }
}

///|
fn set_level(
  level : Int,
  heights : Array[Float],
) -> (Float, Float, Float, Float, Float, Float) {
  if level == 1 {
    set_height(heights, 0, 620.0)
    set_height(heights, 1, 600.0)
    set_height(heights, 2, 630.0)
    set_height(heights, 3, 660.0)
    set_height(heights, 4, 640.0)
    set_height(heights, 5, 590.0)
    set_height(heights, 6, 560.0)
    set_height(heights, 7, 560.0)
    set_height(heights, 8, 610.0)
    set_height(heights, 9, 640.0)
    set_height(heights, 10, 610.0)
    set_height(heights, 11, 570.0)
    set_height(heights, 12, 540.0)
    set_height(heights, 13, 540.0)
    set_height(heights, 14, 590.0)
    set_height(heights, 15, 620.0)
    set_height(heights, 16, 610.0)
    (120.0, 110.0, 480.0, 80.0, heights[6], 8.0)
  } else if level == 2 {
    set_height(heights, 0, 640.0)
    set_height(heights, 1, 650.0)
    set_height(heights, 2, 620.0)
    set_height(heights, 3, 580.0)
    set_height(heights, 4, 580.0)
    set_height(heights, 5, 620.0)
    set_height(heights, 6, 660.0)
    set_height(heights, 7, 630.0)
    set_height(heights, 8, 590.0)
    set_height(heights, 9, 540.0)
    set_height(heights, 10, 540.0)
    set_height(heights, 11, 590.0)
    set_height(heights, 12, 630.0)
    set_height(heights, 13, 610.0)
    set_height(heights, 14, 560.0)
    set_height(heights, 15, 560.0)
    set_height(heights, 16, 610.0)
    (1130.0, 120.0, 240.0, 80.0, heights[3], -16.0)
  } else if level == 3 {
    set_height(heights, 0, 630.0)
    set_height(heights, 1, 610.0)
    set_height(heights, 2, 580.0)
    set_height(heights, 3, 540.0)
    set_height(heights, 4, 540.0)
    set_height(heights, 5, 590.0)
    set_height(heights, 6, 640.0)
    set_height(heights, 7, 680.0)
    set_height(heights, 8, 640.0)
    set_height(heights, 9, 600.0)
    set_height(heights, 10, 560.0)
    set_height(heights, 11, 520.0)
    set_height(heights, 12, 520.0)
    set_height(heights, 13, 570.0)
    set_height(heights, 14, 620.0)
    set_height(heights, 15, 650.0)
    set_height(heights, 16, 630.0)
    (140.0, 112.0, 880.0, 80.0, heights[11], 22.0)
  } else {
    set_height(heights, 0, 660.0)
    set_height(heights, 1, 630.0)
    set_height(heights, 2, 600.0)
    set_height(heights, 3, 560.0)
    set_height(heights, 4, 540.0)
    set_height(heights, 5, 580.0)
    set_height(heights, 6, 640.0)
    set_height(heights, 7, 670.0)
    set_height(heights, 8, 630.0)
    set_height(heights, 9, 630.0)
    set_height(heights, 10, 590.0)
    set_height(heights, 11, 550.0)
    set_height(heights, 12, 520.0)
    set_height(heights, 13, 520.0)
    set_height(heights, 14, 560.0)
    set_height(heights, 15, 610.0)
    set_height(heights, 16, 650.0)
    (1070.0, 124.0, 640.0, 80.0, heights[8], -24.0)
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Lunar Lander Ops 2026")
  @raylib.set_target_fps(60)

  let heights : Array[Float] = Array::make(points, 0.0)
  let meteors : Array[Meteor] = Array::makei(max_meteors, fn(_i) {
    { x: 0.0, y: 0.0, vy: 0.0, active: false }
  })

  clear_meteors(meteors)

  let mut level = 1
  let mut lives = 4
  let mut score = 0

  let mut spawn_x : Float = 0.0
  let mut spawn_y : Float = 0.0
  let mut pad_x : Float = 0.0
  let mut pad_w : Float = 0.0
  let mut pad_y : Float = 0.0
  let mut wind_base : Float = 0.0

  let (sx, sy, px, pw, py, wb) = set_level(level, heights)
  spawn_x = sx
  spawn_y = sy
  pad_x = px
  pad_w = pw
  pad_y = py
  wind_base = wb

  let mut x = spawn_x
  let mut y = spawn_y
  let mut vx : Float = 0.0
  let mut vy : Float = 0.0
  let mut angle : Float = 0.0
  let mut fuel : Float = 920.0

  let mut wind = wind_base
  let mut wind_t : Float = 0.0
  let mut spawn_cd : Float = 0.55

  let mut thrusting = false
  let mut explosion_t : Float = 0.0
  let mut explosion_x : Float = 0.0
  let mut explosion_y : Float = 0.0
  let mut respawn_t : Float = 0.0

  let mut over = false
  let mut won = false
  let mut msg = "A/D rotate, W thrust. Land softly on the highlighted pad."

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      lives = 4
      score = 0
      let (rsx, rsy, rpx, rpw, rpy, rwb) = set_level(level, heights)
      spawn_x = rsx
      spawn_y = rsy
      pad_x = rpx
      pad_w = rpw
      pad_y = rpy
      wind_base = rwb
      x = spawn_x
      y = spawn_y
      vx = 0.0
      vy = 0.0
      angle = 0.0
      fuel = 920.0
      wind = wind_base
      wind_t = 0.0
      spawn_cd = 0.55
      thrusting = false
      explosion_t = 0.0
      explosion_x = 0.0
      explosion_y = 0.0
      respawn_t = 0.0
      over = false
      won = false
      msg = "Mission restarted."
      clear_meteors(meteors)
    }

    if explosion_t > 0.0 {
      explosion_t = explosion_t - dt
      if explosion_t < 0.0 {
        explosion_t = 0.0
      }
    }

    if not(over) {
      wind_t = wind_t + dt
      wind = wind_base + sinf(wind_t * 1.25) * 24.0

      if respawn_t > 0.0 {
        respawn_t = respawn_t - dt
        if respawn_t <= 0.0 {
          respawn_t = 0.0
          x = spawn_x
          y = spawn_y
          vx = 0.0
          vy = 0.0
          angle = 0.0
          fuel = 920.0 - Float::from_int(level - 1) * 90.0
          if fuel < 460.0 {
            fuel = 460.0
          }
          msg = "Ship relaunched."
        }
      } else {
        let ctl_x = 20
        let ctl_y = sh - 178
        let m = @raylib.get_mouse_position()
        let touching = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)

        let mut left_down = @raylib.is_key_down(@raylib.KeyA) ||
          @raylib.is_key_down(@raylib.KeyLeft)
        let mut right_down = @raylib.is_key_down(@raylib.KeyD) ||
          @raylib.is_key_down(@raylib.KeyRight)
        let mut thrust_down = @raylib.is_key_down(@raylib.KeyW) ||
          @raylib.is_key_down(@raylib.KeyUp)

        if touching {
          if inside_rect(m.x, m.y, ctl_x, ctl_y, 82, 54) {
            left_down = true
          }
          if inside_rect(m.x, m.y, ctl_x + 92, ctl_y, 82, 54) {
            right_down = true
          }
          if inside_rect(m.x, m.y, ctl_x, ctl_y + 64, 174, 62) {
            thrust_down = true
          }
        }

        if left_down {
          angle = angle - 92.0 * dt
        }
        if right_down {
          angle = angle + 92.0 * dt
        }
        angle = clampf(angle, -68.0, 68.0)

        let mut ax = wind * 0.55
        let mut ay : Float = 128.0
        thrusting = false

        if thrust_down && fuel > 0.0 {
          thrusting = true
          fuel = fuel - 54.0 * dt
          if fuel < 0.0 {
            fuel = 0.0
          }
          ax = ax + sinf_deg(angle) * 286.0
          ay = ay - cosf_deg(angle) * 286.0
        }

        vx = vx + ax * dt
        vy = vy + ay * dt
        x = x + vx * dt
        y = y + vy * dt

        if x < 14.0 {
          x = 14.0
          vx = vx.abs() * 0.24
        }
        if x > Float::from_int(sw - 14) {
          x = Float::from_int(sw - 14)
          vx = -vx.abs() * 0.24
        }
        if y < 28.0 {
          y = 28.0
          vy = vy.abs() * 0.12
        }

        spawn_cd = spawn_cd - dt
        if spawn_cd <= 0.0 {
          spawn_meteor(meteors, level)
          let mut next : Float = 0.62 - Float::from_int(level) * 0.07
          if next < 0.24 {
            next = 0.24
          }
          spawn_cd = next
        }

        let mut meteor_hit = false
        for i = 0; i < meteors.length(); i = i + 1 {
          if not(meteors[i].active) {
            continue
          }
          meteors[i].y = meteors[i].y + meteors[i].vy * dt
          if meteors[i].y > Float::from_int(sh + 40) {
            meteors[i].active = false
            continue
          }
          let dx = meteors[i].x - x
          let dy = meteors[i].y - y
          if dx * dx + dy * dy < 20.0 * 20.0 {
            meteors[i].active = false
            meteor_hit = true
          }
        }

        if meteor_hit {
          lives = lives - 1
          explosion_t = 0.55
          explosion_x = x
          explosion_y = y
          vx = 0.0
          vy = 0.0

          if lives <= 0 {
            lives = 0
            over = true
            won = false
            msg = "Destroyed by meteors. Press R to retry."
          } else {
            respawn_t = 1.0
            msg = "Meteor impact. Relaunching..."
          }
        } else {
          let ground = sample_height(heights, x)
          if y >= ground - 13.0 {
            let on_pad = x >= pad_x + 8.0 && x <= pad_x + pad_w - 8.0
            let safe = on_pad &&
              absf(vx) <= 34.0 &&
              absf(vy) <= 46.0 &&
              absf(angle) <= 12.0

            if safe {
              let mut bonus = 320 + fuel.to_int() / 2
              if bonus < 80 {
                bonus = 80
              }
              score = score + bonus
              level = level + 1

              if level > 4 {
                over = true
                won = true
                msg = "All landing zones secured. Press R to replay."
              } else {
                let (nsx, nsy, npx, npw, npy, nwb) = set_level(level, heights)
                spawn_x = nsx
                spawn_y = nsy
                pad_x = npx
                pad_w = npw
                pad_y = npy
                wind_base = nwb

                x = spawn_x
                y = spawn_y
                vx = 0.0
                vy = 0.0
                angle = 0.0
                fuel = 920.0 - Float::from_int(level - 1) * 90.0
                if fuel < 460.0 {
                  fuel = 460.0
                }
                wind_t = 0.0
                wind = wind_base
                spawn_cd = 0.55
                clear_meteors(meteors)

                msg = "Pad secured. Sector \{level} online."
              }
            } else {
              lives = lives - 1
              explosion_t = 0.55
              explosion_x = x
              explosion_y = ground - 4.0
              vx = 0.0
              vy = 0.0

              if lives <= 0 {
                lives = 0
                over = true
                won = false
                msg = "Crash landing. Mission failed. Press R to retry."
              } else {
                respawn_t = 1.0
                msg = "Crash. Keep speed and angle lower on touchdown."
              }
            }
          }
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(8, 12, 22, 255))

    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(12, 22, 42, 255))
    @raylib.draw_rectangle(0, 0, sw, 280, @raylib.Color::new(18, 34, 66, 255))
    @raylib.draw_rectangle(0, 0, sw, 140, @raylib.Color::new(30, 58, 98, 255))

    for i = 0; i < 84; i = i + 1 {
      let sx = (i * 173 + level * 97) % sw
      let sy = (i * 97 + level * 61) % 420
      let b = 140 + i * 13 % 100
      @raylib.draw_circle(
        sx,
        sy,
        1.0 + Float::from_int(i % 3),
        @raylib.Color::new(b, b, b + 20, 255),
      )
    }

    let segs = points - 1
    let step = Float::from_int(sw) / Float::from_int(segs)
    let ground_color = @raylib.Color::new(70, 56, 64, 255)
    let ground_color2 = @raylib.Color::new(56, 44, 52, 255)

    for i = 0; i < segs; i = i + 1 {
      let x1 = Float::from_int(i) * step
      let x2 = Float::from_int(i + 1) * step
      let y1 = heights[i]
      let y2 = heights[i + 1]

      @raylib.draw_triangle(
        @raylib.Vector2::new(x1, y1),
        @raylib.Vector2::new(x2, y2),
        @raylib.Vector2::new(x1, Float::from_int(sh)),
        ground_color,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(x2, y2),
        @raylib.Vector2::new(x2, Float::from_int(sh)),
        @raylib.Vector2::new(x1, Float::from_int(sh)),
        ground_color2,
      )

      @raylib.draw_line(
        x1.to_int(),
        y1.to_int(),
        x2.to_int(),
        y2.to_int(),
        @raylib.Color::new(184, 170, 182, 255),
      )
    }

    @raylib.draw_rectangle(
      pad_x.to_int(),
      (pad_y - 10.0).to_int(),
      pad_w.to_int(),
      8,
      @raylib.Color::new(248, 216, 106, 255),
    )
    @raylib.draw_rectangle_lines(
      pad_x.to_int(),
      (pad_y - 10.0).to_int(),
      pad_w.to_int(),
      8,
      @raylib.Color::new(82, 62, 28, 255),
    )
    @raylib.draw_text(
      "LANDING PAD",
      pad_x.to_int() - 20,
      (pad_y - 38.0).to_int(),
      20,
      @raylib.Color::new(248, 232, 170, 255),
    )

    for i = 0; i < meteors.length(); i = i + 1 {
      if not(meteors[i].active) {
        continue
      }
      @raylib.draw_line(
        meteors[i].x.to_int(),
        (meteors[i].y - 22.0).to_int(),
        meteors[i].x.to_int(),
        meteors[i].y.to_int(),
        @raylib.Color::new(244, 152, 88, 255),
      )
      @raylib.draw_circle(
        meteors[i].x.to_int(),
        meteors[i].y.to_int(),
        6.0,
        @raylib.Color::new(250, 202, 122, 255),
      )
      @raylib.draw_circle(
        meteors[i].x.to_int(),
        meteors[i].y.to_int(),
        3.0,
        @raylib.Color::new(98, 78, 62, 255),
      )
    }

    if respawn_t <= 0.0 {
      let s = sinf_deg(angle)
      let c = cosf_deg(angle)

      let nx = x + s * 20.0
      let ny = y - c * 20.0
      let lx = x + sinf_deg(angle + 132.0) * 13.0
      let ly = y - cosf_deg(angle + 132.0) * 13.0
      let rx = x + sinf_deg(angle - 132.0) * 13.0
      let ry = y - cosf_deg(angle - 132.0) * 13.0

      @raylib.draw_triangle(
        @raylib.Vector2::new(nx, ny),
        @raylib.Vector2::new(lx, ly),
        @raylib.Vector2::new(rx, ry),
        @raylib.Color::new(196, 214, 232, 255),
      )
      @raylib.draw_triangle_lines(
        @raylib.Vector2::new(nx, ny),
        @raylib.Vector2::new(lx, ly),
        @raylib.Vector2::new(rx, ry),
        @raylib.Color::new(44, 62, 84, 255),
      )

      let tx = x - s * 12.0
      let ty = y + c * 12.0
      @raylib.draw_line(
        (lx + 2.0).to_int(),
        (ly + 3.0).to_int(),
        (tx - 6.0).to_int(),
        (ty + 7.0).to_int(),
        @raylib.lightgray,
      )
      @raylib.draw_line(
        (rx - 2.0).to_int(),
        (ry + 3.0).to_int(),
        (tx + 6.0).to_int(),
        (ty + 7.0).to_int(),
        @raylib.lightgray,
      )

      if thrusting && fuel > 0.0 {
        let f1x = tx + sinf_deg(angle + 172.0) * 8.0
        let f1y = ty - cosf_deg(angle + 172.0) * 8.0
        let f2x = tx + sinf_deg(angle - 172.0) * 8.0
        let f2y = ty - cosf_deg(angle - 172.0) * 8.0
        let f3x = tx -
          s * (22.0 + Float::from_int(@raylib.get_random_value(0, 8)))
        let f3y = ty +
          c * (22.0 + Float::from_int(@raylib.get_random_value(0, 8)))
        @raylib.draw_triangle(
          @raylib.Vector2::new(f1x, f1y),
          @raylib.Vector2::new(f2x, f2y),
          @raylib.Vector2::new(f3x, f3y),
          @raylib.Color::new(250, 146, 70, 255),
        )
      }
    }

    if explosion_t > 0.0 {
      let t = explosion_t / 0.55
      let r : Float = 20.0 + (Float::from_int(1) - t) * 76.0
      @raylib.draw_circle(
        explosion_x.to_int(),
        explosion_y.to_int(),
        r,
        @raylib.Color::new(248, 134, 74, 160),
      )
      @raylib.draw_circle(
        explosion_x.to_int(),
        explosion_y.to_int(),
        r * 0.6,
        @raylib.Color::new(254, 216, 128, 230),
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 94, @raylib.Color::new(12, 18, 30, 220))
    @raylib.draw_text(
      "LUNAR LANDER OPS 2026",
      20,
      18,
      36,
      @raylib.Color::new(232, 240, 252, 255),
    )
    @raylib.draw_text(
      "Sector: \{level}/4",
      480,
      24,
      28,
      @raylib.Color::new(240, 226, 136, 255),
    )
    @raylib.draw_text(
      "Lives: \{lives}",
      666,
      24,
      28,
      @raylib.Color::new(236, 244, 252, 255),
    )
    @raylib.draw_text(
      "Score: \{score}",
      790,
      24,
      28,
      @raylib.Color::new(236, 244, 252, 255),
    )
    @raylib.draw_text(
      "Wind: \{wind.to_int()}",
      984,
      24,
      28,
      @raylib.Color::new(172, 222, 252, 255),
    )

    @raylib.draw_rectangle(20, 70, 280, 14, @raylib.Color::new(30, 40, 62, 255))
    let fuel_pct = clampf(fuel / 920.0, 0.0, 1.0)
    @raylib.draw_rectangle(
      20,
      70,
      (fuel_pct * 280.0).to_int(),
      14,
      @raylib.Color::new(110, 228, 140, 255),
    )
    @raylib.draw_text(
      "Fuel \{fuel.to_int()}",
      310,
      66,
      22,
      @raylib.Color::new(220, 238, 246, 255),
    )

    @raylib.draw_text(
      "Safe touchdown: |Vx|<=34, |Vy|<=46, |Angle|<=12",
      520,
      66,
      22,
      @raylib.Color::new(208, 220, 238, 255),
    )

    let ctl_x = 20
    let ctl_y = sh - 178
    @raylib.draw_rectangle(
      10,
      sh - 190,
      188,
      170,
      @raylib.Color::new(12, 18, 28, 220),
    )
    @raylib.draw_text("Touch", 74, sh - 186, 20, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x,
      ctl_y,
      82,
      54,
      @raylib.Color::new(46, 64, 90, 255),
    )
    @raylib.draw_text("LEFT", ctl_x + 16, ctl_y + 16, 22, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x + 92,
      ctl_y,
      82,
      54,
      @raylib.Color::new(46, 64, 90, 255),
    )
    @raylib.draw_text("RIGHT", ctl_x + 100, ctl_y + 16, 22, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x,
      ctl_y + 64,
      174,
      62,
      @raylib.Color::new(182, 82, 70, 255),
    )
    @raylib.draw_text("THRUST", ctl_x + 50, ctl_y + 84, 26, @raylib.white)

    @raylib.draw_rectangle(
      214,
      sh - 58,
      sw - 228,
      38,
      @raylib.Color::new(12, 18, 30, 220),
    )
    @raylib.draw_text(
      msg,
      224,
      sh - 50,
      23,
      @raylib.Color::new(228, 236, 246, 255),
    )

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 126))
      @raylib.draw_rectangle(
        sw / 2 - 340,
        sh / 2 - 108,
        680,
        216,
        @raylib.Color::new(16, 24, 40, 242),
      )
      @raylib.draw_text(
        if won {
          "MISSION ACCOMPLISHED"
        } else {
          "MISSION FAILED"
        },
        sw / 2 - 254,
        sh / 2 - 38,
        54,
        if won {
          @raylib.Color::new(246, 236, 142, 255)
        } else {
          @raylib.Color::new(246, 126, 126, 255)
        },
      )
      @raylib.draw_text(
        "Press R to restart",
        sw / 2 - 130,
        sh / 2 + 34,
        32,
        @raylib.Color::new(228, 238, 250, 255),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
