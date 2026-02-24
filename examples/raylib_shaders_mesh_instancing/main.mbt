// ============================================================================
// Light system (ported from rlights.h)
// ============================================================================

///|
const LightDirectional : Int = 0

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
    light.position.to_bytes(),
    @raylib.ShaderUniformVec3,
  )

  // Send light target as vec3
  @raylib.set_shader_value(
    shader,
    light.target_loc,
    light.target.to_bytes(),
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
    color_normalized.to_bytes(),
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
  let max_instances = 10000

  let _ = @raylib.change_directory("examples/raylib_shaders_mesh_instancing")

  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - mesh instancing",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(-125.0, 125.0, -125.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Define mesh to be instanced
  let cube = @raylib.gen_mesh_cube(1.0, 1.0, 1.0)

  // Define transforms to be uploaded to GPU for instances
  let transforms : Array[@raylib.Matrix] = Array::make(
    max_instances,
    @raylib.Matrix::identity(),
  )

  // Translate and rotate cubes randomly
  let deg2rad : Float = 0.017453292519943295
  for i = 0; i < max_instances; i = i + 1 {
    let translation = @raylib.Matrix::translate(
      Float::from_int(@raylib.get_random_value(-50, 50)),
      Float::from_int(@raylib.get_random_value(-50, 50)),
      Float::from_int(@raylib.get_random_value(-50, 50)),
    )
    let axis = @raylib.Vector3::normalize(
      @raylib.Vector3::new(
        Float::from_int(@raylib.get_random_value(0, 360)),
        Float::from_int(@raylib.get_random_value(0, 360)),
        Float::from_int(@raylib.get_random_value(0, 360)),
      ),
    )
    let angle = Float::from_int(@raylib.get_random_value(0, 10)) * deg2rad
    let rotation = @raylib.Matrix::rotate(axis, angle)
    transforms[i] = @raylib.Matrix::multiply(rotation, translation)
  }

  // Load lighting shader
  let shader = @raylib.load_shader(
    "resources/shaders/glsl330/lighting_instancing.vs", "resources/shaders/glsl330/lighting.fs",
  )

  // Get shader locations
  @raylib.set_shader_location(
    shader,
    @raylib.ShaderLocMatrixMvp,
    @raylib.get_shader_location(shader, "mvp"),
  )
  @raylib.set_shader_location(
    shader,
    @raylib.ShaderLocVectorView,
    @raylib.get_shader_location(shader, "viewPos"),
  )
  @raylib.set_shader_location(
    shader,
    @raylib.ShaderLocMatrixModel,
    @raylib.get_shader_location_attrib(shader, "instanceTransform"),
  )

  // Set shader value: ambient light level
  let ambient_loc = @raylib.get_shader_location(shader, "ambient")
  let ambient = @raylib.Vector4::new(0.2, 0.2, 0.2, 1.0)
  @raylib.set_shader_value(
    shader,
    ambient_loc,
    ambient.to_bytes(),
    @raylib.ShaderUniformVec4,
  )

  // Create one light
  let _light = create_light(
    LightDirectional,
    @raylib.Vector3::new(50.0, 50.0, 0.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.white,
    shader,
    0,
  )
  ignore(_light)

  // NOTE: We are assigning the instancing shader to material.shader
  // to be used on mesh drawing with DrawMeshInstanced()
  let mat_instances = @raylib.load_material_default()
  @raylib.set_material_shader(mat_instances, shader)
  @raylib.set_material_map_color(
    mat_instances,
    @raylib.MaterialMapAlbedo,
    @raylib.red,
  )

  // Load default material for non-instanced mesh drawing
  let mat_default = @raylib.load_material_default()
  @raylib.set_material_map_color(
    mat_default,
    @raylib.MaterialMapAlbedo,
    @raylib.blue,
  )

  // Get shader location for camera view position
  let view_pos_loc = @raylib.get_shader_location(shader, "viewPos")

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)

    // Update the light shader with the camera view position
    @raylib.set_shader_value(
      shader,
      view_pos_loc,
      camera.position.to_bytes(),
      @raylib.ShaderUniformVec3,
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_mode_3d(camera)

    // Draw cube mesh with default material (BLUE)
    @raylib.draw_mesh(
      cube,
      mat_default,
      @raylib.Matrix::translate(-10.0, 0.0, 0.0),
    )

    // Draw meshes instanced using material containing instancing shader (RED + lighting)
    @raylib.draw_mesh_instanced(cube, mat_instances, transforms, max_instances)

    // Draw cube mesh with default material (BLUE)
    @raylib.draw_mesh(
      cube,
      mat_default,
      @raylib.Matrix::translate(10.0, 0.0, 0.0),
    )

    @raylib.end_mode_3d()

    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.close_window()
}
