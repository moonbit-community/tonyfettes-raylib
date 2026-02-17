///|
fn vec2_to_bytes(v : @raylib.Vector2) -> Bytes {
  v.to_bytes()
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("examples/raylib_shaders_custom_uniform")

  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - custom uniform",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(8.0, 8.0, 8.0),
    @raylib.Vector3::new(0.0, 1.5, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load postprocessing shader (swirl effect)
  let shader = @raylib.load_shader("", "resources/shaders/glsl330/swirl.fs")

  // Get variable (uniform) location on the shader
  let swirl_center_loc = @raylib.get_shader_location(shader, "center")

  let swirl_center = @raylib.Vector2::new(
    Float::from_int(screen_width) / 2.0,
    Float::from_int(screen_height) / 2.0,
  )

  // Set initial swirl center value
  @raylib.set_shader_value(
    shader,
    swirl_center_loc,
    vec2_to_bytes(swirl_center),
    @raylib.ShaderUniformVec2,
  )

  // Create a RenderTexture2D to be used for render to texture
  let target = @raylib.load_render_texture(screen_width, screen_height)

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)

    let mouse_position = @raylib.get_mouse_position()

    let swirl_center = @raylib.Vector2::new(
      mouse_position.x,
      Float::from_int(screen_height) - mouse_position.y,
    )

    // Send new value to the shader to be used on drawing
    @raylib.set_shader_value(
      shader,
      swirl_center_loc,
      vec2_to_bytes(swirl_center),
      @raylib.ShaderUniformVec2,
    )

    // Draw scene to render texture
    @raylib.begin_texture_mode(target)
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    // Draw some cubes as a 3D scene
    @raylib.draw_cube(
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      2.0,
      2.0,
      2.0,
      @raylib.red,
    )
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      2.0,
      2.0,
      2.0,
      @raylib.maroon,
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(-3.0, 0.0, 0.0),
      1.0,
      3.0,
      1.0,
      @raylib.green,
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(3.0, 0.0, 0.0),
      1.0,
      2.0,
      1.0,
      @raylib.blue,
    )
    @raylib.draw_grid(10, 1.0)
    @raylib.end_mode_3d()
    @raylib.draw_text("TEXT DRAWN IN RENDER TEXTURE", 200, 10, 30, @raylib.red)
    @raylib.end_texture_mode()

    // Draw render texture to screen with shader applied
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_shader_mode(shader)
    let tex_width = @raylib.get_render_texture_width(target)
    let tex_height = @raylib.get_render_texture_height(target)
    @raylib.draw_render_texture_rec(
      target,
      @raylib.Rectangle::new(
        0.0,
        0.0,
        Float::from_int(tex_width),
        Float::from_int(-tex_height),
      ),
      @raylib.Vector2::new(0.0, 0.0),
      @raylib.white,
    )
    @raylib.end_shader_mode()

    @raylib.draw_text(
      "Move mouse to change swirl center",
      10,
      screen_height - 30,
      20,
      @raylib.darkgray,
    )
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.unload_render_texture(target)
  @raylib.close_window()
}
