///|
fn powf(base : Float, exp : Float) -> Float {
  Float::from_double(@math.pow(base.to_double(), exp.to_double()))
}

///|
let pi : Float = 3.14159265358979323846

///|
fn ease_elastic_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  if t == 0.0 {
    return b
  }
  let t = t / d
  if t == 1.0 {
    return b + c
  }
  let p = d * 0.3
  let a = c
  let s = p / 4.0
  a * powf(2.0, -10.0 * t) * @math.sinf((t * d - s) * (2.0 * pi) / p) + c + b
}

///|
fn ease_elastic_in(t : Float, b : Float, c : Float, d : Float) -> Float {
  if t == 0.0 {
    return b
  }
  let t = t / d
  if t == 1.0 {
    return b + c
  }
  let p = d * 0.3
  let a = c
  let s = p / 4.0
  let t = t - 1.0
  -(a * powf(2.0, 10.0 * t) * @math.sinf((t * d - s) * (2.0 * pi) / p)) + b
}

///|
fn ease_cubic_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  let t = t / d - 1.0
  c * (t * t * t + 1.0) + b
}

///|
fn main {
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - easings ball anim",
  )
  let mut ball_position_x = -100
  let mut ball_radius = 20
  let mut ball_alpha : Float = 0.0
  let mut state = 0
  let mut frames_counter = 0
  @raylib.set_target_fps(60)
  while not(@raylib.window_should_close()) {
    if state == 0 {
      frames_counter += 1
      ball_position_x = ease_elastic_out(
        Float::from_int(frames_counter),
        -100.0,
        Float::from_int(screen_width) / 2.0 + 100.0,
        120.0,
      ).to_int()
      if frames_counter >= 120 {
        frames_counter = 0
        state = 1
      }
    } else if state == 1 {
      frames_counter += 1
      ball_radius = ease_elastic_in(
        Float::from_int(frames_counter),
        20.0,
        500.0,
        200.0,
      ).to_int()
      if frames_counter >= 200 {
        frames_counter = 0
        state = 2
      }
    } else if state == 2 {
      frames_counter += 1
      ball_alpha = ease_cubic_out(
        Float::from_int(frames_counter),
        0.0,
        1.0,
        200.0,
      )
      if frames_counter >= 200 {
        frames_counter = 0
        state = 3
      }
    } else if state == 3 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) {
        ball_position_x = -100
        ball_radius = 20
        ball_alpha = 0.0
        state = 0
      }
    }
    if @raylib.is_key_pressed(@raylib.KeyR) {
      frames_counter = 0
    }
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    if state >= 2 {
      @raylib.draw_rectangle(0, 0, screen_width, screen_height, @raylib.green)
    }
    @raylib.draw_circle(
      ball_position_x,
      200,
      Float::from_int(ball_radius),
      @raylib.fade(@raylib.red, 1.0 - ball_alpha),
    )
    if state == 3 {
      @raylib.draw_text(
        "PRESS [ENTER] TO PLAY AGAIN!", 240, 200, 20, @raylib.black,
      )
    }
    @raylib.end_drawing()
  }
  @raylib.close_window()
}
