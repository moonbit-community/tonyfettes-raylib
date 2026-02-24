///|
fn powf(base : Float, exp : Float) -> Float {
  Float::from_double(@math.pow(base.to_double(), exp.to_double()))
}

///|
fn sqrtf(x : Float) -> Float {
  x.sqrt()
}

///|
let pi : Float = 3.14159265358979323846

///|
fn no_ease(_t : Float, b : Float, _c : Float, _d : Float) -> Float {
  b
}

///|
fn ease_linear_none(t : Float, b : Float, c : Float, d : Float) -> Float {
  c * t / d + b
}

///|
fn ease_linear_in(t : Float, b : Float, c : Float, d : Float) -> Float {
  c * t / d + b
}

///|
fn ease_linear_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  c * t / d + b
}

///|
fn ease_linear_in_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  c * t / d + b
}

///|
fn ease_sine_in(t : Float, b : Float, c : Float, d : Float) -> Float {
  -c * @math.cosf(t / d * (pi / 2.0)) + c + b
}

///|
fn ease_sine_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  c * @math.sinf(t / d * (pi / 2.0)) + b
}

///|
fn ease_sine_in_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  -c / 2.0 * (@math.cosf(pi * t / d) - 1.0) + b
}

///|
fn ease_circ_in(t : Float, b : Float, c : Float, d : Float) -> Float {
  let t = t / d
  -c * (sqrtf(1.0 - t * t) - 1.0) + b
}

///|
fn ease_circ_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  let t = t / d - 1.0
  c * sqrtf(1.0 - t * t) + b
}

///|
fn ease_circ_in_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  let t = t / (d / 2.0)
  if t < 1.0 {
    -c / 2.0 * (sqrtf(1.0 - t * t) - 1.0) + b
  } else {
    let t = t - 2.0
    c / 2.0 * (sqrtf(1.0 - t * t) + 1.0) + b
  }
}

///|
fn ease_cubic_in(t : Float, b : Float, c : Float, d : Float) -> Float {
  let t = t / d
  c * t * t * t + b
}

///|
fn ease_cubic_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  let t = t / d - 1.0
  c * (t * t * t + 1.0) + b
}

///|
fn ease_cubic_in_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  let t = t / (d / 2.0)
  if t < 1.0 {
    c / 2.0 * t * t * t + b
  } else {
    let t = t - 2.0
    c / 2.0 * (t * t * t + 2.0) + b
  }
}

///|
fn ease_quad_in(t : Float, b : Float, c : Float, d : Float) -> Float {
  let t = t / d
  c * t * t + b
}

///|
fn ease_quad_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  let t = t / d
  -c * t * (t - 2.0) + b
}

///|
fn ease_quad_in_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  let t = t / (d / 2.0)
  if t < 1.0 {
    c / 2.0 * t * t + b
  } else {
    let t = t - 1.0
    -c / 2.0 * (t * (t - 2.0) - 1.0) + b
  }
}

///|
fn ease_expo_in(t : Float, b : Float, c : Float, d : Float) -> Float {
  if t == 0.0 {
    b
  } else {
    c * powf(2.0, 10.0 * (t / d - 1.0)) + b
  }
}

///|
fn ease_expo_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  if t == d {
    b + c
  } else {
    c * (-powf(2.0, -10.0 * t / d) + 1.0) + b
  }
}

///|
fn ease_expo_in_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  if t == 0.0 {
    return b
  }
  if t == d {
    return b + c
  }
  let t = t / (d / 2.0)
  if t < 1.0 {
    c / 2.0 * powf(2.0, 10.0 * (t - 1.0)) + b
  } else {
    let t = t - 1.0
    c / 2.0 * (-powf(2.0, -10.0 * t) + 2.0) + b
  }
}

///|
fn ease_back_in(t : Float, b : Float, c : Float, d : Float) -> Float {
  let s : Float = 1.70158
  let t = t / d
  c * t * t * ((s + 1.0) * t - s) + b
}

///|
fn ease_back_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  let s : Float = 1.70158
  let t = t / d - 1.0
  c * (t * t * ((s + 1.0) * t + s) + 1.0) + b
}

///|
fn ease_back_in_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  let s : Float = 1.70158 * 1.525
  let t = t / (d / 2.0)
  if t < 1.0 {
    c / 2.0 * (t * t * ((s + 1.0) * t - s)) + b
  } else {
    let t = t - 2.0
    c / 2.0 * (t * t * ((s + 1.0) * t + s) + 2.0) + b
  }
}

///|
fn ease_bounce_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  let t = t / d
  if t < 1.0 / 2.75 {
    c * (7.5625 * t * t) + b
  } else if t < 2.0 / 2.75 {
    let t = t - 1.5 / 2.75
    c * (7.5625 * t * t + 0.75) + b
  } else if t < 2.5 / 2.75 {
    let t = t - 2.25 / 2.75
    c * (7.5625 * t * t + 0.9375) + b
  } else {
    let t = t - 2.625 / 2.75
    c * (7.5625 * t * t + 0.984375) + b
  }
}

///|
fn ease_bounce_in(t : Float, b : Float, c : Float, d : Float) -> Float {
  c - ease_bounce_out(d - t, 0.0, c, d) + b
}

///|
fn ease_bounce_in_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  if t < d / 2.0 {
    ease_bounce_in(t * 2.0, 0.0, c, d) * 0.5 + b
  } else {
    ease_bounce_out(t * 2.0 - d, 0.0, c, d) * 0.5 + c * 0.5 + b
  }
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
  let s = p / 4.0
  let t = t - 1.0
  -(c * powf(2.0, 10.0 * t) * @math.sinf((t * d - s) * (2.0 * pi) / p)) + b
}

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
  let s = p / 4.0
  c * powf(2.0, -10.0 * t) * @math.sinf((t * d - s) * (2.0 * pi) / p) + c + b
}

///|
fn ease_elastic_in_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  if t == 0.0 {
    return b
  }
  let t = t / (d / 2.0)
  if t == 2.0 {
    return b + c
  }
  let p = d * (0.3 * 1.5)
  let s = p / 4.0
  if t < 1.0 {
    let t = t - 1.0
    -0.5 * (c * powf(2.0, 10.0 * t) * @math.sinf((t * d - s) * (2.0 * pi) / p)) +
    b
  } else {
    let t = t - 1.0
    c * powf(2.0, -10.0 * t) * @math.sinf((t * d - s) * (2.0 * pi) / p) * 0.5 +
    c +
    b
  }
}

///|
let easing_names : FixedArray[String] = [
  "EaseLinearNone", "EaseLinearIn", "EaseLinearOut", "EaseLinearInOut", "EaseSineIn",
  "EaseSineOut", "EaseSineInOut", "EaseCircIn", "EaseCircOut", "EaseCircInOut", "EaseCubicIn",
  "EaseCubicOut", "EaseCubicInOut", "EaseQuadIn", "EaseQuadOut", "EaseQuadInOut",
  "EaseExpoIn", "EaseExpoOut", "EaseExpoInOut", "EaseBackIn", "EaseBackOut", "EaseBackInOut",
  "EaseBounceOut", "EaseBounceIn", "EaseBounceInOut", "EaseElasticIn", "EaseElasticOut",
  "EaseElasticInOut", "None",
]

///|
fn apply_easing(
  index : Int,
  t : Float,
  b : Float,
  c : Float,
  d : Float,
) -> Float {
  match index {
    0 => ease_linear_none(t, b, c, d)
    1 => ease_linear_in(t, b, c, d)
    2 => ease_linear_out(t, b, c, d)
    3 => ease_linear_in_out(t, b, c, d)
    4 => ease_sine_in(t, b, c, d)
    5 => ease_sine_out(t, b, c, d)
    6 => ease_sine_in_out(t, b, c, d)
    7 => ease_circ_in(t, b, c, d)
    8 => ease_circ_out(t, b, c, d)
    9 => ease_circ_in_out(t, b, c, d)
    10 => ease_cubic_in(t, b, c, d)
    11 => ease_cubic_out(t, b, c, d)
    12 => ease_cubic_in_out(t, b, c, d)
    13 => ease_quad_in(t, b, c, d)
    14 => ease_quad_out(t, b, c, d)
    15 => ease_quad_in_out(t, b, c, d)
    16 => ease_expo_in(t, b, c, d)
    17 => ease_expo_out(t, b, c, d)
    18 => ease_expo_in_out(t, b, c, d)
    19 => ease_back_in(t, b, c, d)
    20 => ease_back_out(t, b, c, d)
    21 => ease_back_in_out(t, b, c, d)
    22 => ease_bounce_out(t, b, c, d)
    23 => ease_bounce_in(t, b, c, d)
    24 => ease_bounce_in_out(t, b, c, d)
    25 => ease_elastic_in(t, b, c, d)
    26 => ease_elastic_out(t, b, c, d)
    27 => ease_elastic_in_out(t, b, c, d)
    _ => no_ease(t, b, c, d)
  }
}

///|
fn main {
  let screen_width = 800
  let screen_height = 450
  let font_size = 20
  let num_easings = 29 // 28 + None
  let d_step : Float = 20.0
  let d_step_fine : Float = 2.0
  let d_min : Float = 1.0
  let d_max : Float = 10000.0
  @raylib.init_window(
    screen_width, screen_height, "raylib [easings] example - easings testbed",
  )
  let mut ball_x : Float = 100.0
  let mut ball_y : Float = 100.0
  let mut t : Float = 0.0
  let mut d : Float = 300.0
  let mut paused = true
  let mut bounded_t = true
  let mut easing_x = num_easings - 1 // None
  let mut easing_y = num_easings - 1 // None
  @raylib.set_target_fps(60)
  while not(@raylib.window_should_close()) {
    if @raylib.is_key_pressed(@raylib.KeyT) {
      bounded_t = not(bounded_t)
    }
    // Choose easing for X
    if @raylib.is_key_pressed(@raylib.KeyRight) {
      easing_x += 1
      if easing_x > num_easings - 1 {
        easing_x = 0
      }
    } else if @raylib.is_key_pressed(@raylib.KeyLeft) {
      if easing_x == 0 {
        easing_x = num_easings - 1
      } else {
        easing_x -= 1
      }
    }
    // Choose easing for Y
    if @raylib.is_key_pressed(@raylib.KeyDown) {
      easing_y += 1
      if easing_y > num_easings - 1 {
        easing_y = 0
      }
    } else if @raylib.is_key_pressed(@raylib.KeyUp) {
      if easing_y == 0 {
        easing_y = num_easings - 1
      } else {
        easing_y -= 1
      }
    }
    // Change duration
    if @raylib.is_key_pressed(@raylib.KeyW) && d < d_max - d_step {
      d += d_step
    } else if @raylib.is_key_pressed(@raylib.KeyQ) && d > d_min + d_step {
      d -= d_step
    }
    if @raylib.is_key_down(@raylib.KeyS) && d < d_max - d_step_fine {
      d += d_step_fine
    } else if @raylib.is_key_down(@raylib.KeyA) && d > d_min + d_step_fine {
      d -= d_step_fine
    }
    // Reset controls
    if @raylib.is_key_pressed(@raylib.KeySpace) ||
      @raylib.is_key_pressed(@raylib.KeyT) ||
      @raylib.is_key_pressed(@raylib.KeyRight) ||
      @raylib.is_key_pressed(@raylib.KeyLeft) ||
      @raylib.is_key_pressed(@raylib.KeyDown) ||
      @raylib.is_key_pressed(@raylib.KeyUp) ||
      @raylib.is_key_pressed(@raylib.KeyW) ||
      @raylib.is_key_pressed(@raylib.KeyQ) ||
      @raylib.is_key_down(@raylib.KeyS) ||
      @raylib.is_key_down(@raylib.KeyA) ||
      (@raylib.is_key_pressed(@raylib.KeyEnter) && bounded_t && t >= d) {
      t = 0.0
      ball_x = 100.0
      ball_y = 100.0
      paused = true
    }
    if @raylib.is_key_pressed(@raylib.KeyEnter) {
      paused = not(paused)
    }
    if not(paused) && ((bounded_t && t < d) || not(bounded_t)) {
      ball_x = apply_easing(easing_x, t, 100.0, 700.0 - 170.0, d)
      ball_y = apply_easing(easing_y, t, 100.0, 400.0 - 170.0, d)
      t += 1.0
    }
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    let bound_char = if bounded_t { "b" } else { "u" }
    @raylib.draw_text(
      "Easing x: \{easing_names[easing_x]}",
      20,
      font_size,
      font_size,
      @raylib.lightgray,
    )
    @raylib.draw_text(
      "Easing y: \{easing_names[easing_y]}",
      20,
      font_size * 2,
      font_size,
      @raylib.lightgray,
    )
    @raylib.draw_text(
      "t (\{bound_char}) = \{t} d = \{d}",
      20,
      font_size * 3,
      font_size,
      @raylib.lightgray,
    )
    @raylib.draw_text(
      "Use ENTER to play or pause movement, use SPACE to restart",
      20,
      screen_height - font_size * 2,
      font_size,
      @raylib.lightgray,
    )
    @raylib.draw_text(
      "Use Q and W or A and S keys to change duration",
      20,
      screen_height - font_size * 3,
      font_size,
      @raylib.lightgray,
    )
    @raylib.draw_text(
      "Use LEFT or RIGHT keys to choose easing for the x axis",
      20,
      screen_height - font_size * 4,
      font_size,
      @raylib.lightgray,
    )
    @raylib.draw_text(
      "Use UP or DOWN keys to choose easing for the y axis",
      20,
      screen_height - font_size * 5,
      font_size,
      @raylib.lightgray,
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(ball_x, ball_y),
      16.0,
      @raylib.maroon,
    )
    @raylib.end_drawing()
  }
  @raylib.close_window()
}
