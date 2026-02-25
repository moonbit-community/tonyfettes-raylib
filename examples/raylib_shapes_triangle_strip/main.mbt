///|
fn main {
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - triangle strip",
  )

  let center = @raylib.Vector2::new(
    Float::from_int(screen_width) / 2.0 - 125.0,
    Float::from_int(screen_height) / 2.0,
  )
  let segments : Ref[Float] = { val: 6.0 }
  let inside_radius : Float = 100.0
  let outside_radius : Float = 150.0
  let outline : Ref[Bool] = { val: true }
  let pi : Float = Float::from_double(@math.PI)
  let deg2rad : Float = pi / 180.0

  @raylib.set_target_fps(60)

  while not(@raylib.window_should_close()) {
    let point_count = segments.val.to_int()
    let angle_step : Float = Float::from_int(360) /
      Float::from_int(point_count) *
      deg2rad

    // Build triangle strip points
    let points : Array[_] = Array::make(
      point_count * 2 + 2,
      @raylib.Vector2::new(0.0, 0.0),
    )
    for i = 0; i < point_count; i = i + 1 {
      let angle1 = Float::from_int(i) * angle_step
      points[i * 2] = @raylib.Vector2::new(
        center.x + @math.cosf(angle1) * inside_radius,
        center.y + @math.sinf(angle1) * inside_radius,
      )
      let angle2 : Float = angle1 + angle_step / 2.0
      points[i * 2 + 1] = @raylib.Vector2::new(
        center.x + @math.cosf(angle2) * outside_radius,
        center.y + @math.sinf(angle2) * outside_radius,
      )
    }
    points[point_count * 2] = points[0]
    points[point_count * 2 + 1] = points[1]

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    let rad2deg : Float = 180.0 / pi
    for i = 0; i < point_count; i = i + 1 {
      let a = points[i * 2]
      let b = points[i * 2 + 1]
      let c = points[i * 2 + 2]
      let d = points[i * 2 + 3]

      let angle1 = Float::from_int(i) * angle_step
      @raylib.draw_triangle(
        c,
        b,
        a,
        @raylib.color_from_hsv(angle1 * rad2deg, 1.0, 1.0),
      )
      @raylib.draw_triangle(
        d,
        b,
        c,
        @raylib.color_from_hsv(
          {
            let angle2 : Float = angle1 + angle_step / 2.0
            angle2 * rad2deg
          },
          1.0,
          1.0,
        ),
      )

      if outline.val {
        @raylib.draw_triangle_lines(a, b, c, @raylib.black)
        @raylib.draw_triangle_lines(c, b, d, @raylib.black)
      }
    }

    @raylib.draw_line(
      580,
      0,
      580,
      @raylib.get_screen_height(),
      @raylib.Color::new(218, 218, 218, 255),
    )
    @raylib.draw_rectangle(
      580,
      0,
      @raylib.get_screen_width(),
      @raylib.get_screen_height(),
      @raylib.Color::new(232, 232, 232, 255),
    )

    // GUI controls
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(640.0, 40.0, 120.0, 20.0),
      "Segments",
      segments.val.to_int().to_string(),
      segments,
      6.0,
      60.0,
    )
    |> ignore
    @raygui.gui_check_box(
      @raylib.Rectangle::new(640.0, 70.0, 20.0, 20.0),
      "Outline",
      outline,
    )
    |> ignore

    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  @raylib.close_window()
}
