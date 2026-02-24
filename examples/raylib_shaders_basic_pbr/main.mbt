// ============================================================================
// PBR Light system
// ============================================================================

///|
const LightPoint : Int = 1

///|
const MaxLights : Int = 4

///|
struct PbrLight {
  mut enabled : Bool
  light_type : Int
  position : @raylib.Vector3
  target : @raylib.Vector3
  color : FixedArray[Float] // normalized RGBA [0.0..1.0]
  intensity : Float
  // Shader uniform locations
  enabled_loc : Int
  type_loc : Int
  position_loc : Int
  target_loc : Int
  color_loc : Int
  intensity_loc : Int
}

// ============================================================================
// Byte helpers
// ============================================================================

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
fn vec2_to_bytes(v : @raylib.Vector2) -> Bytes {
  v.to_bytes()
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
fn color4_to_bytes(c : FixedArray[Float]) -> Bytes {
  let arr = FixedArray::make(16, b'\x00')
  for i = 0; i < 4; i = i + 1 {
    let bits = c[i].reinterpret_as_int()
    arr[i * 4] = (bits & 0xFF).to_byte()
    arr[i * 4 + 1] = ((bits >> 8) & 0xFF).to_byte()
    arr[i * 4 + 2] = ((bits >> 16) & 0xFF).to_byte()
    arr[i * 4 + 3] = ((bits >> 24) & 0xFF).to_byte()
  }
  FixedArray::unsafe_reinterpret_as_bytes(arr)
}

// ============================================================================
// Light creation and update
// ============================================================================

///|
fn create_pbr_light(
  light_type : Int,
  position : @raylib.Vector3,
  target : @raylib.Vector3,
  color : @raylib.Color,
  intensity : Float,
  shader : @raylib.Shader,
  index : Int,
) -> PbrLight {
  let color_normalized : FixedArray[Float] = [
    Float::from_int(color.r.to_int()) / 255.0,
    Float::from_int(color.g.to_int()) / 255.0,
    Float::from_int(color.b.to_int()) / 255.0,
    Float::from_int(color.a.to_int()) / 255.0,
  ]
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
  let intensity_loc = @raylib.get_shader_location(
    shader,
    "lights[" + index.to_string() + "].intensity",
  )
  let light : PbrLight = {
    enabled: true,
    light_type,
    position,
    target,
    color: color_normalized,
    intensity,
    enabled_loc,
    type_loc,
    position_loc,
    target_loc,
    color_loc,
    intensity_loc,
  }
  update_pbr_light(shader, light)
  light
}

///|
fn update_pbr_light(shader : @raylib.Shader, light : PbrLight) -> Unit {
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
  @raylib.set_shader_value(
    shader,
    light.color_loc,
    color4_to_bytes(light.color),
    @raylib.ShaderUniformVec4,
  )

  // Send light intensity
  @raylib.set_shader_value(
    shader,
    light.intensity_loc,
    float_to_bytes(light.intensity),
    @raylib.ShaderUniformFloat,
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

  let _ = @raylib.change_directory("examples/raylib_shaders_basic_pbr")

  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - basic pbr",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(2.0, 2.0, 6.0),
    @raylib.Vector3::new(0.0, 0.5, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load PBR shader and setup all required locations
  let shader = @raylib.load_shader(
    "resources/shaders/glsl330/pbr.vs", "resources/shaders/glsl330/pbr.fs",
  )
  @raylib.set_shader_locs(
    shader,
    @raylib.ShaderLocMapAlbedo,
    @raylib.get_shader_location(shader, "albedoMap"),
  )
  // WARNING: Metalness, roughness, and ambient occlusion are all packed into a MRA texture
  // They are passed as to the SHADER_LOC_MAP_METALNESS location for convenience,
  // shader already takes care of it accordingly
  @raylib.set_shader_locs(
    shader,
    @raylib.ShaderLocMapMetalness,
    @raylib.get_shader_location(shader, "mraMap"),
  )
  @raylib.set_shader_locs(
    shader,
    @raylib.ShaderLocMapNormal,
    @raylib.get_shader_location(shader, "normalMap"),
  )
  // WARNING: Similar to the MRA map, the emissive map packs different information
  // into a single texture: it stores height and emission data
  // It is binded to SHADER_LOC_MAP_EMISSION location and properly processed on shader
  @raylib.set_shader_locs(
    shader,
    @raylib.ShaderLocMapEmission,
    @raylib.get_shader_location(shader, "emissiveMap"),
  )
  @raylib.set_shader_locs(
    shader,
    @raylib.ShaderLocColorDiffuse,
    @raylib.get_shader_location(shader, "albedoColor"),
  )

  // Setup additional required shader locations, including lights data
  @raylib.set_shader_locs(
    shader,
    @raylib.ShaderLocVectorView,
    @raylib.get_shader_location(shader, "viewPos"),
  )
  let light_count_loc = @raylib.get_shader_location(shader, "numOfLights")
  let max_light_count = MaxLights
  @raylib.set_shader_value(
    shader,
    light_count_loc,
    int_to_bytes(max_light_count),
    @raylib.ShaderUniformInt,
  )

  // Setup ambient color and intensity parameters
  let ambient_intensity : Float = 0.02
  let ambient_color = @raylib.Color::new(26, 32, 135, 255)
  let ambient_color_normalized = @raylib.Vector3::new(
    Float::from_int(ambient_color.r.to_int()) / 255.0,
    Float::from_int(ambient_color.g.to_int()) / 255.0,
    Float::from_int(ambient_color.b.to_int()) / 255.0,
  )
  @raylib.set_shader_value(
    shader,
    @raylib.get_shader_location(shader, "ambientColor"),
    vec3_to_bytes(ambient_color_normalized),
    @raylib.ShaderUniformVec3,
  )
  @raylib.set_shader_value(
    shader,
    @raylib.get_shader_location(shader, "ambient"),
    float_to_bytes(ambient_intensity),
    @raylib.ShaderUniformFloat,
  )

  // Get location for shader parameters that can be modified in real time
  let emissive_intensity_loc = @raylib.get_shader_location(
    shader, "emissivePower",
  )
  let emissive_color_loc = @raylib.get_shader_location(shader, "emissiveColor")
  let texture_tiling_loc = @raylib.get_shader_location(shader, "tiling")

  // Load old car model using PBR maps and shader
  let car = @raylib.load_model("resources/models/old_car_new.glb")

  // Assign already setup PBR shader to model.materials[0]
  @raylib.set_model_material_shader(car, 0, shader)

  // Get material reference for setting map properties
  let car_material = @raylib.get_model_material(car, 0)

  // Setup materials[0].maps default parameters
  @raylib.set_material_map_color(
    car_material,
    @raylib.MaterialMapAlbedo,
    @raylib.white,
  )
  @raylib.set_material_map_value(
    car_material,
    @raylib.MaterialMapMetalness,
    0.0,
  )
  @raylib.set_material_map_value(
    car_material,
    @raylib.MaterialMapRoughness,
    0.0,
  )
  @raylib.set_material_map_value(
    car_material,
    @raylib.MaterialMapOcclusion,
    1.0,
  )
  @raylib.set_material_map_color(
    car_material,
    @raylib.MaterialMapEmission,
    @raylib.Color::new(255, 162, 0, 255),
  )

  // Setup materials[0].maps default textures
  @raylib.set_material_texture(
    car_material,
    @raylib.MaterialMapAlbedo,
    @raylib.load_texture("resources/old_car_d.png"),
  )
  @raylib.set_material_texture(
    car_material,
    @raylib.MaterialMapMetalness,
    @raylib.load_texture("resources/old_car_mra.png"),
  )
  @raylib.set_material_texture(
    car_material,
    @raylib.MaterialMapNormal,
    @raylib.load_texture("resources/old_car_n.png"),
  )
  @raylib.set_material_texture(
    car_material,
    @raylib.MaterialMapEmission,
    @raylib.load_texture("resources/old_car_e.png"),
  )

  // Load floor model mesh and assign material parameters
  let floor_model = @raylib.load_model("resources/models/plane.glb")

  // Assign material shader for our floor model, same PBR shader
  @raylib.set_model_material_shader(floor_model, 0, shader)

  let floor_material = @raylib.get_model_material(floor_model, 0)

  @raylib.set_material_map_color(
    floor_material,
    @raylib.MaterialMapAlbedo,
    @raylib.white,
  )
  @raylib.set_material_map_value(
    floor_material,
    @raylib.MaterialMapMetalness,
    0.0,
  )
  @raylib.set_material_map_value(
    floor_material,
    @raylib.MaterialMapRoughness,
    0.0,
  )
  @raylib.set_material_map_value(
    floor_material,
    @raylib.MaterialMapOcclusion,
    1.0,
  )
  @raylib.set_material_map_color(
    floor_material,
    @raylib.MaterialMapEmission,
    @raylib.black,
  )

  @raylib.set_material_texture(
    floor_material,
    @raylib.MaterialMapAlbedo,
    @raylib.load_texture("resources/road_a.png"),
  )
  @raylib.set_material_texture(
    floor_material,
    @raylib.MaterialMapMetalness,
    @raylib.load_texture("resources/road_mra.png"),
  )
  @raylib.set_material_texture(
    floor_material,
    @raylib.MaterialMapNormal,
    @raylib.load_texture("resources/road_n.png"),
  )

  // Models texture tiling parameter
  let car_texture_tiling = @raylib.Vector2::new(0.5, 0.5)
  let floor_texture_tiling = @raylib.Vector2::new(0.5, 0.5)

  // Create some lights
  let lights = [
    create_pbr_light(
      LightPoint,
      @raylib.Vector3::new(-1.0, 1.0, -2.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.yellow,
      4.0,
      shader,
      0,
    ),
    create_pbr_light(
      LightPoint,
      @raylib.Vector3::new(2.0, 1.0, 1.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.green,
      3.3,
      shader,
      1,
    ),
    create_pbr_light(
      LightPoint,
      @raylib.Vector3::new(-2.0, 1.0, 1.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.red,
      8.3,
      shader,
      2,
    ),
    create_pbr_light(
      LightPoint,
      @raylib.Vector3::new(1.0, 1.0, -2.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.blue,
      2.0,
      shader,
      3,
    ),
  ]

  // Setup material texture maps usage in shader
  // NOTE: By default, the texture maps are always used
  let usage = 1
  @raylib.set_shader_value(
    shader,
    @raylib.get_shader_location(shader, "useTexAlbedo"),
    int_to_bytes(usage),
    @raylib.ShaderUniformInt,
  )
  @raylib.set_shader_value(
    shader,
    @raylib.get_shader_location(shader, "useTexNormal"),
    int_to_bytes(usage),
    @raylib.ShaderUniformInt,
  )
  @raylib.set_shader_value(
    shader,
    @raylib.get_shader_location(shader, "useTexMRA"),
    int_to_bytes(usage),
    @raylib.ShaderUniformInt,
  )
  @raylib.set_shader_value(
    shader,
    @raylib.get_shader_location(shader, "useTexEmissive"),
    int_to_bytes(usage),
    @raylib.ShaderUniformInt,
  )

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)

    // Update the shader with the camera view vector
    let camera_pos = vec3_to_bytes(camera.position)
    @raylib.set_shader_value(
      shader,
      @raylib.get_shader_location(shader, "viewPos"),
      camera_pos,
      @raylib.ShaderUniformVec3,
    )

    // Check key inputs to enable/disable lights
    if @raylib.is_key_pressed(@raylib.KeyOne) {
      lights[2].enabled = not(lights[2].enabled)
    }
    if @raylib.is_key_pressed(@raylib.KeyTwo) {
      lights[1].enabled = not(lights[1].enabled)
    }
    if @raylib.is_key_pressed(@raylib.KeyThree) {
      lights[3].enabled = not(lights[3].enabled)
    }
    if @raylib.is_key_pressed(@raylib.KeyFour) {
      lights[0].enabled = not(lights[0].enabled)
    }

    // Update light values on shader (actually, only enable/disable them)
    for i = 0; i < MaxLights; i = i + 1 {
      update_pbr_light(shader, lights[i])
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.black)

    @raylib.begin_mode_3d(camera)

    // Set floor model texture tiling and emissive color parameters on shader
    @raylib.set_shader_value(
      shader,
      texture_tiling_loc,
      vec2_to_bytes(floor_texture_tiling),
      @raylib.ShaderUniformVec2,
    )
    let floor_emissive_color = @raylib.color_normalize(@raylib.black)
    @raylib.set_shader_value(
      shader,
      emissive_color_loc,
      vec4_to_bytes(floor_emissive_color),
      @raylib.ShaderUniformVec4,
    )

    @raylib.draw_model(
      floor_model,
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      5.0,
      @raylib.white,
    )

    // Set old car model texture tiling, emissive color and emissive intensity parameters on shader
    @raylib.set_shader_value(
      shader,
      texture_tiling_loc,
      vec2_to_bytes(car_texture_tiling),
      @raylib.ShaderUniformVec2,
    )
    let car_emissive_color = @raylib.color_normalize(
      @raylib.Color::new(255, 162, 0, 255),
    )
    @raylib.set_shader_value(
      shader,
      emissive_color_loc,
      vec4_to_bytes(car_emissive_color),
      @raylib.ShaderUniformVec4,
    )
    let emissive_intensity : Float = 0.01
    @raylib.set_shader_value(
      shader,
      emissive_intensity_loc,
      float_to_bytes(emissive_intensity),
      @raylib.ShaderUniformFloat,
    )

    @raylib.draw_model(
      car,
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      0.25,
      @raylib.white,
    )

    // Draw spheres to show the lights positions
    for i = 0; i < MaxLights; i = i + 1 {
      let light_color = @raylib.Color::new(
        (lights[i].color[0] * 255.0).to_int(),
        (lights[i].color[1] * 255.0).to_int(),
        (lights[i].color[2] * 255.0).to_int(),
        (lights[i].color[3] * 255.0).to_int(),
      )
      if lights[i].enabled {
        @raylib.draw_sphere_ex(lights[i].position, 0.2, 8, 8, light_color)
      } else {
        @raylib.draw_sphere_wires(
          lights[i].position,
          0.2,
          8,
          8,
          @raylib.fade(light_color, 0.3),
        )
      }
    }

    @raylib.end_mode_3d()

    @raylib.draw_text(
      "Toggle lights: [1][2][3][4]", 10, 40, 20, @raylib.lightgray,
    )

    @raylib.draw_text(
      "(c) Old Rusty Car model by Renafox (https://skfb.ly/LxRy)",
      screen_width - 320,
      screen_height - 20,
      10,
      @raylib.lightgray,
    )

    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_model(car)
  @raylib.unload_model(floor_model)
  @raylib.unload_shader(shader)
  @raylib.close_window()
}
