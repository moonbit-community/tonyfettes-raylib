///|
let sw : Int = 1280

///|
let sh : Int = 820

///|
let table_x : Int = 90

///|
let table_y : Int = 120

///|
let table_w : Int = 1100

///|
let table_h : Int = 620

///|
let ball_r : Float = 15.0

///|
let portal_r : Float = 30.0

///|
let max_balls : Int = 12

///|
struct Ball {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut active : Bool
  id : Int
  mut portal_cd : Float
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
fn sinf(x : Float) -> Float {
  Float::from_double(@math.sin(x.to_double()))
}

///|
fn cosf(x : Float) -> Float {
  Float::from_double(@math.cos(x.to_double()))
}

///|
fn set_ball(
  balls : Array[Ball],
  i : Int,
  x : Float,
  y : Float,
  active : Bool,
  id : Int,
) -> Unit {
  balls[i] = { x, y, vx: 0.0, vy: 0.0, active, id, portal_cd: 0.0 }
}

///|
fn clear_balls(balls : Array[Ball]) -> Unit {
  for i = 0; i < balls.length(); i = i + 1 {
    set_ball(balls, i, 0.0, 0.0, false, i)
  }
}

///|
fn cue_spawn_x() -> Float {
  Float::from_int(table_x + 230)
}

///|
fn cue_spawn_y() -> Float {
  Float::from_int(table_y + table_h / 2)
}

///|
fn reset_level(level : Int, balls : Array[Ball]) -> Int {
  clear_balls(balls)

  let cx = cue_spawn_x()
  let cy = cue_spawn_y()
  set_ball(balls, 0, cx, cy, true, 0)

  let mut idx = 1
  let base_x = Float::from_int(table_x + table_w - 270)
  let base_y = Float::from_int(table_y + table_h / 2)
  let row_gap = ball_r * 1.95
  let col_gap = ball_r * 1.78

  let rows = if level == 1 { 3 } else if level == 2 { 4 } else { 5 }

  for row = 0; row < rows; row = row + 1 {
    let n = row + 1
    let x = base_x + Float::from_int(row) * col_gap
    let mut y = base_y - Float::from_int(n - 1) * row_gap * 0.5
    for _j = 0; _j < n; _j = _j + 1 {
      if idx < balls.length() {
        set_ball(balls, idx, x, y, true, idx)
        idx = idx + 1
      }
      y = y + row_gap
    }
  }

  if level == 1 {
    9
  } else if level == 2 {
    10
  } else {
    11
  }
}

///|
fn all_targets_cleared(balls : Array[Ball]) -> Bool {
  let mut clear = true
  for i = 1; i < balls.length(); i = i + 1 {
    if balls[i].active {
      clear = false
    }
  }
  clear
}

///|
fn moving_any(balls : Array[Ball]) -> Bool {
  let mut moving = false
  for i = 0; i < balls.length(); i = i + 1 {
    if balls[i].active {
      let s2 = balls[i].vx * balls[i].vx + balls[i].vy * balls[i].vy
      if s2 > 64.0 {
        moving = true
      }
    }
  }
  moving
}

///|
fn pocket_x(i : Int) -> Float {
  if i == 0 {
    Float::from_int(table_x + 8)
  } else if i == 1 {
    Float::from_int(table_x + table_w / 2)
  } else if i == 2 {
    Float::from_int(table_x + table_w - 8)
  } else if i == 3 {
    Float::from_int(table_x + 8)
  } else if i == 4 {
    Float::from_int(table_x + table_w / 2)
  } else {
    Float::from_int(table_x + table_w - 8)
  }
}

///|
fn pocket_y(i : Int) -> Float {
  if i <= 2 {
    Float::from_int(table_y + 8)
  } else {
    Float::from_int(table_y + table_h - 8)
  }
}

///|
fn ball_in_pocket(x : Float, y : Float) -> Bool {
  let mut p = false
  for i = 0; i < 6; i = i + 1 {
    let dx = x - pocket_x(i)
    let dy = y - pocket_y(i)
    if dx * dx + dy * dy <= 24.0 * 24.0 {
      p = true
    }
  }
  p
}

///|
fn goal_top() -> Float {
  Float::from_int(table_y + (table_h - 220) / 2)
}

///|
fn goal_bottom() -> Float {
  goal_top() + 220.0
}

///|
fn goal_opening(y : Float) -> Bool {
  y >= goal_top() && y <= goal_bottom()
}

///|
fn portal_pair(idx : Int) -> Int {
  if idx == 0 {
    1
  } else if idx == 1 {
    0
  } else if idx == 2 {
    3
  } else {
    2
  }
}

///|
fn portal_pos(t : Float, idx : Int) -> (Float, Float) {
  let left = Float::from_int(table_x)
  let top = Float::from_int(table_y)
  let right = Float::from_int(table_x + table_w)
  let bottom = Float::from_int(table_y + table_h)
  let cx = Float::from_int(table_x + table_w / 2)

  if idx == 0 {
    (left + 250.0 + sinf(t * 0.9) * 120.0, top + 130.0 + cosf(t * 1.2) * 44.0)
  } else if idx == 1 {
    (
      right - 250.0 + cosf(t * 0.8) * 120.0,
      bottom - 130.0 + sinf(t * 1.1) * 44.0,
    )
  } else if idx == 2 {
    (cx + sinf(t * 1.1) * 190.0, top + 180.0 + cosf(t * 0.7) * 32.0)
  } else {
    (cx + cosf(t * 1.0) * 190.0, bottom - 180.0 + sinf(t * 0.75) * 32.0)
  }
}

///|
fn nearest_portal_idx(t : Float, x : Float, y : Float) -> Int {
  let mut result = -1
  for i = 0; i < 4; i = i + 1 {
    let (px, py) = portal_pos(t, i)
    let dx = x - px
    let dy = y - py
    if dx * dx + dy * dy <= portal_r * portal_r {
      result = i
      break
    }
  }
  result
}

///|
fn color_for_id(i : Int) -> @raylib.Color {
  if i == 0 {
    @raylib.Color::new(246, 246, 250, 255)
  } else if i % 6 == 1 {
    @raylib.Color::new(244, 184, 74, 255)
  } else if i % 6 == 2 {
    @raylib.Color::new(88, 206, 238, 255)
  } else if i % 6 == 3 {
    @raylib.Color::new(236, 92, 92, 255)
  } else if i % 6 == 4 {
    @raylib.Color::new(120, 224, 130, 255)
  } else if i % 6 == 5 {
    @raylib.Color::new(236, 126, 212, 255)
  } else {
    @raylib.Color::new(246, 220, 110, 255)
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "Portal Billiards 2026")
  @raylib.set_target_fps(60)

  let balls : Array[Ball] = Array::makei(max_balls, fn(i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, active: false, id: i, portal_cd: 0.0 }
  })

  let mut level = 1
  let mut shots_left = reset_level(level, balls)
  let mut score = 0
  let mut power : Float = 540.0

  let mut portal_t : Float = 0.0

  let mut aim_x = cue_spawn_x() + 120.0
  let mut aim_y = cue_spawn_y()

  let mut over = false
  let mut won = false
  let mut msg = "Aim with mouse/touch. W/S power. Space shoot."

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    portal_t = portal_t + dt

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      shots_left = reset_level(level, balls)
      score = 0
      power = 540.0
      portal_t = 0.0
      aim_x = cue_spawn_x() + 120.0
      aim_y = cue_spawn_y()
      over = false
      won = false
      msg = "Table reset."
    }

    if not(over) {
      if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
        power = power + 220.0 * dt
      }
      if @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown) {
        power = power - 220.0 * dt
      }
      power = clampf(power, 260.0, 820.0)

      let mouse = @raylib.get_mouse_position()
      if inside_rect(mouse.x, mouse.y, table_x, table_y, table_w, table_h) {
        aim_x = mouse.x
        aim_y = mouse.y
      }

      let ctl_x = 24
      let ctl_y = sh - 178
      let fire_x = sw - 204
      let fire_y = sh - 152
      let mut fire = @raylib.is_key_pressed(@raylib.KeySpace) ||
        @raylib.is_key_pressed(@raylib.KeyJ)

      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(mouse.x, mouse.y, ctl_x, ctl_y, 74, 54) {
          power = power - 22.0
        } else if inside_rect(mouse.x, mouse.y, ctl_x + 84, ctl_y, 74, 54) {
          power = power + 22.0
        } else if inside_rect(mouse.x, mouse.y, fire_x, fire_y, 170, 116) {
          fire = true
        } else if inside_rect(
            mouse.x,
            mouse.y,
            table_x,
            table_y,
            table_w,
            table_h,
          ) {
          aim_x = mouse.x
          aim_y = mouse.y
        }
      }
      power = clampf(power, 260.0, 820.0)

      let moving = moving_any(balls)

      if fire && not(moving) && shots_left > 0 && balls[0].active {
        let dx = aim_x - balls[0].x
        let dy = aim_y - balls[0].y
        let d = (dx * dx + dy * dy).sqrt()
        if d > 0.001 {
          balls[0].vx = dx / d * power
          balls[0].vy = dy / d * power
          shots_left = shots_left - 1
          msg = "Shot taken."
        }
      }

      for i = 0; i < balls.length(); i = i + 1 {
        if not(balls[i].active) {
          continue
        }

        if balls[i].portal_cd > 0.0 {
          balls[i].portal_cd = balls[i].portal_cd - dt
          if balls[i].portal_cd < 0.0 {
            balls[i].portal_cd = 0.0
          }
        }

        balls[i].x = balls[i].x + balls[i].vx * dt
        balls[i].y = balls[i].y + balls[i].vy * dt

        let friction = Float::from_int(1) - dt * 0.84
        balls[i].vx = balls[i].vx * friction
        balls[i].vy = balls[i].vy * friction

        if absf(balls[i].vx) < 6.0 {
          balls[i].vx = 0.0
        }
        if absf(balls[i].vy) < 6.0 {
          balls[i].vy = 0.0
        }

        if ball_in_pocket(balls[i].x, balls[i].y) {
          if balls[i].id == 0 {
            balls[i].x = cue_spawn_x()
            balls[i].y = cue_spawn_y()
            balls[i].vx = 0.0
            balls[i].vy = 0.0
            balls[i].portal_cd = 0.5
            if shots_left > 0 {
              shots_left = shots_left - 1
            }
            msg = "Cue scratch: -1 shot."
          } else {
            balls[i].active = false
            score = score + 60
            msg = "Ball pocketed +60."
          }
          continue
        }

        let left = Float::from_int(table_x) + ball_r
        let right = Float::from_int(table_x + table_w) - ball_r
        let top = Float::from_int(table_y) + ball_r
        let bottom = Float::from_int(table_y + table_h) - ball_r

        if balls[i].x <= left {
          if not(goal_opening(balls[i].y)) {
            balls[i].x = left
            balls[i].vx = absf(balls[i].vx) * 0.94
          }
        }
        if balls[i].x >= right {
          if not(goal_opening(balls[i].y)) {
            balls[i].x = right
            balls[i].vx = -absf(balls[i].vx) * 0.94
          }
        }
        if balls[i].y <= top {
          balls[i].y = top
          balls[i].vy = absf(balls[i].vy) * 0.94
        }
        if balls[i].y >= bottom {
          balls[i].y = bottom
          balls[i].vy = -absf(balls[i].vy) * 0.94
        }

        if balls[i].portal_cd <= 0.0 {
          let from = nearest_portal_idx(portal_t, balls[i].x, balls[i].y)
          if from >= 0 {
            let to = portal_pair(from)
            let (tx, ty) = portal_pos(portal_t, to)

            let sp = (balls[i].vx * balls[i].vx + balls[i].vy * balls[i].vy).sqrt()
            if sp > 1.0 {
              let nx = balls[i].vx / sp
              let ny = balls[i].vy / sp
              balls[i].x = tx + nx * (portal_r + ball_r + 2.0)
              balls[i].y = ty + ny * (portal_r + ball_r + 2.0)
            } else {
              balls[i].x = tx
              balls[i].y = ty
            }

            balls[i].vx = balls[i].vx * 1.05
            balls[i].vy = balls[i].vy * 1.05
            balls[i].portal_cd = 0.45
            if balls[i].id == 0 {
              msg = "Cue teleported."
            }
          }
        }
      }

      for i = 0; i < balls.length(); i = i + 1 {
        if not(balls[i].active) {
          continue
        }
        for j = i + 1; j < balls.length(); j = j + 1 {
          if not(balls[j].active) {
            continue
          }

          let dx = balls[j].x - balls[i].x
          let dy = balls[j].y - balls[i].y
          let d2 = dx * dx + dy * dy
          let min_d = ball_r * 2.0
          if d2 <= min_d * min_d && d2 > 0.0001 {
            let d = d2.sqrt()
            let nx = dx / d
            let ny = dy / d
            let overlap = min_d - d

            balls[i].x = balls[i].x - nx * overlap * 0.5
            balls[i].y = balls[i].y - ny * overlap * 0.5
            balls[j].x = balls[j].x + nx * overlap * 0.5
            balls[j].y = balls[j].y + ny * overlap * 0.5

            let rvx = balls[i].vx - balls[j].vx
            let rvy = balls[i].vy - balls[j].vy
            let rel = rvx * nx + rvy * ny
            if rel > 0.0 {
              let imp = rel * 0.98
              balls[i].vx = balls[i].vx - nx * imp
              balls[i].vy = balls[i].vy - ny * imp
              balls[j].vx = balls[j].vx + nx * imp
              balls[j].vy = balls[j].vy + ny * imp
            }
          }
        }
      }

      let still_moving = moving_any(balls)
      if not(still_moving) && shots_left <= 0 && not(all_targets_cleared(balls)) {
        over = true
        won = false
        msg = "Out of shots. Press R to retry."
      }

      if all_targets_cleared(balls) {
        score = score + shots_left * 30 + 180
        if level < 3 {
          level = level + 1
          shots_left = reset_level(level, balls)
          power = power + 40.0
          power = clampf(power, 260.0, 820.0)
          msg = "Level \{level}. New rack loaded."
        } else {
          over = true
          won = true
          msg = "All portal racks cleared."
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(12, 18, 28, 255))

    @raylib.draw_rectangle(0, 0, sw, 104, @raylib.Color::new(8, 14, 22, 230))
    @raylib.draw_text(
      "PORTAL BILLIARDS 2026",
      18,
      24,
      36,
      @raylib.Color::new(236, 244, 252, 255),
    )
    @raylib.draw_text(
      "Level \{level}/3",
      460,
      34,
      30,
      @raylib.Color::new(248, 226, 134, 255),
    )
    @raylib.draw_text(
      "Shots \{shots_left}",
      650,
      34,
      30,
      @raylib.Color::new(220, 236, 250, 255),
    )
    @raylib.draw_text(
      "Score \{score}",
      846,
      34,
      30,
      @raylib.Color::new(196, 226, 252, 255),
    )

    @raylib.draw_rectangle(
      table_x - 24,
      table_y - 24,
      table_w + 48,
      table_h + 48,
      @raylib.Color::new(62, 44, 30, 255),
    )
    @raylib.draw_rectangle(
      table_x,
      table_y,
      table_w,
      table_h,
      @raylib.Color::new(26, 92, 62, 255),
    )
    @raylib.draw_rectangle_lines(
      table_x,
      table_y,
      table_w,
      table_h,
      @raylib.Color::new(176, 144, 90, 255),
    )

    for i = 0; i < 6; i = i + 1 {
      @raylib.draw_circle(
        pocket_x(i).to_int(),
        pocket_y(i).to_int(),
        24.0,
        @raylib.Color::new(18, 18, 20, 255),
      )
    }

    for i = 0; i < 4; i = i + 1 {
      let (px, py) = portal_pos(portal_t, i)
      let c = if i < 2 {
        @raylib.Color::new(98, 208, 254, 170)
      } else {
        @raylib.Color::new(252, 162, 98, 170)
      }
      @raylib.draw_circle(px.to_int(), py.to_int(), portal_r + 4.0, c)
      @raylib.draw_circle(
        px.to_int(),
        py.to_int(),
        portal_r - 6.0,
        @raylib.Color::new(12, 22, 30, 220),
      )
      @raylib.draw_circle_lines(
        px.to_int(),
        py.to_int(),
        portal_r + 2.0,
        @raylib.Color::new(240, 246, 254, 220),
      )
    }

    for i = 0; i < balls.length(); i = i + 1 {
      if not(balls[i].active) {
        continue
      }
      let x = balls[i].x.to_int()
      let y = balls[i].y.to_int()
      let c = color_for_id(balls[i].id)
      @raylib.draw_circle(x, y, ball_r, c)
      @raylib.draw_circle(
        x - 4,
        y - 5,
        ball_r * 0.40,
        @raylib.Color::new(250, 250, 252, 210),
      )
      @raylib.draw_circle_lines(
        x,
        y,
        ball_r,
        @raylib.Color::new(24, 24, 30, 180),
      )
    }

    if balls[0].active && not(moving_any(balls)) && not(over) {
      let dx = aim_x - balls[0].x
      let dy = aim_y - balls[0].y
      let d = (dx * dx + dy * dy).sqrt()
      if d > 0.001 {
        let nx = dx / d
        let ny = dy / d
        let len = clampf(d, 40.0, 190.0)
        let sx = balls[0].x - nx * 22.0
        let sy = balls[0].y - ny * 22.0
        let ex = sx - nx * len
        let ey = sy - ny * len
        @raylib.draw_line_ex(
          @raylib.Vector2::new(sx, sy),
          @raylib.Vector2::new(ex, ey),
          5.0,
          @raylib.Color::new(230, 238, 246, 180),
        )
      }
    }

    @raylib.draw_rectangle(
      22,
      112,
      250,
      14,
      @raylib.Color::new(22, 30, 40, 255),
    )
    @raylib.draw_rectangle(
      22,
      112,
      ((power - 260.0) / (820.0 - 260.0) * 250.0).to_int(),
      14,
      @raylib.Color::new(88, 204, 252, 255),
    )
    @raylib.draw_text(
      "Power \{power.to_int()}",
      282,
      106,
      22,
      @raylib.Color::new(220, 238, 250, 255),
    )

    let ctl_x = 24
    let ctl_y = sh - 178
    @raylib.draw_rectangle(
      10,
      sh - 192,
      160,
      170,
      @raylib.Color::new(10, 16, 26, 220),
    )
    @raylib.draw_text("Touch", 60, sh - 188, 20, @raylib.white)

    @raylib.draw_rectangle(
      ctl_x,
      ctl_y,
      74,
      54,
      @raylib.Color::new(44, 62, 88, 255),
    )
    @raylib.draw_text("POW-", ctl_x + 10, ctl_y + 18, 22, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x + 84,
      ctl_y,
      74,
      54,
      @raylib.Color::new(44, 62, 88, 255),
    )
    @raylib.draw_text("POW+", ctl_x + 93, ctl_y + 18, 22, @raylib.white)

    let fire_x = sw - 204
    let fire_y = sh - 152
    @raylib.draw_rectangle(
      fire_x,
      fire_y,
      170,
      116,
      @raylib.Color::new(182, 82, 78, 255),
    )
    @raylib.draw_text("SHOOT", fire_x + 34, fire_y + 44, 34, @raylib.white)

    @raylib.draw_rectangle(
      178,
      sh - 52,
      sw - 392,
      36,
      @raylib.Color::new(10, 16, 24, 220),
    )
    @raylib.draw_text(
      msg,
      188,
      sh - 46,
      22,
      @raylib.Color::new(224, 236, 246, 255),
    )

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 120))
      @raylib.draw_rectangle(
        sw / 2 - 320,
        sh / 2 - 100,
        640,
        200,
        @raylib.Color::new(16, 24, 40, 242),
      )
      @raylib.draw_text(
        if won {
          "TABLE MASTER"
        } else {
          "GAME OVER"
        },
        sw / 2 - 180,
        sh / 2 - 34,
        56,
        if won {
          @raylib.Color::new(248, 234, 142, 255)
        } else {
          @raylib.Color::new(250, 132, 132, 255)
        },
      )
      @raylib.draw_text(
        "Press R to restart",
        sw / 2 - 124,
        sh / 2 + 40,
        32,
        @raylib.Color::new(226, 238, 252, 255),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
