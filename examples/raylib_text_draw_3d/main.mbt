///|
let letter_boundry_size : Float = 0.25

///|
const TextMaxLayers : Int = 32

// WaveTextConfig

///|
struct WaveTextConfig {
  wave_range_x : Float
  wave_range_y : Float
  wave_range_z : Float
  wave_speed_x : Float
  wave_speed_y : Float
  wave_speed_z : Float
  wave_offset_x : Float
  wave_offset_y : Float
  wave_offset_z : Float
}

// Alpha discard fragment shader (GLSL 330) embedded as string

///|
let alpha_discard_fs : String =
  #|#version 330
  #|in vec2 fragTexCoord;
  #|in vec4 fragColor;
  #|uniform sampler2D texture0;
  #|uniform vec4 colDiffuse;
  #|out vec4 finalColor;
  #|void main()
  #|{
  #|    vec4 texelColor = texture(texture0, fragTexCoord);
  #|    if (texelColor.a == 0.0) discard;
  #|    finalColor = texelColor * fragColor * colDiffuse;
  #|}

///|
fn draw_text_codepoint_3d(
  font : @raylib.Font,
  codepoint : Int,
  position : @raylib.Vector3,
  font_size : Float,
  backface : Bool,
  tint : @raylib.Color,
  show_letter_boundry : Bool,
) -> Unit {
  let base_size : Float = Float::from_int(@raylib.get_font_base_size(font))
  let scale : Float = font_size / base_size
  let glyph_padding : Float = Float::from_int(
    @raylib.get_font_glyph_padding(font),
  )
  // Get glyph info
  let glyph = @raylib.get_glyph_info(font, codepoint)
  // Get glyph atlas rectangle
  let rec = @raylib.get_glyph_atlas_rec(font, codepoint)
  let pos_x = position.x +
    (Float::from_int(glyph.offset_x) - glyph_padding) / base_size * scale
  let pos_z = position.z +
    (Float::from_int(glyph.offset_y) - glyph_padding) / base_size * scale
  // Source rectangle from font texture atlas
  let src_x = rec.x - glyph_padding
  let src_y = rec.y - glyph_padding
  let src_w = rec.width + 2.0 * glyph_padding
  let src_h = rec.height + 2.0 * glyph_padding
  let width : Float = src_w / base_size * scale
  let height : Float = src_h / base_size * scale
  let font_texture = @raylib.get_font_texture(font)
  let texture_id = @raylib.get_texture_id(font_texture)
  if texture_id > 0 {
    let x : Float = 0.0
    let y : Float = 0.0
    let z : Float = 0.0
    // Normalized texture coordinates
    let tex_w : Float = Float::from_int(@raylib.get_texture_width(font_texture))
    let tex_h : Float = Float::from_int(
      @raylib.get_texture_height(font_texture),
    )
    let tx : Float = src_x / tex_w
    let ty : Float = src_y / tex_h
    let tw : Float = (src_x + src_w) / tex_w
    let th : Float = (src_y + src_h) / tex_h
    if show_letter_boundry {
      @raylib.draw_cube_wires_v(
        @raylib.Vector3::new(
          pos_x + width / 2.0,
          position.y,
          pos_z + height / 2.0,
        ),
        @raylib.Vector3::new(width, letter_boundry_size, height),
        @raylib.violet,
      )
    }
    let batch_count = if backface { 8 } else { 4 }
    let _ = @rl.check_render_batch_limit(batch_count)
    @rl.set_texture(texture_id.reinterpret_as_uint())
    @rl.push_matrix()
    @rl.translatef(pos_x, position.y, pos_z)
    @rl.begin(@rl.Quads)
    @rl.color4ub(tint.r, tint.g, tint.b, tint.a)
    // Front Face
    @rl.normal3f(0.0, 1.0, 0.0)
    @rl.tex_coord2f(tx, ty)
    @rl.vertex3f(x, y, z)
    @rl.tex_coord2f(tx, th)
    @rl.vertex3f(x, y, z + height)
    @rl.tex_coord2f(tw, th)
    @rl.vertex3f(x + width, y, z + height)
    @rl.tex_coord2f(tw, ty)
    @rl.vertex3f(x + width, y, z)
    if backface {
      // Back Face
      @rl.normal3f(0.0, -1.0, 0.0)
      @rl.tex_coord2f(tx, ty)
      @rl.vertex3f(x, y, z)
      @rl.tex_coord2f(tw, ty)
      @rl.vertex3f(x + width, y, z)
      @rl.tex_coord2f(tw, th)
      @rl.vertex3f(x + width, y, z + height)
      @rl.tex_coord2f(tx, th)
      @rl.vertex3f(x, y, z + height)
    }
    @rl.end_()
    @rl.pop_matrix()
    @rl.set_texture(0U)
  }
}

///|
fn draw_text_3d(
  font : @raylib.Font,
  text : String,
  position : @raylib.Vector3,
  font_size : Float,
  font_spacing : Float,
  line_spacing : Float,
  backface : Bool,
  tint : @raylib.Color,
  show_letter_boundry : Bool,
) -> Unit {
  let base_size : Float = Float::from_int(@raylib.get_font_base_size(font))
  let scale : Float = font_size / base_size
  let codepoints = @raylib.load_codepoints(text)
  let length = codepoints.length()
  let mut text_offset_y : Float = 0.0
  let mut text_offset_x : Float = 0.0
  for i = 0; i < length; i = i + 1 {
    let codepoint = codepoints[i]
    if codepoint == 10 {
      // '\n'
      text_offset_y = text_offset_y + scale + line_spacing / base_size * scale
      text_offset_x = 0.0
    } else {
      if codepoint != 32 && codepoint != 9 {
        // not space or tab
        draw_text_codepoint_3d(
          font,
          codepoint,
          @raylib.Vector3::new(
            position.x + text_offset_x,
            position.y,
            position.z + text_offset_y,
          ),
          font_size,
          backface,
          tint,
          show_letter_boundry,
        )
      }
      let glyph = @raylib.get_glyph_info(font, codepoint)
      let rec = @raylib.get_glyph_atlas_rec(font, codepoint)
      if glyph.advance_x == 0 {
        text_offset_x = text_offset_x +
          (rec.width + font_spacing) / base_size * scale
      } else {
        text_offset_x = text_offset_x +
          (Float::from_int(glyph.advance_x) + font_spacing) / base_size * scale
      }
    }
  }
}

///|
fn measure_text_3d(
  font : @raylib.Font,
  text : String,
  font_size : Float,
  font_spacing : Float,
  line_spacing : Float,
) -> @raylib.Vector3 {
  let base_size : Float = Float::from_int(@raylib.get_font_base_size(font))
  let scale : Float = font_size / base_size
  let mut text_height : Float = scale
  let mut text_width : Float = 0.0
  let mut temp_text_width : Float = 0.0
  let mut temp_len = 0
  let mut len_counter = 0
  let codepoints = @raylib.load_codepoints(text)
  let length = codepoints.length()
  for i = 0; i < length; i = i + 1 {
    len_counter = len_counter + 1
    let letter = codepoints[i]
    let glyph = @raylib.get_glyph_info(font, letter)
    let rec = @raylib.get_glyph_atlas_rec(font, letter)
    if letter != 10 {
      // not '\n'
      if glyph.advance_x != 0 {
        text_width = text_width +
          (Float::from_int(glyph.advance_x) + font_spacing) / base_size * scale
      } else {
        text_width = text_width +
          (rec.width + Float::from_int(glyph.offset_x)) / base_size * scale
      }
    } else {
      if temp_text_width < text_width {
        temp_text_width = text_width
      }
      len_counter = 0
      text_width = 0.0
      text_height = text_height + scale + line_spacing / base_size * scale
    }
    if temp_len < len_counter {
      temp_len = len_counter
    }
  }
  if temp_text_width < text_width {
    temp_text_width = text_width
  }
  let vec_x = temp_text_width +
    Float::from_int(temp_len - 1) * font_spacing / base_size * scale
  @raylib.Vector3::new(vec_x, 0.25, text_height)
}

///|
fn draw_text_wave_3d(
  font : @raylib.Font,
  text : String,
  position : @raylib.Vector3,
  font_size : Float,
  font_spacing : Float,
  line_spacing : Float,
  backface : Bool,
  config : WaveTextConfig,
  time : Float,
  tint : @raylib.Color,
  show_letter_boundry : Bool,
) -> Unit {
  let base_size : Float = Float::from_int(@raylib.get_font_base_size(font))
  let scale : Float = font_size / base_size
  let codepoints = @raylib.load_codepoints(text)
  let length = codepoints.length()
  let mut text_offset_y : Float = 0.0
  let mut text_offset_x : Float = 0.0
  let mut wave = false
  let mut k = 0
  let mut i = 0
  while i < length {
    let codepoint = codepoints[i]
    if codepoint == 10 {
      // '\n'
      text_offset_y = text_offset_y + scale + line_spacing / base_size * scale
      text_offset_x = 0.0
      k = 0
    } else if codepoint == 126 {
      // '~'
      if i + 1 < length && codepoints[i + 1] == 126 {
        // Skip the next '~' too
        i = i + 1
        wave = not(wave)
      }
    } else {
      if codepoint != 32 && codepoint != 9 {
        // not space or tab
        let mut pos_x = position.x + text_offset_x
        let mut pos_y = position.y
        let mut pos_z = position.z + text_offset_y
        if wave {
          let kf = Float::from_int(k)
          pos_x = pos_x +
            @math.sinf(time * config.wave_speed_x - kf * config.wave_offset_x) *
            config.wave_range_x
          pos_y = pos_y +
            @math.sinf(time * config.wave_speed_y - kf * config.wave_offset_y) *
            config.wave_range_y
          pos_z = pos_z +
            @math.sinf(time * config.wave_speed_z - kf * config.wave_offset_z) *
            config.wave_range_z
        }
        draw_text_codepoint_3d(
          font,
          codepoint,
          @raylib.Vector3::new(pos_x, pos_y, pos_z),
          font_size,
          backface,
          tint,
          show_letter_boundry,
        )
      }
      let glyph = @raylib.get_glyph_info(font, codepoint)
      let rec = @raylib.get_glyph_atlas_rec(font, codepoint)
      if glyph.advance_x == 0 {
        text_offset_x = text_offset_x +
          (rec.width + font_spacing) / base_size * scale
      } else {
        text_offset_x = text_offset_x +
          (Float::from_int(glyph.advance_x) + font_spacing) / base_size * scale
      }
    }
    k = k + 1
    i = i + 1
  }
}

///|
fn measure_text_wave_3d(
  font : @raylib.Font,
  text : String,
  font_size : Float,
  font_spacing : Float,
  line_spacing : Float,
) -> @raylib.Vector3 {
  let base_size : Float = Float::from_int(@raylib.get_font_base_size(font))
  let scale : Float = font_size / base_size
  let mut text_height : Float = scale
  let mut text_width : Float = 0.0
  let mut temp_text_width : Float = 0.0
  let mut temp_len = 0
  let mut len_counter = 0
  let codepoints = @raylib.load_codepoints(text)
  let length = codepoints.length()
  let mut i = 0
  while i < length {
    len_counter = len_counter + 1
    let letter = codepoints[i]
    let glyph = @raylib.get_glyph_info(font, letter)
    let rec = @raylib.get_glyph_atlas_rec(font, letter)
    if letter != 10 {
      // not '\n'
      if letter == 126 && i + 1 < length && codepoints[i + 1] == 126 {
        // Skip '~~'
        i = i + 1
      } else if glyph.advance_x != 0 {
        text_width = text_width +
          (Float::from_int(glyph.advance_x) + font_spacing) / base_size * scale
      } else {
        text_width = text_width +
          (rec.width + Float::from_int(glyph.offset_x)) / base_size * scale
      }
    } else {
      if temp_text_width < text_width {
        temp_text_width = text_width
      }
      len_counter = 0
      text_width = 0.0
      text_height = text_height + scale + line_spacing / base_size * scale
    }
    if temp_len < len_counter {
      temp_len = len_counter
    }
    i = i + 1
  }
  if temp_text_width < text_width {
    temp_text_width = text_width
  }
  let vec_x = temp_text_width +
    Float::from_int(temp_len - 1) * font_spacing / base_size * scale
  @raylib.Vector3::new(vec_x, 0.25, text_height)
}

///|
fn generate_random_color(s : Float, v : Float) -> @raylib.Color {
  let phi : Float = 0.618033988749895
  let h0 : Float = Float::from_int(@raylib.get_random_value(0, 360))
  let h : Float = (h0 + h0 * phi) % 360.0
  @raylib.color_from_hsv(h, s, v)
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint | @raylib.FlagVsyncHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [text] example - draw 2D text in 3D",
  )
  let mut spin = true
  let mut multicolor = false
  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(-10.0, 15.0, -10.0), // position
    @raylib.Vector3::new(0.0, 0.0, 0.0), // target
    @raylib.Vector3::new(0.0, 1.0, 0.0), // up
    45.0, // fovy
    @raylib.CameraPerspective, // projection
  )
  let mut camera_mode = @raylib.CameraOrbital
  let cube_position = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let cube_size = @raylib.Vector3::new(2.0, 2.0, 2.0)
  // Use the default font
  let font = @raylib.get_font_default()
  let mut font_size : Float = 8.0
  let mut font_spacing : Float = 0.5
  let mut line_spacing : Float = -1.0
  // Set the text (using markdown!)
  let mut text = "Hello ~~World~~ in 3D!"
  let mut layers = 1
  let mut quads = 0
  let mut layer_distance : Float = 0.01
  let wcfg : WaveTextConfig = {
    wave_range_x: 0.45,
    wave_range_y: 0.45,
    wave_range_z: 0.45,
    wave_speed_x: 3.0,
    wave_speed_y: 3.0,
    wave_speed_z: 0.5,
    wave_offset_x: 0.35,
    wave_offset_y: 0.35,
    wave_offset_z: 0.35,
  }
  let mut time : Float = 0.0
  // Setup a light and dark color
  let mut light = @raylib.maroon
  let mut dark = @raylib.red
  // Load the alpha discard shader (embedded)
  let alpha_discard = @raylib.load_shader_from_memory("", alpha_discard_fs)
  // Array filled with multiple random colors (when multicolor mode is set)
  let multi : Array[@raylib.Color] = Array::make(TextMaxLayers, @raylib.white)
  let mut show_letter_boundry = false
  let mut show_text_boundry = false
  @raylib.disable_cursor()
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, camera_mode)

    // Handle Events
    if @raylib.is_key_pressed(@raylib.KeyF1) {
      show_letter_boundry = not(show_letter_boundry)
    }
    if @raylib.is_key_pressed(@raylib.KeyF2) {
      show_text_boundry = not(show_text_boundry)
    }
    if @raylib.is_key_pressed(@raylib.KeyF3) {
      spin = not(spin)
      if spin {
        camera = @raylib.Camera3D::new(
          @raylib.Vector3::new(-10.0, 15.0, -10.0),
          @raylib.Vector3::new(0.0, 0.0, 0.0),
          @raylib.Vector3::new(0.0, 1.0, 0.0),
          45.0,
          @raylib.CameraPerspective,
        )
        camera_mode = @raylib.CameraOrbital
      } else {
        camera = @raylib.Camera3D::new(
          @raylib.Vector3::new(10.0, 10.0, -10.0),
          @raylib.Vector3::new(0.0, 0.0, 0.0),
          @raylib.Vector3::new(0.0, 1.0, 0.0),
          45.0,
          @raylib.CameraPerspective,
        )
        camera_mode = @raylib.CameraFree
      }
    }

    // Handle clicking the cube
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      let ray = @raylib.get_screen_to_world_ray(
        @raylib.get_mouse_position(),
        camera,
      )
      let collision = @raylib.get_ray_collision_box(
        ray,
        @raylib.BoundingBox::new(
          @raylib.Vector3::new(
            cube_position.x - cube_size.x / 2.0,
            cube_position.y - cube_size.y / 2.0,
            cube_position.z - cube_size.z / 2.0,
          ),
          @raylib.Vector3::new(
            cube_position.x + cube_size.x / 2.0,
            cube_position.y + cube_size.y / 2.0,
            cube_position.z + cube_size.z / 2.0,
          ),
        ),
      )
      if collision.hit {
        light = generate_random_color(0.5, 0.78)
        dark = generate_random_color(0.4, 0.58)
      }
    }

    // Handle text layers changes
    if @raylib.is_key_pressed(@raylib.KeyHome) {
      if layers > 1 {
        layers = layers - 1
      }
    } else if @raylib.is_key_pressed(@raylib.KeyEnd) {
      if layers < TextMaxLayers {
        layers = layers + 1
      }
    }

    // Handle text changes
    if @raylib.is_key_pressed(@raylib.KeyLeft) {
      font_size = font_size - 0.5
    } else if @raylib.is_key_pressed(@raylib.KeyRight) {
      font_size = font_size + 0.5
    } else if @raylib.is_key_pressed(@raylib.KeyUp) {
      font_spacing = font_spacing - 0.1
    } else if @raylib.is_key_pressed(@raylib.KeyDown) {
      font_spacing = font_spacing + 0.1
    } else if @raylib.is_key_pressed(@raylib.KeyPageUp) {
      line_spacing = line_spacing - 0.1
    } else if @raylib.is_key_pressed(@raylib.KeyPageDown) {
      line_spacing = line_spacing + 0.1
    } else if @raylib.is_key_down(@raylib.KeyInsert) {
      layer_distance = layer_distance - 0.001
    } else if @raylib.is_key_down(@raylib.KeyDelete) {
      layer_distance = layer_distance + 0.001
    } else if @raylib.is_key_pressed(@raylib.KeyTab) {
      multicolor = not(multicolor)
      if multicolor {
        for i = 0; i < TextMaxLayers; i = i + 1 {
          let c = generate_random_color(0.5, 0.8)
          let a = @raylib.get_random_value(0, 255)
          multi[i] = @raylib.Color::new(
            c.r.to_int(),
            c.g.to_int(),
            c.b.to_int(),
            a,
          )
        }
      }
    }

    // Handle text input
    if @raylib.is_key_pressed(@raylib.KeyBackspace) {
      // Remove last char
      let cps = @raylib.load_codepoints(text)
      if cps.length() > 0 {
        let buf = StringBuilder::new()
        for j = 0; j < cps.length() - 1; j = j + 1 {
          buf.write_char(cps[j].unsafe_to_char())
        }
        text = buf.to_string()
      }
    } else if @raylib.is_key_pressed(@raylib.KeyEnter) {
      text = text + "\n"
    } else {
      let ch = @raylib.get_char_pressed()
      if ch > 0 {
        let buf = StringBuilder::new()
        buf.write_string(text)
        buf.write_char(ch.unsafe_to_char())
        text = buf.to_string()
      }
    }

    // Measure 3D text so we can center it
    let tbox = measure_text_wave_3d(
      font, text, font_size, font_spacing, line_spacing,
    )
    quads = 0
    time = time + @raylib.get_frame_time()

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_cube_v(cube_position, cube_size, dark)
    @raylib.draw_cube_wires(cube_position, 2.1, 2.1, 2.1, light)
    @raylib.draw_grid(10, 2.0)

    // Use a shader to handle the depth buffer issue with transparent textures
    @raylib.begin_shader_mode(alpha_discard)

    // Draw the 3D text above the red cube
    @rl.push_matrix()
    @rl.rotatef(90.0, 1.0, 0.0, 0.0)
    @rl.rotatef(90.0, 0.0, 0.0, -1.0)
    for i = 0; i < layers; i = i + 1 {
      let clr = if multicolor { multi[i] } else { light }
      draw_text_wave_3d(
        font,
        text,
        @raylib.Vector3::new(
          -tbox.x / 2.0,
          layer_distance * Float::from_int(i),
          -4.5,
        ),
        font_size,
        font_spacing,
        line_spacing,
        true,
        wcfg,
        time,
        clr,
        show_letter_boundry,
      )
    }
    // Draw text bounding box
    if show_text_boundry {
      @raylib.draw_cube_wires_v(
        @raylib.Vector3::new(0.0, 0.0, -4.5 + tbox.z / 2.0),
        tbox,
        dark,
      )
    }
    @rl.pop_matrix()

    // Don't draw letter boundaries for the 3D text below
    let slb = show_letter_boundry
    show_letter_boundry = false

    // Draw 3D options (use default font)
    let default_font = @raylib.get_font_default()
    @rl.push_matrix()
    @rl.rotatef(180.0, 0.0, 1.0, 0.0)
    // SIZE option
    let opt1 = "< SIZE: " + font_size.to_string() + " >"
    quads = quads + opt1.length()
    let m1 = measure_text_3d(default_font, opt1, 8.0, 1.0, 0.0)
    let mut pos_x : Float = -m1.x / 2.0
    let mut pos_z : Float = 2.0
    draw_text_3d(
      default_font,
      opt1,
      @raylib.Vector3::new(pos_x, 0.01, pos_z),
      8.0,
      1.0,
      0.0,
      false,
      @raylib.blue,
      false,
    )
    pos_z = pos_z + 0.5 + m1.z
    // SPACING option
    let opt2 = "< SPACING: " + font_spacing.to_string() + " >"
    quads = quads + opt2.length()
    let m2 = measure_text_3d(default_font, opt2, 8.0, 1.0, 0.0)
    pos_x = -m2.x / 2.0
    draw_text_3d(
      default_font,
      opt2,
      @raylib.Vector3::new(pos_x, 0.01, pos_z),
      8.0,
      1.0,
      0.0,
      false,
      @raylib.blue,
      false,
    )
    pos_z = pos_z + 0.5 + m2.z
    // LINE option
    let opt3 = "< LINE: " + line_spacing.to_string() + " >"
    quads = quads + opt3.length()
    let m3 = measure_text_3d(default_font, opt3, 8.0, 1.0, 0.0)
    pos_x = -m3.x / 2.0
    draw_text_3d(
      default_font,
      opt3,
      @raylib.Vector3::new(pos_x, 0.01, pos_z),
      8.0,
      1.0,
      0.0,
      false,
      @raylib.blue,
      false,
    )
    pos_z = pos_z + 1.0 + m3.z
    // LBOX option
    let lbox_str = if slb { "ON" } else { "OFF" }
    let opt4 = "< LBOX: " + lbox_str + " >"
    quads = quads + opt4.length()
    let m4 = measure_text_3d(default_font, opt4, 8.0, 1.0, 0.0)
    pos_x = -m4.x / 2.0
    draw_text_3d(
      default_font,
      opt4,
      @raylib.Vector3::new(pos_x, 0.01, pos_z),
      8.0,
      1.0,
      0.0,
      false,
      @raylib.red,
      false,
    )
    pos_z = pos_z + 0.5 + m4.z
    // TBOX option
    let tbox_str = if show_text_boundry { "ON" } else { "OFF" }
    let opt5 = "< TBOX: " + tbox_str + " >"
    quads = quads + opt5.length()
    let m5 = measure_text_3d(default_font, opt5, 8.0, 1.0, 0.0)
    pos_x = -m5.x / 2.0
    draw_text_3d(
      default_font,
      opt5,
      @raylib.Vector3::new(pos_x, 0.01, pos_z),
      8.0,
      1.0,
      0.0,
      false,
      @raylib.red,
      false,
    )
    pos_z = pos_z + 0.5 + m5.z
    // LAYER DISTANCE option
    let opt6 = "< LAYER DISTANCE: " + layer_distance.to_string() + " >"
    quads = quads + opt6.length()
    let m6 = measure_text_3d(default_font, opt6, 8.0, 1.0, 0.0)
    pos_x = -m6.x / 2.0
    draw_text_3d(
      default_font,
      opt6,
      @raylib.Vector3::new(pos_x, 0.01, pos_z),
      8.0,
      1.0,
      0.0,
      false,
      @raylib.darkpurple,
      false,
    )
    @rl.pop_matrix()

    // Draw 3D info text (use default font)
    let info1 = "All the text displayed here is in 3D"
    quads = quads + 36
    let mi1 = measure_text_3d(default_font, info1, 10.0, 0.5, 0.0)
    pos_x = -mi1.x / 2.0
    pos_z = 2.0
    draw_text_3d(
      default_font,
      info1,
      @raylib.Vector3::new(pos_x, 0.01, pos_z),
      10.0,
      0.5,
      0.0,
      false,
      @raylib.darkblue,
      false,
    )
    pos_z = pos_z + 1.5 + mi1.z
    let info2 = "press [Left]/[Right] to change the font size"
    quads = quads + 44
    let mi2 = measure_text_3d(default_font, info2, 6.0, 0.5, 0.0)
    pos_x = -mi2.x / 2.0
    draw_text_3d(
      default_font,
      info2,
      @raylib.Vector3::new(pos_x, 0.01, pos_z),
      6.0,
      0.5,
      0.0,
      false,
      @raylib.darkblue,
      false,
    )
    pos_z = pos_z + 0.5 + mi2.z
    let info3 = "press [Up]/[Down] to change the font spacing"
    quads = quads + 44
    let mi3 = measure_text_3d(default_font, info3, 6.0, 0.5, 0.0)
    pos_x = -mi3.x / 2.0
    draw_text_3d(
      default_font,
      info3,
      @raylib.Vector3::new(pos_x, 0.01, pos_z),
      6.0,
      0.5,
      0.0,
      false,
      @raylib.darkblue,
      false,
    )
    pos_z = pos_z + 0.5 + mi3.z
    let info4 = "press [PgUp]/[PgDown] to change the line spacing"
    quads = quads + 48
    let mi4 = measure_text_3d(default_font, info4, 6.0, 0.5, 0.0)
    pos_x = -mi4.x / 2.0
    draw_text_3d(
      default_font,
      info4,
      @raylib.Vector3::new(pos_x, 0.01, pos_z),
      6.0,
      0.5,
      0.0,
      false,
      @raylib.darkblue,
      false,
    )
    pos_z = pos_z + 0.5 + mi4.z
    let info5 = "press [F1] to toggle the letter boundry"
    quads = quads + 39
    let mi5 = measure_text_3d(default_font, info5, 6.0, 0.5, 0.0)
    pos_x = -mi5.x / 2.0
    draw_text_3d(
      default_font,
      info5,
      @raylib.Vector3::new(pos_x, 0.01, pos_z),
      6.0,
      0.5,
      0.0,
      false,
      @raylib.darkblue,
      false,
    )
    pos_z = pos_z + 0.5 + mi5.z
    let info6 = "press [F2] to toggle the text boundry"
    quads = quads + 37
    let mi6 = measure_text_3d(default_font, info6, 6.0, 0.5, 0.0)
    pos_x = -mi6.x / 2.0
    draw_text_3d(
      default_font,
      info6,
      @raylib.Vector3::new(pos_x, 0.01, pos_z),
      6.0,
      0.5,
      0.0,
      false,
      @raylib.darkblue,
      false,
    )
    show_letter_boundry = slb
    @raylib.end_shader_mode()
    @raylib.end_mode_3d()

    // Draw 2D info text & stats
    @raylib.draw_text(
      "Drag & drop a font file to change the font!\nType something, see what happens!\n\nPress [F3] to toggle the camera",
      10, 35, 10, @raylib.black,
    )
    let codepoints_len = @raylib.load_codepoints(text).length()
    quads = quads + codepoints_len * 2 * layers
    let camera_str = if spin { "ORBITAL" } else { "FREE" }
    let stats_text = layers.to_string() +
      " layer(s) | " +
      camera_str +
      " camera | " +
      quads.to_string() +
      " quads (" +
      (quads * 4).to_string() +
      " verts)"
    let stats_width = @raylib.measure_text(stats_text, 10)
    @raylib.draw_text(
      stats_text,
      screen_width - 20 - stats_width,
      10,
      10,
      @raylib.darkgreen,
    )
    let help1 = "[Home]/[End] to add/remove 3D text layers"
    let help1_w = @raylib.measure_text(help1, 10)
    @raylib.draw_text(
      help1,
      screen_width - 20 - help1_w,
      25,
      10,
      @raylib.darkgray,
    )
    let help2 = "[Insert]/[Delete] to increase/decrease distance between layers"
    let help2_w = @raylib.measure_text(help2, 10)
    @raylib.draw_text(
      help2,
      screen_width - 20 - help2_w,
      40,
      10,
      @raylib.darkgray,
    )
    let help3 = "click the [CUBE] for a random color"
    let help3_w = @raylib.measure_text(help3, 10)
    @raylib.draw_text(
      help3,
      screen_width - 20 - help3_w,
      55,
      10,
      @raylib.darkgray,
    )
    let help4 = "[Tab] to toggle multicolor mode"
    let help4_w = @raylib.measure_text(help4, 10)
    @raylib.draw_text(
      help4,
      screen_width - 20 - help4_w,
      70,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_font(font)
  @raylib.close_window()
}
