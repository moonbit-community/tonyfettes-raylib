///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_textures_srcrec_dstrec")
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] examples - texture source and destination rectangles",
  )

  // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
  let scarfy = @raylib.load_texture("resources/scarfy.png")

  // scarfy.png: 768x128, 6 frames
  let frame_width = 768 / 6
  let frame_height = 128

  // Source rectangle (part of the texture to use for drawing)
  let source_rec = @raylib.Rectangle::new(
    0.0,
    0.0,
    Float::from_int(frame_width),
    Float::from_int(frame_height),
  )

  // Destination rectangle (screen rectangle where drawing part of texture)
  let dest_rec = @raylib.Rectangle::new(
    Float::from_int(screen_width) / 2.0,
    Float::from_int(screen_height) / 2.0,
    Float::from_int(frame_width) * 2.0,
    Float::from_int(frame_height) * 2.0,
  )

  // Origin of the texture (rotation/scale point), relative to destination rectangle size
  let origin = @raylib.Vector2::new(
    Float::from_int(frame_width),
    Float::from_int(frame_height),
  )

  let mut rotation = 0
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    rotation += 1

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // NOTE: Using draw_texture_pro() we can easily rotate and scale the part of the texture we draw
    // source_rec defines the part of the texture we use for drawing
    // dest_rec defines the rectangle where our texture part will fit (scaling it to fit)
    // origin defines the point of the texture used as reference for rotation and scaling
    // rotation defines the texture rotation (using origin as rotation point)
    @raylib.draw_texture_pro(
      scarfy,
      source_rec,
      dest_rec,
      origin,
      Float::from_int(rotation),
      @raylib.white,
    )
    @raylib.draw_line(
      dest_rec.x.to_int(),
      0,
      dest_rec.x.to_int(),
      screen_height,
      @raylib.gray,
    )
    @raylib.draw_line(
      0,
      dest_rec.y.to_int(),
      screen_width,
      dest_rec.y.to_int(),
      @raylib.gray,
    )
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
