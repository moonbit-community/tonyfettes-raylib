// ============================================================================
// Light system (ported from rlights.h)
// ============================================================================

///|
const LightPoint : Int = 1

///|
const MaxLights : Int = 4

///|
struct Light {
  mut enabled : Bool
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
  shader.set_value(
    light.enabled_loc,
    @raylib.ShaderUniformData::Int(enabled_val),
  )

  // Send light type
  shader.set_value(
    light.type_loc,
    @raylib.ShaderUniformData::Int(light.light_type),
  )

  // Send light position as vec3
  shader.set_value(
    light.position_loc,
    @raylib.ShaderUniformData::Vec3(light.position),
  )

  // Send light target as vec3
  shader.set_value(
    light.target_loc,
    @raylib.ShaderUniformData::Vec3(light.target),
  )

  // Send light color as vec4 (normalized 0.0-1.0)
  let color_normalized = @raylib.Vector4::new(
    Float::from_int(light.color.r.to_int()) / 255.0,
    Float::from_int(light.color.g.to_int()) / 255.0,
    Float::from_int(light.color.b.to_int()) / 255.0,
    Float::from_int(light.color.a.to_int()) / 255.0,
  )
  shader.set_value(
    light.color_loc,
    @raylib.ShaderUniformData::Vec4(color_normalized),
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

  let _ = @raylib.change_directory("shaders/shaders_basic_lighting")

  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - basic lighting",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(2.0, 4.0, 6.0),
    @raylib.Vector3::new(0.0, 0.5, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load lighting shader
  let shader = @raylib.load_shader(
    "resources/shaders/glsl330/lighting.vs", "resources/shaders/glsl330/lighting.fs",
  )

  // Get shader locations for camera view position
  let view_pos_loc = @raylib.get_shader_location(shader, "viewPos")

  // Set ambient light level
  let ambient_loc = @raylib.get_shader_location(shader, "ambient")
  let ambient = @raylib.Vector4::new(0.1, 0.1, 0.1, 1.0)
  shader.set_value(ambient_loc, @raylib.ShaderUniformData::Vec4(ambient))

  // Create lights
  let lights = [
    create_light(
      LightPoint,
      @raylib.Vector3::new(-2.0, 1.0, -2.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.yellow,
      shader,
      0,
    ),
    create_light(
      LightPoint,
      @raylib.Vector3::new(2.0, 1.0, 2.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.red,
      shader,
      1,
    ),
    create_light(
      LightPoint,
      @raylib.Vector3::new(-2.0, 1.0, 2.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.green,
      shader,
      2,
    ),
    create_light(
      LightPoint,
      @raylib.Vector3::new(2.0, 1.0, -2.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.blue,
      shader,
      3,
    ),
  ]

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)

    // Update shader with current camera position
    shader.set_value(
      view_pos_loc,
      @raylib.ShaderUniformData::Vec3(camera.position),
    )

    // Toggle lights with key presses
    if @raylib.is_key_pressed(@raylib.KeyY) {
      lights[0].enabled = not(lights[0].enabled)
    }
    if @raylib.is_key_pressed(@raylib.KeyR) {
      lights[1].enabled = not(lights[1].enabled)
    }
    if @raylib.is_key_pressed(@raylib.KeyG) {
      lights[2].enabled = not(lights[2].enabled)
    }
    if @raylib.is_key_pressed(@raylib.KeyB) {
      lights[3].enabled = not(lights[3].enabled)
    }

    // Update light values in shader
    for i in 0..<MaxLights {
      update_light_values(shader, lights[i])
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_mode_3d(camera)

    // Draw scene with lighting shader
    @raylib.begin_shader_mode(shader)
    @raylib.draw_plane(
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.Vector2::new(10.0, 10.0),
      @raylib.white,
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(0.0, 2.0, 0.0),
      2.0,
      4.0,
      2.0,
      @raylib.white,
    )
    @raylib.end_shader_mode()

    // Draw light source spheres (without shader)
    for i in 0..<MaxLights {
      if lights[i].enabled {
        @raylib.draw_sphere_ex(lights[i].position, 0.2, 8, 8, lights[i].color)
      } else {
        @raylib.draw_sphere_wires(
          lights[i].position,
          0.2,
          8,
          8,
          @raylib.fade(lights[i].color, 0.3),
        )
      }
    }

    @raylib.draw_grid(10, 1.0)

    @raylib.end_mode_3d()

    @raylib.draw_fps(10, 10)
    @raylib.draw_text(
      "Use keys [Y][R][G][B] to toggle lights", 10, 40, 20, @raylib.darkgray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.close_window()
}
