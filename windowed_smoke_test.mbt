// Windowed smoke tests for raylib FFI bindings - exercises functions
// that require an active window/graphics context.

///|
test "window lifecycle and queries" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  assert_true(@raylib.is_window_ready())
  assert_eq(@raylib.get_screen_width(), 1)
  assert_eq(@raylib.get_screen_height(), 1)
  @raylib.close_window()
}

///|
test "drawing context smoke test" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raylib.begin_drawing()
  @raylib.clear_background(@raylib.raywhite)
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "2D shape drawing smoke test" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raylib.begin_drawing()
  @raylib.draw_pixel(0, 0, @raylib.red)
  @raylib.draw_line(0, 0, 1, 1, @raylib.blue)
  @raylib.draw_circle(0, 0, 1.0, @raylib.green)
  @raylib.draw_rectangle(0, 0, 1, 1, @raylib.white)
  @raylib.draw_triangle(
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(1.0, 0.0),
    @raylib.Vector2::new(0.0, 1.0),
    @raylib.red,
  )
  @raylib.draw_poly(@raylib.Vector2::new(0.0, 0.0), 6, 1.0, 0.0, @raylib.blue)
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "rectangle drawing variants" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raylib.begin_drawing()
  @raylib.draw_rectangle_v(
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(1.0, 1.0),
    @raylib.red,
  )
  @raylib.draw_rectangle_rec(
    @raylib.Rectangle::new(0.0, 0.0, 1.0, 1.0),
    @raylib.blue,
  )
  @raylib.draw_rectangle_pro(
    @raylib.Rectangle::new(0.0, 0.0, 1.0, 1.0),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    @raylib.green,
  )
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(0.0, 0.0, 1.0, 1.0),
    0.5,
    4,
    @raylib.white,
  )
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(0.0, 0.0, 1.0, 1.0),
    0.1,
    @raylib.black,
  )
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "line and curve drawing variants" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raylib.begin_drawing()
  @raylib.draw_line_v(
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(1.0, 1.0),
    @raylib.red,
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(1.0, 1.0),
    1.0,
    @raylib.blue,
  )
  @raylib.draw_line_bezier(
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(1.0, 1.0),
    1.0,
    @raylib.green,
  )
  @raylib.draw_circle_sector(
    @raylib.Vector2::new(0.0, 0.0),
    1.0,
    0.0,
    180.0,
    8,
    @raylib.white,
  )
  @raylib.draw_ring(
    @raylib.Vector2::new(0.0, 0.0),
    0.5,
    1.0,
    0.0,
    360.0,
    8,
    @raylib.black,
  )
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "3D drawing smoke test" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 10.0, 10.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )
  @raylib.begin_drawing()
  @raylib.begin_mode_3d(camera)
  @raylib.draw_cube(
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    1.0,
    1.0,
    1.0,
    @raylib.red,
  )
  @raylib.draw_sphere(@raylib.Vector3::new(2.0, 0.0, 0.0), 0.5, @raylib.blue)
  @raylib.draw_grid(10, 1.0)
  @raylib.draw_plane(
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector2::new(10.0, 10.0),
    @raylib.green,
  )
  @raylib.end_mode_3d()
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "texture from image lifecycle" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let image = @raylib.gen_image_color(16, 16, @raylib.red)
  let texture = image.to_texture()
  assert_true(texture.width() > 0)
  texture.unload()
  image.unload()
  @raylib.close_window()
}

///|
test "render texture lifecycle" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let target = @raylib.RenderTexture::load(16, 16)
  assert_true(target.is_valid())
  target.begin_mode()
  @raylib.clear_background(@raylib.black)
  @raylib.end_texture_mode()
  target.unload()
  @raylib.close_window()
}

///|
test "font and text measurement" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let font = @raylib.Font::default()
  assert_true(font.is_valid())
  let size = font.measure_text("Hello", 20.0, 1.0)
  assert_true(size.x >= 0.0)
  assert_true(size.y >= 0.0)
  @raylib.begin_drawing()
  @raylib.draw_text("Hello", 0, 0, 10, @raylib.black)
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "scissor and blend modes" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raylib.begin_drawing()
  @raylib.begin_scissor_mode(0, 0, 1, 1)
  @raylib.clear_background(@raylib.red)
  @raylib.end_scissor_mode()
  @raylib.begin_blend_mode(@raylib.BlendAlpha)
  @raylib.draw_rectangle(0, 0, 1, 1, @raylib.blue)
  @raylib.end_blend_mode()
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "2D camera mode" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let camera = @raylib.Camera2D::new(
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    1.0,
  )
  @raylib.begin_drawing()
  @raylib.begin_mode_2d(camera)
  @raylib.draw_rectangle(0, 0, 1, 1, @raylib.red)
  @raylib.end_mode_2d()
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "input queries do not crash" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let _ = @raylib.is_key_pressed(@raylib.KeySpace)
  let _ = @raylib.is_key_down(@raylib.KeySpace)
  let _ = @raylib.is_key_up(@raylib.KeySpace)
  let _ = @raylib.get_mouse_position()
  let _ = @raylib.get_mouse_wheel_move()
  @raylib.close_window()
}

///|
test "window state functions" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raylib.set_window_title("test2")
  @raylib.set_window_size(2, 2)
  let rw = @raylib.get_render_width()
  let rh = @raylib.get_render_height()
  assert_true(rw >= 0)
  assert_true(rh >= 0)
  assert_true(!@raylib.window_should_close())
  @raylib.close_window()
}

///|
test "window position and DPI queries" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let _ = @raylib.get_window_position()
  let dpi = @raylib.get_window_scale_dpi()
  assert_true(dpi.x > 0.0)
  @raylib.close_window()
}

///|
test "trace_log does not crash" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raylib.trace_log(4, "test message")
  @raylib.close_window()
}

///|
test "take_screenshot does not crash" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raylib.begin_drawing()
  @raylib.clear_background(@raylib.black)
  @raylib.end_drawing()
  @raylib.take_screenshot("_test_tmp_screenshot.png")
  @raylib.close_window()
}

///|
test "set_window_icon does not crash" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let icon = @raylib.gen_image_color(16, 16, @raylib.red)
  @raylib.set_window_icon(icon)
  icon.unload()
  @raylib.close_window()
}

///|
test "input vector queries do not crash" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let _ = @raylib.get_mouse_delta()
  let _ = @raylib.get_mouse_wheel_move_v()
  let _ = @raylib.get_touch_position(0)
  let _ = @raylib.get_gesture_drag_vector()
  let _ = @raylib.get_gesture_pinch_vector()
  let _ = @raylib.get_gamepad_name(0)
  @raylib.close_window()
}

///|
test "monitor queries do not crash" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let _ = @raylib.get_monitor_position(0)
  let _ = @raylib.get_monitor_name(0)
  @raylib.close_window()
}

///|
test "shapes drawing variants" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raylib.begin_drawing()
  @raylib.draw_circle_sector_lines(
    @raylib.Vector2::new(0.0, 0.0),
    1.0,
    0.0,
    180.0,
    8,
    @raylib.red,
  )
  @raylib.draw_ring_lines(
    @raylib.Vector2::new(0.0, 0.0),
    0.5,
    1.0,
    0.0,
    360.0,
    8,
    @raylib.blue,
  )
  @raylib.draw_ellipse(0, 0, 1.0, 0.5, @raylib.green)
  @raylib.draw_ellipse_lines(0, 0, 1.0, 0.5, @raylib.white)
  @raylib.draw_rectangle_gradient_v(0, 0, 1, 1, @raylib.red, @raylib.blue)
  @raylib.draw_rectangle_gradient_h(0, 0, 1, 1, @raylib.green, @raylib.white)
  @raylib.draw_rectangle_gradient_ex(
    @raylib.Rectangle::new(0.0, 0.0, 1.0, 1.0),
    @raylib.red,
    @raylib.blue,
    @raylib.green,
    @raylib.white,
  )
  @raylib.draw_triangle_lines(
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(1.0, 0.0),
    @raylib.Vector2::new(0.0, 1.0),
    @raylib.black,
  )
  @raylib.end_drawing()
  @raylib.close_window()
}
