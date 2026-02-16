///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("examples/raylib_shaders_postprocessing")

  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - postprocessing",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(2.0, 3.0, 2.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load postprocessing shaders
  let max_postpro_shaders = 3
  let shader_names = ["GRAYSCALE", "BLUR", "CROSS_HATCHING"]
  let shaders = [
    @raylib.load_shader("", "resources/shaders/glsl330/grayscale.fs"),
    @raylib.load_shader("", "resources/shaders/glsl330/blur.fs"),
    @raylib.load_shader("", "resources/shaders/glsl330/cross_hatching.fs"),
  ]

  let mut current_shader = 0

  // Create a RenderTexture2D to be used for render to texture
  let target = @raylib.load_render_texture(screen_width, screen_height)

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)

    if @raylib.is_key_pressed(@raylib.KeyRight) {
      current_shader = current_shader + 1
    } else if @raylib.is_key_pressed(@raylib.KeyLeft) {
      current_shader = current_shader - 1
    }

    if current_shader >= max_postpro_shaders {
      current_shader = 0
    } else if current_shader < 0 {
      current_shader = max_postpro_shaders - 1
    }

    // Draw scene to render texture
    @raylib.begin_texture_mode(target)
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    // Draw some cubes as stand-in for a 3D model
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
      @raylib.Vector3::new(-2.0, 0.0, -2.0),
      1.0,
      2.0,
      1.0,
      @raylib.green,
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(2.0, 0.0, 2.0),
      1.0,
      1.5,
      1.0,
      @raylib.blue,
    )
    @raylib.draw_grid(10, 1.0)
    @raylib.end_mode_3d()
    @raylib.end_texture_mode()

    // Draw render texture to screen with shader applied
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_shader_mode(shaders[current_shader])
    // NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
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

    @raylib.draw_rectangle(0, 9, 580, 30, @raylib.fade(@raylib.lightgray, 0.7))
    @raylib.draw_text("CURRENT POSTPRO SHADER:", 10, 15, 20, @raylib.black)
    @raylib.draw_text(shader_names[current_shader], 330, 15, 20, @raylib.red)
    @raylib.draw_text("< >", 540, 10, 30, @raylib.darkblue)
    @raylib.draw_fps(700, 15)
    @raylib.end_drawing()
  }

  // De-Initialization
  for i = 0; i < max_postpro_shaders; i = i + 1 {
    @raylib.unload_shader(shaders[i])
  }
  @raylib.unload_render_texture(target)
  @raylib.close_window()
}
