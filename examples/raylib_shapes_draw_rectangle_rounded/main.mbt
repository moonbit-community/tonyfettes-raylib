///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - draw rectangle rounded",
  )

  let mut roundness : Float = 0.2
  let mut width : Float = 200.0
  let mut height : Float = 100.0
  let mut segments : Float = 0.0
  let mut line_thick : Float = 1.0

  let mut draw_rect = false
  let mut draw_rounded_rect = true
  let mut draw_rounded_lines = false

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update - keyboard controls
    // Width: LEFT/RIGHT
    if @raylib.is_key_down(@raylib.KeyRight) {
      width = width + 2.0
      let max_w = Float::from_int(@raylib.get_screen_width()) - 300.0
      if width > max_w {
        width = max_w
      }
    }
    if @raylib.is_key_down(@raylib.KeyLeft) {
      width = width - 2.0
      if width < 0.0 {
        width = 0.0
      }
    }
    // Height: UP/DOWN
    if @raylib.is_key_down(@raylib.KeyUp) {
      height = height + 2.0
      let max_h = Float::from_int(@raylib.get_screen_height()) - 50.0
      if height > max_h {
        height = max_h
      }
    }
    if @raylib.is_key_down(@raylib.KeyDown) {
      height = height - 2.0
      if height < 0.0 {
        height = 0.0
      }
    }
    // Roundness: W/S
    if @raylib.is_key_down(@raylib.KeyW) {
      roundness = roundness + 0.01
      if roundness > 1.0 {
        roundness = 1.0
      }
    }
    if @raylib.is_key_down(@raylib.KeyS) {
      roundness = roundness - 0.01
      if roundness < 0.0 {
        roundness = 0.0
      }
    }
    // Segments: A/D
    if @raylib.is_key_down(@raylib.KeyD) {
      segments = segments + 1.0
      if segments > 60.0 {
        segments = 60.0
      }
    }
    if @raylib.is_key_down(@raylib.KeyA) {
      segments = segments - 1.0
      if segments < 0.0 {
        segments = 0.0
      }
    }
    // Line thickness: Q/E
    if @raylib.is_key_down(@raylib.KeyE) {
      line_thick = line_thick + 0.5
      if line_thick > 20.0 {
        line_thick = 20.0
      }
    }
    if @raylib.is_key_down(@raylib.KeyQ) {
      line_thick = line_thick - 0.5
      if line_thick < 0.0 {
        line_thick = 0.0
      }
    }
    // Toggle draw modes: 1/2/3
    if @raylib.is_key_pressed(@raylib.KeyOne) {
      draw_rounded_rect = not(draw_rounded_rect)
    }
    if @raylib.is_key_pressed(@raylib.KeyTwo) {
      draw_rounded_lines = not(draw_rounded_lines)
    }
    if @raylib.is_key_pressed(@raylib.KeyThree) {
      draw_rect = not(draw_rect)
    }

    let rec = @raylib.Rectangle::new(
      (Float::from_int(@raylib.get_screen_width()) - width - 250.0) / 2.0,
      (Float::from_int(@raylib.get_screen_height()) - height) / 2.0,
      width,
      height,
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_line(
      560,
      0,
      560,
      @raylib.get_screen_height(),
      @raylib.fade(@raylib.lightgray, 0.6),
    )
    @raylib.draw_rectangle(
      560,
      0,
      @raylib.get_screen_width() - 500,
      @raylib.get_screen_height(),
      @raylib.fade(@raylib.lightgray, 0.3),
    )

    if draw_rect {
      @raylib.draw_rectangle_rec(rec, @raylib.fade(@raylib.gold, 0.6))
    }
    if draw_rounded_rect {
      @raylib.draw_rectangle_rounded(
        rec,
        roundness,
        segments.to_int(),
        @raylib.fade(@raylib.maroon, 0.2),
      )
    }
    if draw_rounded_lines {
      @raylib.draw_rectangle_rounded_lines_ex(
        rec,
        roundness,
        segments.to_int(),
        line_thick,
        @raylib.fade(@raylib.maroon, 0.4),
      )
    }

    // Draw parameter text
    @raylib.draw_text("Width: \{width.to_int()}", 640, 40, 10, @raylib.darkgray)
    @raylib.draw_text("[LEFT/RIGHT]", 640, 55, 10, @raylib.gray)
    @raylib.draw_text(
      "Height: \{height.to_int()}",
      640,
      70,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("[UP/DOWN]", 640, 85, 10, @raylib.gray)
    @raylib.draw_text("Roundness: \{roundness}", 640, 110, 10, @raylib.darkgray)
    @raylib.draw_text("[W/S]", 640, 125, 10, @raylib.gray)
    @raylib.draw_text(
      "Thickness: \{line_thick}",
      640,
      150,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("[Q/E]", 640, 165, 10, @raylib.gray)
    @raylib.draw_text(
      "Segments: \{segments.to_int()}",
      640,
      190,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("[A/D]", 640, 205, 10, @raylib.gray)

    let mode = if segments >= 4.0 { "MANUAL" } else { "AUTO" }
    let color = if segments >= 4.0 { @raylib.maroon } else { @raylib.darkgray }
    @raylib.draw_text("MODE: \{mode}", 640, 240, 10, color)

    let rr_text = if draw_rounded_rect { "ON" } else { "OFF" }
    let rl_text = if draw_rounded_lines { "ON" } else { "OFF" }
    let r_text = if draw_rect { "ON" } else { "OFF" }
    @raylib.draw_text(
      "[1] DrawRoundedRect: \{rr_text}",
      640,
      320,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "[2] DrawRoundedLines: \{rl_text}",
      640,
      350,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("[3] DrawRect: \{r_text}", 640, 380, 10, @raylib.darkgray)

    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
