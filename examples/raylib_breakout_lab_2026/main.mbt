///|
let arena_w : Int = 960

///|
let arena_h : Int = 720

///|
let bricks_cols : Int = 12

///|
let bricks_rows : Int = 8

///|
let brick_w : Int = 70

///|
let brick_h : Int = 24

///|
let brick_gap : Int = 5

///|
let bricks_x0 : Int = 36

///|
let bricks_y0 : Int = 80

///|
fn fi(v : Int) -> Float {
  Float::from_int(v)
}

///|
struct Brick {
  mut alive : Bool
  x : Int
  y : Int
  mut hp : Int
}

///|
fn make_bricks() -> Array[Brick] {
  let arr : Array[Brick] = []
  for r = 0; r < bricks_rows; r = r + 1 {
    for c = 0; c < bricks_cols; c = c + 1 {
      let px = bricks_x0 + c * (brick_w + brick_gap)
      let py = bricks_y0 + r * (brick_h + brick_gap)
      let hp = if r < 2 { 3 } else if r < 5 { 2 } else { 1 }
      arr.push({ alive: true, x: px, y: py, hp })
    }
  }
  arr
}

///|
fn reset_ball() -> (Float, Float, Float, Float) {
  (fi(arena_w) * (0.5 : Float), fi(arena_h - 120), 180.0, -250.0)
}

///|
fn brick_color(hp : Int) -> @raylib.Color {
  match hp {
    3 => @raylib.maroon
    2 => @raylib.orange
    _ => @raylib.gold
  }
}

///|
fn main {
  @raylib.init_window(arena_w, arena_h, "Breakout Lab 2026")
  @raylib.set_target_fps(60)

  let bricks = make_bricks()
  let mut paddle_x : Float = fi(arena_w) * (0.5 : Float) - 55.0
  let mut paddle_w : Float = 110.0
  let paddle_y : Float = fi(arena_h - 60)
  let paddle_h : Float = 16.0

  let (sx, sy, svx, svy) = reset_ball()
  let mut ball_x : Float = sx
  let mut ball_y : Float = sy
  let mut ball_vx : Float = svx
  let mut ball_vy : Float = svy
  let ball_r : Float = 8.0

  let mut lives = 3
  let mut score = 0
  let mut game_over = false
  let mut win = false
  let mut wide_paddle = false

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > (0.05 : Float) {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      let fresh = make_bricks()
      bricks.clear()
      for i = 0; i < fresh.length(); i = i + 1 {
        bricks.push(fresh[i])
      }

      let (nx, ny, nvx, nvy) = reset_ball()
      ball_x = nx
      ball_y = ny
      ball_vx = nvx
      ball_vy = nvy
      paddle_x = fi(arena_w) * (0.5 : Float) - 55.0
      paddle_w = 110.0
      lives = 3
      score = 0
      game_over = false
      win = false
      wide_paddle = false
    }

    if not(game_over) {
      let mut dir : Float = 0.0
      if @raylib.is_key_down(@raylib.KeyLeft) ||
        @raylib.is_key_down(@raylib.KeyA) {
        dir = dir - (1.0 : Float)
      }
      if @raylib.is_key_down(@raylib.KeyRight) ||
        @raylib.is_key_down(@raylib.KeyD) {
        dir = dir + (1.0 : Float)
      }

      paddle_x = paddle_x + dir * (480.0 : Float) * dt
      if paddle_x < (8.0 : Float) {
        paddle_x = 8.0
      }
      if paddle_x + paddle_w > fi(arena_w - 8) {
        paddle_x = fi(arena_w - 8) - paddle_w
      }

      ball_x = ball_x + ball_vx * dt
      ball_y = ball_y + ball_vy * dt

      if ball_x - ball_r < (0.0 : Float) {
        ball_x = ball_r
        ball_vx = ball_vx.abs()
      }
      if ball_x + ball_r > fi(arena_w) {
        ball_x = fi(arena_w) - ball_r
        ball_vx = -ball_vx.abs()
      }
      if ball_y - ball_r < (0.0 : Float) {
        ball_y = ball_r
        ball_vy = ball_vy.abs()
      }

      if ball_y + ball_r >= paddle_y &&
        ball_y - ball_r <= paddle_y + paddle_h &&
        ball_x >= paddle_x &&
        ball_x <= paddle_x + paddle_w &&
        ball_vy > (0.0 : Float) {
        let t : Float = (ball_x - paddle_x) / paddle_w
        ball_y = paddle_y - ball_r - (0.2 : Float)
        ball_vy = -ball_vy.abs() * (1.02 : Float)
        ball_vx = (t - (0.5 : Float)) * (520.0 : Float)
      }

      let mut alive_count = 0
      for i = 0; i < bricks.length(); i = i + 1 {
        if not(bricks[i].alive) {
          continue
        }
        alive_count = alive_count + 1

        let bx = fi(bricks[i].x)
        let by = fi(bricks[i].y)
        if ball_x + ball_r < bx ||
          ball_x - ball_r > bx + fi(brick_w) ||
          ball_y + ball_r < by ||
          ball_y - ball_r > by + fi(brick_h) {
          continue
        }

        let left_pen = ball_x + ball_r - bx
        let right_pen = bx + fi(brick_w) - (ball_x - ball_r)
        let top_pen = ball_y + ball_r - by
        let bottom_pen = by + fi(brick_h) - (ball_y - ball_r)
        let min_lr = if left_pen < right_pen { left_pen } else { right_pen }
        let min_tb = if top_pen < bottom_pen { top_pen } else { bottom_pen }

        if min_lr < min_tb {
          ball_vx = -ball_vx
        } else {
          ball_vy = -ball_vy
        }

        bricks[i].hp = bricks[i].hp - 1
        score = score + 10
        if bricks[i].hp <= 0 {
          bricks[i].alive = false
          score = score + 40
          if not(wide_paddle) && @raylib.get_random_value(0, 11) == 0 {
            wide_paddle = true
            paddle_w = paddle_w + 30.0
            if paddle_w > (190.0 : Float) {
              paddle_w = 190.0
            }
          }
        }
        break
      }

      if alive_count == 0 {
        game_over = true
        win = true
      }

      if ball_y - ball_r > fi(arena_h) {
        lives = lives - 1
        if lives <= 0 {
          game_over = true
          win = false
        } else {
          let (nx, ny, nvx, nvy) = reset_ball()
          ball_x = nx
          ball_y = ny
          ball_vx = nvx
          ball_vy = nvy
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(14, 16, 28, 255))

    for i = 0; i < bricks.length(); i = i + 1 {
      if bricks[i].alive {
        @raylib.draw_rectangle(
          bricks[i].x,
          bricks[i].y,
          brick_w,
          brick_h,
          brick_color(bricks[i].hp),
        )
        @raylib.draw_rectangle_lines(
          bricks[i].x,
          bricks[i].y,
          brick_w,
          brick_h,
          @raylib.black,
        )
      }
    }

    @raylib.draw_rectangle(
      paddle_x.to_int(),
      paddle_y.to_int(),
      paddle_w.to_int(),
      paddle_h.to_int(),
      if wide_paddle {
        @raylib.lime
      } else {
        @raylib.skyblue
      },
    )
    @raylib.draw_circle(
      ball_x.to_int(),
      ball_y.to_int(),
      ball_r,
      @raylib.raywhite,
    )

    @raylib.draw_text("BREAKOUT LAB 2026", 22, 18, 34, @raylib.skyblue)
    @raylib.draw_text("Score: \{score}", 24, 58, 24, @raylib.raywhite)
    @raylib.draw_text("Lives: \{lives}", 220, 58, 24, @raylib.raywhite)
    @raylib.draw_text("A/D or <- -> move  R restart", 560, 22, 20, @raylib.gray)

    if game_over {
      @raylib.draw_rectangle(
        280,
        290,
        390,
        130,
        @raylib.fade(@raylib.black, 0.75),
      )
      @raylib.draw_text(
        if win {
          "STAGE CLEAR"
        } else {
          "GAME OVER"
        },
        350,
        326,
        44,
        if win {
          @raylib.lime
        } else {
          @raylib.red
        },
      )
      @raylib.draw_text("Press R to restart", 372, 372, 26, @raylib.raywhite)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
