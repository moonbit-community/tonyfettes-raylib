///|
let screen_w : Int = 900

///|
let screen_h : Int = 700

///|
let gravity : Float = 680.0

///|
let ball_r : Float = 10.0

///|
let table_left : Float = 70.0

///|
let table_right : Float = 830.0

///|
let table_top : Float = 40.0

///|
let drain_y : Float = 650.0

///|
let flipper_len : Float = 110.0

///|
let flipper_speed : Float = 12.0

///|
let pi : Float = 3.141592653589793

///|
struct Ball {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut live : Bool
}

///|
struct Flipper {
  pivot_x : Float
  pivot_y : Float
  rest_angle : Float
  active_angle : Float
  mut angle : Float
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
fn seg_end_x(f : Flipper) -> Float {
  f.pivot_x + Float::from_double(@math.cos(f.angle.to_double())) * flipper_len
}

///|
fn seg_end_y(f : Flipper) -> Float {
  f.pivot_y + Float::from_double(@math.sin(f.angle.to_double())) * flipper_len
}

///|
fn reset_ball(ball : Ball) -> Unit {
  ball.x = 780.0
  ball.y = 120.0
  ball.vx = -120.0
  ball.vy = 20.0
  ball.live = false
}

///|
fn collide_ball_with_segment(ball : Ball, f : Flipper, boost : Float) -> Bool {
  let x1 = f.pivot_x
  let y1 = f.pivot_y
  let x2 = seg_end_x(f)
  let y2 = seg_end_y(f)
  let sx = x2 - x1
  let sy = y2 - y1
  let seg_len2 = sx * sx + sy * sy
  if seg_len2 <= 0.0001 {
    return false
  }

  let t = clampf(((ball.x - x1) * sx + (ball.y - y1) * sy) / seg_len2, 0.0, 1.0)
  let cx = x1 + sx * t
  let cy = y1 + sy * t
  let dx = ball.x - cx
  let dy = ball.y - cy
  let d2 = dx * dx + dy * dy
  let rr = ball_r + 6.0
  if d2 > rr * rr {
    return false
  }

  let d = d2.sqrt()
  let nx : Float =
    if d < (0.0001 : Float) { (0.0 : Float) } else { dx / d }
  let ny : Float =
    if d < (0.0001 : Float) { (-1.0 : Float) } else { dy / d }
  ball.x = cx + nx * (rr + (0.2 : Float))
  ball.y = cy + ny * (rr + (0.2 : Float))

  let speed = (ball.vx * ball.vx + ball.vy * ball.vy).sqrt()
  let refl = clampf(speed * 1.03 + boost, 220.0, 800.0)
  ball.vx = nx * refl
  ball.vy = ny * refl - (40.0 : Float)
  true
}

///|
fn ball_vs_bumper(ball : Ball, bx : Float, by : Float, r : Float) -> Bool {
  let dx = ball.x - bx
  let dy = ball.y - by
  let rr = r + ball_r
  if dx * dx + dy * dy > rr * rr {
    return false
  }
  let d = (dx * dx + dy * dy).sqrt()
  let nx : Float =
    if d < (0.0001 : Float) { (1.0 : Float) } else { dx / d }
  let ny : Float =
    if d < (0.0001 : Float) { (0.0 : Float) } else { dy / d }
  ball.x = bx + nx * (rr + (0.2 : Float))
  ball.y = by + ny * (rr + (0.2 : Float))
  let speed = clampf((ball.vx * ball.vx + ball.vy * ball.vy).sqrt() * 1.05, 260.0, 900.0)
  ball.vx = nx * speed
  ball.vy = ny * speed
  true
}

///|
fn main {
  @raylib.init_window(screen_w, screen_h, "Pinball Workshop 2026")
  @raylib.set_target_fps(60)

  let ball : Ball = { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, live: false }
  reset_ball(ball)

  let left_flipper : Flipper = {
    pivot_x: 330.0,
    pivot_y: 585.0,
    rest_angle: -0.20,
    active_angle: -0.85,
    angle: -0.20,
  }
  let right_flipper : Flipper = {
    pivot_x: 570.0,
    pivot_y: 585.0,
    rest_angle: pi + 0.20,
    active_angle: pi + 0.85,
    angle: pi + 0.20,
  }

  let mut score = 0
  let mut lives = 3
  let mut game_over = false

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      score = 0
      lives = 3
      game_over = false
      reset_ball(ball)
    }

    if not(game_over) {
      if not(ball.live) && @raylib.is_key_pressed(@raylib.KeySpace) {
        ball.live = true
        ball.vx = -190.0
        ball.vy = -260.0
      }

      let left_up = @raylib.is_key_down(@raylib.KeyA)
      let right_up = @raylib.is_key_down(@raylib.KeyD)

      if left_up {
        left_flipper.angle = left_flipper.angle - flipper_speed * dt
      } else {
        left_flipper.angle = left_flipper.angle + flipper_speed * dt
      }
      left_flipper.angle = clampf(left_flipper.angle, left_flipper.active_angle, left_flipper.rest_angle)

      if right_up {
        right_flipper.angle = right_flipper.angle + flipper_speed * dt
      } else {
        right_flipper.angle = right_flipper.angle - flipper_speed * dt
      }
      right_flipper.angle = clampf(right_flipper.angle, right_flipper.rest_angle, right_flipper.active_angle)

      if ball.live {
        ball.vy = ball.vy + gravity * dt
        ball.x = ball.x + ball.vx * dt
        ball.y = ball.y + ball.vy * dt

        if ball.x - ball_r <= table_left {
          ball.x = table_left + ball_r
          ball.vx = ball.vx.abs() * 0.96
        }
        if ball.x + ball_r >= table_right {
          ball.x = table_right - ball_r
          ball.vx = -ball.vx.abs() * 0.96
        }
        if ball.y - ball_r <= table_top {
          ball.y = table_top + ball_r
          ball.vy = ball.vy.abs() * 0.96
        }

        let mut gained = false
        if collide_ball_with_segment(ball, left_flipper, if left_up { 160.0 } else { 20.0 }) {
          gained = true
        }
        if collide_ball_with_segment(ball, right_flipper, if right_up { 160.0 } else { 20.0 }) {
          gained = true
        }
        if ball_vs_bumper(ball, 300.0, 240.0, 26.0) {
          score = score + 150
        }
        if ball_vs_bumper(ball, 450.0, 190.0, 30.0) {
          score = score + 200
        }
        if ball_vs_bumper(ball, 605.0, 260.0, 24.0) {
          score = score + 150
        }
        if gained {
          score = score + 25
        }

        if ball.y > drain_y {
          lives = lives - 1
          if lives <= 0 {
            game_over = true
            ball.live = false
          } else {
            reset_ball(ball)
          }
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(18, 20, 32, 255))

    @raylib.draw_rectangle_lines(table_left.to_int(), table_top.to_int(), (table_right - table_left).to_int(), (drain_y - table_top).to_int(), @raylib.lightgray)
    @raylib.draw_circle(300, 240, 26.0, @raylib.orange)
    @raylib.draw_circle(450, 190, 30.0, @raylib.gold)
    @raylib.draw_circle(605, 260, 24.0, @raylib.pink)

    @raylib.draw_line_ex(
      @raylib.Vector2::new(left_flipper.pivot_x, left_flipper.pivot_y),
      @raylib.Vector2::new(seg_end_x(left_flipper), seg_end_y(left_flipper)),
      14.0,
      @raylib.lime,
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(right_flipper.pivot_x, right_flipper.pivot_y),
      @raylib.Vector2::new(seg_end_x(right_flipper), seg_end_y(right_flipper)),
      14.0,
      @raylib.lime,
    )

    if ball.live {
      @raylib.draw_circle(ball.x.to_int(), ball.y.to_int(), ball_r, @raylib.raywhite)
    } else {
      @raylib.draw_circle(ball.x.to_int(), ball.y.to_int(), ball_r, @raylib.gray)
      if not(game_over) {
        @raylib.draw_text("PRESS SPACE TO LAUNCH", 320, 630, 22, @raylib.lightgray)
      }
    }

    @raylib.draw_text("PINBALL WORKSHOP 2026", 18, 12, 30, @raylib.skyblue)
    @raylib.draw_text("Score: \{score}", 20, 54, 24, @raylib.raywhite)
    @raylib.draw_text("Lives: \{lives}", 20, 82, 24, @raylib.raywhite)
    @raylib.draw_text("A/D flippers  R restart", 590, 18, 20, @raylib.gray)

    if game_over {
      @raylib.draw_rectangle(285, 295, 330, 105, @raylib.fade(@raylib.black, 0.75))
      @raylib.draw_text("GAME OVER", 368, 322, 40, @raylib.red)
      @raylib.draw_text("Press R to restart", 350, 365, 24, @raylib.raywhite)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
