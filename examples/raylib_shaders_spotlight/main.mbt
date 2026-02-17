///|
fn float_to_bytes(v : Float) -> Bytes {
  let arr = FixedArray::make(4, b'\x00')
  let bits = v.reinterpret_as_int()
  arr[0] = (bits & 0xFF).to_byte()
  arr[1] = ((bits >> 8) & 0xFF).to_byte()
  arr[2] = ((bits >> 16) & 0xFF).to_byte()
  arr[3] = ((bits >> 24) & 0xFF).to_byte()
  FixedArray::unsafe_reinterpret_as_bytes(arr)
}

///|
fn vec2_to_uniform_bytes(x : Float, y : Float) -> Bytes {
  let arr = FixedArray::make(8, b'\x00')
  let bx = x.reinterpret_as_int()
  arr[0] = (bx & 0xFF).to_byte()
  arr[1] = ((bx >> 8) & 0xFF).to_byte()
  arr[2] = ((bx >> 16) & 0xFF).to_byte()
  arr[3] = ((bx >> 24) & 0xFF).to_byte()
  let by = y.reinterpret_as_int()
  arr[4] = (by & 0xFF).to_byte()
  arr[5] = ((by >> 8) & 0xFF).to_byte()
  arr[6] = ((by >> 16) & 0xFF).to_byte()
  arr[7] = ((by >> 24) & 0xFF).to_byte()
  FixedArray::unsafe_reinterpret_as_bytes(arr)
}

// Spot data

///|
struct Spot {
  mut pos_x : Float
  mut pos_y : Float
  mut speed_x : Float
  mut speed_y : Float
  inner : Float
  radius : Float
  position_loc : Int
  inner_loc : Int
  radius_loc : Int
}

// Star data

///|
struct Star {
  mut pos_x : Float
  mut pos_y : Float
  mut speed_x : Float
  mut speed_y : Float
}

///|
fn abs_float(x : Float) -> Float {
  if x < 0.0 {
    -x
  } else {
    x
  }
}

///|
fn reset_star(star : Star) -> Unit {
  star.pos_x = Float::from_int(@raylib.get_screen_width()) / 2.0
  star.pos_y = Float::from_int(@raylib.get_screen_height()) / 2.0
  star.speed_x = Float::from_int(@raylib.get_random_value(-1000, 1000)) / 100.0
  star.speed_y = Float::from_int(@raylib.get_random_value(-1000, 1000)) / 100.0
  while not(abs_float(star.speed_x) + abs_float(star.speed_y) > 1.0) {
    star.speed_x = Float::from_int(@raylib.get_random_value(-1000, 1000)) /
      100.0
    star.speed_y = Float::from_int(@raylib.get_random_value(-1000, 1000)) /
      100.0
  }
  star.pos_x = star.pos_x + star.speed_x * 8.0
  star.pos_y = star.pos_y + star.speed_y * 8.0
}

///|
fn update_star(star : Star) -> Unit {
  star.pos_x = star.pos_x + star.speed_x
  star.pos_y = star.pos_y + star.speed_y
  if star.pos_x < 0.0 ||
    star.pos_x > Float::from_int(@raylib.get_screen_width()) ||
    star.pos_y < 0.0 ||
    star.pos_y > Float::from_int(@raylib.get_screen_height()) {
    reset_star(star)
  }
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let max_spots = 3
  let max_stars = 400
  let _ = @raylib.change_directory("examples/raylib_shaders_spotlight")
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - spotlight rendering",
  )
  @raylib.hide_cursor()
  let tex_ray = @raylib.load_texture("resources/raysan.png")

  // Initialize stars
  let stars : Array[Star] = Array::make(max_stars, {
    pos_x: 0.0,
    pos_y: 0.0,
    speed_x: 0.0,
    speed_y: 0.0,
  })
  for n = 0; n < max_stars; n = n + 1 {
    stars[n] = { pos_x: 0.0, pos_y: 0.0, speed_x: 0.0, speed_y: 0.0 }
    reset_star(stars[n])
  }

  // Progress all the stars on, so they don't all start in the centre
  let half_width = screen_width / 2
  for m = 0; m < half_width; m = m + 1 {
    for n = 0; n < max_stars; n = n + 1 {
      update_star(stars[n])
    }
  }

  let mut frame_counter = 0

  // Use default vert shader
  let shdr_spot = @raylib.load_shader(
    "", "resources/shaders/glsl330/spotlight.fs",
  )

  // Get the locations of spots in the shader
  let spots : Array[Spot] = []
  for i = 0; i < max_spots; i = i + 1 {
    let idx = i.to_string()
    let pos_name = "spots[" + idx + "].pos"
    let inner_name = "spots[" + idx + "].inner"
    let radius_name = "spots[" + idx + "].radius"
    let position_loc = @raylib.get_shader_location(shdr_spot, pos_name)
    let inner_loc = @raylib.get_shader_location(shdr_spot, inner_name)
    let radius_loc = @raylib.get_shader_location(shdr_spot, radius_name)
    spots.push({
      pos_x: 0.0,
      pos_y: 0.0,
      speed_x: 0.0,
      speed_y: 0.0,
      inner: 0.0,
      radius: 0.0,
      position_loc,
      inner_loc,
      radius_loc,
    })
  }

  // Tell the shader how wide the screen is
  let w_loc = @raylib.get_shader_location(shdr_spot, "screenWidth")
  let sw = Float::from_int(@raylib.get_screen_width())
  @raylib.set_shader_value(
    shdr_spot,
    w_loc,
    float_to_bytes(sw),
    @raylib.ShaderUniformFloat,
  )

  // Randomize the locations and velocities of the spotlights
  for i = 0; i < max_spots; i = i + 1 {
    spots[i].pos_x = Float::from_int(
      @raylib.get_random_value(64, screen_width - 64),
    )
    spots[i].pos_y = Float::from_int(
      @raylib.get_random_value(64, screen_height - 64),
    )
    spots[i].speed_x = 0.0
    spots[i].speed_y = 0.0
    while abs_float(spots[i].speed_x) + abs_float(spots[i].speed_y) <
          (2.0 : Float) {
      spots[i].speed_x = Float::from_int(@raylib.get_random_value(-400, 40)) /
        (25.0 : Float)
      spots[i].speed_y = Float::from_int(@raylib.get_random_value(-400, 40)) /
        (25.0 : Float)
    }
    let inner = (28.0 : Float) * Float::from_int(i + 1)
    let radius = (48.0 : Float) * Float::from_int(i + 1)
    // Use struct update via direct field assignment
    spots[i] = { ..spots[i], inner, radius }
    @raylib.set_shader_value(
      shdr_spot,
      spots[i].position_loc,
      vec2_to_uniform_bytes(spots[i].pos_x, spots[i].pos_y),
      @raylib.ShaderUniformVec2,
    )
    @raylib.set_shader_value(
      shdr_spot,
      spots[i].inner_loc,
      float_to_bytes(spots[i].inner),
      @raylib.ShaderUniformFloat,
    )
    @raylib.set_shader_value(
      shdr_spot,
      spots[i].radius_loc,
      float_to_bytes(spots[i].radius),
      @raylib.ShaderUniformFloat,
    )
  }

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    frame_counter += 1

    // Move the stars, resetting them if they go offscreen
    for n = 0; n < max_stars; n = n + 1 {
      update_star(stars[n])
    }

    // Update the spots, send them to the shader
    for i = 0; i < max_spots; i = i + 1 {
      if i == 0 {
        let mp = @raylib.get_mouse_position()
        spots[i].pos_x = mp.x
        spots[i].pos_y = Float::from_int(screen_height) - mp.y
      } else {
        spots[i].pos_x = spots[i].pos_x + spots[i].speed_x
        spots[i].pos_y = spots[i].pos_y + spots[i].speed_y
        if spots[i].pos_x < 64.0 {
          spots[i].speed_x = -spots[i].speed_x
        }
        if spots[i].pos_x > Float::from_int(screen_width - 64) {
          spots[i].speed_x = -spots[i].speed_x
        }
        if spots[i].pos_y < 64.0 {
          spots[i].speed_y = -spots[i].speed_y
        }
        if spots[i].pos_y > Float::from_int(screen_height - 64) {
          spots[i].speed_y = -spots[i].speed_y
        }
      }
      @raylib.set_shader_value(
        shdr_spot,
        spots[i].position_loc,
        vec2_to_uniform_bytes(spots[i].pos_x, spots[i].pos_y),
        @raylib.ShaderUniformVec2,
      )
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.darkblue)

    // Draw stars and bobs
    for n = 0; n < max_stars; n = n + 1 {
      @raylib.draw_rectangle(
        stars[n].pos_x.to_int(),
        stars[n].pos_y.to_int(),
        2,
        2,
        @raylib.white,
      )
    }
    let sw_f = Float::from_int(screen_width)
    let sh_f = Float::from_int(screen_height)
    for i = 0; i < 16; i = i + 1 {
      let fi = Float::from_int(frame_counter + i * 8)
      let cos_val = Float::from_double(@math.cos(fi.to_double() / 51.45))
      let sin_val = Float::from_double(@math.sin(fi.to_double() / 17.87))
      let tx = (sw_f / (2.0 : Float) +
      cos_val * (sw_f / (2.2 : Float)) -
      (32.0 : Float)).to_int()
      let ty = (sh_f / (2.0 : Float) + sin_val * (sh_f / (4.2 : Float))).to_int()
      @raylib.draw_texture(tex_ray, tx, ty, @raylib.white)
    }

    // Draw spot lights
    @raylib.begin_shader_mode(shdr_spot)
    @raylib.draw_rectangle(0, 0, screen_width, screen_height, @raylib.white)
    @raylib.end_shader_mode()
    @raylib.draw_fps(10, 10)
    @raylib.draw_text("Move the mouse!", 10, 30, 20, @raylib.green)
    @raylib.draw_text(
      "Pitch Black",
      (Float::from_int(screen_width) * 0.2).to_int(),
      screen_height / 2,
      20,
      @raylib.green,
    )
    @raylib.draw_text(
      "Dark",
      (Float::from_int(screen_width) * 0.66).to_int(),
      screen_height / 2,
      20,
      @raylib.green,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(tex_ray)
  @raylib.unload_shader(shdr_spot)
  @raylib.close_window()
}
