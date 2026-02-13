// ============================================================================
// Window management
// ============================================================================

///|
#borrow(title)
extern "c" fn init_window_ffi(width : Int, height : Int, title : Bytes) = "moonbit_InitWindow"

///|
pub fn init_window(width : Int, height : Int, title : String) -> Unit {
  init_window_ffi(width, height, @utf8.encode(title))
}

///|
extern "c" fn close_window_ffi() = "CloseWindow"

///|
pub fn close_window() -> Unit {
  close_window_ffi()
}

///|
extern "c" fn window_should_close_ffi() -> Bool = "WindowShouldClose"

///|
pub fn window_should_close() -> Bool {
  window_should_close_ffi()
}

///|
extern "c" fn is_window_ready_ffi() -> Bool = "IsWindowReady"

///|
pub fn is_window_ready() -> Bool {
  is_window_ready_ffi()
}

///|
extern "c" fn is_window_fullscreen_ffi() -> Bool = "IsWindowFullscreen"

///|
pub fn is_window_fullscreen() -> Bool {
  is_window_fullscreen_ffi()
}

///|
extern "c" fn is_window_hidden_ffi() -> Bool = "IsWindowHidden"

///|
pub fn is_window_hidden() -> Bool {
  is_window_hidden_ffi()
}

///|
extern "c" fn is_window_minimized_ffi() -> Bool = "IsWindowMinimized"

///|
pub fn is_window_minimized() -> Bool {
  is_window_minimized_ffi()
}

///|
extern "c" fn is_window_maximized_ffi() -> Bool = "IsWindowMaximized"

///|
pub fn is_window_maximized() -> Bool {
  is_window_maximized_ffi()
}

///|
extern "c" fn is_window_focused_ffi() -> Bool = "IsWindowFocused"

///|
pub fn is_window_focused() -> Bool {
  is_window_focused_ffi()
}

///|
extern "c" fn is_window_resized_ffi() -> Bool = "IsWindowResized"

///|
pub fn is_window_resized() -> Bool {
  is_window_resized_ffi()
}

///|
#borrow(title)
extern "c" fn set_window_title_ffi(title : Bytes) = "moonbit_SetWindowTitle"

///|
pub fn set_window_title(title : String) -> Unit {
  set_window_title_ffi(@utf8.encode(title))
}

///|
extern "c" fn set_window_size_ffi(width : Int, height : Int) = "SetWindowSize"

///|
pub fn set_window_size(width : Int, height : Int) -> Unit {
  set_window_size_ffi(width, height)
}

///|
extern "c" fn set_window_position_ffi(x : Int, y : Int) = "SetWindowPosition"

///|
pub fn set_window_position(x : Int, y : Int) -> Unit {
  set_window_position_ffi(x, y)
}

///|
extern "c" fn set_window_min_size_ffi(width : Int, height : Int) = "SetWindowMinSize"

///|
pub fn set_window_min_size(width : Int, height : Int) -> Unit {
  set_window_min_size_ffi(width, height)
}

///|
extern "c" fn set_window_max_size_ffi(width : Int, height : Int) = "SetWindowMaxSize"

///|
pub fn set_window_max_size(width : Int, height : Int) -> Unit {
  set_window_max_size_ffi(width, height)
}

///|
extern "c" fn set_window_opacity_ffi(opacity : Float) = "SetWindowOpacity"

///|
pub fn set_window_opacity(opacity : Float) -> Unit {
  set_window_opacity_ffi(opacity)
}

///|
extern "c" fn set_window_focused_ffi() = "SetWindowFocused"

///|
pub fn set_window_focused() -> Unit {
  set_window_focused_ffi()
}

///|
extern "c" fn get_screen_width_ffi() -> Int = "GetScreenWidth"

///|
pub fn get_screen_width() -> Int {
  get_screen_width_ffi()
}

///|
extern "c" fn get_screen_height_ffi() -> Int = "GetScreenHeight"

///|
pub fn get_screen_height() -> Int {
  get_screen_height_ffi()
}

///|
extern "c" fn get_render_width_ffi() -> Int = "GetRenderWidth"

///|
pub fn get_render_width() -> Int {
  get_render_width_ffi()
}

///|
extern "c" fn get_render_height_ffi() -> Int = "GetRenderHeight"

///|
pub fn get_render_height() -> Int {
  get_render_height_ffi()
}

///|
extern "c" fn toggle_fullscreen_ffi() = "ToggleFullscreen"

///|
pub fn toggle_fullscreen() -> Unit {
  toggle_fullscreen_ffi()
}

///|
extern "c" fn toggle_borderless_windowed_ffi() = "ToggleBorderlessWindowed"

///|
pub fn toggle_borderless_windowed() -> Unit {
  toggle_borderless_windowed_ffi()
}

///|
extern "c" fn maximize_window_ffi() = "MaximizeWindow"

///|
pub fn maximize_window() -> Unit {
  maximize_window_ffi()
}

///|
extern "c" fn minimize_window_ffi() = "MinimizeWindow"

///|
pub fn minimize_window() -> Unit {
  minimize_window_ffi()
}

///|
extern "c" fn restore_window_ffi() = "RestoreWindow"

///|
pub fn restore_window() -> Unit {
  restore_window_ffi()
}

///|
extern "c" fn set_config_flags_ffi(flags : Int) = "SetConfigFlags"

///|
pub fn set_config_flags(flags : Int) -> Unit {
  set_config_flags_ffi(flags)
}

///|
extern "c" fn set_window_state_ffi(flags : Int) = "SetWindowState"

///|
pub fn set_window_state(flags : Int) -> Unit {
  set_window_state_ffi(flags)
}

///|
extern "c" fn clear_window_state_ffi(flags : Int) = "ClearWindowState"

///|
pub fn clear_window_state(flags : Int) -> Unit {
  clear_window_state_ffi(flags)
}

// ============================================================================
// Cursor
// ============================================================================

///|
extern "c" fn show_cursor_ffi() = "ShowCursor"

///|
pub fn show_cursor() -> Unit {
  show_cursor_ffi()
}

///|
extern "c" fn hide_cursor_ffi() = "HideCursor"

///|
pub fn hide_cursor() -> Unit {
  hide_cursor_ffi()
}

///|
extern "c" fn is_cursor_hidden_ffi() -> Bool = "IsCursorHidden"

///|
pub fn is_cursor_hidden() -> Bool {
  is_cursor_hidden_ffi()
}

///|
extern "c" fn enable_cursor_ffi() = "EnableCursor"

///|
pub fn enable_cursor() -> Unit {
  enable_cursor_ffi()
}

///|
extern "c" fn disable_cursor_ffi() = "DisableCursor"

///|
pub fn disable_cursor() -> Unit {
  disable_cursor_ffi()
}

///|
extern "c" fn is_cursor_on_screen_ffi() -> Bool = "IsCursorOnScreen"

///|
pub fn is_cursor_on_screen() -> Bool {
  is_cursor_on_screen_ffi()
}

// ============================================================================
// Drawing
// ============================================================================

///|
#borrow(color)
extern "c" fn clear_background_ffi(color : Bytes) = "moonbit_ClearBackground"

///|
pub fn clear_background(color : Color) -> Unit {
  clear_background_ffi(color.to_bytes())
}

///|
extern "c" fn begin_drawing_ffi() = "BeginDrawing"

///|
pub fn begin_drawing() -> Unit {
  begin_drawing_ffi()
}

///|
extern "c" fn end_drawing_ffi() = "EndDrawing"

///|
pub fn end_drawing() -> Unit {
  end_drawing_ffi()
}

///|
#borrow(camera)
extern "c" fn begin_mode_2d_ffi(camera : Bytes) = "moonbit_BeginMode2D"

///|
pub fn begin_mode_2d(camera : Camera2D) -> Unit {
  begin_mode_2d_ffi(camera.to_bytes())
}

///|
extern "c" fn end_mode_2d_ffi() = "EndMode2D"

///|
pub fn end_mode_2d() -> Unit {
  end_mode_2d_ffi()
}

///|
#borrow(camera)
extern "c" fn begin_mode_3d_ffi(camera : Bytes) = "moonbit_BeginMode3D"

///|
pub fn begin_mode_3d(camera : Camera3D) -> Unit {
  begin_mode_3d_ffi(camera.to_bytes())
}

///|
extern "c" fn end_mode_3d_ffi() = "EndMode3D"

///|
pub fn end_mode_3d() -> Unit {
  end_mode_3d_ffi()
}

///|
extern "c" fn begin_scissor_mode_ffi(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) = "BeginScissorMode"

///|
pub fn begin_scissor_mode(x : Int, y : Int, width : Int, height : Int) -> Unit {
  begin_scissor_mode_ffi(x, y, width, height)
}

///|
extern "c" fn end_scissor_mode_ffi() = "EndScissorMode"

///|
pub fn end_scissor_mode() -> Unit {
  end_scissor_mode_ffi()
}

///|
extern "c" fn begin_blend_mode_ffi(mode : Int) = "BeginBlendMode"

///|
pub fn begin_blend_mode(mode : Int) -> Unit {
  begin_blend_mode_ffi(mode)
}

///|
extern "c" fn end_blend_mode_ffi() = "EndBlendMode"

///|
pub fn end_blend_mode() -> Unit {
  end_blend_mode_ffi()
}

///|
#borrow(target)
extern "c" fn begin_texture_mode_ffi(target : RenderTexture) = "moonbit_BeginTextureMode"

///|
pub fn begin_texture_mode(target : RenderTexture) -> Unit {
  begin_texture_mode_ffi(target)
}

///|
extern "c" fn end_texture_mode_ffi() = "EndTextureMode"

///|
pub fn end_texture_mode() -> Unit {
  end_texture_mode_ffi()
}

// ============================================================================
// Timing
// ============================================================================

///|
extern "c" fn set_target_fps_ffi(fps : Int) = "SetTargetFPS"

///|
pub fn set_target_fps(fps : Int) -> Unit {
  set_target_fps_ffi(fps)
}

///|
extern "c" fn get_frame_time_ffi() -> Float = "GetFrameTime"

///|
pub fn get_frame_time() -> Float {
  get_frame_time_ffi()
}

///|
extern "c" fn get_time_ffi() -> Double = "GetTime"

///|
pub fn get_time() -> Double {
  get_time_ffi()
}

///|
extern "c" fn get_fps_ffi() -> Int = "GetFPS"

///|
pub fn get_fps() -> Int {
  get_fps_ffi()
}

// ============================================================================
// Keyboard input
// ============================================================================

///|
extern "c" fn is_key_pressed_ffi(key : Int) -> Bool = "IsKeyPressed"

///|
pub fn is_key_pressed(key : Int) -> Bool {
  is_key_pressed_ffi(key)
}

///|
extern "c" fn is_key_pressed_repeat_ffi(key : Int) -> Bool = "IsKeyPressedRepeat"

///|
pub fn is_key_pressed_repeat(key : Int) -> Bool {
  is_key_pressed_repeat_ffi(key)
}

///|
extern "c" fn is_key_down_ffi(key : Int) -> Bool = "IsKeyDown"

///|
pub fn is_key_down(key : Int) -> Bool {
  is_key_down_ffi(key)
}

///|
extern "c" fn is_key_released_ffi(key : Int) -> Bool = "IsKeyReleased"

///|
pub fn is_key_released(key : Int) -> Bool {
  is_key_released_ffi(key)
}

///|
extern "c" fn is_key_up_ffi(key : Int) -> Bool = "IsKeyUp"

///|
pub fn is_key_up(key : Int) -> Bool {
  is_key_up_ffi(key)
}

///|
extern "c" fn get_key_pressed_ffi() -> Int = "GetKeyPressed"

///|
pub fn get_key_pressed() -> Int {
  get_key_pressed_ffi()
}

///|
extern "c" fn get_char_pressed_ffi() -> Int = "GetCharPressed"

///|
pub fn get_char_pressed() -> Int {
  get_char_pressed_ffi()
}

///|
extern "c" fn set_exit_key_ffi(key : Int) = "SetExitKey"

///|
pub fn set_exit_key(key : Int) -> Unit {
  set_exit_key_ffi(key)
}

// ============================================================================
// Mouse input
// ============================================================================

///|
extern "c" fn is_mouse_button_pressed_ffi(button : Int) -> Bool = "IsMouseButtonPressed"

///|
pub fn is_mouse_button_pressed(button : Int) -> Bool {
  is_mouse_button_pressed_ffi(button)
}

///|
extern "c" fn is_mouse_button_down_ffi(button : Int) -> Bool = "IsMouseButtonDown"

///|
pub fn is_mouse_button_down(button : Int) -> Bool {
  is_mouse_button_down_ffi(button)
}

///|
extern "c" fn is_mouse_button_released_ffi(button : Int) -> Bool = "IsMouseButtonReleased"

///|
pub fn is_mouse_button_released(button : Int) -> Bool {
  is_mouse_button_released_ffi(button)
}

///|
extern "c" fn is_mouse_button_up_ffi(button : Int) -> Bool = "IsMouseButtonUp"

///|
pub fn is_mouse_button_up(button : Int) -> Bool {
  is_mouse_button_up_ffi(button)
}

///|
extern "c" fn get_mouse_x_ffi() -> Int = "GetMouseX"

///|
pub fn get_mouse_x() -> Int {
  get_mouse_x_ffi()
}

///|
extern "c" fn get_mouse_y_ffi() -> Int = "GetMouseY"

///|
pub fn get_mouse_y() -> Int {
  get_mouse_y_ffi()
}

///|
extern "c" fn get_mouse_position_ffi() -> Bytes = "moonbit_GetMousePosition"

///|
pub fn get_mouse_position() -> Vector2 {
  Vector2::from_bytes(get_mouse_position_ffi())
}

///|
extern "c" fn get_mouse_delta_ffi() -> Bytes = "moonbit_GetMouseDelta"

///|
pub fn get_mouse_delta() -> Vector2 {
  Vector2::from_bytes(get_mouse_delta_ffi())
}

///|
extern "c" fn set_mouse_position_ffi(x : Int, y : Int) = "SetMousePosition"

///|
pub fn set_mouse_position(x : Int, y : Int) -> Unit {
  set_mouse_position_ffi(x, y)
}

///|
extern "c" fn set_mouse_offset_ffi(offset_x : Int, offset_y : Int) = "SetMouseOffset"

///|
pub fn set_mouse_offset(offset_x : Int, offset_y : Int) -> Unit {
  set_mouse_offset_ffi(offset_x, offset_y)
}

///|
extern "c" fn set_mouse_scale_ffi(scale_x : Float, scale_y : Float) = "SetMouseScale"

///|
pub fn set_mouse_scale(scale_x : Float, scale_y : Float) -> Unit {
  set_mouse_scale_ffi(scale_x, scale_y)
}

///|
extern "c" fn get_mouse_wheel_move_ffi() -> Float = "GetMouseWheelMove"

///|
pub fn get_mouse_wheel_move() -> Float {
  get_mouse_wheel_move_ffi()
}

///|
extern "c" fn get_mouse_wheel_move_v_ffi() -> Bytes = "moonbit_GetMouseWheelMoveV"

///|
pub fn get_mouse_wheel_move_v() -> Vector2 {
  Vector2::from_bytes(get_mouse_wheel_move_v_ffi())
}

///|
extern "c" fn set_mouse_cursor_ffi(cursor : Int) = "SetMouseCursor"

///|
pub fn set_mouse_cursor(cursor : Int) -> Unit {
  set_mouse_cursor_ffi(cursor)
}

// ============================================================================
// Camera
// ============================================================================

///|
#borrow(camera)
extern "c" fn update_camera_ffi(camera : Bytes, mode : Int) -> Bytes = "moonbit_UpdateCamera"

///|
pub fn update_camera(camera : Camera3D, mode : Int) -> Camera3D {
  Camera3D::from_bytes(update_camera_ffi(camera.to_bytes(), mode))
}

///|
#borrow(camera, movement, rotation)
extern "c" fn update_camera_pro_ffi(
  camera : Bytes,
  movement : Bytes,
  rotation : Bytes,
  zoom : Float,
) -> Bytes = "moonbit_UpdateCameraPro"

///|
pub fn update_camera_pro(
  camera : Camera3D,
  movement : Vector3,
  rotation : Vector3,
  zoom : Float,
) -> Camera3D {
  Camera3D::from_bytes(
    update_camera_pro_ffi(
      camera.to_bytes(),
      movement.to_bytes(),
      rotation.to_bytes(),
      zoom,
    ),
  )
}

///|
#borrow(position, camera)
extern "c" fn get_world_to_screen_ffi(
  position : Bytes,
  camera : Bytes,
) -> Bytes = "moonbit_GetWorldToScreen"

///|
pub fn get_world_to_screen(position : Vector3, camera : Camera3D) -> Vector2 {
  Vector2::from_bytes(
    get_world_to_screen_ffi(position.to_bytes(), camera.to_bytes()),
  )
}

///|
#borrow(position, camera)
extern "c" fn get_screen_to_world_2d_ffi(
  position : Bytes,
  camera : Bytes,
) -> Bytes = "moonbit_GetScreenToWorld2D"

///|
pub fn get_screen_to_world_2d(position : Vector2, camera : Camera2D) -> Vector2 {
  Vector2::from_bytes(
    get_screen_to_world_2d_ffi(position.to_bytes(), camera.to_bytes()),
  )
}

///|
#borrow(position, camera)
extern "c" fn get_world_to_screen_2d_ffi(
  position : Bytes,
  camera : Bytes,
) -> Bytes = "moonbit_GetWorldToScreen2D"

///|
pub fn get_world_to_screen_2d(position : Vector2, camera : Camera2D) -> Vector2 {
  Vector2::from_bytes(
    get_world_to_screen_2d_ffi(position.to_bytes(), camera.to_bytes()),
  )
}

// ============================================================================
// Misc
// ============================================================================

///|
extern "c" fn set_trace_log_level_ffi(log_level : Int) = "SetTraceLogLevel"

///|
pub fn set_trace_log_level(log_level : Int) -> Unit {
  set_trace_log_level_ffi(log_level)
}

///|
#borrow(file_name)
extern "c" fn take_screenshot_ffi(file_name : Bytes) = "moonbit_TakeScreenshot"

///|
pub fn take_screenshot(file_name : String) -> Unit {
  take_screenshot_ffi(@utf8.encode(file_name))
}

///|
#borrow(url)
extern "c" fn open_url_ffi(url : Bytes) = "moonbit_OpenURL"

///|
pub fn open_url(url : String) -> Unit {
  open_url_ffi(@utf8.encode(url))
}

///|
extern "c" fn get_random_value_ffi(min : Int, max : Int) -> Int = "GetRandomValue"

///|
pub fn get_random_value(min : Int, max : Int) -> Int {
  get_random_value_ffi(min, max)
}

///|
extern "c" fn set_random_seed_ffi(seed : Int) = "SetRandomSeed"

///|
pub fn set_random_seed(seed : Int) -> Unit {
  set_random_seed_ffi(seed)
}

// ============================================================================
// Color utilities
// ============================================================================

///|
#borrow(color)
extern "c" fn fade_ffi(color : Bytes, alpha : Float) -> Bytes = "moonbit_Fade"

///|
pub fn fade(color : Color, alpha : Float) -> Color {
  Color::from_bytes(fade_ffi(color.to_bytes(), alpha))
}

///|
#borrow(color)
extern "c" fn color_alpha_ffi(color : Bytes, alpha : Float) -> Bytes = "moonbit_ColorAlpha"

///|
pub fn color_alpha(color : Color, alpha : Float) -> Color {
  Color::from_bytes(color_alpha_ffi(color.to_bytes(), alpha))
}

///|
#borrow(color)
extern "c" fn color_to_int_ffi(color : Bytes) -> Int = "moonbit_ColorToInt"

///|
pub fn color_to_int(color : Color) -> Int {
  color_to_int_ffi(color.to_bytes())
}

///|
extern "c" fn get_color_ffi(hex_value : Int) -> Bytes = "moonbit_GetColor"

///|
pub fn get_color(hex_value : Int) -> Color {
  Color::from_bytes(get_color_ffi(hex_value))
}

///|
extern "c" fn color_from_hsv_ffi(
  hue : Float,
  saturation : Float,
  value : Float,
) -> Bytes = "moonbit_ColorFromHSV"

///|
pub fn color_from_hsv(hue : Float, saturation : Float, value : Float) -> Color {
  Color::from_bytes(color_from_hsv_ffi(hue, saturation, value))
}

///|
#borrow(color, tint)
extern "c" fn color_tint_ffi(color : Bytes, tint : Bytes) -> Bytes = "moonbit_ColorTint"

///|
pub fn color_tint(color : Color, tint : Color) -> Color {
  Color::from_bytes(color_tint_ffi(color.to_bytes(), tint.to_bytes()))
}

///|
#borrow(color)
extern "c" fn color_brightness_ffi(color : Bytes, factor : Float) -> Bytes = "moonbit_ColorBrightness"

///|
pub fn color_brightness(color : Color, factor : Float) -> Color {
  Color::from_bytes(color_brightness_ffi(color.to_bytes(), factor))
}

///|
#borrow(color1, color2)
extern "c" fn color_lerp_ffi(
  color1 : Bytes,
  color2 : Bytes,
  factor : Float,
) -> Bytes = "moonbit_ColorLerp"

///|
pub fn color_lerp(color1 : Color, color2 : Color, factor : Float) -> Color {
  Color::from_bytes(
    color_lerp_ffi(color1.to_bytes(), color2.to_bytes(), factor),
  )
}

///|
#borrow(col1, col2)
extern "c" fn color_is_equal_ffi(col1 : Bytes, col2 : Bytes) -> Bool = "moonbit_ColorIsEqual"

///|
pub fn color_is_equal(col1 : Color, col2 : Color) -> Bool {
  color_is_equal_ffi(col1.to_bytes(), col2.to_bytes())
}
