///|
fn compute_hilbert_step(order : Int, index : Int) -> (Float, Float) {
  // Hilbert points base pattern
  let hilbert_points_x : FixedArray[Float] = [0.0, 0.0, 1.0, 1.0]
  let hilbert_points_y : FixedArray[Float] = [0.0, 1.0, 1.0, 0.0]
  let hilbert_index = index & 3
  let mut vx : Float = hilbert_points_x[hilbert_index]
  let mut vy : Float = hilbert_points_y[hilbert_index]
  let mut idx = index
  for j = 1; j < order; j = j + 1 {
    idx = (idx.reinterpret_as_uint() >> 2).reinterpret_as_int()
    let hi = idx & 3
    let len : Float = Float::from_int(1 << j)
    match hi {
      0 => {
        let temp = vx
        vx = vy
        vy = temp
      }
      1 => vy = vy + len
      2 => {
        // case 2 falls through to case 1 in C: both x += len and y += len
        vx = vx + len
        vy = vy + len
      }
      3 => {
        let temp : Float = len - 1.0 - vx
        vx = 2.0 * len - 1.0 - vy
        vy = temp
      }
      _ => ()
    }
  }
  (vx, vy)
}

///|
fn load_hilbert_path(order : Int, size : Float) -> Array[@raylib.Vector2] {
  let n = 1 << order
  let len : Float = size / Float::from_int(n)
  let stroke_count = n * n
  let path : Array[@raylib.Vector2] = Array::make(
    stroke_count,
    @raylib.Vector2::new(0.0, 0.0),
  )
  for i = 0; i < stroke_count; i = i + 1 {
    let (vx, vy) = compute_hilbert_step(order, i)
    let half : Float = len / 2.0
    path[i] = @raylib.Vector2::new(vx * len + half, vy * len + half)
  }
  path
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - hilbert curve",
  )

  let order : Ref[Int] = { val: 2 }
  let size : Ref[Float] = { val: Float::from_int(@raylib.get_screen_height()) }
  let mut hilbert_path = load_hilbert_path(order.val, size.val)
  let mut stroke_count = hilbert_path.length()

  let mut prev_order = order.val
  let mut prev_size = size.val.to_int()
  let mut counter = 0
  let thick : Ref[Float] = { val: 2.0 }
  let animate : Ref[Bool] = { val: true }

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // Check if order or size have changed to regenerate
    if prev_order != order.val || prev_size != size.val.to_int() {
      hilbert_path = load_hilbert_path(order.val, size.val)
      stroke_count = hilbert_path.length()
      if animate.val {
        counter = 0
      } else {
        counter = stroke_count
      }
      prev_order = order.val
      prev_size = size.val.to_int()
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    if counter < stroke_count {
      // Draw Hilbert path animation, one stroke every frame
      for i = 1; i <= counter; i = i + 1 {
        let hue : Float = Float::from_int(i) /
          Float::from_int(stroke_count) *
          360.0
        @raylib.draw_line_ex(
          hilbert_path[i],
          hilbert_path[i - 1],
          thick.val,
          @raylib.color_from_hsv(hue, 1.0, 1.0),
        )
      }
      counter += 1
    } else {
      // Draw full Hilbert path
      for i = 1; i < stroke_count; i = i + 1 {
        let hue : Float = Float::from_int(i) /
          Float::from_int(stroke_count) *
          360.0
        @raylib.draw_line_ex(
          hilbert_path[i],
          hilbert_path[i - 1],
          thick.val,
          @raylib.color_from_hsv(hue, 1.0, 1.0),
        )
      }
    }

    // Draw UI using raygui
    @raygui.gui_check_box(
      @raylib.Rectangle::new(450.0, 50.0, 20.0, 20.0),
      "ANIMATE GENERATION ON CHANGE",
      animate,
    )
    |> ignore
    @raygui.gui_spinner(
      @raylib.Rectangle::new(585.0, 100.0, 180.0, 30.0),
      "HILBERT CURVE ORDER:  ",
      order,
      2,
      8,
      false,
    )
    |> ignore
    @raygui.gui_slider(
      @raylib.Rectangle::new(524.0, 150.0, 240.0, 24.0),
      "THICKNESS:  ",
      "",
      thick,
      1.0,
      10.0,
    )
    |> ignore
    @raygui.gui_slider(
      @raylib.Rectangle::new(524.0, 190.0, 240.0, 24.0),
      "TOTAL SIZE: ",
      "",
      size,
      10.0,
      Float::from_int(@raylib.get_screen_height()) * 1.5,
    )
    |> ignore

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
