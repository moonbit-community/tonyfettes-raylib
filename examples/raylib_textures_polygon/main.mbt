///|
const MaxPoints : Int = 11 // 10 points and back to the start

///|
let deg2rad : Float = 0.017453292519943295

// Draw textured polygon, defined by vertex and texture coordinates
// NOTE: Polygon center must have straight line path to all points
// without crossing perimeter, points must be in anticlockwise order

///|
fn draw_texture_poly(
  texture : @raylib.Texture,
  center : @raylib.Vector2,
  points : FixedArray[@raylib.Vector2],
  texcoords : FixedArray[@raylib.Vector2],
  point_count : Int,
  tint : @raylib.Color,
) -> Unit {
  @rl.set_texture(@raylib.get_texture_id(texture).reinterpret_as_uint())

  // Texturing is only supported on RL_QUADS
  @rl.begin(@rl.Quads)

  @rl.color4ub(tint.r, tint.g, tint.b, tint.a)

  for i = 0; i < point_count - 1; i = i + 1 {
    @rl.tex_coord2f(0.5, 0.5)
    @rl.vertex2f(center.x, center.y)

    @rl.tex_coord2f(texcoords[i].x, texcoords[i].y)
    @rl.vertex2f(points[i].x + center.x, points[i].y + center.y)

    @rl.tex_coord2f(texcoords[i + 1].x, texcoords[i + 1].y)
    @rl.vertex2f(points[i + 1].x + center.x, points[i + 1].y + center.y)

    @rl.tex_coord2f(texcoords[i + 1].x, texcoords[i + 1].y)
    @rl.vertex2f(points[i + 1].x + center.x, points[i + 1].y + center.y)
  }

  @rl.end_()

  @rl.set_texture(0U)
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - textured polygon",
  )

  // Define texture coordinates to map our texture to poly
  let texcoords : FixedArray[@raylib.Vector2] = [
    @raylib.Vector2::new(0.75, 0.0),
    @raylib.Vector2::new(0.25, 0.0),
    @raylib.Vector2::new(0.0, 0.5),
    @raylib.Vector2::new(0.0, 0.75),
    @raylib.Vector2::new(0.25, 1.0),
    @raylib.Vector2::new(0.375, 0.875),
    @raylib.Vector2::new(0.625, 0.875),
    @raylib.Vector2::new(0.75, 1.0),
    @raylib.Vector2::new(1.0, 0.75),
    @raylib.Vector2::new(1.0, 0.5),
    @raylib.Vector2::new(0.75, 0.0), // Close the poly
  ]

  // Define the base poly vertices from the UV's
  // NOTE: They can be specified in any other way
  let points : FixedArray[@raylib.Vector2] = FixedArray::make(
    MaxPoints,
    @raylib.Vector2::new(0.0, 0.0),
  )
  for i = 0; i < MaxPoints; i = i + 1 {
    let x : Float = (texcoords[i].x - 0.5) * 256.0
    let y : Float = (texcoords[i].y - 0.5) * 256.0
    points[i] = @raylib.Vector2::new(x, y)
  }

  // Define the vertices drawing position
  // NOTE: Initially same as points but updated every frame
  let positions : FixedArray[@raylib.Vector2] = FixedArray::make(
    MaxPoints,
    @raylib.Vector2::new(0.0, 0.0),
  )
  for i = 0; i < MaxPoints; i = i + 1 {
    positions[i] = points[i]
  }

  // Load texture to be mapped to poly
  let texture = @raylib.load_texture("resources/cat.png")

  let mut angle : Float = 0.0 // Rotation angle (in degrees)

  @raylib.set_target_fps(60) // Set our game to run at 60 frames-per-second

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // Update points rotation with an angle transform
    // NOTE: Base points position are not modified
    angle = angle + 1.0
    for i = 0; i < MaxPoints; i = i + 1 {
      positions[i] = @raylib.Vector2::rotate(points[i], angle * deg2rad)
    }

    // Draw
    @raylib.begin_drawing()

    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_text("textured polygon", 20, 20, 20, @raylib.darkgray)

    draw_texture_poly(
      texture,
      @raylib.Vector2::new(
        Float::from_int(@raylib.get_screen_width()) / 2.0,
        Float::from_int(@raylib.get_screen_height()) / 2.0,
      ),
      positions,
      texcoords,
      MaxPoints,
      @raylib.white,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(texture) // Unload texture
  @raylib.close_window() // Close window and OpenGL context
}
