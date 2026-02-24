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
fn ease_linear_in(t : Float, b : Float, c : Float, d : Float) -> Float {
  c * t / d + b
}

///|
fn main {
  let screen_width = 800
  let screen_height = 450
  let recs_width = 50
  let recs_height = 50
  let max_recs_x = screen_width / recs_width // 16
  let max_recs_y = screen_height / recs_height // 9
  let play_time = 240
  let total_recs = max_recs_x * max_recs_y

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - easings rectangle array",
  )

  let recs_x : FixedArray[Float] = FixedArray::make(total_recs, 0.0)
  let recs_y : FixedArray[Float] = FixedArray::make(total_recs, 0.0)
  let recs_w : FixedArray[Float] = FixedArray::make(
    total_recs,
    Float::from_int(recs_width),
  )
  let recs_h : FixedArray[Float] = FixedArray::make(
    total_recs,
    Float::from_int(recs_height),
  )

  for y = 0; y < max_recs_y; y = y + 1 {
    for x = 0; x < max_recs_x; x = x + 1 {
      recs_x[y * max_recs_x + x] = Float::from_int(recs_width) / 2.0 +
        Float::from_int(recs_width * x)
      recs_y[y * max_recs_x + x] = Float::from_int(recs_height) / 2.0 +
        Float::from_int(recs_height * y)
    }
  }

  let mut rotation : Float = 0.0
  let mut frames_counter = 0
  let mut state = 0

  @raylib.set_target_fps(60)

  while not(@raylib.window_should_close()) {
    if state == 0 {
      frames_counter += 1
      for i = 0; i < total_recs; i = i + 1 {
        recs_h[i] = ease_circ_out(
          Float::from_int(frames_counter),
          Float::from_int(recs_height),
          Float::from_int(-recs_height),
          Float::from_int(play_time),
        )
        recs_w[i] = ease_circ_out(
          Float::from_int(frames_counter),
          Float::from_int(recs_width),
          Float::from_int(-recs_width),
          Float::from_int(play_time),
        )
        if recs_h[i] < 0.0 {
          recs_h[i] = 0.0
        }
        if recs_w[i] < 0.0 {
          recs_w[i] = 0.0
        }
        if recs_h[i] == 0.0 && recs_w[i] == 0.0 {
          state = 1
        }
        rotation = ease_linear_in(
          Float::from_int(frames_counter),
          0.0,
          360.0,
          Float::from_int(play_time),
        )
      }
    } else if state == 1 && @raylib.is_key_pressed(@raylib.KeySpace) {
      frames_counter = 0
      for i = 0; i < total_recs; i = i + 1 {
        recs_h[i] = Float::from_int(recs_height)
        recs_w[i] = Float::from_int(recs_width)
      }
      state = 0
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    if state == 0 {
      for i = 0; i < total_recs; i = i + 1 {
        @raylib.draw_rectangle_pro(
          @raylib.Rectangle::new(recs_x[i], recs_y[i], recs_w[i], recs_h[i]),
          @raylib.Vector2::new(recs_w[i] / 2.0, recs_h[i] / 2.0),
          rotation,
          @raylib.red,
        )
      }
    } else if state == 1 {
      @raylib.draw_text(
        "PRESS [SPACE] TO PLAY AGAIN!", 240, 200, 20, @raylib.gray,
      )
    }
    @raylib.end_drawing()
  }
  @raylib.close_window()
}
