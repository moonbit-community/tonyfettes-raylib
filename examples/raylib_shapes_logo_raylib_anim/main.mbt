///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - raylib logo animation",
  )

  let logo_position_x = screen_width / 2 - 128
  let logo_position_y = screen_height / 2 - 128

  let mut frames_counter = 0
  let mut letters_count = 0

  let mut top_side_rec_width = 16
  let mut left_side_rec_height = 16

  let mut bottom_side_rec_width = 16
  let mut right_side_rec_height = 16

  let mut state = 0 // Tracking animation states (State Machine)
  let mut alpha : Float = 1.0 // Useful for fading

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if state == 0 {
      // State 0: Small box blinking
      frames_counter = frames_counter + 1
      if frames_counter == 120 {
        state = 1
        frames_counter = 0
      }
    } else if state == 1 {
      // State 1: Top and left bars growing
      top_side_rec_width = top_side_rec_width + 4
      left_side_rec_height = left_side_rec_height + 4
      if top_side_rec_width == 256 {
        state = 2
      }
    } else if state == 2 {
      // State 2: Bottom and right bars growing
      bottom_side_rec_width = bottom_side_rec_width + 4
      right_side_rec_height = right_side_rec_height + 4
      if bottom_side_rec_width == 256 {
        state = 3
      }
    } else if state == 3 {
      // State 3: Letters appearing (one by one)
      frames_counter = frames_counter + 1
      if frames_counter / 12 != 0 {
        // Every 12 frames, one more letter!
        letters_count = letters_count + 1
        frames_counter = 0
      }
      if letters_count >= 10 {
        // When all letters have appeared, just fade out everything
        alpha = alpha - 0.02
        if alpha <= 0.0 {
          alpha = 0.0
          state = 4
        }
      }
    } else if state == 4 {
      // State 4: Reset and Replay
      if @raylib.is_key_pressed(@raylib.KeyR) {
        frames_counter = 0
        letters_count = 0
        top_side_rec_width = 16
        left_side_rec_height = 16
        bottom_side_rec_width = 16
        right_side_rec_height = 16
        alpha = 1.0
        state = 0
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    if state == 0 {
      if frames_counter / 15 % 2 != 0 {
        @raylib.draw_rectangle(
          logo_position_x, logo_position_y, 16, 16, @raylib.black,
        )
      }
    } else if state == 1 {
      @raylib.draw_rectangle(
        logo_position_x, logo_position_y, top_side_rec_width, 16, @raylib.black,
      )
      @raylib.draw_rectangle(
        logo_position_x, logo_position_y, 16, left_side_rec_height, @raylib.black,
      )
    } else if state == 2 {
      @raylib.draw_rectangle(
        logo_position_x, logo_position_y, top_side_rec_width, 16, @raylib.black,
      )
      @raylib.draw_rectangle(
        logo_position_x, logo_position_y, 16, left_side_rec_height, @raylib.black,
      )
      @raylib.draw_rectangle(
        logo_position_x + 240,
        logo_position_y,
        16,
        right_side_rec_height,
        @raylib.black,
      )
      @raylib.draw_rectangle(
        logo_position_x,
        logo_position_y + 240,
        bottom_side_rec_width,
        16,
        @raylib.black,
      )
    } else if state == 3 {
      @raylib.draw_rectangle(
        logo_position_x,
        logo_position_y,
        top_side_rec_width,
        16,
        @raylib.fade(@raylib.black, alpha),
      )
      @raylib.draw_rectangle(
        logo_position_x,
        logo_position_y + 16,
        16,
        left_side_rec_height - 32,
        @raylib.fade(@raylib.black, alpha),
      )
      @raylib.draw_rectangle(
        logo_position_x + 240,
        logo_position_y + 16,
        16,
        right_side_rec_height - 32,
        @raylib.fade(@raylib.black, alpha),
      )
      @raylib.draw_rectangle(
        logo_position_x,
        logo_position_y + 240,
        bottom_side_rec_width,
        16,
        @raylib.fade(@raylib.black, alpha),
      )
      @raylib.draw_rectangle(
        @raylib.get_screen_width() / 2 - 112,
        @raylib.get_screen_height() / 2 - 112,
        224,
        224,
        @raylib.fade(@raylib.raywhite, alpha),
      )

      // TextSubtext equivalent: take first letters_count characters of "raylib"
      let sub_text = match letters_count {
        0 => ""
        1 => "r"
        2 => "ra"
        3 => "ray"
        4 => "rayl"
        5 => "rayli"
        _ => "raylib"
      }
      @raylib.draw_text(
        sub_text,
        @raylib.get_screen_width() / 2 - 44,
        @raylib.get_screen_height() / 2 + 48,
        50,
        @raylib.fade(@raylib.black, alpha),
      )
    } else if state == 4 {
      @raylib.draw_text("[R] REPLAY", 340, 200, 20, @raylib.gray)
    }

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
