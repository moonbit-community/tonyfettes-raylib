///|
let deg2rad : Float = 3.14159265358979323846 / 180.0

// Draw sphere without any matrix transformation
// NOTE: Sphere is drawn in world position (0, 0, 0) with radius 1.0

///|
fn draw_sphere_basic(color : @raylib.Color) -> Unit {
  let rings = 16
  let slices = 16

  // Make sure there is enough space in the internal render batch
  // buffer to store all required vertex, batch is reseted if required
  let _ = @rl.check_render_batch_limit((rings + 2) * slices * 6)

  @rl.begin(@rl.Triangles)
  @rl.color4ub(color.r, color.g, color.b, color.a)

  for i = 0; i < rings + 2; i = i + 1 {
    for j = 0; j < slices; j = j + 1 {
      let fi = Float::from_int(i)
      let fj = Float::from_int(j)
      let fi1 = Float::from_int(i + 1)
      let fj1 = Float::from_int(j + 1)
      let fslices = Float::from_int(slices)
      let frings1 = Float::from_int(rings + 1)

      @rl.vertex3f(
        @math.cosf(deg2rad * (270.0 + 180.0 / frings1 * fi)) *
        @math.sinf(deg2rad * (fj * 360.0 / fslices)),
        @math.sinf(deg2rad * (270.0 + 180.0 / frings1 * fi)),
        @math.cosf(deg2rad * (270.0 + 180.0 / frings1 * fi)) *
        @math.cosf(deg2rad * (fj * 360.0 / fslices)),
      )
      @rl.vertex3f(
        @math.cosf(deg2rad * (270.0 + 180.0 / frings1 * fi1)) *
        @math.sinf(deg2rad * (fj1 * 360.0 / fslices)),
        @math.sinf(deg2rad * (270.0 + 180.0 / frings1 * fi1)),
        @math.cosf(deg2rad * (270.0 + 180.0 / frings1 * fi1)) *
        @math.cosf(deg2rad * (fj1 * 360.0 / fslices)),
      )
      @rl.vertex3f(
        @math.cosf(deg2rad * (270.0 + 180.0 / frings1 * fi1)) *
        @math.sinf(deg2rad * (fj * 360.0 / fslices)),
        @math.sinf(deg2rad * (270.0 + 180.0 / frings1 * fi1)),
        @math.cosf(deg2rad * (270.0 + 180.0 / frings1 * fi1)) *
        @math.cosf(deg2rad * (fj * 360.0 / fslices)),
      )

      @rl.vertex3f(
        @math.cosf(deg2rad * (270.0 + 180.0 / frings1 * fi)) *
        @math.sinf(deg2rad * (fj * 360.0 / fslices)),
        @math.sinf(deg2rad * (270.0 + 180.0 / frings1 * fi)),
        @math.cosf(deg2rad * (270.0 + 180.0 / frings1 * fi)) *
        @math.cosf(deg2rad * (fj * 360.0 / fslices)),
      )
      @rl.vertex3f(
        @math.cosf(deg2rad * (270.0 + 180.0 / frings1 * fi)) *
        @math.sinf(deg2rad * (fj1 * 360.0 / fslices)),
        @math.sinf(deg2rad * (270.0 + 180.0 / frings1 * fi)),
        @math.cosf(deg2rad * (270.0 + 180.0 / frings1 * fi)) *
        @math.cosf(deg2rad * (fj1 * 360.0 / fslices)),
      )
      @rl.vertex3f(
        @math.cosf(deg2rad * (270.0 + 180.0 / frings1 * fi1)) *
        @math.sinf(deg2rad * (fj1 * 360.0 / fslices)),
        @math.sinf(deg2rad * (270.0 + 180.0 / frings1 * fi1)),
        @math.cosf(deg2rad * (270.0 + 180.0 / frings1 * fi1)) *
        @math.cosf(deg2rad * (fj1 * 360.0 / fslices)),
      )
    }
  }
  @rl.end_()
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let sun_radius : Float = 4.0
  let earth_radius : Float = 0.6
  let earth_orbit_radius : Float = 8.0
  let moon_radius : Float = 0.16
  let moon_orbit_radius : Float = 1.5

  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - rlgl module usage with push/pop matrix transformations",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(16.0, 16.0, 16.0), // position
    @raylib.Vector3::new(0.0, 0.0, 0.0), // target
    @raylib.Vector3::new(0.0, 1.0, 0.0), // up
    45.0, // fovy
    @raylib.CameraPerspective, // projection
  )

  let rotation_speed : Float = 0.2

  let mut earth_rotation : Float = 0.0
  let mut earth_orbit_rotation : Float = 0.0
  let mut moon_rotation : Float = 0.0
  let mut moon_orbit_rotation : Float = 0.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)

    earth_rotation += 5.0 * rotation_speed
    earth_orbit_rotation += 365.0 /
      360.0 *
      (5.0 * rotation_speed) *
      rotation_speed
    moon_rotation += 2.0 * rotation_speed
    moon_orbit_rotation += 8.0 * rotation_speed

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_mode_3d(camera)

    @rl.push_matrix()
    @rl.scalef(sun_radius, sun_radius, sun_radius) // Scale Sun
    draw_sphere_basic(@raylib.gold) // Draw the Sun
    @rl.pop_matrix()

    @rl.push_matrix()
    @rl.rotatef(earth_orbit_rotation, 0.0, 1.0, 0.0) // Rotation for Earth orbit around Sun
    @rl.translatef(earth_orbit_radius, 0.0, 0.0) // Translation for Earth orbit

    @rl.push_matrix()
    @rl.rotatef(earth_rotation, 0.25, 1.0, 0.0) // Rotation for Earth itself
    @rl.scalef(earth_radius, earth_radius, earth_radius) // Scale Earth
    draw_sphere_basic(@raylib.blue) // Draw the Earth
    @rl.pop_matrix()

    @rl.rotatef(moon_orbit_rotation, 0.0, 1.0, 0.0) // Rotation for Moon orbit around Earth
    @rl.translatef(moon_orbit_radius, 0.0, 0.0) // Translation for Moon orbit
    @rl.rotatef(moon_rotation, 0.0, 1.0, 0.0) // Rotation for Moon itself
    @rl.scalef(moon_radius, moon_radius, moon_radius) // Scale Moon
    draw_sphere_basic(@raylib.lightgray) // Draw the Moon
    @rl.pop_matrix()

    // Some reference elements (not affected by previous matrix transformations)
    @raylib.draw_circle_3d(
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      earth_orbit_radius,
      @raylib.Vector3::new(1.0, 0.0, 0.0),
      90.0,
      @raylib.fade(@raylib.red, 0.5),
    )
    @raylib.draw_grid(20, 1.0)

    @raylib.end_mode_3d()

    @raylib.draw_text(
      "EARTH ORBITING AROUND THE SUN!", 400, 10, 20, @raylib.maroon,
    )
    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
