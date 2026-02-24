///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - 2d camera mouse zoom",
  )

  let mut camera = @raylib.Camera2D::new(
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    1.0,
  )

  let mut zoom_mode = 0 // 0-Mouse Wheel, 1-Mouse Move

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeyOne) {
      zoom_mode = 0
    } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
      zoom_mode = 1
    }

    // Translate based on mouse left click
    let mut cam_target = camera.target
    let mut cam_offset = camera.offset
    let mut cam_zoom = camera.zoom
    if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
      let delta = @raylib.get_mouse_delta()
      let scale : Float = -1.0 / cam_zoom
      cam_target = @raylib.Vector2::new(
        cam_target.x + delta.x * scale,
        cam_target.y + delta.y * scale,
      )
    }
    if zoom_mode == 0 {
      // Zoom based on mouse wheel
      let wheel = @raylib.get_mouse_wheel_move()
      if wheel != 0.0 {
        // Get the world point that is under the mouse
        let mouse_world_pos = @raylib.get_screen_to_world_2d(
          @raylib.get_mouse_position(),
          camera,
        )
        // Set the offset to where the mouse is
        cam_offset = @raylib.get_mouse_position()
        // Set the target to match
        cam_target = mouse_world_pos
        // Zoom increment
        let abs_wheel : Float = if wheel < 0.0 { -wheel } else { wheel }
        let mut scale_factor : Float = 1.0 + 0.25 * abs_wheel
        if wheel < 0.0 {
          scale_factor = 1.0 / scale_factor
        }
        cam_zoom = cam_zoom * scale_factor
        if cam_zoom < 0.125 {
          cam_zoom = 0.125
        }
        if cam_zoom > 64.0 {
          cam_zoom = 64.0
        }
      }
    } else {
      // Zoom based on mouse right click
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
        let mouse_world_pos = @raylib.get_screen_to_world_2d(
          @raylib.get_mouse_position(),
          camera,
        )
        cam_offset = @raylib.get_mouse_position()
        cam_target = mouse_world_pos
      }
      if @raylib.is_mouse_button_down(@raylib.MouseButtonRight) {
        let delta_x = @raylib.get_mouse_delta().x
        let abs_dx : Float = if delta_x < 0.0 { -delta_x } else { delta_x }
        let mut scale_factor : Float = 1.0 + 0.01 * abs_dx
        if delta_x < 0.0 {
          scale_factor = 1.0 / scale_factor
        }
        cam_zoom = cam_zoom * scale_factor
        if cam_zoom < 0.125 {
          cam_zoom = 0.125
        }
        if cam_zoom > 64.0 {
          cam_zoom = 64.0
        }
      }
    }

    // Reconstruct camera
    camera = @raylib.Camera2D::new(cam_offset, cam_target, 0.0, cam_zoom)

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_2d(camera)

    // Draw a grid of lines in the XY plane as a visual reference
    for i = -50; i <= 50; i = i + 1 {
      let fi = Float::from_int(i) * 50.0
      @raylib.draw_line_v(
        @raylib.Vector2::new(fi, -2500.0),
        @raylib.Vector2::new(fi, 2500.0),
        if i == 0 {
          @raylib.darkgray
        } else {
          @raylib.lightgray
        },
      )
      @raylib.draw_line_v(
        @raylib.Vector2::new(-2500.0, fi),
        @raylib.Vector2::new(2500.0, fi),
        if i == 0 {
          @raylib.darkgray
        } else {
          @raylib.lightgray
        },
      )
    }

    // Draw a reference circle
    @raylib.draw_circle(
      screen_width / 2,
      screen_height / 2,
      50.0,
      @raylib.maroon,
    )

    @raylib.end_mode_2d()

    // Draw mouse reference
    let mouse_pos = @raylib.get_mouse_position()
    @raylib.draw_circle_v(mouse_pos, 4.0, @raylib.darkgray)
    @raylib.draw_text_ex(
      @raylib.get_font_default(),
      "[\{@raylib.get_mouse_x()}, \{@raylib.get_mouse_y()}]",
      @raylib.Vector2::new(mouse_pos.x - 44.0, mouse_pos.y - 24.0),
      20.0,
      2.0,
      @raylib.black,
    )

    @raylib.draw_text(
      "[1][2] Select mouse zoom mode (Wheel or Move)", 20, 20, 20, @raylib.darkgray,
    )
    if zoom_mode == 0 {
      @raylib.draw_text(
        "Mouse left button drag to move, mouse wheel to zoom", 20, 50, 20, @raylib.darkgray,
      )
    } else {
      @raylib.draw_text(
        "Mouse left button drag to move, mouse press and move to zoom", 20, 50, 20,
        @raylib.darkgray,
      )
    }

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
