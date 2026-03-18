///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - draw circle sector",
  )

  let center = @raylib.Vector2::new(
    Float::from_int(@raylib.get_screen_width() - 300) / 2.0,
    Float::from_int(@raylib.get_screen_height()) / 2.0,
  )

  let mut outer_radius : Float = 180.0
  let mut start_angle : Float = 0.0
  let mut end_angle : Float = 180.0
  let mut segments : Float = 10.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update - use keyboard to adjust parameters
    // Start angle: LEFT/RIGHT arrows
    if @raylib.is_key_down(@raylib.KeyRight) {
      start_angle = start_angle + 2.0
      if start_angle > 720.0 {
        start_angle = 720.0
      }
    }
    if @raylib.is_key_down(@raylib.KeyLeft) {
      start_angle = start_angle - 2.0
      if start_angle < 0.0 {
        start_angle = 0.0
      }
    }
    // End angle: UP/DOWN arrows
    if @raylib.is_key_down(@raylib.KeyUp) {
      end_angle = end_angle + 2.0
      if end_angle > 720.0 {
        end_angle = 720.0
      }
    }
    if @raylib.is_key_down(@raylib.KeyDown) {
      end_angle = end_angle - 2.0
      if end_angle < 0.0 {
        end_angle = 0.0
      }
    }
    // Radius: W/S keys
    if @raylib.is_key_down(@raylib.KeyW) {
      outer_radius = outer_radius + 1.0
      if outer_radius > 200.0 {
        outer_radius = 200.0
      }
    }
    if @raylib.is_key_down(@raylib.KeyS) {
      outer_radius = outer_radius - 1.0
      if outer_radius < 0.0 {
        outer_radius = 0.0
      }
    }
    // Segments: A/D keys
    if @raylib.is_key_down(@raylib.KeyD) {
      segments = segments + 1.0
      if segments > 100.0 {
        segments = 100.0
      }
    }
    if @raylib.is_key_down(@raylib.KeyA) {
      segments = segments - 1.0
      if segments < 0.0 {
        segments = 0.0
      }
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

    @raylib.draw_circle_sector(
      center,
      outer_radius,
      start_angle,
      end_angle,
      segments.to_int(),
      @raylib.fade(@raylib.maroon, 0.3),
    )
    @raylib.draw_circle_sector_lines(
      center,
      outer_radius,
      start_angle,
      end_angle,
      segments.to_int(),
      @raylib.fade(@raylib.maroon, 0.6),
    )

    // Draw GUI-like text controls
    @raylib.draw_text(
      "StartAngle: \{start_angle.to_int()}",
      600,
      40,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("[LEFT/RIGHT] to adjust", 600, 55, 10, @raylib.gray)
    @raylib.draw_text(
      "EndAngle: \{end_angle.to_int()}",
      600,
      80,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("[UP/DOWN] to adjust", 600, 95, 10, @raylib.gray)
    @raylib.draw_text(
      "Radius: \{outer_radius.to_int()}",
      600,
      130,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("[W/S] to adjust", 600, 145, 10, @raylib.gray)
    @raylib.draw_text(
      "Segments: \{segments.to_int()}",
      600,
      170,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("[A/D] to adjust", 600, 185, 10, @raylib.gray)

    let diff = end_angle - start_angle
    let min_segments = if diff > 0.0 {
      let v = diff / 90.0
      // ceiling
      let vi = v.to_int()
      let ceil = if Float::from_int(vi) < v { vi + 1 } else { vi }
      Float::from_int(ceil)
    } else {
      4.0
    }
    let mode = if segments >= min_segments { "MANUAL" } else { "AUTO" }
    let color = if segments >= min_segments {
      @raylib.maroon
    } else {
      @raylib.darkgray
    }
    @raylib.draw_text("MODE: \{mode}", 600, 210, 10, color)

    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
