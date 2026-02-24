///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - custom frame control",
  )

  // Custom timing variables
  let mut previous_time = @raylib.get_time() // Previous time measure
  let mut current_time = 0.0 // Current time measure
  let mut update_draw_time = 0.0 // Update + Draw time
  let mut wait_time_val = 0.0 // Wait time (if target fps required)
  let mut delta_time : Float = 0.0 // Frame time (Update + Draw + Wait time)

  let mut time_counter : Float = 0.0 // Accumulative time counter (seconds)
  let mut position : Float = 0.0 // Circle position
  let mut pause = false // Pause control flag

  let mut target_fps = 60 // Our initial target fps

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    @raylib.poll_input_events() // Poll input events (SUPPORT_CUSTOM_FRAME_CONTROL)

    if @raylib.is_key_pressed(@raylib.KeySpace) {
      pause = not(pause)
    }

    if @raylib.is_key_pressed(@raylib.KeyUp) {
      target_fps += 20
    } else if @raylib.is_key_pressed(@raylib.KeyDown) {
      target_fps -= 20
    }

    if target_fps < 0 {
      target_fps = 0
    }

    if not(pause) {
      position += 200.0 * delta_time // We move at 200 pixels per second
      if position >= Float::from_int(@raylib.get_screen_width()) {
        position = 0.0
      }
      time_counter += delta_time // We count time (seconds)
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    for i = 0; i < @raylib.get_screen_width() / 200; i = i + 1 {
      @raylib.draw_rectangle(
        200 * i,
        0,
        1,
        @raylib.get_screen_height(),
        @raylib.skyblue,
      )
    }

    @raylib.draw_circle(
      position.to_int(),
      @raylib.get_screen_height() / 2 - 25,
      50.0,
      @raylib.red,
    )

    let ms = (time_counter * 1000.0).to_int()
    @raylib.draw_text(
      "\{ms} ms",
      position.to_int() - 40,
      @raylib.get_screen_height() / 2 - 100,
      20,
      @raylib.maroon,
    )
    @raylib.draw_text(
      "PosX: \{position.to_int()}",
      position.to_int() - 50,
      @raylib.get_screen_height() / 2 + 40,
      20,
      @raylib.black,
    )

    @raylib.draw_text(
      "Circle is moving at a constant 200 pixels/sec,\nindependently of the frame rate.",
      10, 10, 20, @raylib.darkgray,
    )
    @raylib.draw_text(
      "PRESS SPACE to PAUSE MOVEMENT",
      10,
      @raylib.get_screen_height() - 60,
      20,
      @raylib.gray,
    )
    @raylib.draw_text(
      "PRESS UP | DOWN to CHANGE TARGET FPS",
      10,
      @raylib.get_screen_height() - 30,
      20,
      @raylib.gray,
    )
    @raylib.draw_text(
      "TARGET FPS: \{target_fps}",
      @raylib.get_screen_width() - 220,
      10,
      20,
      @raylib.lime,
    )
    let current_fps = if delta_time > 0.0 {
      ((1.0 : Float) / delta_time).to_int()
    } else {
      0
    }
    @raylib.draw_text(
      "CURRENT FPS: \{current_fps}",
      @raylib.get_screen_width() - 220,
      40,
      20,
      @raylib.green,
    )

    @raylib.end_drawing()

    // NOTE: In case raylib is configured to SUPPORT_CUSTOM_FRAME_CONTROL,
    // Events polling, screen buffer swap and frame time control must be managed by the user

    @raylib.swap_screen_buffer() // Flip the back buffer to screen (front buffer)

    current_time = @raylib.get_time()
    update_draw_time = current_time - previous_time

    if target_fps > 0 {
      // We want a fixed frame rate
      wait_time_val = 1.0 / Double::from_int(target_fps) - update_draw_time
      if wait_time_val > 0.0 {
        @raylib.wait_time(wait_time_val)
        current_time = @raylib.get_time()
        delta_time = Float::from_double(current_time - previous_time)
      }
    } else {
      delta_time = Float::from_double(update_draw_time) // Framerate could be variable
    }

    previous_time = current_time
  }

  // De-Initialization
  @raylib.close_window()
}
