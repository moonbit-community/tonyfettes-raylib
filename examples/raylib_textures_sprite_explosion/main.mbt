///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let num_frames_per_line = 5
  let num_lines = 5
  let _ = @raylib.change_directory("examples/raylib_textures_sprite_explosion")
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - sprite explosion",
  )

  @raylib.init_audio_device()

  // Load explosion sound
  let fx_boom = @raylib.load_sound("resources/boom.wav")

  // Load explosion texture
  let explosion = @raylib.load_texture("resources/explosion.png")

  // explosion.png: 1024x1024, 5x5 grid
  let explosion_width = 1024
  let explosion_height = 1024

  // Init variables for animation
  let frame_width = Float::from_int(explosion_width / num_frames_per_line)
  let frame_height = Float::from_int(explosion_height / num_lines)
  let mut current_frame = 0
  let mut current_line = 0

  let mut position = @raylib.Vector2::new(0.0, 0.0)

  let mut active = false
  let mut frames_counter = 0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update

    // Check for mouse button pressed and activate explosion (if not active)
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) && not(active) {
      position = @raylib.get_mouse_position()
      active = true
      position = @raylib.Vector2::new(
        position.x - frame_width / 2.0,
        position.y - frame_height / 2.0,
      )
      @raylib.play_sound(fx_boom)
    }

    // Compute explosion animation frames
    if active {
      frames_counter += 1
      if frames_counter > 2 {
        current_frame += 1
        if current_frame >= num_frames_per_line {
          current_frame = 0
          current_line += 1
          if current_line >= num_lines {
            current_line = 0
            active = false
          }
        }
        frames_counter = 0
      }
    }

    let frame_rec = @raylib.Rectangle::new(
      frame_width * Float::from_int(current_frame),
      frame_height * Float::from_int(current_line),
      frame_width,
      frame_height,
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw explosion required frame rectangle
    if active {
      @raylib.draw_texture_rec(explosion, frame_rec, position, @raylib.white)
    }

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(explosion)
  @raylib.unload_sound(fx_boom)
  @raylib.close_audio_device()
  @raylib.close_window()
}
