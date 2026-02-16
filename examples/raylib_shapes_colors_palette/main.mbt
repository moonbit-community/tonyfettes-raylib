///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - colors palette",
  )
  let colors : Array[@raylib.Color] = [
    @raylib.darkgray, @raylib.maroon, @raylib.orange, @raylib.darkgreen, @raylib.darkblue,
    @raylib.darkpurple, @raylib.darkbrown, @raylib.gray, @raylib.red, @raylib.gold,
    @raylib.lime, @raylib.blue, @raylib.violet, @raylib.brown, @raylib.lightgray,
    @raylib.pink, @raylib.yellow, @raylib.green, @raylib.skyblue, @raylib.purple,
    @raylib.beige,
  ]
  let color_names : Array[String] = [
    "DARKGRAY", "MAROON", "ORANGE", "DARKGREEN", "DARKBLUE", "DARKPURPLE", "DARKBROWN",
    "GRAY", "RED", "GOLD", "LIME", "BLUE", "VIOLET", "BROWN", "LIGHTGRAY", "PINK",
    "YELLOW", "GREEN", "SKYBLUE", "PURPLE", "BEIGE",
  ]
  let max_colors_count = colors.length()

  // Fills colors_recs data (for every rectangle)
  let colors_recs : Array[@raylib.Rectangle] = Array::make(
    max_colors_count,
    @raylib.Rectangle::new(0.0, 0.0, 0.0, 0.0),
  )
  for i = 0; i < max_colors_count; i = i + 1 {
    let fi = Float::from_int(i % 7)
    let row = Float::from_int(i / 7)
    colors_recs[i] = @raylib.Rectangle::new(
      20.0 + 100.0 * fi + 10.0 * fi,
      80.0 + 100.0 * row + 10.0 * row,
      100.0,
      100.0,
    )
  }

  // Color state: 0 = DEFAULT, 1 = MOUSE_HOVER
  let color_state : Array[Int] = Array::make(max_colors_count, 0)

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let mouse_point = @raylib.get_mouse_position()
    for i = 0; i < max_colors_count; i = i + 1 {
      if @raylib.check_collision_point_rec(mouse_point, colors_recs[i]) {
        color_state[i] = 1
      } else {
        color_state[i] = 0
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_text("raylib colors palette", 28, 42, 20, @raylib.black)
    @raylib.draw_text(
      "press SPACE to see all colors",
      @raylib.get_screen_width() - 180,
      @raylib.get_screen_height() - 40,
      10,
      @raylib.gray,
    )
    for i = 0; i < max_colors_count; i = i + 1 {
      // Draw color rectangle
      let alpha : Float = if color_state[i] == 1 { 0.6 } else { 1.0 }
      @raylib.draw_rectangle_rec(colors_recs[i], @raylib.fade(colors[i], alpha))
      if @raylib.is_key_down(@raylib.KeySpace) || color_state[i] == 1 {
        let rec = colors_recs[i]
        @raylib.draw_rectangle(
          rec.x.to_int(),
          (rec.y + rec.height - 26.0).to_int(),
          rec.width.to_int(),
          20,
          @raylib.black,
        )
        @raylib.draw_rectangle_lines_ex(
          rec,
          6.0,
          @raylib.fade(@raylib.black, 0.3),
        )
        let text_width = @raylib.measure_text(color_names[i], 10)
        @raylib.draw_text(
          color_names[i],
          (rec.x + rec.width - Float::from_int(text_width) - 12.0).to_int(),
          (rec.y + rec.height - 20.0).to_int(),
          10,
          colors[i],
        )
      }
    }
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
