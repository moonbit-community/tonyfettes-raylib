///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - draw ring",
  )

  let center = @raylib.Vector2::new(
    Float::from_int(@raylib.get_screen_width() - 300) / 2.0,
    Float::from_int(@raylib.get_screen_height()) / 2.0,
  )

  let mut inner_radius : Float = 80.0
  let mut outer_radius : Float = 190.0

  let mut start_angle : Float = 0.0
  let mut end_angle : Float = 360.0
  let mut segments : Float = 0.0

  let mut draw_ring = true
  let mut draw_ring_lines = false
  let mut draw_circle_lines = false

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update - keyboard controls
    // Start angle: LEFT/RIGHT
    if @raylib.is_key_down(@raylib.KeyRight) {
      start_angle = start_angle + 2.0
      if start_angle > 450.0 {
        start_angle = 450.0
      }
    }
    if @raylib.is_key_down(@raylib.KeyLeft) {
      start_angle = start_angle - 2.0
      if start_angle < -450.0 {
        start_angle = -450.0
      }
    }
    // End angle: UP/DOWN
    if @raylib.is_key_down(@raylib.KeyUp) {
      end_angle = end_angle + 2.0
      if end_angle > 450.0 {
        end_angle = 450.0
      }
    }
    if @raylib.is_key_down(@raylib.KeyDown) {
      end_angle = end_angle - 2.0
      if end_angle < -450.0 {
        end_angle = -450.0
      }
    }
    // Inner radius: W/S
    if @raylib.is_key_down(@raylib.KeyW) {
      inner_radius = inner_radius + 1.0
      if inner_radius > 100.0 {
        inner_radius = 100.0
      }
    }
    if @raylib.is_key_down(@raylib.KeyS) {
      inner_radius = inner_radius - 1.0
      if inner_radius < 0.0 {
        inner_radius = 0.0
      }
    }
    // Outer radius: A/D
    if @raylib.is_key_down(@raylib.KeyD) {
      outer_radius = outer_radius + 1.0
      if outer_radius > 200.0 {
        outer_radius = 200.0
      }
    }
    if @raylib.is_key_down(@raylib.KeyA) {
      outer_radius = outer_radius - 1.0
      if outer_radius < 0.0 {
        outer_radius = 0.0
      }
    }
    // Segments: Q/E
    if @raylib.is_key_down(@raylib.KeyE) {
      segments = segments + 1.0
      if segments > 100.0 {
        segments = 100.0
      }
    }
    if @raylib.is_key_down(@raylib.KeyQ) {
      segments = segments - 1.0
      if segments < 0.0 {
        segments = 0.0
      }
    }
    // Toggle draw modes: 1/2/3
    if @raylib.is_key_pressed(@raylib.KeyOne) {
      draw_ring = not(draw_ring)
    }
    if @raylib.is_key_pressed(@raylib.KeyTwo) {
      draw_ring_lines = not(draw_ring_lines)
    }
    if @raylib.is_key_pressed(@raylib.KeyThree) {
      draw_circle_lines = not(draw_circle_lines)
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_line(
      500,
      0,
      500,
      @raylib.get_screen_height(),
      @raylib.fade(@raylib.lightgray, 0.6),
    )
    @raylib.draw_rectangle(
      500,
      0,
      @raylib.get_screen_width() - 500,
      @raylib.get_screen_height(),
      @raylib.fade(@raylib.lightgray, 0.3),
    )

    if draw_ring {
      @raylib.draw_ring(
        center,
        inner_radius,
        outer_radius,
        start_angle,
        end_angle,
        segments.to_int(),
        @raylib.fade(@raylib.maroon, 0.3),
      )
    }
    if draw_ring_lines {
      @raylib.draw_ring_lines(
        center,
        inner_radius,
        outer_radius,
        start_angle,
        end_angle,
        segments.to_int(),
        @raylib.fade(@raylib.black, 0.4),
      )
    }
    if draw_circle_lines {
      @raylib.draw_circle_sector_lines(
        center,
        outer_radius,
        start_angle,
        end_angle,
        segments.to_int(),
        @raylib.fade(@raylib.black, 0.4),
      )
    }

    // Draw parameter text
    @raylib.draw_text(
      "StartAngle: \{start_angle.to_int()}",
      600,
      40,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("[LEFT/RIGHT]", 600, 55, 10, @raylib.gray)
    @raylib.draw_text(
      "EndAngle: \{end_angle.to_int()}",
      600,
      70,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("[UP/DOWN]", 600, 85, 10, @raylib.gray)
    @raylib.draw_text(
      "InnerRadius: \{inner_radius.to_int()}",
      600,
      120,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("[W/S]", 600, 135, 10, @raylib.gray)
    @raylib.draw_text(
      "OuterRadius: \{outer_radius.to_int()}",
      600,
      150,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("[A/D]", 600, 165, 10, @raylib.gray)
    @raylib.draw_text(
      "Segments: \{segments.to_int()}",
      600,
      200,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("[Q/E]", 600, 215, 10, @raylib.gray)

    let diff = end_angle - start_angle
    let min_segments_val = diff / 90.0
    let min_segments_int = min_segments_val.to_int()
    let min_segments = if Float::from_int(min_segments_int) < min_segments_val {
      min_segments_int + 1
    } else {
      min_segments_int
    }
    let mode = if segments.to_int() >= min_segments { "MANUAL" } else { "AUTO" }
    let color = if segments.to_int() >= min_segments {
      @raylib.maroon
    } else {
      @raylib.darkgray
    }
    @raylib.draw_text("MODE: \{mode}", 600, 240, 10, color)

    let ring_text = if draw_ring { "ON" } else { "OFF" }
    let ring_lines_text = if draw_ring_lines { "ON" } else { "OFF" }
    let circle_lines_text = if draw_circle_lines { "ON" } else { "OFF" }
    @raylib.draw_text(
      "[1] Draw Ring: \{ring_text}",
      600,
      320,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "[2] Draw RingLines: \{ring_lines_text}",
      600,
      350,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "[3] Draw CircleLines: \{circle_lines_text}",
      600,
      380,
      10,
      @raylib.darkgray,
    )

    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
