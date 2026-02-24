///|
let deg2rad : Float = 0.017453292519943295

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - plane rotations (yaw, pitch, roll)",
  )
  let _ = @raylib.change_directory("examples/raylib_models_yaw_pitch_roll")
  let camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 50.0, -120.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    30.0,
    @raylib.CameraPerspective,
  )
  // Load model
  let model = @raylib.load_model("resources/models/obj/plane.obj")
  // Load model texture
  let texture = @raylib.load_texture("resources/models/obj/plane_diffuse.png")
  // Set map diffuse texture
  @raylib.set_model_material_texture(
    model,
    0,
    @raylib.MaterialMapAlbedo,
    texture,
  )
  let mut pitch : Float = 0.0
  let mut roll : Float = 0.0
  let mut yaw : Float = 0.0
  @raylib.set_target_fps(60)
  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // Plane pitch (x-axis) controls
    if @raylib.is_key_down(@raylib.KeyDown) {
      pitch += 0.6
    } else if @raylib.is_key_down(@raylib.KeyUp) {
      pitch -= 0.6
    } else if pitch > 0.3 {
      pitch -= 0.3
    } else if pitch < -0.3 {
      pitch += 0.3
    }
    // Plane yaw (y-axis) controls
    if @raylib.is_key_down(@raylib.KeyS) {
      yaw -= 1.0
    } else if @raylib.is_key_down(@raylib.KeyA) {
      yaw += 1.0
    } else if yaw > 0.0 {
      yaw -= 0.5
    } else if yaw < 0.0 {
      yaw += 0.5
    }
    // Plane roll (z-axis) controls
    if @raylib.is_key_down(@raylib.KeyLeft) {
      roll -= 1.0
    } else if @raylib.is_key_down(@raylib.KeyRight) {
      roll += 1.0
    } else if roll > 0.0 {
      roll -= 0.5
    } else if roll < 0.0 {
      roll += 0.5
    }
    // Transformation matrix for rotations
    @raylib.set_model_transform(
      model,
      @raylib.Matrix::rotate_xyz(
        @raylib.Vector3::new(deg2rad * pitch, deg2rad * yaw, deg2rad * roll),
      ),
    )
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    // Draw 3D model (recommended to draw 3D always before 2D)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_model(
      model,
      @raylib.Vector3::new(0.0, -8.0, 0.0),
      1.0,
      @raylib.white,
    )
    @raylib.draw_grid(10, 10.0)
    @raylib.end_mode_3d()
    // Draw controls info
    @raylib.draw_rectangle(30, 370, 260, 70, @raylib.fade(@raylib.green, 0.5))
    @raylib.draw_rectangle_lines(
      30,
      370,
      260,
      70,
      @raylib.fade(@raylib.darkgreen, 0.5),
    )
    @raylib.draw_text(
      "Pitch controlled with: KEY_UP / KEY_DOWN", 40, 380, 10, @raylib.darkgray,
    )
    @raylib.draw_text(
      "Roll controlled with: KEY_LEFT / KEY_RIGHT", 40, 400, 10, @raylib.darkgray,
    )
    @raylib.draw_text(
      "Yaw controlled with: KEY_A / KEY_S", 40, 420, 10, @raylib.darkgray,
    )
    @raylib.draw_text(
      "(c) WWI Plane Model created by GiaHanLam",
      screen_width - 240,
      screen_height - 20,
      10,
      @raylib.darkgray,
    )
    @raylib.end_drawing()
  }
  // De-Initialization
  @raylib.unload_model(model)
  @raylib.unload_texture(texture)
  @raylib.close_window()
}
