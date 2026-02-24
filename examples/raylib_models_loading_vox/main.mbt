// ============================================================================
// Light system (ported from rlights.h)
// ============================================================================

///|
const LightPoint : Int = 1

///|
const MaxLights : Int = 4

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
  let max_vox_files = 4

  let _ = @raylib.change_directory("examples/raylib_models_loading_vox")

  let vox_file_names = [
    "resources/models/vox/chr_knight.vox", "resources/models/vox/chr_sword.vox",
    "resources/models/vox/monu9.vox", "resources/models/vox/fez.vox",
  ]

  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - magicavoxel loading",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(10.0, 10.0, 10.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load MagicaVoxel files
  let models : Array[@raylib.Model] = []

  for i = 0; i < max_vox_files; i = i + 1 {
    // Load VOX file and measure time
    let t0 = @raylib.get_time() * 1000.0
    let model = @raylib.load_model(vox_file_names[i])
    let t1 = @raylib.get_time() * 1000.0

    @raylib.trace_log(
      @raylib.LogWarning,
      "[" +
      vox_file_names[i] +
      "] File loaded in " +
      (t1 - t0).to_string() +
      " ms",
    )

    // Compute model translation matrix to center model on draw position (0, 0, 0)
    let bb = @raylib.get_model_bounding_box(model)
    let center_x = bb.min.x + (bb.max.x - bb.min.x) / 2.0
    let center_z = bb.min.z + (bb.max.z - bb.min.z) / 2.0

    let mat_translate = @raylib.Matrix::translate(-center_x, 0.0, -center_z)
    @raylib.set_model_transform(model, mat_translate)

    models.push(model)
  }

  let mut current_model = 0

  // Load voxel shader
  let shader = @raylib.load_shader(
    "resources/shaders/glsl330/voxel_lighting.vs", "resources/shaders/glsl330/voxel_lighting.fs",
  )

  // Get some required shader locations
  let view_pos_loc = @raylib.get_shader_location(shader, "viewPos")

  // Ambient light level (some basic lighting)
  let ambient_loc = @raylib.get_shader_location(shader, "ambient")
  let ambient = @raylib.Vector4::new(0.1, 0.1, 0.1, 1.0)
  @raylib.set_shader_value(
    shader,
    ambient_loc,
    vec4_to_bytes(ambient),
    @raylib.ShaderUniformVec4,
  )

  // Assign our lighting shader to model
  for i = 0; i < max_vox_files; i = i + 1 {
    let mat_count = @raylib.get_model_material_count(models[i])
    for j = 0; j < mat_count; j = j + 1 {
      @raylib.set_model_material_shader(models[i], j, shader)
    }
  }

  // Create lights
  let lights = [
    create_light(
      LightPoint,
      @raylib.Vector3::new(-20.0, 20.0, -20.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.gray,
      shader,
      0,
    ),
    create_light(
      LightPoint,
      @raylib.Vector3::new(20.0, -20.0, 20.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.gray,
      shader,
      1,
    ),
    create_light(
      LightPoint,
      @raylib.Vector3::new(-20.0, 20.0, 20.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.gray,
      shader,
      2,
    ),
    create_light(
      LightPoint,
      @raylib.Vector3::new(20.0, -20.0, -20.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.gray,
      shader,
      3,
    ),
  ]

  @raylib.set_target_fps(60)

  let model_pos = @raylib.Vector3::new(0.0, 0.0, 0.0)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let mut camera_rot_x : Float = 0.0
    let mut camera_rot_y : Float = 0.0

    if @raylib.is_mouse_button_down(@raylib.MouseButtonMiddle) {
      let mouse_delta = @raylib.get_mouse_delta()
      camera_rot_x = mouse_delta.x * 0.05
      camera_rot_y = mouse_delta.y * 0.05
    }

    let move_forward : Float = if @raylib.is_key_down(@raylib.KeyW) ||
      @raylib.is_key_down(@raylib.KeyUp) {
      0.1
    } else {
      0.0
    }
    let move_backward : Float = if @raylib.is_key_down(@raylib.KeyS) ||
      @raylib.is_key_down(@raylib.KeyDown) {
      0.1
    } else {
      0.0
    }
    let move_right : Float = if @raylib.is_key_down(@raylib.KeyD) ||
      @raylib.is_key_down(@raylib.KeyRight) {
      0.1
    } else {
      0.0
    }
    let move_left : Float = if @raylib.is_key_down(@raylib.KeyA) ||
      @raylib.is_key_down(@raylib.KeyLeft) {
      0.1
    } else {
      0.0
    }

    camera = @raylib.update_camera_pro(
      camera,
      @raylib.Vector3::new(
        move_forward - move_backward,
        move_right - move_left,
        0.0,
      ),
      @raylib.Vector3::new(camera_rot_x, camera_rot_y, 0.0),
      @raylib.get_mouse_wheel_move() * -2.0,
    )

    // Cycle between models on mouse click
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      current_model = (current_model + 1) % max_vox_files
    }

    // Update the shader with the camera view vector
    @raylib.set_shader_value(
      shader,
      view_pos_loc,
      camera.position.to_bytes(),
      @raylib.ShaderUniformVec3,
    )

    // Update light values (actually, only enable/disable them)
    for i = 0; i < MaxLights; i = i + 1 {
      update_light_values(shader, lights[i])
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw 3D model
    @raylib.begin_mode_3d(camera)

    @raylib.draw_model(models[current_model], model_pos, 1.0, @raylib.white)
    @raylib.draw_grid(10, 1.0)

    // Draw spheres to show where the lights are
    for i = 0; i < MaxLights; i = i + 1 {
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

    @raylib.end_mode_3d()

    // Display info
    @raylib.draw_rectangle(10, 400, 340, 60, @raylib.fade(@raylib.skyblue, 0.5))
    @raylib.draw_rectangle_lines(
      10,
      400,
      340,
      60,
      @raylib.fade(@raylib.darkblue, 0.5),
    )
    @raylib.draw_text(
      "MOUSE LEFT BUTTON to CYCLE VOX MODELS", 40, 410, 10, @raylib.blue,
    )
    @raylib.draw_text(
      "MOUSE MIDDLE BUTTON to ZOOM OR ROTATE CAMERA", 40, 420, 10, @raylib.blue,
    )
    @raylib.draw_text(
      "UP-DOWN-LEFT-RIGHT KEYS to MOVE CAMERA", 40, 430, 10, @raylib.blue,
    )

    // Display filename for current model
    let vox_display_names = [
      "chr_knight.vox", "chr_sword.vox", "monu9.vox", "fez.vox",
    ]
    @raylib.draw_text(
      "File: " + vox_display_names[current_model],
      10,
      10,
      20,
      @raylib.gray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  for i = 0; i < max_vox_files; i = i + 1 {
    @raylib.unload_model(models[i])
  }
  @raylib.unload_shader(shader)
  @raylib.close_window()
}
