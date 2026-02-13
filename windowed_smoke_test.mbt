// Windowed smoke tests for raylib FFI bindings - exercises functions
// that require an active window/graphics context.

///|
test "window lifecycle and queries" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  assert_true(is_window_ready())
  assert_eq(get_screen_width(), 1)
  assert_eq(get_screen_height(), 1)
  close_window()
}

///|
test "drawing context smoke test" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  begin_drawing()
  clear_background(raywhite)
  end_drawing()
  close_window()
}

///|
test "2D shape drawing smoke test" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  begin_drawing()
  draw_pixel(0, 0, red)
  draw_line(0, 0, 1, 1, blue)
  draw_circle(0, 0, 1.0, green)
  draw_rectangle(0, 0, 1, 1, white)
  draw_triangle(
    Vector2::new(0.0, 0.0),
    Vector2::new(1.0, 0.0),
    Vector2::new(0.0, 1.0),
    red,
  )
  draw_poly(Vector2::new(0.0, 0.0), 6, 1.0, 0.0, blue)
  end_drawing()
  close_window()
}

///|
test "rectangle drawing variants" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  begin_drawing()
  draw_rectangle_v(Vector2::new(0.0, 0.0), Vector2::new(1.0, 1.0), red)
  draw_rectangle_rec(Rectangle::new(0.0, 0.0, 1.0, 1.0), blue)
  draw_rectangle_pro(
    Rectangle::new(0.0, 0.0, 1.0, 1.0),
    Vector2::new(0.0, 0.0),
    0.0,
    green,
  )
  draw_rectangle_rounded(Rectangle::new(0.0, 0.0, 1.0, 1.0), 0.5, 4, white)
  draw_rectangle_lines_ex(Rectangle::new(0.0, 0.0, 1.0, 1.0), 0.1, black)
  end_drawing()
  close_window()
}

///|
test "line and curve drawing variants" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  begin_drawing()
  draw_line_v(Vector2::new(0.0, 0.0), Vector2::new(1.0, 1.0), red)
  draw_line_ex(Vector2::new(0.0, 0.0), Vector2::new(1.0, 1.0), 1.0, blue)
  draw_line_bezier(Vector2::new(0.0, 0.0), Vector2::new(1.0, 1.0), 1.0, green)
  draw_circle_sector(Vector2::new(0.0, 0.0), 1.0, 0.0, 180.0, 8, white)
  draw_ring(Vector2::new(0.0, 0.0), 0.5, 1.0, 0.0, 360.0, 8, black)
  end_drawing()
  close_window()
}

///|
test "3D drawing smoke test" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  let camera = Camera3D::new(
    Vector3::new(0.0, 10.0, 10.0),
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
    45.0,
    CameraPerspective,
  )
  begin_drawing()
  begin_mode_3d(camera)
  draw_cube(Vector3::new(0.0, 0.0, 0.0), 1.0, 1.0, 1.0, red)
  draw_sphere(Vector3::new(2.0, 0.0, 0.0), 0.5, blue)
  draw_grid(10, 1.0)
  draw_plane(Vector3::new(0.0, 0.0, 0.0), Vector2::new(10.0, 10.0), green)
  end_mode_3d()
  end_drawing()
  close_window()
}

///|
test "texture from image lifecycle" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  let image = gen_image_color(16, 16, red)
  let texture = load_texture_from_image(image)
  assert_true(is_texture_valid(texture))
  unload_texture(texture)
  unload_image(image)
  close_window()
}

///|
test "render texture lifecycle" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  let target = load_render_texture(16, 16)
  assert_true(is_render_texture_valid(target))
  begin_texture_mode(target)
  clear_background(black)
  end_texture_mode()
  unload_render_texture(target)
  close_window()
}

///|
test "font and text measurement" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  let font = get_font_default()
  assert_true(is_font_valid(font))
  let size = measure_text_ex(font, "Hello", 20.0, 1.0)
  assert_true(size.x >= 0.0)
  assert_true(size.y >= 0.0)
  begin_drawing()
  draw_text("Hello", 0, 0, 10, black)
  end_drawing()
  close_window()
}

///|
test "scissor and blend modes" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  begin_drawing()
  begin_scissor_mode(0, 0, 1, 1)
  clear_background(red)
  end_scissor_mode()
  begin_blend_mode(BlendAlpha)
  draw_rectangle(0, 0, 1, 1, blue)
  end_blend_mode()
  end_drawing()
  close_window()
}

///|
test "2D camera mode" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  let camera = Camera2D::new(
    Vector2::new(0.0, 0.0),
    Vector2::new(0.0, 0.0),
    0.0,
    1.0,
  )
  begin_drawing()
  begin_mode_2d(camera)
  draw_rectangle(0, 0, 1, 1, red)
  end_mode_2d()
  end_drawing()
  close_window()
}

///|
test "input queries do not crash" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  let _pressed = is_key_pressed(KeySpace)
  let _down = is_key_down(KeySpace)
  let _up = is_key_up(KeySpace)
  let _mouse_pos = get_mouse_position()
  let _wheel = get_mouse_wheel_move()
  close_window()
}

///|
test "window state functions" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  set_window_title("test2")
  set_window_size(2, 2)
  let rw = get_render_width()
  let rh = get_render_height()
  assert_true(rw >= 0)
  assert_true(rh >= 0)
  assert_true(not(window_should_close()))
  close_window()
}
