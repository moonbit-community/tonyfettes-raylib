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
fn ease_quad_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  let t = t / d
  -c * t * (t - 2.0) + b
}

///|
fn sqrtf(x : Float) -> Float {
  x.sqrt()
}

///|
fn ease_circ_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  let t = t / d - 1.0
  c * sqrtf(1.0 - t * t) + b
}

///|
fn ease_sine_out(t : Float, b : Float, c : Float, d : Float) -> Float {
  c * @math.sinf(t / d * (pi / 2.0)) + b
}

///|
fn main {
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - easings box anim",
  )
  let mut rec_x = Float::from_int(screen_width) / 2.0
  let mut rec_y : Float = -100.0
  let mut rec_width : Float = 100.0
  let mut rec_height : Float = 100.0
  let mut rotation : Float = 0.0
  let mut alpha : Float = 1.0
  let mut state = 0
  let mut frames_counter = 0
  @raylib.set_target_fps(60)
  while not(@raylib.window_should_close()) {
    if state == 0 {
      frames_counter += 1
      rec_y = ease_elastic_out(
        Float::from_int(frames_counter),
        -100.0,
        Float::from_int(screen_height) / 2.0 + 100.0,
        120.0,
      )
      if frames_counter >= 120 {
        frames_counter = 0
        state = 1
      }
    } else if state == 1 {
      frames_counter += 1
      rec_height = ease_bounce_out(
        Float::from_int(frames_counter),
        100.0,
        -90.0,
        120.0,
      )
      rec_width = ease_bounce_out(
        Float::from_int(frames_counter),
        100.0,
        Float::from_int(screen_width),
        120.0,
      )
      if frames_counter >= 120 {
        frames_counter = 0
        state = 2
      }
    } else if state == 2 {
      frames_counter += 1
      rotation = ease_quad_out(
        Float::from_int(frames_counter),
        0.0,
        270.0,
        240.0,
      )
      if frames_counter >= 240 {
        frames_counter = 0
        state = 3
      }
    } else if state == 3 {
      frames_counter += 1
      rec_height = ease_circ_out(
        Float::from_int(frames_counter),
        10.0,
        Float::from_int(screen_width),
        120.0,
      )
      if frames_counter >= 120 {
        frames_counter = 0
        state = 4
      }
    } else if state == 4 {
      frames_counter += 1
      alpha = ease_sine_out(Float::from_int(frames_counter), 1.0, -1.0, 160.0)
      if frames_counter >= 160 {
        frames_counter = 0
        state = 5
      }
    }
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      rec_x = Float::from_int(screen_width) / 2.0
      rec_y = -100.0
      rec_width = 100.0
      rec_height = 100.0
      rotation = 0.0
      alpha = 1.0
      state = 0
      frames_counter = 0
    }
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_rectangle_pro(
      @raylib.Rectangle::new(rec_x, rec_y, rec_width, rec_height),
      @raylib.Vector2::new(rec_width / 2.0, rec_height / 2.0),
      rotation,
      @raylib.fade(@raylib.black, alpha),
    )
    @raylib.draw_text(
      "PRESS [SPACE] TO RESET BOX ANIMATION!",
      10,
      screen_height - 25,
      20,
      @raylib.lightgray,
    )
    @raylib.end_drawing()
  }
  @raylib.close_window()
}
