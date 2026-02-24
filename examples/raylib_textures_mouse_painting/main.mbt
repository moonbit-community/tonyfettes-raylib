///|
fn main {
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - mouse painting",
  )

  // Color palette
  let colors : FixedArray[@raylib.Color] = [
    @raylib.raywhite, @raylib.yellow, @raylib.gold, @raylib.orange, @raylib.pink,
    @raylib.red, @raylib.maroon, @raylib.green, @raylib.lime, @raylib.darkgreen,
    @raylib.skyblue, @raylib.blue, @raylib.darkblue, @raylib.purple, @raylib.violet,
    @raylib.darkpurple, @raylib.beige, @raylib.brown, @raylib.darkbrown, @raylib.lightgray,
    @raylib.gray, @raylib.darkgray, @raylib.black,
  ]
  let max_colors = 23

  // Color selection rectangles
  let colors_recs : FixedArray[@raylib.Rectangle] = FixedArray::make(
    max_colors,
    @raylib.Rectangle::new(0.0, 0.0, 0.0, 0.0),
  )
  for i = 0; i < max_colors; i = i + 1 {
    colors_recs[i] = @raylib.Rectangle::new(
      10.0 + 30.0 * Float::from_int(i) + 2.0 * Float::from_int(i),
      10.0,
      30.0,
      30.0,
    )
  }

  let mut color_selected = 0
  let mut color_selected_prev = 0
  let mut color_mouse_hover : Int = 0
  let mut brush_size : Float = 20.0
  let mut mouse_was_pressed = false

  let btn_save_rec = @raylib.Rectangle::new(750.0, 10.0, 40.0, 30.0)
  let mut btn_save_mouse_hover = false
  let mut show_save_message = false
  let mut save_message_counter = 0

  // Canvas render texture
  let target = @raylib.load_render_texture(screen_width, screen_height)

  // Clear canvas
  @raylib.begin_texture_mode(target)
  @raylib.clear_background(colors[0])
  @raylib.end_texture_mode()

  @raylib.set_target_fps(120)

  while not(@raylib.window_should_close()) {
    let mouse_pos = @raylib.get_mouse_position()

    // Move between colors with keys
    if @raylib.is_key_pressed(@raylib.KeyRight) {
      color_selected += 1
    } else if @raylib.is_key_pressed(@raylib.KeyLeft) {
      color_selected -= 1
    }

    if color_selected >= max_colors {
      color_selected = max_colors - 1
    } else if color_selected < 0 {
      color_selected = 0
    }

    // Choose color with mouse
    color_mouse_hover = -1
    for i = 0; i < max_colors; i = i + 1 {
      if @raylib.check_collision_point_rec(mouse_pos, colors_recs[i]) {
        color_mouse_hover = i
        break
      }
    }

    if color_mouse_hover >= 0 &&
      @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      color_selected = color_mouse_hover
      color_selected_prev = color_selected
    }

    // Change brush size
    brush_size += @raylib.get_mouse_wheel_move() * 5.0
    if brush_size < 2.0 {
      brush_size = 2.0
    }
    if brush_size > 50.0 {
      brush_size = 50.0
    }

    if @raylib.is_key_pressed(@raylib.KeyC) {
      @raylib.begin_texture_mode(target)
      @raylib.clear_background(colors[0])
      @raylib.end_texture_mode()
    }

    if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
      @raylib.get_gesture_detected() == @raylib.GestureDrag {
      @raylib.begin_texture_mode(target)
      if mouse_pos.y > 50.0 {
        @raylib.draw_circle(
          mouse_pos.x.to_int(),
          mouse_pos.y.to_int(),
          brush_size,
          colors[color_selected],
        )
      }
      @raylib.end_texture_mode()
    }

    if @raylib.is_mouse_button_down(@raylib.MouseButtonRight) {
      if not(mouse_was_pressed) {
        color_selected_prev = color_selected
        color_selected = 0
      }
      mouse_was_pressed = true
      @raylib.begin_texture_mode(target)
      if mouse_pos.y > 50.0 {
        @raylib.draw_circle(
          mouse_pos.x.to_int(),
          mouse_pos.y.to_int(),
          brush_size,
          colors[0],
        )
      }
      @raylib.end_texture_mode()
    } else if @raylib.is_mouse_button_released(@raylib.MouseButtonRight) &&
      mouse_was_pressed {
      color_selected = color_selected_prev
      mouse_was_pressed = false
    }

    // Check save button hover
    btn_save_mouse_hover = @raylib.check_collision_point_rec(
      mouse_pos, btn_save_rec,
    )

    // Save image
    if (
        btn_save_mouse_hover &&
        @raylib.is_mouse_button_released(@raylib.MouseButtonLeft)
      ) ||
      @raylib.is_key_pressed(@raylib.KeyS) {
      let texture = @raylib.get_render_texture_texture(target)
      let image = @raylib.load_image_from_texture(texture)
      @raylib.image_flip_vertical(image)
      let _ = @raylib.export_image(image, "my_amazing_texture_painting.png")
      @raylib.unload_image(image)
      show_save_message = true
    }

    if show_save_message {
      save_message_counter += 1
      if save_message_counter > 240 {
        show_save_message = false
        save_message_counter = 0
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw canvas (y-flipped)
    @raylib.draw_render_texture_rec(
      target,
      @raylib.Rectangle::new(
        0.0,
        0.0,
        Float::from_int(screen_width),
        Float::from_int(-screen_height),
      ),
      @raylib.Vector2::new(0.0, 0.0),
      @raylib.white,
    )

    // Draw brush circle
    if mouse_pos.y > 50.0 {
      if @raylib.is_mouse_button_down(@raylib.MouseButtonRight) {
        @raylib.draw_circle_lines(
          mouse_pos.x.to_int(),
          mouse_pos.y.to_int(),
          brush_size,
          @raylib.gray,
        )
      } else {
        @raylib.draw_circle(
          @raylib.get_mouse_x(),
          @raylib.get_mouse_y(),
          brush_size,
          colors[color_selected],
        )
      }
    }

    // Top panel
    @raylib.draw_rectangle(
      0,
      0,
      @raylib.get_screen_width(),
      50,
      @raylib.raywhite,
    )
    @raylib.draw_line(0, 50, @raylib.get_screen_width(), 50, @raylib.lightgray)

    // Color rectangles
    for i = 0; i < max_colors; i = i + 1 {
      @raylib.draw_rectangle_rec(colors_recs[i], colors[i])
    }
    @raylib.draw_rectangle_lines(10, 10, 30, 30, @raylib.lightgray)

    if color_mouse_hover >= 0 {
      @raylib.draw_rectangle_rec(
        colors_recs[color_mouse_hover],
        @raylib.fade(@raylib.white, 0.6),
      )
    }

    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        colors_recs[color_selected].x - 2.0,
        colors_recs[color_selected].y - 2.0,
        colors_recs[color_selected].width + 4.0,
        colors_recs[color_selected].height + 4.0,
      ),
      2.0,
      @raylib.black,
    )

    // Save button
    let save_color = if btn_save_mouse_hover {
      @raylib.red
    } else {
      @raylib.black
    }
    @raylib.draw_rectangle_lines_ex(btn_save_rec, 2.0, save_color)
    @raylib.draw_text("SAVE!", 755, 20, 10, save_color)

    // Save message
    if show_save_message {
      @raylib.draw_rectangle(
        0,
        0,
        @raylib.get_screen_width(),
        @raylib.get_screen_height(),
        @raylib.fade(@raylib.raywhite, 0.8),
      )
      @raylib.draw_rectangle(
        0,
        150,
        @raylib.get_screen_width(),
        80,
        @raylib.black,
      )
      @raylib.draw_text(
        "IMAGE SAVED:  my_amazing_texture_painting.png", 150, 180, 20, @raylib.raywhite,
      )
    }

    @raylib.end_drawing()
  }

  @raylib.unload_render_texture(target)
  @raylib.close_window()
}
