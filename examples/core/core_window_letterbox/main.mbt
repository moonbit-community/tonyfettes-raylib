///|
fn min_f(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn main {
  // Initialization
  let window_width = 800
  let window_height = 450

  // Enable config flags for resizable window and vertical synchro
  @raylib.set_config_flags(@raylib.FlagWindowResizable | @raylib.FlagVsyncHint)
  @raylib.init_window(
    window_width, window_height, "raylib [core] example - window scale letterbox",
  )
  @raylib.set_window_min_size(320, 240)

  let game_screen_width = 640
  let game_screen_height = 480

  // Render texture initialization, used to hold the rendering result so we can easily resize it
  let target = @raylib.load_render_texture(
    game_screen_width, game_screen_height,
  )
  @raylib.set_render_texture_filter(target, @raylib.TextureFilterBilinear)

  let colors : Array[@raylib.Color] = Array::make(10, @raylib.black)
  for i in 0..<10 {
    colors[i] = @raylib.Color::new(
      @raylib.get_random_value(100, 250),
      @raylib.get_random_value(50, 150),
      @raylib.get_random_value(10, 100),
      255,
    )
  }

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // Compute required framebuffer scaling
    let scale = min_f(
      Float::from_int(@raylib.get_screen_width()) /
      Float::from_int(game_screen_width),
      Float::from_int(@raylib.get_screen_height()) /
      Float::from_int(game_screen_height),
    )

    if @raylib.is_key_pressed(@raylib.KeySpace) {
      // Recalculate random colors for the bars
      for i in 0..<10 {
        colors[i] = @raylib.Color::new(
          @raylib.get_random_value(100, 250),
          @raylib.get_random_value(50, 150),
          @raylib.get_random_value(10, 100),
          255,
        )
      }
    }

    // Update virtual mouse (clamped mouse value behind game screen)
    let mouse = @raylib.get_mouse_position()
    let virtual_mouse_x = (
        mouse.x -
        (
          Float::from_int(@raylib.get_screen_width()) -
          Float::from_int(game_screen_width) * scale
        ) *
        0.5
      ) /
      scale
    let virtual_mouse_y = (
        mouse.y -
        (
          Float::from_int(@raylib.get_screen_height()) -
          Float::from_int(game_screen_height) * scale
        ) *
        0.5
      ) /
      scale
    let virtual_mouse = @raylib.Vector2::clamp(
      @raylib.Vector2::new(virtual_mouse_x, virtual_mouse_y),
      @raylib.Vector2::new(0.0, 0.0),
      @raylib.Vector2::new(
        Float::from_int(game_screen_width),
        Float::from_int(game_screen_height),
      ),
    )

    // Draw
    // Draw everything in the render texture, note this will not be rendered on screen, yet
    @raylib.begin_texture_mode(target)
    @raylib.clear_background(@raylib.raywhite)
    for i in 0..<10 {
      @raylib.draw_rectangle(
        0,
        game_screen_height / 10 * i,
        game_screen_width,
        game_screen_height / 10,
        colors[i],
      )
    }
    @raylib.draw_text(
      "If executed inside a window,\nyou can resize the window,\nand see the screen scaling!",
      10, 25, 20, @raylib.white,
    )
    @raylib.draw_text(
      "Default Mouse: [\{mouse.x.to_int()} , \{mouse.y.to_int()}]",
      350,
      25,
      20,
      @raylib.green,
    )
    @raylib.draw_text(
      "Virtual Mouse: [\{virtual_mouse.x.to_int()} , \{virtual_mouse.y.to_int()}]",
      350,
      55,
      20,
      @raylib.yellow,
    )
    @raylib.end_texture_mode()

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.black)
    // Draw render texture to screen, properly scaled
    @raylib.draw_render_texture_pro(
      target,
      @raylib.Rectangle::new(
        0.0,
        0.0,
        Float::from_int(game_screen_width),
        -Float::from_int(game_screen_height),
      ),
      @raylib.Rectangle::new(
        (
          Float::from_int(@raylib.get_screen_width()) -
          Float::from_int(game_screen_width) * scale
        ) *
        0.5,
        (
          Float::from_int(@raylib.get_screen_height()) -
          Float::from_int(game_screen_height) * scale
        ) *
        0.5,
        Float::from_int(game_screen_width) * scale,
        Float::from_int(game_screen_height) * scale,
      ),
      @raylib.Vector2::new(0.0, 0.0),
      0.0,
      @raylib.white,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_render_texture(target)
  @raylib.close_window()
}
