// ============================================================================
// Window management
// ============================================================================

///|
#borrow(title)
extern "c" fn raylib_init_window(width : Int, height : Int, title : Bytes) = "moonbit_raylib_init_window"

///|
pub fn init_window(width : Int, height : Int, title : String) -> Unit {
  raylib_init_window(width, height, @utf8.encode(title))
}

///|
extern "c" fn raylib_close_window() = "CloseWindow"

///|
pub fn close_window() -> Unit {
  raylib_close_window()
}

///|
extern "c" fn raylib_window_should_close() -> Bool = "WindowShouldClose"

///|
pub fn window_should_close() -> Bool {
  raylib_window_should_close()
}

///|
extern "c" fn raylib_is_window_ready() -> Bool = "IsWindowReady"

///|
pub fn is_window_ready() -> Bool {
  raylib_is_window_ready()
}

///|
extern "c" fn raylib_is_window_fullscreen() -> Bool = "IsWindowFullscreen"

///|
pub fn is_window_fullscreen() -> Bool {
  raylib_is_window_fullscreen()
}

///|
extern "c" fn raylib_is_window_hidden() -> Bool = "IsWindowHidden"

///|
pub fn is_window_hidden() -> Bool {
  raylib_is_window_hidden()
}

///|
extern "c" fn raylib_is_window_minimized() -> Bool = "IsWindowMinimized"

///|
pub fn is_window_minimized() -> Bool {
  raylib_is_window_minimized()
}

///|
extern "c" fn raylib_is_window_maximized() -> Bool = "IsWindowMaximized"

///|
pub fn is_window_maximized() -> Bool {
  raylib_is_window_maximized()
}

///|
extern "c" fn raylib_is_window_focused() -> Bool = "IsWindowFocused"

///|
pub fn is_window_focused() -> Bool {
  raylib_is_window_focused()
}

///|
extern "c" fn raylib_is_window_resized() -> Bool = "IsWindowResized"

///|
pub fn is_window_resized() -> Bool {
  raylib_is_window_resized()
}

///|
#borrow(title)
extern "c" fn raylib_set_window_title(title : Bytes) = "moonbit_raylib_set_window_title"

///|
pub fn set_window_title(title : String) -> Unit {
  raylib_set_window_title(@utf8.encode(title))
}

///|
extern "c" fn raylib_set_window_size(width : Int, height : Int) = "SetWindowSize"

///|
pub fn set_window_size(width : Int, height : Int) -> Unit {
  raylib_set_window_size(width, height)
}

///|
extern "c" fn raylib_set_window_position(x : Int, y : Int) = "SetWindowPosition"

///|
pub fn set_window_position(x : Int, y : Int) -> Unit {
  raylib_set_window_position(x, y)
}

///|
extern "c" fn raylib_set_window_min_size(width : Int, height : Int) = "SetWindowMinSize"

///|
pub fn set_window_min_size(width : Int, height : Int) -> Unit {
  raylib_set_window_min_size(width, height)
}

///|
extern "c" fn raylib_set_window_max_size(width : Int, height : Int) = "SetWindowMaxSize"

///|
pub fn set_window_max_size(width : Int, height : Int) -> Unit {
  raylib_set_window_max_size(width, height)
}

///|
extern "c" fn raylib_set_window_opacity(opacity : Float) = "SetWindowOpacity"

///|
pub fn set_window_opacity(opacity : Float) -> Unit {
  raylib_set_window_opacity(opacity)
}

///|
extern "c" fn raylib_set_window_focused() = "SetWindowFocused"

///|
pub fn set_window_focused() -> Unit {
  raylib_set_window_focused()
}

///|
extern "c" fn raylib_get_screen_width() -> Int = "GetScreenWidth"

///|
pub fn get_screen_width() -> Int {
  raylib_get_screen_width()
}

///|
extern "c" fn raylib_get_screen_height() -> Int = "GetScreenHeight"

///|
pub fn get_screen_height() -> Int {
  raylib_get_screen_height()
}

///|
extern "c" fn raylib_get_render_width() -> Int = "GetRenderWidth"

///|
pub fn get_render_width() -> Int {
  raylib_get_render_width()
}

///|
extern "c" fn raylib_get_render_height() -> Int = "GetRenderHeight"

///|
pub fn get_render_height() -> Int {
  raylib_get_render_height()
}

///|
extern "c" fn raylib_toggle_fullscreen() = "ToggleFullscreen"

///|
pub fn toggle_fullscreen() -> Unit {
  raylib_toggle_fullscreen()
}

///|
extern "c" fn raylib_toggle_borderless_windowed() = "ToggleBorderlessWindowed"

///|
pub fn toggle_borderless_windowed() -> Unit {
  raylib_toggle_borderless_windowed()
}

///|
extern "c" fn raylib_maximize_window() = "MaximizeWindow"

///|
pub fn maximize_window() -> Unit {
  raylib_maximize_window()
}

///|
extern "c" fn raylib_minimize_window() = "MinimizeWindow"

///|
pub fn minimize_window() -> Unit {
  raylib_minimize_window()
}

///|
extern "c" fn raylib_restore_window() = "RestoreWindow"

///|
pub fn restore_window() -> Unit {
  raylib_restore_window()
}

///|
extern "c" fn raylib_set_config_flags(flags : Int) = "SetConfigFlags"

///|
pub fn set_config_flags(flags : Int) -> Unit {
  raylib_set_config_flags(flags)
}

///|
extern "c" fn raylib_set_window_state(flags : Int) = "SetWindowState"

///|
pub fn set_window_state(flags : Int) -> Unit {
  raylib_set_window_state(flags)
}

///|
extern "c" fn raylib_clear_window_state(flags : Int) = "ClearWindowState"

///|
pub fn clear_window_state(flags : Int) -> Unit {
  raylib_clear_window_state(flags)
}

// ============================================================================
// Cursor
// ============================================================================

///|
extern "c" fn raylib_show_cursor() = "ShowCursor"

///|
pub fn show_cursor() -> Unit {
  raylib_show_cursor()
}

///|
extern "c" fn raylib_hide_cursor() = "HideCursor"

///|
pub fn hide_cursor() -> Unit {
  raylib_hide_cursor()
}

///|
extern "c" fn raylib_is_cursor_hidden() -> Bool = "IsCursorHidden"

///|
pub fn is_cursor_hidden() -> Bool {
  raylib_is_cursor_hidden()
}

///|
extern "c" fn raylib_enable_cursor() = "EnableCursor"

///|
pub fn enable_cursor() -> Unit {
  raylib_enable_cursor()
}

///|
extern "c" fn raylib_disable_cursor() = "DisableCursor"

///|
pub fn disable_cursor() -> Unit {
  raylib_disable_cursor()
}

///|
extern "c" fn raylib_is_cursor_on_screen() -> Bool = "IsCursorOnScreen"

///|
pub fn is_cursor_on_screen() -> Bool {
  raylib_is_cursor_on_screen()
}

// ============================================================================
// Drawing
// ============================================================================

///|
#borrow(color)
extern "c" fn raylib_clear_background(color : Bytes) = "moonbit_raylib_clear_background"

///|
pub fn clear_background(color : Color) -> Unit {
  raylib_clear_background(color.to_bytes())
}

///|
extern "c" fn raylib_begin_drawing() = "BeginDrawing"

///|
pub fn begin_drawing() -> Unit {
  raylib_begin_drawing()
}

///|
extern "c" fn raylib_end_drawing() = "EndDrawing"

///|
pub fn end_drawing() -> Unit {
  raylib_end_drawing()
}

///|
#borrow(camera)
extern "c" fn raylib_begin_mode_2d(camera : Bytes) = "moonbit_raylib_begin_mode_2d"

///|
pub fn begin_mode_2d(camera : Camera2D) -> Unit {
  raylib_begin_mode_2d(camera.to_bytes())
}

///|
extern "c" fn raylib_end_mode_2d() = "EndMode2D"

///|
pub fn end_mode_2d() -> Unit {
  raylib_end_mode_2d()
}

///|
#borrow(camera)
extern "c" fn raylib_begin_mode_3d(camera : Bytes) = "moonbit_raylib_begin_mode_3d"

///|
pub fn begin_mode_3d(camera : Camera3D) -> Unit {
  raylib_begin_mode_3d(camera.to_bytes())
}

///|
extern "c" fn raylib_end_mode_3d() = "EndMode3D"

///|
pub fn end_mode_3d() -> Unit {
  raylib_end_mode_3d()
}

///|
extern "c" fn raylib_begin_scissor_mode(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) = "BeginScissorMode"

///|
pub fn begin_scissor_mode(x : Int, y : Int, width : Int, height : Int) -> Unit {
  raylib_begin_scissor_mode(x, y, width, height)
}

///|
extern "c" fn raylib_end_scissor_mode() = "EndScissorMode"

///|
pub fn end_scissor_mode() -> Unit {
  raylib_end_scissor_mode()
}

///|
extern "c" fn raylib_begin_blend_mode(mode : Int) = "BeginBlendMode"

///|
pub fn begin_blend_mode(mode : Int) -> Unit {
  raylib_begin_blend_mode(mode)
}

///|
extern "c" fn raylib_end_blend_mode() = "EndBlendMode"

///|
pub fn end_blend_mode() -> Unit {
  raylib_end_blend_mode()
}

///|
#borrow(target)
extern "c" fn raylib_begin_texture_mode(target : RenderTexture) = "moonbit_raylib_begin_texture_mode"

///|
pub fn begin_texture_mode(target : RenderTexture) -> Unit {
  raylib_begin_texture_mode(target)
}

///|
extern "c" fn raylib_end_texture_mode() = "EndTextureMode"

///|
pub fn end_texture_mode() -> Unit {
  raylib_end_texture_mode()
}

// ============================================================================
// Timing
// ============================================================================

///|
extern "c" fn raylib_set_target_fps(fps : Int) = "SetTargetFPS"

///|
pub fn set_target_fps(fps : Int) -> Unit {
  raylib_set_target_fps(fps)
}

///|
extern "c" fn raylib_get_frame_time() -> Float = "GetFrameTime"

///|
pub fn get_frame_time() -> Float {
  raylib_get_frame_time()
}

///|
extern "c" fn raylib_get_time() -> Double = "GetTime"

///|
pub fn get_time() -> Double {
  raylib_get_time()
}

///|
extern "c" fn raylib_get_fps() -> Int = "GetFPS"

///|
pub fn get_fps() -> Int {
  raylib_get_fps()
}

// ============================================================================
// Keyboard input
// ============================================================================

///|
extern "c" fn raylib_is_key_pressed(key : Int) -> Bool = "IsKeyPressed"

///|
pub fn is_key_pressed(key : Int) -> Bool {
  raylib_is_key_pressed(key)
}

///|
extern "c" fn raylib_is_key_pressed_repeat(key : Int) -> Bool = "IsKeyPressedRepeat"

///|
pub fn is_key_pressed_repeat(key : Int) -> Bool {
  raylib_is_key_pressed_repeat(key)
}

///|
extern "c" fn raylib_is_key_down(key : Int) -> Bool = "IsKeyDown"

///|
pub fn is_key_down(key : Int) -> Bool {
  raylib_is_key_down(key)
}

///|
extern "c" fn raylib_is_key_released(key : Int) -> Bool = "IsKeyReleased"

///|
pub fn is_key_released(key : Int) -> Bool {
  raylib_is_key_released(key)
}

///|
extern "c" fn raylib_is_key_up(key : Int) -> Bool = "IsKeyUp"

///|
pub fn is_key_up(key : Int) -> Bool {
  raylib_is_key_up(key)
}

///|
extern "c" fn raylib_get_key_pressed() -> Int = "GetKeyPressed"

///|
pub fn get_key_pressed() -> Int {
  raylib_get_key_pressed()
}

///|
extern "c" fn raylib_get_char_pressed() -> Int = "GetCharPressed"

///|
pub fn get_char_pressed() -> Int {
  raylib_get_char_pressed()
}

///|
extern "c" fn raylib_set_exit_key(key : Int) = "SetExitKey"

///|
pub fn set_exit_key(key : Int) -> Unit {
  raylib_set_exit_key(key)
}

// ============================================================================
// Mouse input
// ============================================================================

///|
extern "c" fn raylib_is_mouse_button_pressed(button : Int) -> Bool = "IsMouseButtonPressed"

///|
pub fn is_mouse_button_pressed(button : Int) -> Bool {
  raylib_is_mouse_button_pressed(button)
}

///|
extern "c" fn raylib_is_mouse_button_down(button : Int) -> Bool = "IsMouseButtonDown"

///|
pub fn is_mouse_button_down(button : Int) -> Bool {
  raylib_is_mouse_button_down(button)
}

///|
extern "c" fn raylib_is_mouse_button_released(button : Int) -> Bool = "IsMouseButtonReleased"

///|
pub fn is_mouse_button_released(button : Int) -> Bool {
  raylib_is_mouse_button_released(button)
}

///|
extern "c" fn raylib_is_mouse_button_up(button : Int) -> Bool = "IsMouseButtonUp"

///|
pub fn is_mouse_button_up(button : Int) -> Bool {
  raylib_is_mouse_button_up(button)
}

///|
extern "c" fn raylib_get_mouse_x() -> Int = "GetMouseX"

///|
pub fn get_mouse_x() -> Int {
  raylib_get_mouse_x()
}

///|
extern "c" fn raylib_get_mouse_y() -> Int = "GetMouseY"

///|
pub fn get_mouse_y() -> Int {
  raylib_get_mouse_y()
}

///|
extern "c" fn raylib_get_mouse_position() -> Bytes = "moonbit_raylib_get_mouse_position"

///|
pub fn get_mouse_position() -> Vector2 {
  Vector2::from_bytes(raylib_get_mouse_position())
}

///|
extern "c" fn raylib_get_mouse_delta() -> Bytes = "moonbit_raylib_get_mouse_delta"

///|
pub fn get_mouse_delta() -> Vector2 {
  Vector2::from_bytes(raylib_get_mouse_delta())
}

///|
extern "c" fn raylib_set_mouse_position(x : Int, y : Int) = "SetMousePosition"

///|
pub fn set_mouse_position(x : Int, y : Int) -> Unit {
  raylib_set_mouse_position(x, y)
}

///|
extern "c" fn raylib_set_mouse_offset(offset_x : Int, offset_y : Int) = "SetMouseOffset"

///|
pub fn set_mouse_offset(offset_x : Int, offset_y : Int) -> Unit {
  raylib_set_mouse_offset(offset_x, offset_y)
}

///|
extern "c" fn raylib_set_mouse_scale(scale_x : Float, scale_y : Float) = "SetMouseScale"

///|
pub fn set_mouse_scale(scale_x : Float, scale_y : Float) -> Unit {
  raylib_set_mouse_scale(scale_x, scale_y)
}

///|
extern "c" fn raylib_get_mouse_wheel_move() -> Float = "GetMouseWheelMove"

///|
pub fn get_mouse_wheel_move() -> Float {
  raylib_get_mouse_wheel_move()
}

///|
extern "c" fn raylib_get_mouse_wheel_move_v() -> Bytes = "moonbit_raylib_get_mouse_wheel_move_v"

///|
pub fn get_mouse_wheel_move_v() -> Vector2 {
  Vector2::from_bytes(raylib_get_mouse_wheel_move_v())
}

///|
extern "c" fn raylib_set_mouse_cursor(cursor : Int) = "SetMouseCursor"

///|
pub fn set_mouse_cursor(cursor : Int) -> Unit {
  raylib_set_mouse_cursor(cursor)
}

// ============================================================================
// Camera
// ============================================================================

///|
#borrow(camera)
extern "c" fn raylib_update_camera(camera : Bytes, mode : Int) -> Bytes = "moonbit_raylib_update_camera"

///|
pub fn update_camera(camera : Camera3D, mode : Int) -> Camera3D {
  Camera3D::from_bytes(raylib_update_camera(camera.to_bytes(), mode))
}

///|
#borrow(camera, movement, rotation)
extern "c" fn raylib_update_camera_pro(
  camera : Bytes,
  movement : Bytes,
  rotation : Bytes,
  zoom : Float,
) -> Bytes = "moonbit_raylib_update_camera_pro"

///|
pub fn update_camera_pro(
  camera : Camera3D,
  movement : Vector3,
  rotation : Vector3,
  zoom : Float,
) -> Camera3D {
  Camera3D::from_bytes(
    raylib_update_camera_pro(
      camera.to_bytes(),
      movement.to_bytes(),
      rotation.to_bytes(),
      zoom,
    ),
  )
}

///|
#borrow(position, camera)
extern "c" fn raylib_get_world_to_screen(
  position : Bytes,
  camera : Bytes,
) -> Bytes = "moonbit_raylib_get_world_to_screen"

///|
pub fn get_world_to_screen(position : Vector3, camera : Camera3D) -> Vector2 {
  Vector2::from_bytes(
    raylib_get_world_to_screen(position.to_bytes(), camera.to_bytes()),
  )
}

///|
#borrow(position, camera)
extern "c" fn raylib_get_screen_to_world_2d(
  position : Bytes,
  camera : Bytes,
) -> Bytes = "moonbit_raylib_get_screen_to_world_2d"

///|
pub fn get_screen_to_world_2d(position : Vector2, camera : Camera2D) -> Vector2 {
  Vector2::from_bytes(
    raylib_get_screen_to_world_2d(position.to_bytes(), camera.to_bytes()),
  )
}

///|
#borrow(position, camera)
extern "c" fn raylib_get_world_to_screen_2d(
  position : Bytes,
  camera : Bytes,
) -> Bytes = "moonbit_raylib_get_world_to_screen_2d"

///|
pub fn get_world_to_screen_2d(position : Vector2, camera : Camera2D) -> Vector2 {
  Vector2::from_bytes(
    raylib_get_world_to_screen_2d(position.to_bytes(), camera.to_bytes()),
  )
}

// ============================================================================
// Misc
// ============================================================================

///|
extern "c" fn raylib_set_trace_log_level(log_level : Int) = "SetTraceLogLevel"

///|
pub fn set_trace_log_level(log_level : Int) -> Unit {
  raylib_set_trace_log_level(log_level)
}

///|
#borrow(file_name)
extern "c" fn raylib_take_screenshot(file_name : Bytes) = "moonbit_raylib_take_screenshot"

///|
pub fn take_screenshot(file_name : String) -> Unit {
  raylib_take_screenshot(@utf8.encode(file_name))
}

///|
#borrow(url)
extern "c" fn raylib_open_url(url : Bytes) = "moonbit_raylib_open_url"

///|
pub fn open_url(url : String) -> Unit {
  raylib_open_url(@utf8.encode(url))
}

///|
extern "c" fn raylib_get_random_value(min : Int, max : Int) -> Int = "GetRandomValue"

///|
pub fn get_random_value(min : Int, max : Int) -> Int {
  raylib_get_random_value(min, max)
}

///|
extern "c" fn raylib_set_random_seed(seed : Int) = "SetRandomSeed"

///|
pub fn set_random_seed(seed : Int) -> Unit {
  raylib_set_random_seed(seed)
}

// ============================================================================
// Color utilities
// ============================================================================

///|
#borrow(color)
extern "c" fn raylib_fade(color : Bytes, alpha : Float) -> Bytes = "moonbit_raylib_fade"

///|
pub fn fade(color : Color, alpha : Float) -> Color {
  Color::from_bytes(raylib_fade(color.to_bytes(), alpha))
}

///|
#borrow(color)
extern "c" fn raylib_color_alpha(color : Bytes, alpha : Float) -> Bytes = "moonbit_raylib_color_alpha"

///|
pub fn color_alpha(color : Color, alpha : Float) -> Color {
  Color::from_bytes(raylib_color_alpha(color.to_bytes(), alpha))
}

///|
#borrow(color)
extern "c" fn raylib_color_to_int(color : Bytes) -> Int = "moonbit_raylib_color_to_int"

///|
pub fn color_to_int(color : Color) -> Int {
  raylib_color_to_int(color.to_bytes())
}

///|
extern "c" fn raylib_get_color(hex_value : Int) -> Bytes = "moonbit_raylib_get_color"

///|
pub fn get_color(hex_value : Int) -> Color {
  Color::from_bytes(raylib_get_color(hex_value))
}

///|
extern "c" fn raylib_color_from_hsv(
  hue : Float,
  saturation : Float,
  value : Float,
) -> Bytes = "moonbit_raylib_color_from_hsv"

///|
pub fn color_from_hsv(hue : Float, saturation : Float, value : Float) -> Color {
  Color::from_bytes(raylib_color_from_hsv(hue, saturation, value))
}

///|
#borrow(color, tint)
extern "c" fn raylib_color_tint(color : Bytes, tint : Bytes) -> Bytes = "moonbit_raylib_color_tint"

///|
pub fn color_tint(color : Color, tint : Color) -> Color {
  Color::from_bytes(raylib_color_tint(color.to_bytes(), tint.to_bytes()))
}

///|
#borrow(color)
extern "c" fn raylib_color_brightness(color : Bytes, factor : Float) -> Bytes = "moonbit_raylib_color_brightness"

///|
pub fn color_brightness(color : Color, factor : Float) -> Color {
  Color::from_bytes(raylib_color_brightness(color.to_bytes(), factor))
}

///|
#borrow(color1, color2)
extern "c" fn raylib_color_lerp(
  color1 : Bytes,
  color2 : Bytes,
  factor : Float,
) -> Bytes = "moonbit_raylib_color_lerp"

///|
pub fn color_lerp(color1 : Color, color2 : Color, factor : Float) -> Color {
  Color::from_bytes(
    raylib_color_lerp(color1.to_bytes(), color2.to_bytes(), factor),
  )
}

///|
#borrow(col1, col2)
extern "c" fn raylib_color_is_equal(col1 : Bytes, col2 : Bytes) -> Bool = "moonbit_raylib_color_is_equal"

///|
pub fn color_is_equal(col1 : Color, col2 : Color) -> Bool {
  raylib_color_is_equal(col1.to_bytes(), col2.to_bytes())
}
