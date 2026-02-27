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
// GBuffer data
// ============================================================================

///|
struct GBuffer {
  framebuffer : UInt
  position_texture : UInt
  normal_texture : UInt
  albedo_spec_texture : UInt
  depth_renderbuffer : UInt
}

// ============================================================================
// Deferred mode passes
// ============================================================================

///|
const DeferredPosition : Int = 0

///|
const DeferredNormal : Int = 1

///|
const DeferredAlbedo : Int = 2

///|
const DeferredShading : Int = 3

// ============================================================================
// Constants
// ============================================================================

///|
const MaxCubes : Int = 30

///|
let cube_scale : Float = 0.25

// ============================================================================
// Main
// ============================================================================

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("examples/raylib_shaders_deferred_render")

  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - deferred render",
  )

  // Define the camera to look into our 3D world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(5.0, 4.0, 5.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    60.0,
    @raylib.CameraPerspective,
  )

  // Load plane model from a generated mesh
  let model = @raylib.load_model_from_mesh(
    @raylib.gen_mesh_plane(10.0, 10.0, 3, 3),
  )
  let cube = @raylib.load_model_from_mesh(@raylib.gen_mesh_cube(2.0, 2.0, 2.0))

  // Load geometry buffer (G-buffer) shader and deferred shader
  let gbuffer_shader = @raylib.load_shader(
    "resources/shaders/glsl330/gbuffer.vs", "resources/shaders/glsl330/gbuffer.fs",
  )

  let deferred_shader = @raylib.load_shader(
    "resources/shaders/glsl330/deferred_shading.vs", "resources/shaders/glsl330/deferred_shading.fs",
  )
  @raylib.set_shader_locs(
    deferred_shader,
    @raylib.ShaderLocVectorView,
    @raylib.get_shader_location(deferred_shader, "viewPosition"),
  )

  // Initialize the G-buffer
  let fbo = @rl.load_framebuffer()
  if fbo == 0U {
    @raylib.trace_log(@raylib.LogWarning, "Failed to create framebuffer")
    @raylib.close_window()
    return
  }

  @rl.enable_framebuffer(fbo)

  // Since we are storing position and normal data in these textures,
  // we need to use a floating point format.
  let position_texture = @rl.load_texture(
    screen_width,
    screen_height,
    @raylib.PixelformatUncompressedR32g32b32,
    1,
  )
  let normal_texture = @rl.load_texture(
    screen_width,
    screen_height,
    @raylib.PixelformatUncompressedR32g32b32,
    1,
  )
  // Albedo (diffuse color) and specular strength can be combined into one texture.
  // The color in RGB, and the specular strength in the alpha channel.
  let albedo_spec_texture = @rl.load_texture(
    screen_width,
    screen_height,
    @raylib.PixelformatUncompressedR8g8b8a8,
    1,
  )

  // Activate the draw buffers for our framebuffer
  @rl.active_draw_buffers(3)

  // Now we attach our textures to the framebuffer.
  @rl.framebuffer_attach(
    fbo,
    position_texture,
    @rl.AttachmentColorChannel0,
    @rl.AttachmentTexture2d,
    0,
  )
  @rl.framebuffer_attach(
    fbo,
    normal_texture,
    @rl.AttachmentColorChannel1,
    @rl.AttachmentTexture2d,
    0,
  )
  @rl.framebuffer_attach(
    fbo,
    albedo_spec_texture,
    @rl.AttachmentColorChannel2,
    @rl.AttachmentTexture2d,
    0,
  )

  // Finally we attach the depth buffer.
  let depth_renderbuffer = @rl.load_texture_depth(
    screen_width, screen_height, true,
  )
  @rl.framebuffer_attach(
    fbo,
    depth_renderbuffer,
    @rl.AttachmentDepth,
    @rl.AttachmentRenderbuffer,
    0,
  )

  // Make sure our framebuffer is complete.
  // NOTE: rlFramebufferComplete() automatically unbinds the framebuffer.
  if not(@rl.framebuffer_complete(fbo)) {
    @raylib.trace_log(@raylib.LogWarning, "Framebuffer is not complete")
    @raylib.close_window()
    return
  }

  let gbuffer : GBuffer = {
    framebuffer: fbo,
    position_texture,
    normal_texture,
    albedo_spec_texture,
    depth_renderbuffer,
  }

  // Now we initialize the sampler2D uniform's in the deferred shader.
  // We do this by setting the uniform's value to the color channel slot we earlier
  // bound our textures to.
  let deferred_shader_id = @raylib.get_shader_id(deferred_shader).reinterpret_as_uint()
  @rl.enable_shader(deferred_shader_id)
  @rl.set_uniform_sampler(
    @rl.get_location_uniform(deferred_shader_id, "gPosition"),
    0U,
  )
  @rl.set_uniform_sampler(
    @rl.get_location_uniform(deferred_shader_id, "gNormal"),
    1U,
  )
  @rl.set_uniform_sampler(
    @rl.get_location_uniform(deferred_shader_id, "gAlbedoSpec"),
    2U,
  )
  @rl.disable_shader()

  // Assign our gbuffer shader to model materials
  @raylib.set_model_material_shader(model, 0, gbuffer_shader)
  @raylib.set_model_material_shader(cube, 0, gbuffer_shader)

  // Create lights
  let lights = [
    create_light(
      LightPoint,
      @raylib.Vector3::new(-2.0, 1.0, -2.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.yellow,
      deferred_shader,
      0,
    ),
    create_light(
      LightPoint,
      @raylib.Vector3::new(2.0, 1.0, 2.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.red,
      deferred_shader,
      1,
    ),
    create_light(
      LightPoint,
      @raylib.Vector3::new(-2.0, 1.0, 2.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.green,
      deferred_shader,
      2,
    ),
    create_light(
      LightPoint,
      @raylib.Vector3::new(2.0, 1.0, -2.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.blue,
      deferred_shader,
      3,
    ),
  ]

  // Generate random cube positions and rotations
  let cube_positions : Array[@raylib.Vector3] = []
  let cube_rotations : Array[Float] = []
  for i = 0; i < MaxCubes; i = i + 1 {
    let _ = i
    cube_positions.push(
      @raylib.Vector3::new(
        Float::from_int(@raylib.get_random_value(0, 10) - 5),
        Float::from_int(@raylib.get_random_value(0, 5)),
        Float::from_int(@raylib.get_random_value(0, 10) - 5),
      ),
    )
    cube_rotations.push(Float::from_int(@raylib.get_random_value(0, 360)))
  }

  let mut mode = DeferredShading

  @rl.enable_depth_test()

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)

    // Update the shader with the camera view vector
    let camera_pos = vec3_to_bytes(camera.position)
    @raylib.set_shader_value(
      deferred_shader,
      @raylib.get_shader_location(deferred_shader, "viewPosition"),
      camera_pos,
      @raylib.ShaderUniformVec3,
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

    // Check key inputs to switch between G-buffer textures
    if @raylib.is_key_pressed(@raylib.KeyOne) {
      mode = DeferredPosition
    }
    if @raylib.is_key_pressed(@raylib.KeyTwo) {
      mode = DeferredNormal
    }
    if @raylib.is_key_pressed(@raylib.KeyThree) {
      mode = DeferredAlbedo
    }
    if @raylib.is_key_pressed(@raylib.KeyFour) {
      mode = DeferredShading
    }

    // Update light values in shader
    for i = 0; i < MaxLights; i = i + 1 {
      update_light_values(deferred_shader, lights[i])
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw to the geometry buffer by first activating it
    @rl.enable_framebuffer(gbuffer.framebuffer)
    @rl.clear_screen_buffers()

    @rl.disable_color_blend()
    @raylib.begin_mode_3d(camera)

    // NOTE: We have to use rlEnableShader here. BeginShaderMode or thus rlSetShader
    // will not work, as they won't immediately load the shader program.
    let gbuffer_shader_id = @raylib.get_shader_id(gbuffer_shader).reinterpret_as_uint()
    @rl.enable_shader(gbuffer_shader_id)

    // When drawing a model here, make sure that the material's shaders
    // are set to the gbuffer shader!
    @raylib.draw_model(
      model,
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      1.0,
      @raylib.white,
    )
    @raylib.draw_model(
      cube,
      @raylib.Vector3::new(0.0, 1.0, 0.0),
      1.0,
      @raylib.white,
    )

    for i = 0; i < MaxCubes; i = i + 1 {
      @raylib.draw_model_ex(
        cube,
        cube_positions[i],
        @raylib.Vector3::new(1.0, 1.0, 1.0),
        cube_rotations[i],
        @raylib.Vector3::new(cube_scale, cube_scale, cube_scale),
        @raylib.white,
      )
    }

    @rl.disable_shader()
    @raylib.end_mode_3d()
    @rl.enable_color_blend()

    // Go back to the default framebuffer (0) and draw our deferred shading.
    @rl.disable_framebuffer()
    @rl.clear_screen_buffers()

    if mode == DeferredShading {
      @raylib.begin_mode_3d(camera)
      @rl.disable_color_blend()
      @rl.enable_shader(deferred_shader_id)

      // Activate our g-buffer textures
      // These will now be bound to the sampler2D uniforms gPosition, gNormal,
      // and gAlbedoSpec
      @rl.active_texture_slot(0)
      @rl.enable_texture(gbuffer.position_texture)
      @rl.active_texture_slot(1)
      @rl.enable_texture(gbuffer.normal_texture)
      @rl.active_texture_slot(2)
      @rl.enable_texture(gbuffer.albedo_spec_texture)

      // Finally, we draw a fullscreen quad to our default framebuffer
      // This will now be shaded using our deferred shader
      @rl.load_draw_quad()
      @rl.disable_shader()
      @rl.enable_color_blend()
      @raylib.end_mode_3d()

      // Copy over the depth buffer from our g-buffer to the default framebuffer.
      @rl.bind_framebuffer(@rl.ReadFramebuffer, gbuffer.framebuffer)
      @rl.bind_framebuffer(@rl.DrawFramebuffer, 0U)
      @rl.blit_framebuffer(
        0, 0, screen_width, screen_height, 0, 0, screen_width, screen_height, 0x00000100, // GL_DEPTH_BUFFER_BIT
      )
      @rl.disable_framebuffer()

      // Since our shader is now done and disabled, we can draw our lights in default
      // forward rendering
      @raylib.begin_mode_3d(camera)
      @rl.enable_shader(@rl.get_shader_id_default())
      for i = 0; i < MaxLights; i = i + 1 {
        if lights[i].enabled {
          @raylib.draw_sphere_ex(lights[i].position, 0.2, 8, 8, lights[i].color)
        } else {
          @raylib.draw_sphere_wires(
            lights[i].position,
            0.2,
            8,
            8,
            @raylib.color_alpha(lights[i].color, 0.3),
          )
        }
      }
      @rl.disable_shader()
      @raylib.end_mode_3d()

      @raylib.draw_text(
        "FINAL RESULT",
        10,
        screen_height - 30,
        20,
        @raylib.darkgreen,
      )
    } else if mode == DeferredPosition {
      let tex = @raylib.texture_from_id(
        gbuffer.position_texture,
        screen_width,
        screen_height,
      )
      @raylib.draw_texture_rec(
        tex,
        @raylib.Rectangle::new(
          0.0,
          0.0,
          Float::from_int(screen_width),
          Float::from_int(-screen_height),
        ),
        @raylib.Vector2::new(0.0, 0.0),
        @raylib.raywhite,
      )
      @raylib.draw_text(
        "POSITION TEXTURE",
        10,
        screen_height - 30,
        20,
        @raylib.darkgreen,
      )
    } else if mode == DeferredNormal {
      let tex = @raylib.texture_from_id(
        gbuffer.normal_texture,
        screen_width,
        screen_height,
      )
      @raylib.draw_texture_rec(
        tex,
        @raylib.Rectangle::new(
          0.0,
          0.0,
          Float::from_int(screen_width),
          Float::from_int(-screen_height),
        ),
        @raylib.Vector2::new(0.0, 0.0),
        @raylib.raywhite,
      )
      @raylib.draw_text(
        "NORMAL TEXTURE",
        10,
        screen_height - 30,
        20,
        @raylib.darkgreen,
      )
    } else if mode == DeferredAlbedo {
      let tex = @raylib.texture_from_id(
        gbuffer.albedo_spec_texture,
        screen_width,
        screen_height,
      )
      @raylib.draw_texture_rec(
        tex,
        @raylib.Rectangle::new(
          0.0,
          0.0,
          Float::from_int(screen_width),
          Float::from_int(-screen_height),
        ),
        @raylib.Vector2::new(0.0, 0.0),
        @raylib.raywhite,
      )
      @raylib.draw_text(
        "ALBEDO TEXTURE",
        10,
        screen_height - 30,
        20,
        @raylib.darkgreen,
      )
    }

    @raylib.draw_text(
      "Toggle lights keys: [Y][R][G][B]", 10, 40, 20, @raylib.darkgray,
    )
    @raylib.draw_text(
      "Switch G-buffer textures: [1][2][3][4]", 10, 70, 20, @raylib.darkgray,
    )

    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_model(model)
  @raylib.unload_model(cube)

  @raylib.unload_shader(deferred_shader)
  @raylib.unload_shader(gbuffer_shader)

  // Unload geometry buffer and all attached textures
  @rl.unload_framebuffer(gbuffer.framebuffer)
  @rl.unload_texture(gbuffer.position_texture)
  @rl.unload_texture(gbuffer.normal_texture)
  @rl.unload_texture(gbuffer.albedo_spec_texture)
  @rl.unload_texture(gbuffer.depth_renderbuffer)

  @raylib.close_window()
}
