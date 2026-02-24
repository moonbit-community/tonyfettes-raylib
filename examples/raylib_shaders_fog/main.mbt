// ============================================================================
// Light system (ported from rlights.h)
// ============================================================================

///|
const LightPoint : Int = 1

///|
struct Light {
  enabled : Bool
  light_type : Int
  position : @raylib.Vector3
  target : @raylib.Vector3
  color : @raylib.Color
  // Shader uniform locations
  enabled_loc : Int
  type_loc : Int
  position_loc : Int
  target_loc : Int
  color_loc : Int
}

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
fn float_to_bytes(v : Float) -> Bytes {
  let bits = v.reinterpret_as_int()
  let arr = FixedArray::make(4, b'\x00')
  arr[0] = (bits & 0xFF).to_byte()
  arr[1] = ((bits >> 8) & 0xFF).to_byte()
  arr[2] = ((bits >> 16) & 0xFF).to_byte()
  arr[3] = ((bits >> 24) & 0xFF).to_byte()
  FixedArray::unsafe_reinterpret_as_bytes(arr)
}

///|
fn format_float(v : Float) -> String {
  let i = v.to_int()
  let frac = ((v - Float::from_int(i)).abs() * 100.0).to_int()
  let sign = if v < 0.0 && i == 0 { "-" } else { "" }
  let frac_str = if frac < 10 {
    "0" + frac.to_string()
  } else {
    frac.to_string()
  }
  sign + i.to_string() + "." + frac_str
}

///|
fn vec3_to_bytes(v : @raylib.Vector3) -> Bytes {
  v.to_bytes()
}

///|
fn vec4_to_bytes(v : @raylib.Vector4) -> Bytes {
  v.to_bytes()
}

///|
fn create_light(
  light_type : Int,
  position : @raylib.Vector3,
  target : @raylib.Vector3,
  color : @raylib.Color,
  shader : @raylib.Shader,
  index : Int,
) -> Light {
  let enabled_loc = @raylib.get_shader_location(
    shader,
    "lights[" + index.to_string() + "].enabled",
  )
  let type_loc = @raylib.get_shader_location(
    shader,
    "lights[" + index.to_string() + "].type",
  )
  let position_loc = @raylib.get_shader_location(
    shader,
    "lights[" + index.to_string() + "].position",
  )
  let target_loc = @raylib.get_shader_location(
    shader,
    "lights[" + index.to_string() + "].target",
  )
  let color_loc = @raylib.get_shader_location(
    shader,
    "lights[" + index.to_string() + "].color",
  )
  let light : Light = {
    enabled: true,
    light_type,
    position,
    target,
    color,
    enabled_loc,
    type_loc,
    position_loc,
    target_loc,
    color_loc,
  }
  update_light_values(shader, light)
  light
}

///|
fn update_light_values(shader : @raylib.Shader, light : Light) -> Unit {
  // Send light enabled state as integer
  let enabled_val = if light.enabled { 1 } else { 0 }
  @raylib.set_shader_value(
    shader,
    light.enabled_loc,
    int_to_bytes(enabled_val),
    @raylib.ShaderUniformInt,
  )

  // Send light type
  @raylib.set_shader_value(
    shader,
    light.type_loc,
    int_to_bytes(light.light_type),
    @raylib.ShaderUniformInt,
  )

  // Send light position as vec3
  @raylib.set_shader_value(
    shader,
    light.position_loc,
    vec3_to_bytes(light.position),
    @raylib.ShaderUniformVec3,
  )

  // Send light target as vec3
  @raylib.set_shader_value(
    shader,
    light.target_loc,
    vec3_to_bytes(light.target),
    @raylib.ShaderUniformVec3,
  )

  // Send light color as vec4 (normalized 0.0-1.0)
  let color_normalized = @raylib.Vector4::new(
    Float::from_int(light.color.r.to_int()) / 255.0,
    Float::from_int(light.color.g.to_int()) / 255.0,
    Float::from_int(light.color.b.to_int()) / 255.0,
    Float::from_int(light.color.a.to_int()) / 255.0,
  )
  @raylib.set_shader_value(
    shader,
    light.color_loc,
    vec4_to_bytes(color_normalized),
    @raylib.ShaderUniformVec4,
  )
}

// ============================================================================
// Main
// ============================================================================

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("examples/raylib_shaders_fog")

  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - fog",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(2.0, 2.0, 6.0),
    @raylib.Vector3::new(0.0, 0.5, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load models and texture
  let model_a = @raylib.load_model_from_mesh(
    @raylib.gen_mesh_torus(0.4, 1.0, 16, 32),
  )
  let model_b = @raylib.load_model_from_mesh(
    @raylib.gen_mesh_cube(1.0, 1.0, 1.0),
  )
  let model_c = @raylib.load_model_from_mesh(
    @raylib.gen_mesh_sphere(0.5, 32, 32),
  )
  let texture = @raylib.load_texture("resources/texel_checker.png")

  // Assign texture to default model material (MATERIAL_MAP_DIFFUSE = 0)
  @raylib.set_model_material_texture(
    model_a,
    0,
    @raylib.MaterialMapAlbedo,
    texture,
  )
  @raylib.set_model_material_texture(
    model_b,
    0,
    @raylib.MaterialMapAlbedo,
    texture,
  )
  @raylib.set_model_material_texture(
    model_c,
    0,
    @raylib.MaterialMapAlbedo,
    texture,
  )

  // Load shader and set up some uniforms
  let shader = @raylib.load_shader(
    "resources/shaders/glsl330/lighting.vs", "resources/shaders/glsl330/fog.fs",
  )

  // Set shader locations for matModel and viewPos
  @raylib.set_shader_locs(
    shader,
    @raylib.ShaderLocMatrixModel,
    @raylib.get_shader_location(shader, "matModel"),
  )
  @raylib.set_shader_locs(
    shader,
    @raylib.ShaderLocVectorView,
    @raylib.get_shader_location(shader, "viewPos"),
  )

  // Ambient light level
  let ambient_loc = @raylib.get_shader_location(shader, "ambient")
  let ambient = @raylib.Vector4::new(0.2, 0.2, 0.2, 1.0)
  @raylib.set_shader_value(
    shader,
    ambient_loc,
    vec4_to_bytes(ambient),
    @raylib.ShaderUniformVec4,
  )

  // Fog density
  let mut fog_density : Float = 0.15
  let fog_density_loc = @raylib.get_shader_location(shader, "fogDensity")
  @raylib.set_shader_value(
    shader,
    fog_density_loc,
    float_to_bytes(fog_density),
    @raylib.ShaderUniformFloat,
  )

  // NOTE: All models share the same shader
  @raylib.set_model_material_shader(model_a, 0, shader)
  @raylib.set_model_material_shader(model_b, 0, shader)
  @raylib.set_model_material_shader(model_c, 0, shader)

  // Using just 1 point light
  let _light = create_light(
    LightPoint,
    @raylib.Vector3::new(0.0, 2.0, 6.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.white,
    shader,
    0,
  )

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)

    if @raylib.is_key_down(@raylib.KeyUp) {
      fog_density += 0.001
      if fog_density > 1.0 {
        fog_density = 1.0
      }
    }

    if @raylib.is_key_down(@raylib.KeyDown) {
      fog_density -= 0.001
      if fog_density < 0.0 {
        fog_density = 0.0
      }
    }

    @raylib.set_shader_value(
      shader,
      fog_density_loc,
      float_to_bytes(fog_density),
      @raylib.ShaderUniformFloat,
    )

    // Rotate the torus
    let transform_a = @raylib.get_model_transform(model_a)
    let rotated = @raylib.Matrix::multiply(
      transform_a,
      @raylib.Matrix::rotate_x(-0.025),
    )
    let rotated2 = @raylib.Matrix::multiply(
      rotated,
      @raylib.Matrix::rotate_z(0.012),
    )
    @raylib.set_model_transform(model_a, rotated2)

    // Update the light shader with the camera view position
    let view_pos_loc = @raylib.get_shader_location(shader, "viewPos")
    let camera_pos = vec3_to_bytes(camera.position)
    @raylib.set_shader_value(
      shader,
      view_pos_loc,
      camera_pos,
      @raylib.ShaderUniformVec3,
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.gray)

    @raylib.begin_mode_3d(camera)

    // Draw the three models
    @raylib.draw_model(
      model_a,
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      1.0,
      @raylib.white,
    )
    @raylib.draw_model(
      model_b,
      @raylib.Vector3::new(-2.6, 0.0, 0.0),
      1.0,
      @raylib.white,
    )
    @raylib.draw_model(
      model_c,
      @raylib.Vector3::new(2.6, 0.0, 0.0),
      1.0,
      @raylib.white,
    )

    for i = -20; i < 20; i = i + 2 {
      @raylib.draw_model(
        model_a,
        @raylib.Vector3::new(Float::from_int(i), 0.0, 2.0),
        1.0,
        @raylib.white,
      )
    }

    @raylib.end_mode_3d()

    // Format fog density text
    let density_text = "Use KEY_UP/KEY_DOWN to change fog density [" +
      format_float(fog_density) +
      "]"
    @raylib.draw_text(density_text, 10, 10, 20, @raylib.raywhite)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_model(model_a)
  @raylib.unload_model(model_b)
  @raylib.unload_model(model_c)
  @raylib.unload_texture(texture)
  @raylib.unload_shader(shader)
  @raylib.close_window()
}
