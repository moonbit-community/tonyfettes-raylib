///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - first person maze",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.2, 0.4, 0.2),
    @raylib.Vector3::new(0.185, 0.4, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load cubicmap image (RAM)
  // NOTE: Requires resources/cubicmap.png and resources/cubicmap_atlas.png
  // to be placed in the example directory.
  let _ = @raylib.change_directory("examples/raylib_models_first_person_maze")
  let im_map = @raylib.load_image("resources/cubicmap.png")
  let cubicmap = @raylib.load_texture_from_image(im_map)
  let map_width = @raylib.image_width(im_map)
  let map_height = @raylib.image_height(im_map)
  let mesh = @raylib.gen_mesh_cubicmap(
    im_map,
    @raylib.Vector3::new(1.0, 1.0, 1.0),
  )
  let model = @raylib.load_model_from_mesh(mesh)

  // Load map texture
  let texture = @raylib.load_texture("resources/cubicmap_atlas.png")
  @raylib.set_model_material_texture(
    model,
    0,
    @raylib.MaterialMapAlbedo,
    texture,
  )

  let map_position = @raylib.Vector3::new(-16.0, 0.0, -8.0)

  @raylib.disable_cursor()
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Store old camera position
    let old_cam_pos = camera.position

    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraFirstPerson)

    // Check player collision (we simplify to 2D collision detection)
    let player_pos_x = camera.position.x
    let player_pos_z = camera.position.z
    let player_radius : Float = 0.1

    let mut player_cell_x = (player_pos_x - map_position.x + 0.5).to_int()
    let mut player_cell_y = (player_pos_z - map_position.z + 0.5).to_int()

    // Out-of-limits security check
    if player_cell_x < 0 {
      player_cell_x = 0
    } else if player_cell_x >= map_width {
      player_cell_x = map_width - 1
    }
    if player_cell_y < 0 {
      player_cell_y = 0
    } else if player_cell_y >= map_height {
      player_cell_y = map_height - 1
    }

    // Check map collisions using image data and player position
    for y = player_cell_y - 1; y <= player_cell_y + 1; y = y + 1 {
      if y >= 0 && y < map_height {
        for x = player_cell_x - 1; x <= player_cell_x + 1; x = x + 1 {
          if x >= 0 && x < map_width {
            // Check R channel for white pixel (wall)
            let pixel = @raylib.get_image_color(im_map, x, y)
            if pixel.r == b'\xFF' {
              // Check collision with this cell
              let cell_rec = @raylib.Rectangle::new(
                map_position.x - 0.5 + Float::from_int(x) * 1.0,
                map_position.z - 0.5 + Float::from_int(y) * 1.0,
                1.0,
                1.0,
              )
              if @raylib.check_collision_circle_rec(
                  @raylib.Vector2::new(player_pos_x, player_pos_z),
                  player_radius,
                  cell_rec,
                ) {
                // Collision detected, reset camera position
                camera = @raylib.Camera3D::new(
                  old_cam_pos,
                  camera.target,
                  camera.up,
                  camera.fovy,
                  camera.projection,
                )
              }
            }
          }
        }
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_model(model, map_position, 1.0, @raylib.white)
    @raylib.end_mode_3d()

    // Draw minimap
    let minimap_x = @raylib.get_screen_width() - map_width * 4 - 20
    @raylib.draw_texture_ex(
      cubicmap,
      @raylib.Vector2::new(Float::from_int(minimap_x), 20.0),
      0.0,
      4.0,
      @raylib.white,
    )
    @raylib.draw_rectangle_lines(
      minimap_x,
      20,
      map_width * 4,
      map_height * 4,
      @raylib.green,
    )

    // Draw player position radar
    @raylib.draw_rectangle(
      minimap_x + player_cell_x * 4,
      20 + player_cell_y * 4,
      4,
      4,
      @raylib.red,
    )

    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_image(im_map)
  @raylib.unload_texture(cubicmap)
  @raylib.unload_texture(texture)
  @raylib.unload_model(model)
  @raylib.close_window()
}
