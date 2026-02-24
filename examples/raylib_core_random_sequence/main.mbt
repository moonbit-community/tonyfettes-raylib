///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - Generates a random sequence",
  )

  let mut rect_count = 20
  let mut rect_size : Float = Float::from_int(screen_width) /
    Float::from_int(rect_count)
  let mut rect_colors : Array[@raylib.Color] = []
  let mut rect_rects : Array[@raylib.Rectangle] = []
  generate_sequence(
    rect_count,
    rect_size,
    Float::from_int(screen_width),
    0.75 * Float::from_int(screen_height),
    rect_colors,
    rect_rects,
  )

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      shuffle_sequence(rect_colors, rect_rects, rect_count)
    }

    if @raylib.is_key_pressed(@raylib.KeyUp) {
      rect_count += 1
      rect_size = Float::from_int(screen_width) / Float::from_int(rect_count)
      rect_colors = []
      rect_rects = []
      generate_sequence(
        rect_count,
        rect_size,
        Float::from_int(screen_width),
        0.75 * Float::from_int(screen_height),
        rect_colors,
        rect_rects,
      )
    }

    if @raylib.is_key_pressed(@raylib.KeyDown) {
      if rect_count >= 4 {
        rect_count -= 1
        rect_size = Float::from_int(screen_width) / Float::from_int(rect_count)
        rect_colors = []
        rect_rects = []
        generate_sequence(
          rect_count,
          rect_size,
          Float::from_int(screen_width),
          0.75 * Float::from_int(screen_height),
          rect_colors,
          rect_rects,
        )
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    let font_size = 20
    for x = 0; x < rect_count; x = x + 1 {
      @raylib.draw_rectangle_rec(rect_rects[x], rect_colors[x])
    }

    draw_text_center_key_help(
      "SPACE",
      "to shuffle the sequence.",
      10,
      screen_height - 96,
      font_size,
      @raylib.black,
    )
    draw_text_center_key_help(
      "UP",
      "to add a rectangle and generate a new sequence.",
      10,
      screen_height - 64,
      font_size,
      @raylib.black,
    )
    draw_text_center_key_help(
      "DOWN",
      "to remove a rectangle and generate a new sequence.",
      10,
      screen_height - 32,
      font_size,
      @raylib.black,
    )

    let rect_count_text = "\{rect_count} rectangles"
    let rect_count_text_size = @raylib.measure_text(rect_count_text, font_size)
    @raylib.draw_text(
      rect_count_text,
      screen_width - rect_count_text_size - 10,
      10,
      font_size,
      @raylib.black,
    )

    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}

///|
fn generate_sequence(
  rect_count : Int,
  rect_width : Float,
  screen_width : Float,
  screen_height : Float,
  colors : Array[@raylib.Color],
  rects : Array[@raylib.Rectangle],
) -> Unit {
  let seq = @raylib.load_random_sequence(rect_count, 0, rect_count - 1)
  let rect_seq_width = Float::from_int(rect_count) * rect_width
  let start_x = (screen_width - rect_seq_width) * 0.5

  for x = 0; x < rect_count; x = x + 1 {
    // Remap: (value - inputStart) / (inputEnd - inputStart) * (outputEnd - outputStart) + outputStart
    let rect_height = Float::from_int(seq[x]) /
      Float::from_int(rect_count - 1) *
      screen_height
    colors.push(
      @raylib.Color::new(
        @raylib.get_random_value(0, 255),
        @raylib.get_random_value(0, 255),
        @raylib.get_random_value(0, 255),
        255,
      ),
    )
    rects.push(
      @raylib.Rectangle::new(
        start_x + Float::from_int(x) * rect_width,
        screen_height - rect_height,
        rect_width,
        rect_height,
      ),
    )
  }
}

///|
fn shuffle_sequence(
  colors : Array[@raylib.Color],
  rects : Array[@raylib.Rectangle],
  rect_count : Int,
) -> Unit {
  let seq = @raylib.load_random_sequence(rect_count, 0, rect_count - 1)
  for i = 0; i < rect_count; i = i + 1 {
    let j = seq[i]
    // Swap color, height, and y between i and j
    let tmp_c = colors[i]
    let tmp_h = rects[i].height
    let tmp_y = rects[i].y
    colors[i] = colors[j]
    rects[i] = @raylib.Rectangle::new(
      rects[i].x,
      rects[j].y,
      rects[i].width,
      rects[j].height,
    )
    colors[j] = tmp_c
    rects[j] = @raylib.Rectangle::new(rects[j].x, tmp_y, rects[j].width, tmp_h)
  }
}

///|
fn draw_text_center_key_help(
  key : String,
  text : String,
  pos_x : Int,
  pos_y : Int,
  font_size : Int,
  color : @raylib.Color,
) -> Unit {
  let space_size = @raylib.measure_text(" ", font_size)
  let press_size = @raylib.measure_text("Press", font_size)
  let key_size = @raylib.measure_text(key, font_size)
  let mut text_size_current = 0
  @raylib.draw_text("Press", pos_x, pos_y, font_size, color)
  text_size_current += press_size + 2 * space_size
  @raylib.draw_text(
    key,
    pos_x + text_size_current,
    pos_y,
    font_size,
    @raylib.red,
  )
  @raylib.draw_rectangle(
    pos_x + text_size_current,
    pos_y + font_size,
    key_size,
    3,
    @raylib.red,
  )
  text_size_current += key_size + 2 * space_size
  @raylib.draw_text(text, pos_x + text_size_current, pos_y, font_size, color)
}
