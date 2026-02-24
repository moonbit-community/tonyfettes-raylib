// Draw cube textured
// NOTE: Cube position is the center position

///|
fn draw_cube_texture(
  texture : @raylib.Texture,
  position : @raylib.Vector3,
  width : Float,
  height : Float,
  length : Float,
  color : @raylib.Color,
) -> Unit {
  let x = position.x
  let y = position.y
  let z = position.z

  // Set desired texture to be enabled while drawing following vertex data
  @raylib.rl_set_texture(@raylib.get_texture_id(texture).reinterpret_as_uint())

  @raylib.rl_begin(@raylib.RlQuads)
  @raylib.rl_color4ub(color.r, color.g, color.b, color.a)

  // Front Face
  @raylib.rl_normal3f(0.0, 0.0, 1.0)
  @raylib.rl_tex_coord2f(0.0, 0.0)
  @raylib.rl_vertex3f(x - width / 2.0, y - height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(1.0, 0.0)
  @raylib.rl_vertex3f(x + width / 2.0, y - height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(1.0, 1.0)
  @raylib.rl_vertex3f(x + width / 2.0, y + height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(0.0, 1.0)
  @raylib.rl_vertex3f(x - width / 2.0, y + height / 2.0, z + length / 2.0)

  // Back Face
  @raylib.rl_normal3f(0.0, 0.0, -1.0)
  @raylib.rl_tex_coord2f(1.0, 0.0)
  @raylib.rl_vertex3f(x - width / 2.0, y - height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(1.0, 1.0)
  @raylib.rl_vertex3f(x - width / 2.0, y + height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(0.0, 1.0)
  @raylib.rl_vertex3f(x + width / 2.0, y + height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(0.0, 0.0)
  @raylib.rl_vertex3f(x + width / 2.0, y - height / 2.0, z - length / 2.0)

  // Top Face
  @raylib.rl_normal3f(0.0, 1.0, 0.0)
  @raylib.rl_tex_coord2f(0.0, 1.0)
  @raylib.rl_vertex3f(x - width / 2.0, y + height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(0.0, 0.0)
  @raylib.rl_vertex3f(x - width / 2.0, y + height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(1.0, 0.0)
  @raylib.rl_vertex3f(x + width / 2.0, y + height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(1.0, 1.0)
  @raylib.rl_vertex3f(x + width / 2.0, y + height / 2.0, z - length / 2.0)

  // Bottom Face
  @raylib.rl_normal3f(0.0, -1.0, 0.0)
  @raylib.rl_tex_coord2f(1.0, 1.0)
  @raylib.rl_vertex3f(x - width / 2.0, y - height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(0.0, 1.0)
  @raylib.rl_vertex3f(x + width / 2.0, y - height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(0.0, 0.0)
  @raylib.rl_vertex3f(x + width / 2.0, y - height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(1.0, 0.0)
  @raylib.rl_vertex3f(x - width / 2.0, y - height / 2.0, z + length / 2.0)

  // Right Face
  @raylib.rl_normal3f(1.0, 0.0, 0.0)
  @raylib.rl_tex_coord2f(1.0, 0.0)
  @raylib.rl_vertex3f(x + width / 2.0, y - height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(1.0, 1.0)
  @raylib.rl_vertex3f(x + width / 2.0, y + height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(0.0, 1.0)
  @raylib.rl_vertex3f(x + width / 2.0, y + height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(0.0, 0.0)
  @raylib.rl_vertex3f(x + width / 2.0, y - height / 2.0, z + length / 2.0)

  // Left Face
  @raylib.rl_normal3f(-1.0, 0.0, 0.0)
  @raylib.rl_tex_coord2f(0.0, 0.0)
  @raylib.rl_vertex3f(x - width / 2.0, y - height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(1.0, 0.0)
  @raylib.rl_vertex3f(x - width / 2.0, y - height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(1.0, 1.0)
  @raylib.rl_vertex3f(x - width / 2.0, y + height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(0.0, 1.0)
  @raylib.rl_vertex3f(x - width / 2.0, y + height / 2.0, z - length / 2.0)

  @raylib.rl_end()

  @raylib.rl_set_texture(0)
}

// Draw cube with texture piece applied to all faces

///|
fn draw_cube_texture_rec(
  texture : @raylib.Texture,
  source : @raylib.Rectangle,
  position : @raylib.Vector3,
  width : Float,
  height : Float,
  length : Float,
  color : @raylib.Color,
) -> Unit {
  let x = position.x
  let y = position.y
  let z = position.z
  let tex_width = Float::from_int(@raylib.get_texture_width(texture))
  let tex_height = Float::from_int(@raylib.get_texture_height(texture))

  // Set desired texture to be enabled while drawing following vertex data
  @raylib.rl_set_texture(@raylib.get_texture_id(texture).reinterpret_as_uint())

  // We calculate the normalized texture coordinates for the desired texture-source-rectangle
  // It means converting from (tex.width, tex.height) coordinates to [0.0, 1.0] equivalent
  @raylib.rl_begin(@raylib.RlQuads)
  @raylib.rl_color4ub(color.r, color.g, color.b, color.a)

  // Front face
  @raylib.rl_normal3f(0.0, 0.0, 1.0)
  @raylib.rl_tex_coord2f(
    source.x / tex_width,
    (source.y + source.height) / tex_height,
  )
  @raylib.rl_vertex3f(x - width / 2.0, y - height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(
    (source.x + source.width) / tex_width,
    (source.y + source.height) / tex_height,
  )
  @raylib.rl_vertex3f(x + width / 2.0, y - height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(
    (source.x + source.width) / tex_width,
    source.y / tex_height,
  )
  @raylib.rl_vertex3f(x + width / 2.0, y + height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(source.x / tex_width, source.y / tex_height)
  @raylib.rl_vertex3f(x - width / 2.0, y + height / 2.0, z + length / 2.0)

  // Back face
  @raylib.rl_normal3f(0.0, 0.0, -1.0)
  @raylib.rl_tex_coord2f(
    (source.x + source.width) / tex_width,
    (source.y + source.height) / tex_height,
  )
  @raylib.rl_vertex3f(x - width / 2.0, y - height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(
    (source.x + source.width) / tex_width,
    source.y / tex_height,
  )
  @raylib.rl_vertex3f(x - width / 2.0, y + height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(source.x / tex_width, source.y / tex_height)
  @raylib.rl_vertex3f(x + width / 2.0, y + height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(
    source.x / tex_width,
    (source.y + source.height) / tex_height,
  )
  @raylib.rl_vertex3f(x + width / 2.0, y - height / 2.0, z - length / 2.0)

  // Top face
  @raylib.rl_normal3f(0.0, 1.0, 0.0)
  @raylib.rl_tex_coord2f(source.x / tex_width, source.y / tex_height)
  @raylib.rl_vertex3f(x - width / 2.0, y + height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(
    source.x / tex_width,
    (source.y + source.height) / tex_height,
  )
  @raylib.rl_vertex3f(x - width / 2.0, y + height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(
    (source.x + source.width) / tex_width,
    (source.y + source.height) / tex_height,
  )
  @raylib.rl_vertex3f(x + width / 2.0, y + height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(
    (source.x + source.width) / tex_width,
    source.y / tex_height,
  )
  @raylib.rl_vertex3f(x + width / 2.0, y + height / 2.0, z - length / 2.0)

  // Bottom face
  @raylib.rl_normal3f(0.0, -1.0, 0.0)
  @raylib.rl_tex_coord2f(
    (source.x + source.width) / tex_width,
    source.y / tex_height,
  )
  @raylib.rl_vertex3f(x - width / 2.0, y - height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(source.x / tex_width, source.y / tex_height)
  @raylib.rl_vertex3f(x + width / 2.0, y - height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(
    source.x / tex_width,
    (source.y + source.height) / tex_height,
  )
  @raylib.rl_vertex3f(x + width / 2.0, y - height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(
    (source.x + source.width) / tex_width,
    (source.y + source.height) / tex_height,
  )
  @raylib.rl_vertex3f(x - width / 2.0, y - height / 2.0, z + length / 2.0)

  // Right face
  @raylib.rl_normal3f(1.0, 0.0, 0.0)
  @raylib.rl_tex_coord2f(
    (source.x + source.width) / tex_width,
    (source.y + source.height) / tex_height,
  )
  @raylib.rl_vertex3f(x + width / 2.0, y - height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(
    (source.x + source.width) / tex_width,
    source.y / tex_height,
  )
  @raylib.rl_vertex3f(x + width / 2.0, y + height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(source.x / tex_width, source.y / tex_height)
  @raylib.rl_vertex3f(x + width / 2.0, y + height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(
    source.x / tex_width,
    (source.y + source.height) / tex_height,
  )
  @raylib.rl_vertex3f(x + width / 2.0, y - height / 2.0, z + length / 2.0)

  // Left face
  @raylib.rl_normal3f(-1.0, 0.0, 0.0)
  @raylib.rl_tex_coord2f(
    source.x / tex_width,
    (source.y + source.height) / tex_height,
  )
  @raylib.rl_vertex3f(x - width / 2.0, y - height / 2.0, z - length / 2.0)
  @raylib.rl_tex_coord2f(
    (source.x + source.width) / tex_width,
    (source.y + source.height) / tex_height,
  )
  @raylib.rl_vertex3f(x - width / 2.0, y - height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(
    (source.x + source.width) / tex_width,
    source.y / tex_height,
  )
  @raylib.rl_vertex3f(x - width / 2.0, y + height / 2.0, z + length / 2.0)
  @raylib.rl_tex_coord2f(source.x / tex_width, source.y / tex_height)
  @raylib.rl_vertex3f(x - width / 2.0, y + height / 2.0, z - length / 2.0)

  @raylib.rl_end()

  @raylib.rl_set_texture(0)
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - draw cube texture",
  )

  // Define the camera to look into our 3d world
  let camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 10.0, 10.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load texture to be applied to the cubes sides
  let texture = @raylib.load_texture("resources/cubicmap_atlas.png")

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_mode_3d(camera)

    // Draw cube with an applied texture
    draw_cube_texture(
      texture,
      @raylib.Vector3::new(-2.0, 2.0, 0.0),
      2.0,
      4.0,
      2.0,
      @raylib.white,
    )

    // Draw cube with an applied texture, but only a defined rectangle piece of the texture
    draw_cube_texture_rec(
      texture,
      @raylib.Rectangle::new(
        0.0,
        Float::from_int(@raylib.get_texture_height(texture)) / 2.0,
        Float::from_int(@raylib.get_texture_width(texture)) / 2.0,
        Float::from_int(@raylib.get_texture_height(texture)) / 2.0,
      ),
      @raylib.Vector3::new(2.0, 1.0, 0.0),
      2.0,
      2.0,
      2.0,
      @raylib.white,
    )

    @raylib.draw_grid(10, 1.0)

    @raylib.end_mode_3d()

    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(texture)
  @raylib.close_window()
}
