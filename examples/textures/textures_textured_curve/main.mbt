///|
fn draw_textured_curve(
  tex_road : @raylib.Texture,
  curve_start_position : @raylib.Vector2,
  curve_start_position_tangent : @raylib.Vector2,
  curve_end_position : @raylib.Vector2,
  curve_end_position_tangent : @raylib.Vector2,
  curve_width : Float,
  curve_segments : Int,
) -> Unit {
  let step : Float = 1.0 / Float::from_int(curve_segments)
  let mut previous = curve_start_position
  let mut previous_tangent = @raylib.Vector2::new(0.0, 0.0)
  let mut previous_v : Float = 0.0
  let mut tangent_set = false
  for i in 1..<=curve_segments {
    let t : Float = step * Float::from_int(i)
    let a : Float = (1.0 - t) * (1.0 - t) * (1.0 - t)
    let b : Float = 3.0 * (1.0 - t) * (1.0 - t) * t
    let c : Float = (3.0 : Float) * (1.0 - t) * t * t
    let d : Float = t * t * t
    // Compute the endpoint for this segment
    let current = @raylib.Vector2::new(
      a * curve_start_position.x +
      b * curve_start_position_tangent.x +
      c * curve_end_position_tangent.x +
      d * curve_end_position.x,
      a * curve_start_position.y +
      b * curve_start_position_tangent.y +
      c * curve_end_position_tangent.y +
      d * curve_end_position.y,
    )
    // Vector from previous to current
    let delta = @raylib.Vector2::new(
      current.x - previous.x,
      current.y - previous.y,
    )
    // The right hand normal to the delta vector
    let normal = @raylib.Vector2::normalize(
      @raylib.Vector2::new(-delta.y, delta.x),
    )
    // The v texture coordinate of the segment
    let v = previous_v + @raylib.Vector2::length(delta)
    // Make sure the start point has a normal
    if not(tangent_set) {
      previous_tangent = normal
      tangent_set = true
    }
    // Extend out the normals from the previous and current points
    let prev_pos_normal = @raylib.Vector2::add(
      previous,
      @raylib.Vector2::scale(previous_tangent, curve_width),
    )
    let prev_neg_normal = @raylib.Vector2::add(
      previous,
      @raylib.Vector2::scale(previous_tangent, -curve_width),
    )
    let current_pos_normal = @raylib.Vector2::add(
      current,
      @raylib.Vector2::scale(normal, curve_width),
    )
    let current_neg_normal = @raylib.Vector2::add(
      current,
      @raylib.Vector2::scale(normal, -curve_width),
    )
    // Draw the segment as a quad
    @rl.set_texture(tex_road.id())
    @rl.begin(@rl.Quads)
    @rl.color4ub(b'\xFF', b'\xFF', b'\xFF', b'\xFF')
    @rl.normal3f(0.0, 0.0, 1.0)
    @rl.tex_coord2f(0.0, previous_v)
    @rl.vertex2f(prev_neg_normal.x, prev_neg_normal.y)
    @rl.tex_coord2f(1.0, previous_v)
    @rl.vertex2f(prev_pos_normal.x, prev_pos_normal.y)
    @rl.tex_coord2f(1.0, v)
    @rl.vertex2f(current_pos_normal.x, current_pos_normal.y)
    @rl.tex_coord2f(0.0, v)
    @rl.vertex2f(current_neg_normal.x, current_neg_normal.y)
    @rl.end_()
    // The current step is the start of the next step
    previous = current
    previous_tangent = normal
    previous_v = v
  }
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("textures/textures_textured_curve")

  @raylib.set_config_flags(@raylib.FlagVsyncHint | @raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] examples - textured curve",
  )

  // Load the road texture
  let tex_road = @raylib.load_texture("resources/road.png")
  @raylib.set_texture_filter(tex_road, @raylib.TextureFilterBilinear)

  // Setup the curve
  let mut curve_start_position = @raylib.Vector2::new(80.0, 100.0)
  let mut curve_start_position_tangent = @raylib.Vector2::new(100.0, 300.0)
  let mut curve_end_position = @raylib.Vector2::new(700.0, 350.0)
  let mut curve_end_position_tangent = @raylib.Vector2::new(600.0, 100.0)

  let mut show_curve = false
  let mut curve_width : Float = 50.0
  let mut curve_segments = 24

  // Track which point is selected (0=none, 1=start, 2=start_tangent, 3=end, 4=end_tangent)
  let mut curve_selected_point = 0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // Curve config options
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      show_curve = not(show_curve)
    }
    if @raylib.is_key_pressed(@raylib.KeyEqual) {
      curve_width += 2.0
    }
    if @raylib.is_key_pressed(@raylib.KeyMinus) {
      curve_width -= 2.0
    }
    if curve_width < 2.0 {
      curve_width = 2.0
    }

    // Update segments
    if @raylib.is_key_pressed(@raylib.KeyLeft) {
      curve_segments -= 2
    }
    if @raylib.is_key_pressed(@raylib.KeyRight) {
      curve_segments += 2
    }
    if curve_segments < 2 {
      curve_segments = 2
    }

    // If the mouse is not down, clear the selection
    if not(@raylib.is_mouse_button_down(@raylib.MouseButtonLeft)) {
      curve_selected_point = 0
    }

    // If a point was selected, move it
    let mouse_delta = @raylib.get_mouse_delta()
    if curve_selected_point == 1 {
      curve_start_position = @raylib.Vector2::add(
        curve_start_position, mouse_delta,
      )
    } else if curve_selected_point == 2 {
      curve_start_position_tangent = @raylib.Vector2::add(
        curve_start_position_tangent, mouse_delta,
      )
    } else if curve_selected_point == 3 {
      curve_end_position = @raylib.Vector2::add(curve_end_position, mouse_delta)
    } else if curve_selected_point == 4 {
      curve_end_position_tangent = @raylib.Vector2::add(
        curve_end_position_tangent, mouse_delta,
      )
    }

    // The mouse is down, and nothing was selected, so see if anything was picked
    let mouse = @raylib.get_mouse_position()
    if @raylib.check_collision_point_circle(mouse, curve_start_position, 6.0) {
      curve_selected_point = 1
    } else if @raylib.check_collision_point_circle(
        mouse, curve_start_position_tangent, 6.0,
      ) {
      curve_selected_point = 2
    } else if @raylib.check_collision_point_circle(
        mouse, curve_end_position, 6.0,
      ) {
      curve_selected_point = 3
    } else if @raylib.check_collision_point_circle(
        mouse, curve_end_position_tangent, 6.0,
      ) {
      curve_selected_point = 4
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    draw_textured_curve(
      tex_road, curve_start_position, curve_start_position_tangent, curve_end_position,
      curve_end_position_tangent, curve_width, curve_segments,
    )

    // Draw spline for reference
    if show_curve {
      @raylib.draw_spline_segment_bezier_cubic(
        curve_start_position, curve_end_position, curve_start_position_tangent, curve_end_position_tangent,
        2.0, @raylib.blue,
      )
    }

    // Draw the various control points and highlight where the mouse is
    @raylib.draw_line_v(
      curve_start_position, curve_start_position_tangent, @raylib.skyblue,
    )
    @raylib.draw_line_v(
      curve_start_position_tangent,
      curve_end_position_tangent,
      @raylib.fade(@raylib.lightgray, 0.4),
    )
    @raylib.draw_line_v(
      curve_end_position, curve_end_position_tangent, @raylib.purple,
    )

    if @raylib.check_collision_point_circle(mouse, curve_start_position, 6.0) {
      @raylib.draw_circle_v(curve_start_position, 7.0, @raylib.yellow)
    }
    @raylib.draw_circle_v(curve_start_position, 5.0, @raylib.red)

    if @raylib.check_collision_point_circle(
        mouse, curve_start_position_tangent, 6.0,
      ) {
      @raylib.draw_circle_v(curve_start_position_tangent, 7.0, @raylib.yellow)
    }
    @raylib.draw_circle_v(curve_start_position_tangent, 5.0, @raylib.maroon)

    if @raylib.check_collision_point_circle(mouse, curve_end_position, 6.0) {
      @raylib.draw_circle_v(curve_end_position, 7.0, @raylib.yellow)
    }
    @raylib.draw_circle_v(curve_end_position, 5.0, @raylib.green)

    if @raylib.check_collision_point_circle(
        mouse, curve_end_position_tangent, 6.0,
      ) {
      @raylib.draw_circle_v(curve_end_position_tangent, 7.0, @raylib.yellow)
    }
    @raylib.draw_circle_v(curve_end_position_tangent, 5.0, @raylib.darkgreen)

    // Draw usage info
    @raylib.draw_text(
      "Drag points to move curve, press SPACE to show/hide base curve", 10, 10, 10,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "Curve width: \{curve_width.to_int()} (Use + and - to adjust)",
      10,
      30,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "Curve segments: \{curve_segments} (Use LEFT and RIGHT to adjust)",
      10,
      50,
      10,
      @raylib.darkgray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(tex_road)
  @raylib.close_window()
}
