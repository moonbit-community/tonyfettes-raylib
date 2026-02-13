// Re-export passthrough functions from internal FFI layer
pub using @raylib {
  // Window management
  close_window,
  window_should_close,
  is_window_ready,
  is_window_fullscreen,
  is_window_hidden,
  is_window_minimized,
  is_window_maximized,
  is_window_focused,
  is_window_resized,
  set_window_size,
  set_window_position,
  set_window_min_size,
  set_window_max_size,
  set_window_opacity,
  set_window_focused,
  get_screen_width,
  get_screen_height,
  get_render_width,
  get_render_height,
  toggle_fullscreen,
  toggle_borderless_windowed,
  maximize_window,
  minimize_window,
  restore_window,
  set_config_flags,
  set_window_state,
  clear_window_state,
  // Cursor
  show_cursor,
  hide_cursor,
  is_cursor_hidden,
  enable_cursor,
  disable_cursor,
  is_cursor_on_screen,
  // Drawing
  begin_drawing,
  end_drawing,
  end_mode_2d,
  end_mode_3d,
  begin_scissor_mode,
  end_scissor_mode,
  begin_blend_mode,
  end_blend_mode,
  begin_texture_mode,
  end_texture_mode,
  // Timing
  set_target_fps,
  get_frame_time,
  get_time,
  get_fps,
  // Keyboard
  is_key_pressed,
  is_key_pressed_repeat,
  is_key_down,
  is_key_released,
  is_key_up,
  get_key_pressed,
  get_char_pressed,
  set_exit_key,
  // Mouse
  is_mouse_button_pressed,
  is_mouse_button_down,
  is_mouse_button_released,
  is_mouse_button_up,
  get_mouse_x,
  get_mouse_y,
  set_mouse_position,
  set_mouse_offset,
  set_mouse_scale,
  get_mouse_wheel_move,
  set_mouse_cursor,
  // Misc
  set_trace_log_level,
  get_random_value,
  set_random_seed,
}

// ============================================================================
// Window management (wrappers)
// ============================================================================

///|
pub fn init_window(width : Int, height : Int, title : String) -> Unit {
  @raylib.init_window(width, height, @utf8.encode(title))
}

///|
pub fn set_window_title(title : String) -> Unit {
  @raylib.set_window_title(@utf8.encode(title))
}

// ============================================================================
// Drawing (wrappers)
// ============================================================================

///|
pub fn clear_background(color : Color) -> Unit {
  @raylib.clear_background(color.to_bytes())
}

///|
pub fn begin_mode_2d(camera : Camera2D) -> Unit {
  @raylib.begin_mode_2d(camera.to_bytes())
}

///|
pub fn begin_mode_3d(camera : Camera3D) -> Unit {
  @raylib.begin_mode_3d(camera.to_bytes())
}

// ============================================================================
// Mouse input (wrappers)
// ============================================================================

///|
pub fn get_mouse_position() -> Vector2 {
  Vector2::from_bytes(@raylib.get_mouse_position())
}

///|
pub fn get_mouse_delta() -> Vector2 {
  Vector2::from_bytes(@raylib.get_mouse_delta())
}

///|
pub fn get_mouse_wheel_move_v() -> Vector2 {
  Vector2::from_bytes(@raylib.get_mouse_wheel_move_v())
}

// ============================================================================
// Camera (wrappers)
// ============================================================================

///|
pub fn update_camera(camera : Camera3D, mode : Int) -> Camera3D {
  Camera3D::from_bytes(@raylib.update_camera(camera.to_bytes(), mode))
}

///|
pub fn update_camera_pro(
  camera : Camera3D,
  movement : Vector3,
  rotation : Vector3,
  zoom : Float,
) -> Camera3D {
  Camera3D::from_bytes(
    @raylib.update_camera_pro(
      camera.to_bytes(),
      movement.to_bytes(),
      rotation.to_bytes(),
      zoom,
    ),
  )
}

///|
pub fn get_world_to_screen(position : Vector3, camera : Camera3D) -> Vector2 {
  Vector2::from_bytes(
    @raylib.get_world_to_screen(position.to_bytes(), camera.to_bytes()),
  )
}

///|
pub fn get_screen_to_world_2d(position : Vector2, camera : Camera2D) -> Vector2 {
  Vector2::from_bytes(
    @raylib.get_screen_to_world_2d(position.to_bytes(), camera.to_bytes()),
  )
}

///|
pub fn get_world_to_screen_2d(position : Vector2, camera : Camera2D) -> Vector2 {
  Vector2::from_bytes(
    @raylib.get_world_to_screen_2d(position.to_bytes(), camera.to_bytes()),
  )
}

// ============================================================================
// Misc (wrappers)
// ============================================================================

///|
pub fn take_screenshot(file_name : String) -> Unit {
  @raylib.take_screenshot(@utf8.encode(file_name))
}

///|
pub fn open_url(url : String) -> Unit {
  @raylib.open_url(@utf8.encode(url))
}

// ============================================================================
// Color utilities (wrappers)
// ============================================================================

///|
pub fn fade(color : Color, alpha : Float) -> Color {
  Color::from_bytes(@raylib.fade(color.to_bytes(), alpha))
}

///|
pub fn color_alpha(color : Color, alpha : Float) -> Color {
  Color::from_bytes(@raylib.color_alpha(color.to_bytes(), alpha))
}

///|
pub fn color_to_int(color : Color) -> Int {
  @raylib.color_to_int(color.to_bytes())
}

///|
pub fn get_color(hex_value : Int) -> Color {
  Color::from_bytes(@raylib.get_color(hex_value))
}

///|
pub fn color_from_hsv(hue : Float, saturation : Float, value : Float) -> Color {
  Color::from_bytes(@raylib.color_from_hsv(hue, saturation, value))
}

///|
pub fn color_tint(color : Color, tint : Color) -> Color {
  Color::from_bytes(@raylib.color_tint(color.to_bytes(), tint.to_bytes()))
}

///|
pub fn color_brightness(color : Color, factor : Float) -> Color {
  Color::from_bytes(@raylib.color_brightness(color.to_bytes(), factor))
}

///|
pub fn color_lerp(color1 : Color, color2 : Color, factor : Float) -> Color {
  Color::from_bytes(
    @raylib.color_lerp(color1.to_bytes(), color2.to_bytes(), factor),
  )
}

///|
pub fn color_is_equal(col1 : Color, col2 : Color) -> Bool {
  @raylib.color_is_equal(col1.to_bytes(), col2.to_bytes())
}
