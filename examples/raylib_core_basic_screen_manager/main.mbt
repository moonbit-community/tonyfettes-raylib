///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - basic screen manager",
  )

  // Game screen enum represented as Int: 0=LOGO, 1=TITLE, 2=GAMEPLAY, 3=ENDING
  let mut current_screen = 0
  let mut frames_counter = 0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    match current_screen {
      0 => {
        // LOGO
        frames_counter += 1
        // Wait for 2 seconds (120 frames) before jumping to TITLE screen
        if frames_counter > 120 {
          current_screen = 1
        }
      }
      1 =>
        // TITLE
        if @raylib.is_key_pressed(@raylib.KeyEnter) ||
          @raylib.is_gesture_detected(@raylib.GestureTap) {
          current_screen = 2
        }
      2 =>
        // GAMEPLAY
        if @raylib.is_key_pressed(@raylib.KeyEnter) ||
          @raylib.is_gesture_detected(@raylib.GestureTap) {
          current_screen = 3
        }
      3 =>
        // ENDING
        if @raylib.is_key_pressed(@raylib.KeyEnter) ||
          @raylib.is_gesture_detected(@raylib.GestureTap) {
          current_screen = 1
        }
      _ => ()
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    match current_screen {
      0 => {
        // LOGO
        @raylib.draw_text("LOGO SCREEN", 20, 20, 40, @raylib.lightgray)
        @raylib.draw_text("WAIT for 2 SECONDS...", 290, 220, 20, @raylib.gray)
      }
      1 => {
        // TITLE
        @raylib.draw_rectangle(0, 0, screen_width, screen_height, @raylib.green)
        @raylib.draw_text("TITLE SCREEN", 20, 20, 40, @raylib.darkgreen)
        @raylib.draw_text(
          "PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN", 120, 220, 20, @raylib.darkgreen,
        )
      }
      2 => {
        // GAMEPLAY
        @raylib.draw_rectangle(
          0, 0, screen_width, screen_height, @raylib.purple,
        )
        @raylib.draw_text("GAMEPLAY SCREEN", 20, 20, 40, @raylib.maroon)
        @raylib.draw_text(
          "PRESS ENTER or TAP to JUMP to ENDING SCREEN", 130, 220, 20, @raylib.maroon,
        )
      }
      3 => {
        // ENDING
        @raylib.draw_rectangle(0, 0, screen_width, screen_height, @raylib.blue)
        @raylib.draw_text("ENDING SCREEN", 20, 20, 40, @raylib.darkblue)
        @raylib.draw_text(
          "PRESS ENTER or TAP to RETURN to TITLE SCREEN", 120, 220, 20, @raylib.darkblue,
        )
      }
      _ => ()
    }
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
