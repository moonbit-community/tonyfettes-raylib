///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let num_frames = 3
  let _ = @raylib.change_directory("examples/raylib_textures_sprite_button")
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - sprite button",
  )

  @raylib.init_audio_device()

  let fx_button = @raylib.load_sound("resources/buttonfx.wav")
  let button = @raylib.load_texture("resources/button.png")

  // button.png: 224x318, 3 frames vertically
  let button_width = 224
  let button_height = 318

  // Define frame rectangle for drawing
  let frame_height = Float::from_int(button_height / num_frames)

  // Define button bounds on screen
  let btn_bounds_x = Float::from_int(screen_width) / 2.0 -
    Float::from_int(button_width) / 2.0
  let btn_bounds_y = Float::from_int(screen_height) / 2.0 - frame_height / 2.0
  let btn_bounds_w = Float::from_int(button_width)
  let btn_bounds_h = frame_height

  let mut btn_state = 0 // 0-NORMAL, 1-MOUSE_HOVER, 2-PRESSED
  let mut btn_action = false

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let mouse_point = @raylib.get_mouse_position()
    btn_action = false

    let btn_bounds = @raylib.Rectangle::new(
      btn_bounds_x, btn_bounds_y, btn_bounds_w, btn_bounds_h,
    )

    // Check button state
    if @raylib.check_collision_point_rec(mouse_point, btn_bounds) {
      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        btn_state = 2
      } else {
        btn_state = 1
      }
      if @raylib.is_mouse_button_released(@raylib.MouseButtonLeft) {
        btn_action = true
      }
    } else {
      btn_state = 0
    }

    if btn_action {
      @raylib.play_sound(fx_button)
    }

    // Calculate button frame rectangle to draw depending on button state
    let source_rec = @raylib.Rectangle::new(
      0.0,
      Float::from_int(btn_state) * frame_height,
      Float::from_int(button_width),
      frame_height,
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_texture_rec(
      button,
      source_rec,
      @raylib.Vector2::new(btn_bounds_x, btn_bounds_y),
      @raylib.white,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(button)
  @raylib.unload_sound(fx_button)
  @raylib.close_audio_device()
  @raylib.close_window()
}
