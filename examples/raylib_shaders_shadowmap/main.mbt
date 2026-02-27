// ============================================================================
// raylib [shaders] example - Shadowmap
//
// Ported from: shaders_shadowmap.c
// ============================================================================

///|
const ShadowmapResolution : Int = 1024

///|
fn int_to_bytes(v : Int) -> Bytes {
  let arr = FixedArray::make(4, b'\x00')
  arr[0] = (v & 0xFF).to_byte()
  arr[1] = ((v >> 8) & 0xFF).to_byte()
  arr[2] = ((v >> 16) & 0xFF).to_byte()
  arr[3] = ((v >> 24) & 0xFF).to_byte()
  FixedArray::unsafe_reinterpret_as_bytes(arr)
}

///|
fn draw_scene(cube : @raylib.Model, robot : @raylib.Model) -> Unit {
  // Ground plane (scaled cube)
  @raylib.draw_model_ex(
    cube,
    @raylib.Vector3::zero(),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    0.0,
    @raylib.Vector3::new(10.0, 1.0, 10.0),
    @raylib.blue,
  )
  // Small cube
  @raylib.draw_model_ex(
    cube,
    @raylib.Vector3::new(1.5, 1.0, -1.5),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    0.0,
    @raylib.Vector3::one(),
    @raylib.white,
  )
  // Robot model
  @raylib.draw_model_ex(
    robot,
    @raylib.Vector3::new(0.0, 0.5, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    0.0,
    @raylib.Vector3::new(1.0, 1.0, 1.0),
    @raylib.red,
  )
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("examples/raylib_shaders_shadowmap")

  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - shadowmap",
  )

  // Define the camera to look into our 3d world
  let mut cam = @raylib.Camera3D::new(
    @raylib.Vector3::new(10.0, 10.0, 10.0),
    @raylib.Vector3::zero(),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load the shadow mapping shader
  let shadow_shader = @raylib.load_shader(
    "resources/shaders/glsl330/shadowmap.vs", "resources/shaders/glsl330/shadowmap.fs",
  )
  // Set the shader location for the view position
  let view_pos_loc = @raylib.get_shader_location(shadow_shader, "viewPos")
  @raylib.set_shader_location(
    shadow_shader,
    @raylib.ShaderLocVectorView,
    view_pos_loc,
  )

  // Set up light direction and color
  let mut light_dir = @raylib.Vector3::normalize(
    @raylib.Vector3::new(0.35, -1.0, -0.35),
  )
  let light_color = @raylib.white
  let light_color_normalized = @raylib.color_normalize(light_color)

  let light_dir_loc = @raylib.get_shader_location(shadow_shader, "lightDir")
  let light_col_loc = @raylib.get_shader_location(shadow_shader, "lightColor")
  @raylib.set_shader_value(
    shadow_shader,
    light_dir_loc,
    light_dir.to_bytes(),
    @raylib.ShaderUniformVec3,
  )
  @raylib.set_shader_value(
    shadow_shader,
    light_col_loc,
    light_color_normalized.to_bytes(),
    @raylib.ShaderUniformVec4,
  )

  // Ambient light
  let ambient_loc = @raylib.get_shader_location(shadow_shader, "ambient")
  let ambient = @raylib.Vector4::new(0.1, 0.1, 0.1, 1.0)
  @raylib.set_shader_value(
    shadow_shader,
    ambient_loc,
    ambient.to_bytes(),
    @raylib.ShaderUniformVec4,
  )

  // Shadow map uniforms
  let light_vp_loc = @raylib.get_shader_location(shadow_shader, "lightVP")
  let shadow_map_loc = @raylib.get_shader_location(shadow_shader, "shadowMap")
  let shadow_map_resolution_loc = @raylib.get_shader_location(
    shadow_shader, "shadowMapResolution",
  )
  @raylib.set_shader_value(
    shadow_shader,
    shadow_map_resolution_loc,
    int_to_bytes(ShadowmapResolution),
    @raylib.ShaderUniformInt,
  )

  // Load models
  let cube = @raylib.load_model_from_mesh(@raylib.gen_mesh_cube(1.0, 1.0, 1.0))
  @raylib.set_model_material_shader(cube, 0, shadow_shader)

  let robot = @raylib.load_model("resources/models/robot.glb")
  let robot_material_count = @raylib.get_model_material_count(robot)
  for i = 0; i < robot_material_count; i = i + 1 {
    @raylib.set_model_material_shader(robot, i, shadow_shader)
  }

  // Load model animations
  let robot_animations = @raylib.load_model_animations(
    "resources/models/robot.glb",
  )
  let anim_frame_count = @raylib.get_model_animation_frame_count(
    robot_animations, 0,
  )

  // Load shadow map render texture (depth-only)
  let shadow_map = @raylib.load_shadowmap_render_texture(
    ShadowmapResolution,
    ShadowmapResolution,
  )

  // Light camera for shadow mapping (renders from the light's point of view)
  let mut light_cam = @raylib.Camera3D::new(
    @raylib.Vector3::scale(light_dir, -15.0),
    @raylib.Vector3::zero(),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    20.0,
    @raylib.CameraOrthographic,
  )

  @raylib.set_target_fps(60)

  let mut fc = 0

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let dt = @raylib.get_frame_time()

    // Update shader with current camera position
    let camera_pos = cam.position
    @raylib.set_shader_value(
      shadow_shader,
      view_pos_loc,
      camera_pos.to_bytes(),
      @raylib.ShaderUniformVec3,
    )
    cam = @raylib.update_camera(cam, @raylib.CameraOrbital)

    // Update animation
    fc = (fc + 1) % anim_frame_count
    @raylib.update_model_animation(robot, robot_animations, 0, fc)

    // Update light direction with arrow keys
    let camera_speed : Float = 0.05
    let mut ld_x = light_dir.x
    let mut ld_z = light_dir.z
    if @raylib.is_key_down(@raylib.KeyLeft) {
      if ld_x < 0.6 {
        ld_x = ld_x + camera_speed * 60.0 * dt
      }
    }
    if @raylib.is_key_down(@raylib.KeyRight) {
      if ld_x > -0.6 {
        ld_x = ld_x - camera_speed * 60.0 * dt
      }
    }
    if @raylib.is_key_down(@raylib.KeyUp) {
      if ld_z < 0.6 {
        ld_z = ld_z + camera_speed * 60.0 * dt
      }
    }
    if @raylib.is_key_down(@raylib.KeyDown) {
      if ld_z > -0.6 {
        ld_z = ld_z - camera_speed * 60.0 * dt
      }
    }
    light_dir = @raylib.Vector3::normalize(
      @raylib.Vector3::new(ld_x, light_dir.y, ld_z),
    )
    light_cam = @raylib.Camera3D::new(
      @raylib.Vector3::scale(light_dir, -15.0),
      light_cam.target,
      light_cam.up,
      light_cam.fovy,
      light_cam.projection,
    )
    @raylib.set_shader_value(
      shadow_shader,
      light_dir_loc,
      light_dir.to_bytes(),
      @raylib.ShaderUniformVec3,
    )

    // Draw
    @raylib.begin_drawing()

    // First, render all objects into the shadowmap
    // Record the light matrices for future use
    @raylib.begin_texture_mode(shadow_map)
    @raylib.clear_background(@raylib.white)
    @raylib.begin_mode_3d(light_cam)
    let light_view = @rl.get_matrix_modelview()
    let light_proj = @rl.get_matrix_projection()
    draw_scene(cube, robot)
    @raylib.end_mode_3d()
    @raylib.end_texture_mode()

    let light_view_proj = @raylib.Matrix::multiply(light_view, light_proj)

    @raylib.clear_background(@raylib.raywhite)

    @raylib.set_shader_value_matrix(
      shadow_shader, light_vp_loc, light_view_proj,
    )

    // Enable the shadow shader and bind the shadow map texture
    let shader_id = @raylib.get_shader_id(shadow_shader).reinterpret_as_uint()
    @rl.enable_shader(shader_id)
    let slot : Int = 10 // Can be anything 0 to 15, but 0 will probably be taken up
    @rl.active_texture_slot(10)
    let depth_id = @raylib.get_render_texture_depth_id(shadow_map)
    @rl.enable_texture(depth_id)
    @rl.set_uniform(
      shadow_map_loc,
      int_to_bytes(slot),
      @raylib.ShaderUniformInt,
      1,
    )

    @raylib.begin_mode_3d(cam)
    // Draw the same exact things as we drew in the shadowmap
    draw_scene(cube, robot)
    @raylib.end_mode_3d()

    @raylib.draw_text(
      "Shadows in raylib using the shadowmapping algorithm!",
      screen_width - 320,
      screen_height - 20,
      10,
      @raylib.gray,
    )
    @raylib.draw_text(
      "Use the arrow keys to rotate the light!", 10, 10, 30, @raylib.red,
    )

    @raylib.end_drawing()

    if @raylib.is_key_pressed(@raylib.KeyF) {
      @raylib.take_screenshot("shaders_shadowmap.png")
    }
  }

  // De-Initialization
  @raylib.unload_shader(shadow_shader)
  @raylib.unload_model(cube)
  @raylib.unload_model(robot)
  @raylib.unload_model_animations(robot_animations)
  @raylib.unload_shadowmap_render_texture(shadow_map)

  @raylib.close_window()
}
