///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let max_frame_speed = 15
  let min_frame_speed = 1
  let _ = @raylib.change_directory("examples/raylib_textures_sprite_anim")
  @raylib.init_window(
    screen_width, screen_height, "raylib [texture] example - sprite anim",
  )

  // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
  let scarfy = @raylib.load_texture("resources/scarfy.png")

  // scarfy.png: 768x128, 6 frames of 128x128
  let scarfy_width = 768
  let scarfy_height = 128
  let frame_width = scarfy_width / 6

  let position = @raylib.Vector2::new(350.0, 280.0)
  let mut frame_rec_x : Float = 0.0
  let frame_rec_y : Float = 0.0
  let frame_rec_width : Float = Float::from_int(frame_width)
  let frame_rec_height : Float = Float::from_int(scarfy_height)
  let mut current_frame = 0
  let mut frames_counter = 0
  let mut frames_speed = 8 // Number of spritesheet frames shown by second
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    frames_counter += 1
    if frames_counter >= 60 / frames_speed {
      frames_counter = 0
      current_frame += 1
      if current_frame > 5 {
        current_frame = 0
      }
      frame_rec_x = Float::from_int(current_frame) *
        Float::from_int(scarfy_width) /
        6.0
    }

    // Control frames speed
    if @raylib.is_key_pressed(@raylib.KeyRight) {
      frames_speed += 1
    } else if @raylib.is_key_pressed(@raylib.KeyLeft) {
      frames_speed -= 1
    }
    if frames_speed > max_frame_speed {
      frames_speed = max_frame_speed
    } else if frames_speed < min_frame_speed {
      frames_speed = min_frame_speed
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_texture(scarfy, 15, 40, @raylib.white)
    @raylib.draw_rectangle_lines(
      15, 40, scarfy_width, scarfy_height, @raylib.lime,
    )
    @raylib.draw_rectangle_lines(
      15 + frame_rec_x.to_int(),
      40 + frame_rec_y.to_int(),
      frame_rec_width.to_int(),
      frame_rec_height.to_int(),
      @raylib.red,
    )
    @raylib.draw_text("FRAME SPEED: ", 165, 210, 10, @raylib.darkgray)
    @raylib.draw_text("\{frames_speed} FPS", 575, 210, 10, @raylib.darkgray)
    @raylib.draw_text(
      "PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 240, 10, @raylib.darkgray,
    )
    for i in 0..<max_frame_speed {
      if i < frames_speed {
        @raylib.draw_rectangle(250 + 21 * i, 205, 20, 20, @raylib.red)
      }
      @raylib.draw_rectangle_lines(250 + 21 * i, 205, 20, 20, @raylib.maroon)
    }
    let frame_rec = @raylib.Rectangle::new(
      frame_rec_x, frame_rec_y, frame_rec_width, frame_rec_height,
    )
    @raylib.draw_texture_rec(scarfy, frame_rec, position, @raylib.white)
    @raylib.draw_text(
      "(c) Scarfy sprite by Eiden Marsal",
      screen_width - 200,
      screen_height - 20,
      10,
      @raylib.gray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(scarfy)
  @raylib.close_window()
}
