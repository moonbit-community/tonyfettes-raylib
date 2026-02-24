///|
const MaxPoints : Int = 10000000 // 10 million

///|
const MinPoints : Int = 1000 // 1 thousand

///|
let pi : Float = 3.14159265358979323846

///|
fn gen_point_cloud(
  num_points : Int,
) -> (Array[@raylib.Vector3], Array[@raylib.Color], @raylib.Mesh) {
  let positions : Array[@raylib.Vector3] = Array::make(
    num_points,
    @raylib.Vector3::new(0.0, 0.0, 0.0),
  )
  let colors : Array[@raylib.Color] = Array::make(
    num_points,
    @raylib.Color::new(0, 0, 0, 0),
  )
  // Build vertex and color byte arrays for mesh creation
  let vert_arr = FixedArray::make(num_points * 3 * 4, b'\x00')
  let col_arr = FixedArray::make(num_points * 4, b'\x00')
  // Spherical coordinate point generation
  // REF: https://en.wikipedia.org/wiki/Spherical_coordinate_system
  for i = 0; i < num_points; i = i + 1 {
    let rand_theta : Float = Float::from_int(
      @raylib.get_random_value(0, 1000000),
    )
    let rand_phi : Float = Float::from_int(@raylib.get_random_value(0, 1000000))
    let rand_r : Float = Float::from_int(@raylib.get_random_value(0, 1000000))
    let theta : Float = pi * rand_theta / (1000000.0 : Float)
    let phi : Float = (2.0 : Float) * pi * rand_phi / (1000000.0 : Float)
    let r : Float = (10.0 : Float) * rand_r / (1000000.0 : Float)
    let x : Float = r * @math.sinf(theta) * @math.cosf(phi)
    let y : Float = r * @math.sinf(theta) * @math.sinf(phi)
    let z : Float = r * @math.cosf(theta)
    positions[i] = @raylib.Vector3::new(x, y, z)
    let color = @raylib.color_from_hsv(
      r * (36.0 : Float),
      (1.0 : Float),
      (1.0 : Float),
    )
    colors[i] = color
    // Write vertex floats (x, y, z) as little-endian bytes
    let xb = x.reinterpret_as_int()
    let yb = y.reinterpret_as_int()
    let zb = z.reinterpret_as_int()
    let base = i * 12
    vert_arr[base] = (xb & 0xFF).to_byte()
    vert_arr[base + 1] = ((xb >> 8) & 0xFF).to_byte()
    vert_arr[base + 2] = ((xb >> 16) & 0xFF).to_byte()
    vert_arr[base + 3] = ((xb >> 24) & 0xFF).to_byte()
    vert_arr[base + 4] = (yb & 0xFF).to_byte()
    vert_arr[base + 5] = ((yb >> 8) & 0xFF).to_byte()
    vert_arr[base + 6] = ((yb >> 16) & 0xFF).to_byte()
    vert_arr[base + 7] = ((yb >> 24) & 0xFF).to_byte()
    vert_arr[base + 8] = (zb & 0xFF).to_byte()
    vert_arr[base + 9] = ((zb >> 8) & 0xFF).to_byte()
    vert_arr[base + 10] = ((zb >> 16) & 0xFF).to_byte()
    vert_arr[base + 11] = ((zb >> 24) & 0xFF).to_byte()
    // Write color bytes (r, g, b, a)
    let cbase = i * 4
    col_arr[cbase] = color.r
    col_arr[cbase + 1] = color.g
    col_arr[cbase + 2] = color.b
    col_arr[cbase + 3] = color.a
  }
  let vert_bytes = FixedArray::unsafe_reinterpret_as_bytes(vert_arr)
  let col_bytes = FixedArray::unsafe_reinterpret_as_bytes(col_arr)
  let mesh = @raylib.gen_mesh_from_points(vert_bytes, col_bytes, num_points)
  (positions, colors, mesh)
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - point rendering",
  )
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(3.0, 3.0, 3.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )
  let position = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let mut use_draw_model_points = true
  let mut num_points_changed = false
  let mut num_points = 1000
  let result = gen_point_cloud(num_points)
  let mut positions = result.0
  let mut colors = result.1
  let mut model = @raylib.load_model_from_mesh(result.2)
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      use_draw_model_points = not(use_draw_model_points)
    }
    if @raylib.is_key_pressed(@raylib.KeyUp) {
      num_points = if num_points * 10 > MaxPoints {
        MaxPoints
      } else {
        num_points * 10
      }
      num_points_changed = true
    }
    if @raylib.is_key_pressed(@raylib.KeyDown) {
      num_points = if num_points / 10 < MinPoints {
        MinPoints
      } else {
        num_points / 10
      }
      num_points_changed = true
    }

    // Upload a different point cloud size
    if num_points_changed {
      @raylib.unload_model(model)
      let new_result = gen_point_cloud(num_points)
      positions = new_result.0
      colors = new_result.1
      model = @raylib.load_model_from_mesh(new_result.2)
      num_points_changed = false
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.black)
    @raylib.begin_mode_3d(camera)

    // The new method only uploads the points once to the GPU
    if use_draw_model_points {
      @raylib.draw_model_points(model, position, (1.0 : Float), @raylib.white)
    } else {
      // The old method must continually draw the "points" (lines)
      for i = 0; i < num_points; i = i + 1 {
        @raylib.draw_point_3d(positions[i], colors[i])
      }
    }

    // Draw a unit sphere for reference
    @raylib.draw_sphere_wires(position, (1.0 : Float), 10, 10, @raylib.yellow)
    @raylib.end_mode_3d()

    // Draw UI text
    @raylib.draw_text(
      "Point Count: " + num_points.to_string(),
      10,
      screen_height - 50,
      40,
      @raylib.white,
    )
    @raylib.draw_text("UP - Increase points", 10, 40, 20, @raylib.white)
    @raylib.draw_text("DOWN - Decrease points", 10, 70, 20, @raylib.white)
    @raylib.draw_text("SPACE - Drawing function", 10, 100, 20, @raylib.white)
    if use_draw_model_points {
      @raylib.draw_text("Using: DrawModelPoints()", 10, 130, 20, @raylib.green)
    } else {
      @raylib.draw_text("Using: DrawPoint3D()", 10, 130, 20, @raylib.red)
    }
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_model(model)
  @raylib.close_window()
}
