///|
fn truncf(x : Float) -> Float {
  Float::from_int(x.to_int())
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let virtual_screen_width = 160
  let virtual_screen_height = 90

  let virtual_ratio = Float::from_int(screen_width) /
    Float::from_int(virtual_screen_width)

  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - smooth pixel-perfect camera",
  )

  let mut world_space_camera = @raylib.Camera2D::new(
    @raylib.Vector2::new(0.0, 0.0), // offset
    @raylib.Vector2::new(0.0, 0.0), // target
    0.0, // rotation
    1.0, // zoom
  )

  let mut screen_space_camera = @raylib.Camera2D::new(
    @raylib.Vector2::new(0.0, 0.0), // offset
    @raylib.Vector2::new(0.0, 0.0), // target
    0.0, // rotation
    1.0, // zoom
  )

  let target = @raylib.load_render_texture(
    virtual_screen_width, virtual_screen_height,
  )

  let rec01 = @raylib.Rectangle::new(70.0, 35.0, 20.0, 20.0)
  let rec02 = @raylib.Rectangle::new(90.0, 55.0, 30.0, 10.0)
  let rec03 = @raylib.Rectangle::new(80.0, 65.0, 15.0, 25.0)

  // The target's height is flipped (in the source Rectangle), due to OpenGL reasons
  let source_rec = @raylib.Rectangle::new(
    0.0,
    0.0,
    Float::from_int(virtual_screen_width),
    -Float::from_int(virtual_screen_height),
  )
  let dest_rec = @raylib.Rectangle::new(
    -virtual_ratio,
    -virtual_ratio,
    Float::from_int(screen_width) + virtual_ratio * 2.0,
    Float::from_int(screen_height) + virtual_ratio * 2.0,
  )

  let origin = @raylib.Vector2::new(0.0, 0.0)

  let mut rotation : Float = 0.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    rotation = rotation + (60.0 : Float) * @raylib.get_frame_time()

    // Make the camera move to demonstrate the effect
    let time_f = Float::from_double(@raylib.get_time())
    let camera_x = @math.sinf(time_f) * (50.0 : Float) - (10.0 : Float)
    let camera_y = @math.cosf(time_f) * (30.0 : Float)

    // Set the camera's target to the values computed above
    screen_space_camera = @raylib.Camera2D::new(
      screen_space_camera.offset,
      @raylib.Vector2::new(camera_x, camera_y),
      screen_space_camera.rotation,
      screen_space_camera.zoom,
    )

    // Round worldSpace coordinates, keep decimals into screenSpace coordinates
    let world_target_x = truncf(screen_space_camera.target.x)
    let screen_target_x = (screen_space_camera.target.x - world_target_x) *
      virtual_ratio

    let world_target_y = truncf(screen_space_camera.target.y)
    let screen_target_y = (screen_space_camera.target.y - world_target_y) *
      virtual_ratio

    world_space_camera = @raylib.Camera2D::new(
      world_space_camera.offset,
      @raylib.Vector2::new(world_target_x, world_target_y),
      world_space_camera.rotation,
      world_space_camera.zoom,
    )

    screen_space_camera = @raylib.Camera2D::new(
      screen_space_camera.offset,
      @raylib.Vector2::new(screen_target_x, screen_target_y),
      screen_space_camera.rotation,
      screen_space_camera.zoom,
    )

    // Draw
    @raylib.begin_texture_mode(target)
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_2d(world_space_camera)
    @raylib.draw_rectangle_pro(rec01, origin, rotation, @raylib.black)
    @raylib.draw_rectangle_pro(rec02, origin, -rotation, @raylib.red)
    @raylib.draw_rectangle_pro(rec03, origin, rotation + 45.0, @raylib.blue)
    @raylib.end_mode_2d()
    @raylib.end_texture_mode()

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.red)
    @raylib.begin_mode_2d(screen_space_camera)
    @raylib.draw_render_texture_pro(
      target, source_rec, dest_rec, origin, 0.0, @raylib.white,
    )
    @raylib.end_mode_2d()
    @raylib.draw_text(
      "Screen resolution: \{screen_width}x\{screen_height}",
      10,
      10,
      20,
      @raylib.darkblue,
    )
    @raylib.draw_text(
      "World resolution: \{virtual_screen_width}x\{virtual_screen_height}",
      10,
      40,
      20,
      @raylib.darkgreen,
    )
    @raylib.draw_fps(@raylib.get_screen_width() - 95, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_render_texture(target)
  @raylib.close_window()
}
