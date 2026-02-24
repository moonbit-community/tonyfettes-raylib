///|
let flt_max : Float = 340282346638528859811704183484516925440.0

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - mesh picking",
  )
  let _ = @raylib.change_directory("examples/raylib_models_mesh_picking")
  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(20.0, 20.0, 20.0),
    @raylib.Vector3::new(0.0, 8.0, 0.0),
    @raylib.Vector3::new(0.0, 1.6, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )
  // Load OBJ model
  let tower = @raylib.load_model("resources/models/obj/turret.obj")
  let texture = @raylib.load_texture("resources/models/obj/turret_diffuse.png")
  @raylib.set_model_material_texture(
    tower,
    0,
    @raylib.MaterialMapAlbedo,
    texture,
  )
  let tower_pos = @raylib.Vector3::new(0.0, 0.0, 0.0)
  // Get mesh bounding box (using the first mesh)
  let mesh0 = @raylib.get_model_mesh(tower, 0)
  let tower_bbox = @raylib.get_mesh_bounding_box(mesh0)
  // Ground quad
  let g0 = @raylib.Vector3::new(-50.0, 0.0, -50.0)
  let g1 = @raylib.Vector3::new(-50.0, 0.0, 50.0)
  let g2 = @raylib.Vector3::new(50.0, 0.0, 50.0)
  let g3 = @raylib.Vector3::new(50.0, 0.0, -50.0)
  // Test triangle
  let ta = @raylib.Vector3::new(-25.0, 0.5, 0.0)
  let tb = @raylib.Vector3::new(-4.0, 2.5, 1.0)
  let tc = @raylib.Vector3::new(-8.0, 6.5, 0.0)
  let mut bary = @raylib.Vector3::new(0.0, 0.0, 0.0)
  // Test sphere
  let sp = @raylib.Vector3::new(-30.0, 5.0, 5.0)
  let sr : Float = 4.0
  @raylib.set_target_fps(60)
  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_cursor_hidden() {
      camera = @raylib.update_camera(camera, @raylib.CameraFirstPerson)
    }
    // Toggle camera controls
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
      if @raylib.is_cursor_hidden() {
        @raylib.enable_cursor()
      } else {
        @raylib.disable_cursor()
      }
    }
    // Display information about closest hit
    let mut collision = @raylib.RayCollision::new(
      false,
      flt_max,
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.Vector3::new(0.0, 0.0, 0.0),
    )
    let mut hit_object_name = "None"
    let mut cursor_color = @raylib.white
    // Get ray and test against objects
    let ray = @raylib.get_screen_to_world_ray(
      @raylib.get_mouse_position(),
      camera,
    )
    // Check ray collision against ground quad
    let ground_hit_info = @raylib.get_ray_collision_quad(ray, g0, g1, g2, g3)
    if ground_hit_info.hit && ground_hit_info.distance < collision.distance {
      collision = ground_hit_info
      cursor_color = @raylib.green
      hit_object_name = "Ground"
    }
    // Check ray collision against test triangle
    let tri_hit_info = @raylib.get_ray_collision_triangle(ray, ta, tb, tc)
    if tri_hit_info.hit && tri_hit_info.distance < collision.distance {
      collision = tri_hit_info
      cursor_color = @raylib.purple
      hit_object_name = "Triangle"
      bary = @raylib.Vector3::barycenter(collision.point, ta, tb, tc)
    }
    // Check ray collision against test sphere
    let sphere_hit_info = @raylib.get_ray_collision_sphere(ray, sp, sr)
    if sphere_hit_info.hit && sphere_hit_info.distance < collision.distance {
      collision = sphere_hit_info
      cursor_color = @raylib.orange
      hit_object_name = "Sphere"
    }
    // Check ray collision against bounding box first
    let box_hit_info = @raylib.get_ray_collision_box(ray, tower_bbox)
    if box_hit_info.hit && box_hit_info.distance < collision.distance {
      collision = box_hit_info
      cursor_color = @raylib.orange
      hit_object_name = "Box"
      // Check ray collision against model meshes
      let mesh_count = @raylib.get_model_mesh_count(tower)
      let transform = @raylib.get_model_transform(tower)
      for m = 0; m < mesh_count; m = m + 1 {
        let mesh_i = @raylib.get_model_mesh(tower, m)
        let mesh_hit_info = @raylib.get_ray_collision_mesh(
          ray, mesh_i, transform,
        )
        if mesh_hit_info.hit {
          if not(collision.hit) || collision.distance > mesh_hit_info.distance {
            collision = mesh_hit_info
          }
          cursor_color = @raylib.orange
          hit_object_name = "Mesh"
          break
        }
      }
    }
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    // Draw the tower
    @raylib.draw_model(tower, tower_pos, 1.0, @raylib.white)
    // Draw the test triangle
    @raylib.draw_line_3d(ta, tb, @raylib.purple)
    @raylib.draw_line_3d(tb, tc, @raylib.purple)
    @raylib.draw_line_3d(tc, ta, @raylib.purple)
    // Draw the test sphere
    @raylib.draw_sphere_wires(sp, sr, 8, 8, @raylib.purple)
    // Draw the mesh bbox if we hit it
    if box_hit_info.hit {
      @raylib.draw_bounding_box(tower_bbox, @raylib.lime)
    }
    // If we hit something, draw the cursor at the hit point
    if collision.hit {
      @raylib.draw_cube(collision.point, 0.3, 0.3, 0.3, cursor_color)
      @raylib.draw_cube_wires(collision.point, 0.3, 0.3, 0.3, @raylib.red)
      let normal_end = @raylib.Vector3::new(
        collision.point.x + collision.normal.x,
        collision.point.y + collision.normal.y,
        collision.point.z + collision.normal.z,
      )
      @raylib.draw_line_3d(collision.point, normal_end, @raylib.red)
    }
    @raylib.draw_ray(ray, @raylib.maroon)
    @raylib.draw_grid(10, 10.0)
    @raylib.end_mode_3d()
    // Draw some debug GUI text
    @raylib.draw_text(
      "Hit Object: " + hit_object_name,
      10,
      50,
      10,
      @raylib.black,
    )
    if collision.hit {
      let ypos = 70
      @raylib.draw_text(
        "Distance: " + format_float(collision.distance),
        10,
        ypos,
        10,
        @raylib.black,
      )
      @raylib.draw_text(
        "Hit Pos: " +
        format_float(collision.point.x) +
        " " +
        format_float(collision.point.y) +
        " " +
        format_float(collision.point.z),
        10,
        ypos + 15,
        10,
        @raylib.black,
      )
      @raylib.draw_text(
        "Hit Norm: " +
        format_float(collision.normal.x) +
        " " +
        format_float(collision.normal.y) +
        " " +
        format_float(collision.normal.z),
        10,
        ypos + 30,
        10,
        @raylib.black,
      )
      if tri_hit_info.hit && hit_object_name == "Triangle" {
        @raylib.draw_text(
          "Barycenter: " +
          format_float(bary.x) +
          " " +
          format_float(bary.y) +
          " " +
          format_float(bary.z),
          10,
          ypos + 45,
          10,
          @raylib.black,
        )
      }
    }
    @raylib.draw_text(
      "Right click mouse to toggle camera controls", 10, 430, 10, @raylib.gray,
    )
    @raylib.draw_text(
      "(c) Turret 3D model by Alberto Cano",
      screen_width - 200,
      screen_height - 20,
      10,
      @raylib.gray,
    )
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }
  // De-Initialization
  @raylib.unload_model(tower)
  @raylib.unload_texture(texture)
  @raylib.close_window()
}

///|
fn format_float(v : Float) -> String {
  let i = v.to_int()
  let frac = ((v - Float::from_int(i)).abs() * 100.0).to_int()
  let sign = if v < 0.0 && i == 0 { "-" } else { "" }
  let frac_str = if frac < 10 {
    "0" + frac.to_string()
  } else {
    frac.to_string()
  }
  sign + i.to_string() + "." + frac_str
}
