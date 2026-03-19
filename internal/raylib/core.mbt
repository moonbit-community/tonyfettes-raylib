// ============================================================================
// Window management
// ============================================================================

///|
#borrow(title)
pub extern "c" fn init_window(width : Int, height : Int, title : Bytes) = "moonbit_raylib_init_window"

///|
/// Close window and unload OpenGL context.
pub extern "c" fn close_window() = "CloseWindow"

///|
/// Check if application should close (KEY_ESCAPE pressed or windows close icon clicked).
pub extern "c" fn window_should_close() -> Bool = "moonbit_raylib_window_should_close"

///|
/// Check if window has been initialized successfully.
pub extern "c" fn is_window_ready() -> Bool = "moonbit_raylib_is_window_ready"

///|
/// Check if window is currently fullscreen.
pub extern "c" fn is_window_fullscreen() -> Bool = "moonbit_raylib_is_window_fullscreen"

///|
/// Check if window is currently hidden.
pub extern "c" fn is_window_hidden() -> Bool = "moonbit_raylib_is_window_hidden"

///|
/// Check if window is currently minimized.
pub extern "c" fn is_window_minimized() -> Bool = "moonbit_raylib_is_window_minimized"

///|
/// Check if window is currently maximized.
pub extern "c" fn is_window_maximized() -> Bool = "moonbit_raylib_is_window_maximized"

///|
/// Check if window is currently focused.
pub extern "c" fn is_window_focused() -> Bool = "moonbit_raylib_is_window_focused"

///|
/// Check if window has been resized last frame.
pub extern "c" fn is_window_resized() -> Bool = "moonbit_raylib_is_window_resized"

///|
#borrow(title)
pub extern "c" fn set_window_title(title : Bytes) = "moonbit_raylib_set_window_title"

///|
/// Set window dimensions.
pub extern "c" fn set_window_size(width : Int, height : Int) = "SetWindowSize"

///|
/// Set window position on screen.
pub extern "c" fn set_window_position(x : Int, y : Int) = "SetWindowPosition"

///|
/// Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE).
pub extern "c" fn set_window_min_size(width : Int, height : Int) = "SetWindowMinSize"

///|
/// Set window maximum dimensions (for FLAG_WINDOW_RESIZABLE).
pub extern "c" fn set_window_max_size(width : Int, height : Int) = "SetWindowMaxSize"

///|
/// Set window opacity [0.0f..1.0f].
pub extern "c" fn set_window_opacity(opacity : Float) = "SetWindowOpacity"

///|
/// Set window focused.
pub extern "c" fn set_window_focused() = "SetWindowFocused"

///|
/// Get current screen width.
pub extern "c" fn get_screen_width() -> Int = "GetScreenWidth"

///|
/// Get current screen height.
pub extern "c" fn get_screen_height() -> Int = "GetScreenHeight"

///|
/// Get current render width (it considers HiDPI).
pub extern "c" fn get_render_width() -> Int = "GetRenderWidth"

///|
/// Get current render height (it considers HiDPI).
pub extern "c" fn get_render_height() -> Int = "GetRenderHeight"

///|
/// Toggle window state: fullscreen/windowed, resizes monitor to match window resolution.
pub extern "c" fn toggle_fullscreen() = "ToggleFullscreen"

///|
/// Toggle window state: borderless windowed, resizes window to match monitor resolution.
pub extern "c" fn toggle_borderless_windowed() = "ToggleBorderlessWindowed"

///|
/// Set window state: maximized, if resizable.
pub extern "c" fn maximize_window() = "MaximizeWindow"

///|
/// Set window state: minimized, if resizable.
pub extern "c" fn minimize_window() = "MinimizeWindow"

///|
/// Set window state: not minimized/maximized.
pub extern "c" fn restore_window() = "RestoreWindow"

///|
/// Setup init configuration flags (view FLAGS).
pub extern "c" fn set_config_flags(flags : Int) = "SetConfigFlags"

///|
/// Set window configuration state using flags.
pub extern "c" fn set_window_state(flags : Int) = "SetWindowState"

///|
/// Clear window configuration state flags.
pub extern "c" fn clear_window_state(flags : Int) = "ClearWindowState"

///|
/// Check if one specific window flag is enabled.
pub extern "c" fn is_window_state(flag : Int) -> Bool = "moonbit_raylib_is_window_state"

///|
pub extern "c" fn get_window_position() -> Bytes = "moonbit_raylib_get_window_position"

///|
pub extern "c" fn get_window_scale_dpi() -> Bytes = "moonbit_raylib_get_window_scale_dpi"

// ============================================================================
// Monitor management
// ============================================================================

///|
/// Get number of connected monitors.
pub extern "c" fn get_monitor_count() -> Int = "GetMonitorCount"

///|
/// Get current monitor where window is placed.
pub extern "c" fn get_current_monitor() -> Int = "GetCurrentMonitor"

///|
/// Get specified monitor width (current video mode used by monitor).
pub extern "c" fn get_monitor_width(monitor : Int) -> Int = "GetMonitorWidth"

///|
/// Get specified monitor height (current video mode used by monitor).
pub extern "c" fn get_monitor_height(monitor : Int) -> Int = "GetMonitorHeight"

///|
/// Get specified monitor physical width in millimetres.
pub extern "c" fn get_monitor_physical_width(monitor : Int) -> Int = "GetMonitorPhysicalWidth"

///|
/// Get specified monitor physical height in millimetres.
pub extern "c" fn get_monitor_physical_height(monitor : Int) -> Int = "GetMonitorPhysicalHeight"

///|
/// Get specified monitor refresh rate.
pub extern "c" fn get_monitor_refresh_rate(monitor : Int) -> Int = "GetMonitorRefreshRate"

///|
pub extern "c" fn get_monitor_position(monitor : Int) -> Bytes = "moonbit_raylib_get_monitor_position"

///|
pub extern "c" fn get_monitor_name(monitor : Int) -> Bytes = "moonbit_raylib_get_monitor_name"

///|
pub extern "c" fn set_window_monitor(monitor : Int) = "SetWindowMonitor"

// ============================================================================
// Clipboard
// ============================================================================

///|
#borrow(text)
pub extern "c" fn set_clipboard_text(text : Bytes) = "moonbit_raylib_set_clipboard_text"

///|
pub extern "c" fn get_clipboard_text() -> Bytes = "moonbit_raylib_get_clipboard_text"

// ============================================================================
// Event waiting
// ============================================================================

///|
pub extern "c" fn enable_event_waiting() = "EnableEventWaiting"

///|
pub extern "c" fn disable_event_waiting() = "DisableEventWaiting"

// ============================================================================
// Custom frame control
// ============================================================================

///|
pub extern "c" fn swap_screen_buffer() = "SwapScreenBuffer"

///|
pub extern "c" fn poll_input_events() = "PollInputEvents"

///|
pub extern "c" fn wait_time(seconds : Double) = "WaitTime"

// ============================================================================
// Cursor
// ============================================================================

///|
/// Shows cursor.
pub extern "c" fn show_cursor() = "ShowCursor"

///|
/// Hides cursor.
pub extern "c" fn hide_cursor() = "HideCursor"

///|
/// Check if cursor is not visible.
pub extern "c" fn is_cursor_hidden() -> Bool = "moonbit_raylib_is_cursor_hidden"

///|
/// Enables cursor (unlock cursor).
pub extern "c" fn enable_cursor() = "EnableCursor"

///|
/// Disables cursor (lock cursor).
pub extern "c" fn disable_cursor() = "DisableCursor"

///|
/// Check if cursor is on the screen.
pub extern "c" fn is_cursor_on_screen() -> Bool = "moonbit_raylib_is_cursor_on_screen"

// ============================================================================
// Drawing
// ============================================================================

///|
#borrow(color)
pub extern "c" fn clear_background(color : Bytes) = "moonbit_raylib_clear_background"

///|
/// Setup canvas (framebuffer) to start drawing.
pub extern "c" fn begin_drawing() = "BeginDrawing"

///|
/// End canvas drawing and swap buffers (double buffering).
pub extern "c" fn end_drawing() = "EndDrawing"

///|
#borrow(camera)
pub extern "c" fn begin_mode_2d(camera : Bytes) = "moonbit_raylib_begin_mode_2d"

///|
/// Ends 2D mode with custom camera.
pub extern "c" fn end_mode_2d() = "EndMode2D"

///|
#borrow(camera)
pub extern "c" fn begin_mode_3d(camera : Bytes) = "moonbit_raylib_begin_mode_3d"

///|
/// Ends 3D mode and returns to default 2D orthographic mode.
pub extern "c" fn end_mode_3d() = "EndMode3D"

///|
/// Begin scissor mode (define screen area for following drawing).
pub extern "c" fn begin_scissor_mode(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) = "BeginScissorMode"

///|
/// End scissor mode.
pub extern "c" fn end_scissor_mode() = "EndScissorMode"

///|
/// Begin blending mode (alpha, additive, multiplied, subtract, custom).
pub extern "c" fn begin_blend_mode(mode : Int) = "BeginBlendMode"

///|
/// End blending mode (reset to default: alpha blending).
pub extern "c" fn end_blend_mode() = "EndBlendMode"

///|
#borrow(render_texture)
pub extern "c" fn begin_texture_mode(render_texture : RenderTexture) = "moonbit_raylib_begin_texture_mode"

///|
/// Ends drawing to render texture.
pub extern "c" fn end_texture_mode() = "EndTextureMode"

// ============================================================================
// Timing
// ============================================================================

///|
/// Set target FPS (maximum).
pub extern "c" fn set_target_fps(fps : Int) = "SetTargetFPS"

///|
/// Get time in seconds for last frame drawn (delta time).
pub extern "c" fn get_frame_time() -> Float = "GetFrameTime"

///|
/// Get elapsed time in seconds since InitWindow().
pub extern "c" fn get_time() -> Double = "GetTime"

///|
/// Get current FPS.
pub extern "c" fn get_fps() -> Int = "GetFPS"

// ============================================================================
// Keyboard input
// ============================================================================

///|
/// Check if a key has been pressed once.
pub extern "c" fn is_key_pressed(key : Int) -> Bool = "moonbit_raylib_is_key_pressed"

///|
/// Check if a key has been pressed again.
pub extern "c" fn is_key_pressed_repeat(key : Int) -> Bool = "moonbit_raylib_is_key_pressed_repeat"

///|
/// Check if a key is being pressed.
pub extern "c" fn is_key_down(key : Int) -> Bool = "moonbit_raylib_is_key_down"

///|
/// Check if a key has been released once.
pub extern "c" fn is_key_released(key : Int) -> Bool = "moonbit_raylib_is_key_released"

///|
/// Check if a key is NOT being pressed.
pub extern "c" fn is_key_up(key : Int) -> Bool = "moonbit_raylib_is_key_up"

///|
/// Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty.
pub extern "c" fn get_key_pressed() -> Int = "GetKeyPressed"

///|
/// Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty.
pub extern "c" fn get_char_pressed() -> Int = "GetCharPressed"

///|
/// Set a custom key to exit program (default is ESC).
pub extern "c" fn set_exit_key(key : Int) = "SetExitKey"

// ============================================================================
// Mouse input
// ============================================================================

///|
/// Check if a mouse button has been pressed once.
pub extern "c" fn is_mouse_button_pressed(button : Int) -> Bool = "moonbit_raylib_is_mouse_button_pressed"

///|
/// Check if a mouse button is being pressed.
pub extern "c" fn is_mouse_button_down(button : Int) -> Bool = "moonbit_raylib_is_mouse_button_down"

///|
/// Check if a mouse button has been released once.
pub extern "c" fn is_mouse_button_released(button : Int) -> Bool = "moonbit_raylib_is_mouse_button_released"

///|
/// Check if a mouse button is NOT being pressed.
pub extern "c" fn is_mouse_button_up(button : Int) -> Bool = "moonbit_raylib_is_mouse_button_up"

///|
/// Get mouse position X.
pub extern "c" fn get_mouse_x() -> Int = "GetMouseX"

///|
/// Get mouse position Y.
pub extern "c" fn get_mouse_y() -> Int = "GetMouseY"

///|
pub extern "c" fn get_mouse_position() -> Bytes = "moonbit_raylib_get_mouse_position"

///|
pub extern "c" fn get_mouse_delta() -> Bytes = "moonbit_raylib_get_mouse_delta"

///|
/// Set mouse position XY.
pub extern "c" fn set_mouse_position(x : Int, y : Int) = "SetMousePosition"

///|
/// Set mouse offset.
pub extern "c" fn set_mouse_offset(offset_x : Int, offset_y : Int) = "SetMouseOffset"

///|
/// Set mouse scaling.
pub extern "c" fn set_mouse_scale(scale_x : Float, scale_y : Float) = "SetMouseScale"

///|
/// Get mouse wheel movement for X or Y, whichever is larger.
pub extern "c" fn get_mouse_wheel_move() -> Float = "GetMouseWheelMove"

///|
pub extern "c" fn get_mouse_wheel_move_v() -> Bytes = "moonbit_raylib_get_mouse_wheel_move_v"

///|
/// Set mouse cursor.
pub extern "c" fn set_mouse_cursor(cursor : Int) = "SetMouseCursor"

// ============================================================================
// Gamepad input
// ============================================================================

///|
/// Check if a gamepad is available.
pub extern "c" fn is_gamepad_available(gamepad : Int) -> Bool = "moonbit_raylib_is_gamepad_available"

///|
pub extern "c" fn get_gamepad_name(gamepad : Int) -> Bytes = "moonbit_raylib_get_gamepad_name"

///|
/// Check if a gamepad button has been pressed once.
pub extern "c" fn is_gamepad_button_pressed(
  gamepad : Int,
  button : Int,
) -> Bool = "moonbit_raylib_is_gamepad_button_pressed"

///|
/// Check if a gamepad button is being pressed.
pub extern "c" fn is_gamepad_button_down(gamepad : Int, button : Int) -> Bool = "moonbit_raylib_is_gamepad_button_down"

///|
/// Check if a gamepad button has been released once.
pub extern "c" fn is_gamepad_button_released(
  gamepad : Int,
  button : Int,
) -> Bool = "moonbit_raylib_is_gamepad_button_released"

///|
/// Check if a gamepad button is NOT being pressed.
pub extern "c" fn is_gamepad_button_up(gamepad : Int, button : Int) -> Bool = "moonbit_raylib_is_gamepad_button_up"

///|
/// Get the last gamepad button pressed.
pub extern "c" fn get_gamepad_button_pressed() -> Int = "GetGamepadButtonPressed"

///|
/// Get gamepad axis count for a gamepad.
pub extern "c" fn get_gamepad_axis_count(gamepad : Int) -> Int = "GetGamepadAxisCount"

///|
/// Get axis movement value for a gamepad axis.
pub extern "c" fn get_gamepad_axis_movement(gamepad : Int, axis : Int) -> Float = "GetGamepadAxisMovement"

///|
#borrow(mappings)
pub extern "c" fn set_gamepad_mappings(mappings : Bytes) -> Int = "moonbit_raylib_set_gamepad_mappings"

///|
pub extern "c" fn set_gamepad_vibration(
  gamepad : Int,
  left_motor : Float,
  right_motor : Float,
  duration : Float,
) = "SetGamepadVibration"

// ============================================================================
// Touch input
// ============================================================================

///|
/// Get touch position X for touch point 0 (relative to screen size).
pub extern "c" fn get_touch_x() -> Int = "GetTouchX"

///|
/// Get touch position Y for touch point 0 (relative to screen size).
pub extern "c" fn get_touch_y() -> Int = "GetTouchY"

///|
pub extern "c" fn get_touch_position(index : Int) -> Bytes = "moonbit_raylib_get_touch_position"

///|
/// Get touch point identifier for given index.
pub extern "c" fn get_touch_point_id(index : Int) -> Int = "GetTouchPointId"

///|
/// Get number of touch points.
pub extern "c" fn get_touch_point_count() -> Int = "GetTouchPointCount"

// ============================================================================
// Gesture input
// ============================================================================

///|
/// Enable a set of gestures using flags.
pub extern "c" fn set_gestures_enabled(flags : Int) = "SetGesturesEnabled"

///|
/// Check if a gesture have been detected.
pub extern "c" fn is_gesture_detected(gesture : Int) -> Bool = "moonbit_raylib_is_gesture_detected"

///|
/// Get latest detected gesture.
pub extern "c" fn get_gesture_detected() -> Int = "GetGestureDetected"

///|
/// Get gesture hold time in seconds.
pub extern "c" fn get_gesture_hold_duration() -> Float = "GetGestureHoldDuration"

///|
pub extern "c" fn get_gesture_drag_vector() -> Bytes = "moonbit_raylib_get_gesture_drag_vector"

///|
/// Get gesture drag angle.
pub extern "c" fn get_gesture_drag_angle() -> Float = "GetGestureDragAngle"

///|
pub extern "c" fn get_gesture_pinch_vector() -> Bytes = "moonbit_raylib_get_gesture_pinch_vector"

///|
/// Get gesture pinch angle.
pub extern "c" fn get_gesture_pinch_angle() -> Float = "GetGesturePinchAngle"

// ============================================================================
// Camera
// ============================================================================

///|
#borrow(camera)
pub extern "c" fn update_camera(camera : Bytes, mode : Int) -> Bytes = "moonbit_raylib_update_camera"

///|
#borrow(camera, movement, rotation)
pub extern "c" fn update_camera_pro(
  camera : Bytes,
  movement : Bytes,
  rotation : Bytes,
  zoom : Float,
) -> Bytes = "moonbit_raylib_update_camera_pro"

///|
#borrow(position, camera)
pub extern "c" fn get_world_to_screen(
  position : Bytes,
  camera : Bytes,
) -> Bytes = "moonbit_raylib_get_world_to_screen"

///|
#borrow(position, camera)
pub extern "c" fn get_screen_to_world_2d(
  position : Bytes,
  camera : Bytes,
) -> Bytes = "moonbit_raylib_get_screen_to_world_2d"

///|
#borrow(position, camera)
pub extern "c" fn get_world_to_screen_2d(
  position : Bytes,
  camera : Bytes,
) -> Bytes = "moonbit_raylib_get_world_to_screen_2d"

// ============================================================================
// Shader management
// ============================================================================

///|
#borrow(vs_file_name, fs_file_name)
pub extern "c" fn load_shader(
  vs_file_name : Bytes,
  fs_file_name : Bytes,
) -> Shader = "moonbit_raylib_load_shader"

///|
#borrow(vs_code, fs_code)
pub extern "c" fn load_shader_from_memory(
  vs_code : Bytes,
  fs_code : Bytes,
) -> Shader = "moonbit_raylib_load_shader_from_memory"

///|
#borrow(shader)
pub extern "c" fn is_shader_valid(shader : Shader) -> Bool = "moonbit_raylib_is_shader_valid"

///|
#borrow(shader)
pub extern "c" fn get_shader_id(shader : Shader) -> UInt = "moonbit_raylib_get_shader_id"

///|
#borrow(shader, uniform_name)
pub extern "c" fn get_shader_location(
  shader : Shader,
  uniform_name : Bytes,
) -> Int = "moonbit_raylib_get_shader_location"

///|
#borrow(shader, attrib_name)
pub extern "c" fn get_shader_location_attrib(
  shader : Shader,
  attrib_name : Bytes,
) -> Int = "moonbit_raylib_get_shader_location_attrib"

///|
#borrow(shader)
pub extern "c" fn set_shader_locs(
  shader : Shader,
  loc_index : Int,
  loc_value : Int,
) = "moonbit_raylib_set_shader_locs"

///|
#borrow(shader, value)
pub extern "c" fn set_shader_value(
  shader : Shader,
  loc_index : Int,
  value : Bytes,
  uniform_type : Int,
) = "moonbit_raylib_set_shader_value"

///|
#borrow(shader, value)
pub extern "c" fn set_shader_value_v(
  shader : Shader,
  loc_index : Int,
  value : Bytes,
  uniform_type : Int,
  count : Int,
) = "moonbit_raylib_set_shader_value_v"

///|
#borrow(shader, mat)
pub extern "c" fn set_shader_value_matrix(
  shader : Shader,
  loc_index : Int,
  mat : Bytes,
) = "moonbit_raylib_set_shader_value_matrix"

///|
#borrow(shader, texture)
pub extern "c" fn set_shader_value_texture(
  shader : Shader,
  loc_index : Int,
  texture : Texture,
) = "moonbit_raylib_set_shader_value_texture"

///|
#borrow(shader)
pub extern "c" fn unload_shader(shader : Shader) = "moonbit_raylib_unload_shader"

///|
#borrow(shader)
pub extern "c" fn begin_shader_mode(shader : Shader) = "moonbit_raylib_begin_shader_mode"

///|
/// End custom shader drawing (use default shader).
pub extern "c" fn end_shader_mode() = "EndShaderMode"

// ============================================================================
// Camera matrix
// ============================================================================

///|
#borrow(camera)
pub extern "c" fn get_camera_matrix(camera : Bytes) -> Bytes = "moonbit_raylib_get_camera_matrix"

///|
#borrow(camera)
pub extern "c" fn get_camera_matrix_2d(camera : Bytes) -> Bytes = "moonbit_raylib_get_camera_matrix_2d"

///|
#borrow(position, camera)
pub extern "c" fn get_screen_to_world_ray(
  position : Bytes,
  camera : Bytes,
) -> Bytes = "moonbit_raylib_get_screen_to_world_ray"

///|
#borrow(position, camera)
pub extern "c" fn get_screen_to_world_ray_ex(
  position : Bytes,
  camera : Bytes,
  width : Int,
  height : Int,
) -> Bytes = "moonbit_raylib_get_screen_to_world_ray_ex"

///|
#borrow(position, camera)
pub extern "c" fn get_world_to_screen_ex(
  position : Bytes,
  camera : Bytes,
  width : Int,
  height : Int,
) -> Bytes = "moonbit_raylib_get_world_to_screen_ex"

// ============================================================================
// Misc
// ============================================================================

///|
pub extern "c" fn set_trace_log_level(log_level : Int) = "SetTraceLogLevel"

///|
#borrow(text)
pub extern "c" fn trace_log(log_level : Int, text : Bytes) = "moonbit_raylib_trace_log"

///|
#borrow(file_name)
pub extern "c" fn take_screenshot(file_name : Bytes) = "moonbit_raylib_take_screenshot"

///|
#borrow(url)
pub extern "c" fn open_url(url : Bytes) = "moonbit_raylib_open_url"

///|
/// Get a random value between min and max (both included).
pub extern "c" fn get_random_value(min : Int, max : Int) -> Int = "GetRandomValue"

///|
/// Set the seed for the random number generator.
pub extern "c" fn set_random_seed(seed : Int) = "SetRandomSeed"

// ============================================================================
// Color utilities
// ============================================================================

///|
#borrow(color)
pub extern "c" fn fade(color : Bytes, alpha : Float) -> Bytes = "moonbit_raylib_fade"

///|
#borrow(color)
pub extern "c" fn color_alpha(color : Bytes, alpha : Float) -> Bytes = "moonbit_raylib_color_alpha"

///|
#borrow(color)
pub extern "c" fn color_to_int(color : Bytes) -> Int = "moonbit_raylib_color_to_int"

///|
pub extern "c" fn get_color(hex_value : Int) -> Bytes = "moonbit_raylib_get_color"

///|
pub extern "c" fn color_from_hsv(
  hue : Float,
  saturation : Float,
  value : Float,
) -> Bytes = "moonbit_raylib_color_from_hsv"

///|
#borrow(color, tint)
pub extern "c" fn color_tint(color : Bytes, tint : Bytes) -> Bytes = "moonbit_raylib_color_tint"

///|
#borrow(color)
pub extern "c" fn color_brightness(color : Bytes, factor : Float) -> Bytes = "moonbit_raylib_color_brightness"

///|
#borrow(color1, color2)
pub extern "c" fn color_lerp(
  color1 : Bytes,
  color2 : Bytes,
  factor : Float,
) -> Bytes = "moonbit_raylib_color_lerp"

///|
#borrow(col1, col2)
pub extern "c" fn color_is_equal(col1 : Bytes, col2 : Bytes) -> Bool = "moonbit_raylib_color_is_equal"

///|
#borrow(color)
pub extern "c" fn color_normalize(color : Bytes) -> Bytes = "moonbit_raylib_color_normalize"

///|
#borrow(normalized)
pub extern "c" fn color_from_normalized(normalized : Bytes) -> Bytes = "moonbit_raylib_color_from_normalized"

///|
#borrow(color)
pub extern "c" fn color_to_hsv(color : Bytes) -> Bytes = "moonbit_raylib_color_to_hsv"

///|
#borrow(color)
pub extern "c" fn color_contrast(color : Bytes, contrast : Float) -> Bytes = "moonbit_raylib_color_contrast"

///|
#borrow(dst, src, tint)
pub extern "c" fn color_alpha_blend(
  dst : Bytes,
  src : Bytes,
  tint : Bytes,
) -> Bytes = "moonbit_raylib_color_alpha_blend"

///|
/// Get pixel data size in bytes for certain format.
pub extern "c" fn get_pixel_data_size(
  width : Int,
  height : Int,
  format : Int,
) -> Int = "GetPixelDataSize"

// ============================================================================
// Window icon
// ============================================================================

///|
#borrow(image)
pub extern "c" fn set_window_icon(image : Image) = "moonbit_raylib_set_window_icon"

// ============================================================================
// VR stereo
// ============================================================================

///|
#borrow(device)
pub extern "c" fn load_vr_stereo_config(device : Bytes) -> VrStereoConfig = "moonbit_raylib_load_vr_stereo_config"

///|
#borrow(config)
pub extern "c" fn unload_vr_stereo_config(config : VrStereoConfig) = "moonbit_raylib_unload_vr_stereo_config"

///|
/// Begin stereo rendering (requires VR simulator).
#borrow(config)
pub extern "c" fn begin_vr_stereo_mode(config : VrStereoConfig) = "moonbit_raylib_begin_vr_stereo_mode"

///|
/// End stereo rendering (requires VR simulator).
pub extern "c" fn end_vr_stereo_mode() = "EndVrStereoMode"

// VrStereoConfig field accessors

///|
#borrow(config)
pub extern "c" fn vr_stereo_config_left_lens_center(
  config : VrStereoConfig,
) -> Bytes = "moonbit_raylib_vr_stereo_config_left_lens_center"

///|
#borrow(config)
pub extern "c" fn vr_stereo_config_right_lens_center(
  config : VrStereoConfig,
) -> Bytes = "moonbit_raylib_vr_stereo_config_right_lens_center"

///|
#borrow(config)
pub extern "c" fn vr_stereo_config_left_screen_center(
  config : VrStereoConfig,
) -> Bytes = "moonbit_raylib_vr_stereo_config_left_screen_center"

///|
#borrow(config)
pub extern "c" fn vr_stereo_config_right_screen_center(
  config : VrStereoConfig,
) -> Bytes = "moonbit_raylib_vr_stereo_config_right_screen_center"

///|
#borrow(config)
pub extern "c" fn vr_stereo_config_scale(config : VrStereoConfig) -> Bytes = "moonbit_raylib_vr_stereo_config_scale"

///|
#borrow(config)
pub extern "c" fn vr_stereo_config_scale_in(config : VrStereoConfig) -> Bytes = "moonbit_raylib_vr_stereo_config_scale_in"

// ============================================================================
// rlgl: Low-level OpenGL functions
// ============================================================================

///|
pub extern "c" fn rl_set_blend_mode(mode : Int) = "rlSetBlendMode"

///|
pub extern "c" fn rl_set_blend_factors(
  gl_src_factor : Int,
  gl_dst_factor : Int,
  gl_equation : Int,
) = "rlSetBlendFactors"

///|
pub extern "c" fn rl_draw_render_batch_active() = "rlDrawRenderBatchActive"

// rlgl: Geometry submission (vertex-level)

///|
pub extern "c" fn rl_begin(mode : Int) = "rlBegin"

///|
pub extern "c" fn rl_end() = "rlEnd"

///|
pub extern "c" fn rl_vertex2f(x : Float, y : Float) = "rlVertex2f"

///|
pub extern "c" fn rl_vertex3f(x : Float, y : Float, z : Float) = "rlVertex3f"

///|
pub extern "c" fn rl_tex_coord2f(x : Float, y : Float) = "rlTexCoord2f"

///|
pub extern "c" fn rl_color4ub(r : Byte, g : Byte, b : Byte, a : Byte) = "rlColor4ub"

///|
pub extern "c" fn rl_normal3f(x : Float, y : Float, z : Float) = "rlNormal3f"

///|
pub extern "c" fn rl_set_texture(id : UInt) = "rlSetTexture"

// rlgl: Matrix stack

///|
pub extern "c" fn rl_push_matrix() = "rlPushMatrix"

///|
pub extern "c" fn rl_pop_matrix() = "rlPopMatrix"

///|
pub extern "c" fn rl_translatef(x : Float, y : Float, z : Float) = "rlTranslatef"

///|
pub extern "c" fn rl_rotatef(angle : Float, x : Float, y : Float, z : Float) = "rlRotatef"

///|
pub extern "c" fn rl_scalef(x : Float, y : Float, z : Float) = "rlScalef"

///|
#borrow(matf)
pub extern "c" fn rl_mult_matrixf(matf : Bytes) = "rlMultMatrixf"

// rlgl: State control

///|
pub extern "c" fn rl_enable_backface_culling() = "rlEnableBackfaceCulling"

///|
pub extern "c" fn rl_disable_backface_culling() = "rlDisableBackfaceCulling"

///|
pub extern "c" fn rl_check_render_batch_limit(v_count : Int) -> Bool = "moonbit_raylib_rl_check_render_batch_limit"

///|
pub extern "c" fn rl_enable_depth_test() = "rlEnableDepthTest"

///|
pub extern "c" fn rl_disable_depth_test() = "rlDisableDepthTest"

///|
pub extern "c" fn rl_enable_depth_mask() = "rlEnableDepthMask"

///|
pub extern "c" fn rl_disable_depth_mask() = "rlDisableDepthMask"

///|
pub extern "c" fn rl_enable_color_blend() = "rlEnableColorBlend"

///|
pub extern "c" fn rl_disable_color_blend() = "rlDisableColorBlend"

///|
pub extern "c" fn rl_active_texture_slot(slot : Int) = "rlActiveTextureSlot"

///|
pub extern "c" fn rl_enable_texture(id : UInt) = "rlEnableTexture"

///|
pub extern "c" fn rl_disable_texture() = "rlDisableTexture"

///|
pub extern "c" fn rl_enable_shader(id : UInt) = "rlEnableShader"

///|
pub extern "c" fn rl_disable_shader() = "rlDisableShader"

///|
pub extern "c" fn rl_enable_framebuffer(id : UInt) = "rlEnableFramebuffer"

///|
pub extern "c" fn rl_disable_framebuffer() = "rlDisableFramebuffer"

///|
pub extern "c" fn rl_active_draw_buffers(count : Int) = "rlActiveDrawBuffers"

///|
pub extern "c" fn rl_viewport(x : Int, y : Int, width : Int, height : Int) = "rlViewport"

///|
pub extern "c" fn rl_clear_screen_buffers() = "rlClearScreenBuffers"

// rlgl: Framebuffer management

///|
pub extern "c" fn rl_load_framebuffer() -> UInt = "rlLoadFramebuffer"

///|
pub extern "c" fn rl_framebuffer_complete(id : UInt) -> Bool = "moonbit_raylib_rl_framebuffer_complete"

///|
pub extern "c" fn rl_framebuffer_attach(
  fbo_id : UInt,
  tex_id : UInt,
  attach_type : Int,
  tex_type : Int,
  mip_level : Int,
) = "rlFramebufferAttach"

///|
pub extern "c" fn rl_unload_framebuffer(id : UInt) = "rlUnloadFramebuffer"

// rlgl: Texture management (low-level)

///|
pub extern "c" fn rl_load_texture_depth(
  width : Int,
  height : Int,
  use_render_buffer : Bool,
) -> UInt = "moonbit_raylib_rl_load_texture_depth"

///|
pub extern "c" fn rl_unload_texture(id : UInt) = "rlUnloadTexture"

// rlgl: Shader management (low-level)

///|
#borrow(uniform_name)
pub extern "c" fn rl_get_location_uniform(
  shader_id : UInt,
  uniform_name : Bytes,
) -> Int = "rlGetLocationUniform"

///|
pub extern "c" fn rl_set_uniform_sampler(loc_index : Int, texture_id : UInt) = "rlSetUniformSampler"

///|
pub extern "c" fn rl_get_shader_id_default() -> UInt = "rlGetShaderIdDefault"

// rlgl: Draw helpers

///|
pub extern "c" fn rl_load_draw_quad() = "rlLoadDrawQuad"

///|
pub extern "c" fn rl_load_draw_cube() = "rlLoadDrawCube"

// rlgl: Misc

///|
pub extern "c" fn rl_get_framebuffer_width() -> Int = "rlGetFramebufferWidth"

///|
pub extern "c" fn rl_get_framebuffer_height() -> Int = "rlGetFramebufferHeight"

///|
pub extern "c" fn rl_bind_framebuffer(target : UInt, fbo : UInt) = "rlBindFramebuffer"

///|
pub extern "c" fn rl_blit_framebuffer(
  src_x : Int,
  src_y : Int,
  src_w : Int,
  src_h : Int,
  dst_x : Int,
  dst_y : Int,
  dst_w : Int,
  dst_h : Int,
  buffer_mask : Int,
) = "rlBlitFramebuffer"

// rlgl: Matrix getters

///|
pub extern "c" fn rl_get_matrix_modelview() -> Bytes = "moonbit_raylib_rl_get_matrix_modelview"

///|
pub extern "c" fn rl_get_matrix_projection() -> Bytes = "moonbit_raylib_rl_get_matrix_projection"

// rlgl: SetUniform (low-level)

///|
#borrow(value)
pub extern "c" fn rl_set_uniform(
  loc_index : Int,
  value : Bytes,
  uniform_type : Int,
  count : Int,
) = "moonbit_raylib_rl_set_uniform"

// ============================================================================
// rlgl: Matrix operations
// ============================================================================

///|
/// Choose the current matrix to be transformed.
pub extern "c" fn rl_matrix_mode(mode : Int) = "rlMatrixMode"

///|
/// Reset current matrix to identity matrix.
pub extern "c" fn rl_load_identity() = "rlLoadIdentity"

///|
/// Set up a perspective projection matrix.
pub extern "c" fn rl_frustum(
  left : Double,
  right : Double,
  bottom : Double,
  top : Double,
  znear : Double,
  zfar : Double,
) = "rlFrustum"

///|
/// Set up an orthographic projection matrix.
pub extern "c" fn rl_ortho(
  left : Double,
  right : Double,
  bottom : Double,
  top : Double,
  znear : Double,
  zfar : Double,
) = "rlOrtho"

///|
/// Set clip planes distances.
pub extern "c" fn rl_set_clip_planes(near_plane : Double, far_plane : Double) = "rlSetClipPlanes"

///|
/// Get cull plane distance near.
pub extern "c" fn rl_get_cull_distance_near() -> Double = "rlGetCullDistanceNear"

///|
/// Get cull plane distance far.
pub extern "c" fn rl_get_cull_distance_far() -> Double = "rlGetCullDistanceFar"

// ============================================================================
// rlgl: Vertex level (additional)
// ============================================================================

///|
/// Define one vertex (position) - 2 int.
pub extern "c" fn rl_vertex2i(x : Int, y : Int) = "rlVertex2i"

///|
/// Define one vertex (color) - 3 float.
pub extern "c" fn rl_color3f(x : Float, y : Float, z : Float) = "rlColor3f"

///|
/// Define one vertex (color) - 4 float.
pub extern "c" fn rl_color4f(x : Float, y : Float, z : Float, w : Float) = "rlColor4f"

// ============================================================================
// rlgl: Vertex buffers state
// ============================================================================

///|
/// Enable vertex array (VAO, if supported).
pub extern "c" fn rl_enable_vertex_array(vao_id : UInt) -> Bool = "moonbit_raylib_rl_enable_vertex_array"

///|
/// Disable vertex array (VAO, if supported).
pub extern "c" fn rl_disable_vertex_array() = "rlDisableVertexArray"

///|
/// Enable vertex buffer (VBO).
pub extern "c" fn rl_enable_vertex_buffer(id : UInt) = "rlEnableVertexBuffer"

///|
/// Disable vertex buffer (VBO).
pub extern "c" fn rl_disable_vertex_buffer() = "rlDisableVertexBuffer"

///|
/// Enable vertex buffer element (VBO element).
pub extern "c" fn rl_enable_vertex_buffer_element(id : UInt) = "rlEnableVertexBufferElement"

///|
/// Disable vertex buffer element (VBO element).
pub extern "c" fn rl_disable_vertex_buffer_element() = "rlDisableVertexBufferElement"

///|
/// Enable vertex attribute index.
pub extern "c" fn rl_enable_vertex_attribute(index : UInt) = "rlEnableVertexAttribute"

///|
/// Disable vertex attribute index.
pub extern "c" fn rl_disable_vertex_attribute(index : UInt) = "rlDisableVertexAttribute"

// ============================================================================
// rlgl: Textures state (additional)
// ============================================================================

///|
/// Enable texture cubemap.
pub extern "c" fn rl_enable_texture_cubemap(id : UInt) = "rlEnableTextureCubemap"

///|
/// Disable texture cubemap.
pub extern "c" fn rl_disable_texture_cubemap() = "rlDisableTextureCubemap"

///|
/// Set texture parameters (filter, wrap).
pub extern "c" fn rl_texture_parameters(id : UInt, param : Int, value : Int) = "rlTextureParameters"

///|
/// Set cubemap parameters (filter, wrap).
pub extern "c" fn rl_cubemap_parameters(id : UInt, param : Int, value : Int) = "rlCubemapParameters"

// ============================================================================
// rlgl: Framebuffer state (additional)
// ============================================================================

///|
/// Get the currently active render texture (fbo), 0 for default framebuffer.
pub extern "c" fn rl_get_active_framebuffer() -> UInt = "rlGetActiveFramebuffer"

// ============================================================================
// rlgl: General render state
// ============================================================================

///|
/// Set face culling mode.
pub extern "c" fn rl_set_cull_face(mode : Int) = "rlSetCullFace"

///|
/// Enable scissor test.
pub extern "c" fn rl_enable_scissor_test() = "rlEnableScissorTest"

///|
/// Disable scissor test.
pub extern "c" fn rl_disable_scissor_test() = "rlDisableScissorTest"

///|
/// Scissor test.
pub extern "c" fn rl_scissor(x : Int, y : Int, width : Int, height : Int) = "rlScissor"

///|
/// Enable wire mode.
pub extern "c" fn rl_enable_wire_mode() = "rlEnableWireMode"

///|
/// Enable point mode.
pub extern "c" fn rl_enable_point_mode() = "rlEnablePointMode"

///|
/// Disable wire (and point) mode.
pub extern "c" fn rl_disable_wire_mode() = "rlDisableWireMode"

///|
/// Set the line drawing width.
pub extern "c" fn rl_set_line_width(width : Float) = "rlSetLineWidth"

///|
/// Get the line drawing width.
pub extern "c" fn rl_get_line_width() -> Float = "rlGetLineWidth"

///|
/// Enable line aliasing.
pub extern "c" fn rl_enable_smooth_lines() = "rlEnableSmoothLines"

///|
/// Disable line aliasing.
pub extern "c" fn rl_disable_smooth_lines() = "rlDisableSmoothLines"

///|
/// Enable stereo rendering.
pub extern "c" fn rl_enable_stereo_render() = "rlEnableStereoRender"

///|
/// Disable stereo rendering.
pub extern "c" fn rl_disable_stereo_render() = "rlDisableStereoRender"

///|
/// Check if stereo render is enabled.
pub extern "c" fn rl_is_stereo_render_enabled() -> Bool = "moonbit_raylib_rl_is_stereo_render_enabled"

///|
/// Clear color buffer with color.
pub extern "c" fn rl_clear_color(r : Byte, g : Byte, b : Byte, a : Byte) = "rlClearColor"

///|
/// Check and log OpenGL error codes.
pub extern "c" fn rl_check_errors() = "rlCheckErrors"

///|
/// Set blending mode factors and equations separately (using OpenGL factors).
pub extern "c" fn rl_set_blend_factors_separate(
  gl_src_rgb : Int,
  gl_dst_rgb : Int,
  gl_src_alpha : Int,
  gl_dst_alpha : Int,
  gl_eq_rgb : Int,
  gl_eq_alpha : Int,
) = "rlSetBlendFactorsSeparate"

///|
/// Color mask control.
pub extern "c" fn rl_color_mask(r : Bool, g : Bool, b : Bool, a : Bool) = "moonbit_raylib_rl_color_mask"

// ============================================================================
// rlgl: Init / version
// ============================================================================

///|
/// Get current OpenGL version.
pub extern "c" fn rl_get_version() -> Int = "rlGetVersion"

///|
/// Set current framebuffer width.
pub extern "c" fn rl_set_framebuffer_width(width : Int) = "rlSetFramebufferWidth"

///|
/// Set current framebuffer height.
pub extern "c" fn rl_set_framebuffer_height(height : Int) = "rlSetFramebufferHeight"

// ============================================================================
// rlgl: Default resource
// ============================================================================

///|
/// Get default texture id.
pub extern "c" fn rl_get_texture_id_default() -> UInt = "rlGetTextureIdDefault"

// ============================================================================
// rlgl: Vertex buffers management
// ============================================================================

///|
/// Load vertex array (vao) if supported.
pub extern "c" fn rl_load_vertex_array() -> UInt = "rlLoadVertexArray"

///|
/// Load a vertex buffer object.
#borrow(buffer)
pub extern "c" fn rl_load_vertex_buffer(
  buffer : Bytes,
  size : Int,
  dynamic : Bool,
) -> UInt = "moonbit_raylib_rl_load_vertex_buffer"

///|
/// Load vertex buffer elements object.
#borrow(buffer)
pub extern "c" fn rl_load_vertex_buffer_element(
  buffer : Bytes,
  size : Int,
  dynamic : Bool,
) -> UInt = "moonbit_raylib_rl_load_vertex_buffer_element"

///|
/// Unload vertex array (vao).
pub extern "c" fn rl_unload_vertex_array(vao_id : UInt) = "rlUnloadVertexArray"

///|
/// Unload vertex buffer object.
pub extern "c" fn rl_unload_vertex_buffer(vbo_id : UInt) = "rlUnloadVertexBuffer"

///|
/// Update vertex buffer object data on GPU buffer.
#borrow(data)
pub extern "c" fn rl_update_vertex_buffer(
  buffer_id : UInt,
  data : Bytes,
  data_size : Int,
  offset : Int,
) = "moonbit_raylib_rl_update_vertex_buffer"

///|
/// Update vertex buffer elements data on GPU buffer.
#borrow(data)
pub extern "c" fn rl_update_vertex_buffer_elements(
  id : UInt,
  data : Bytes,
  data_size : Int,
  offset : Int,
) = "moonbit_raylib_rl_update_vertex_buffer_elements"

///|
/// Set vertex attribute data divisor.
pub extern "c" fn rl_set_vertex_attribute_divisor(index : UInt, divisor : Int) = "rlSetVertexAttributeDivisor"

///|
/// Set vertex attribute data configuration.
pub extern "c" fn rl_set_vertex_attribute(
  index : UInt,
  comp_size : Int,
  type_ : Int,
  normalized : Bool,
  stride : Int,
  offset : Int,
) = "moonbit_raylib_rl_set_vertex_attribute"

///|
/// Set vertex attribute default value, when attribute is not provided.
#borrow(value)
pub extern "c" fn rl_set_vertex_attribute_default(
  loc_index : Int,
  value : Bytes,
  attrib_type : Int,
  count : Int,
) = "moonbit_raylib_rl_set_vertex_attribute_default"

///|
/// Draw vertex array (currently active vao).
pub extern "c" fn rl_draw_vertex_array(offset : Int, count : Int) = "rlDrawVertexArray"

///|
/// Draw vertex array (currently active vao) with instancing.
pub extern "c" fn rl_draw_vertex_array_instanced(
  offset : Int,
  count : Int,
  instances : Int,
) = "rlDrawVertexArrayInstanced"

///|
/// Draw vertex array elements.
pub extern "c" fn rl_draw_vertex_array_elements(
  offset : Int,
  count : Int,
  buffer : Int,
) = "moonbit_raylib_rl_draw_vertex_array_elements"

///|
/// Draw vertex array elements with instancing.
pub extern "c" fn rl_draw_vertex_array_elements_instanced(
  offset : Int,
  count : Int,
  buffer : Int,
  instances : Int,
) = "moonbit_raylib_rl_draw_vertex_array_elements_instanced"

// ============================================================================
// rlgl: Textures management (additional)
// ============================================================================

///|
/// Load texture cubemap data.
#borrow(data)
pub extern "c" fn rl_load_texture_cubemap(
  data : Bytes,
  size : Int,
  format : Int,
  mipmap_count : Int,
) -> UInt = "moonbit_raylib_rl_load_texture_cubemap"

///|
/// Update texture with new data on GPU.
#borrow(data)
pub extern "c" fn rl_update_texture(
  id : UInt,
  offset_x : Int,
  offset_y : Int,
  width : Int,
  height : Int,
  format : Int,
  data : Bytes,
) = "moonbit_raylib_rl_update_texture"

// ============================================================================
// rlgl: Shader management (additional)
// ============================================================================

///|
/// Load shader from code strings.
#borrow(vs_code, fs_code)
pub extern "c" fn rl_load_shader_code(vs_code : Bytes, fs_code : Bytes) -> UInt = "moonbit_raylib_rl_load_shader_code"

///|
/// Compile custom shader and return shader id.
#borrow(shader_code)
pub extern "c" fn rl_compile_shader(shader_code : Bytes, type_ : Int) -> UInt = "rlCompileShader"

///|
/// Load custom shader program.
pub extern "c" fn rl_load_shader_program(
  v_shader_id : UInt,
  f_shader_id : UInt,
) -> UInt = "rlLoadShaderProgram"

///|
/// Unload shader program.
pub extern "c" fn rl_unload_shader_program(id : UInt) = "rlUnloadShaderProgram"

///|
/// Get shader location attribute.
#borrow(attrib_name)
pub extern "c" fn rl_get_location_attrib(
  shader_id : UInt,
  attrib_name : Bytes,
) -> Int = "rlGetLocationAttrib"

///|
/// Set shader value matrix.
#borrow(mat)
pub extern "c" fn rl_set_uniform_matrix(loc_index : Int, mat : Bytes) = "moonbit_raylib_rl_set_uniform_matrix"

///|
/// Set shader value matrices.
#borrow(mat)
pub extern "c" fn rl_set_uniform_matrices(
  loc_index : Int,
  mat : Bytes,
  count : Int,
) = "moonbit_raylib_rl_set_uniform_matrices"

// ============================================================================
// rlgl: Compute shader
// ============================================================================

///|
/// Load compute shader program.
pub extern "c" fn rl_load_compute_shader_program(shader_id : UInt) -> UInt = "rlLoadComputeShaderProgram"

///|
/// Dispatch compute shader (equivalent to draw for graphics pipeline).
pub extern "c" fn rl_compute_shader_dispatch(
  group_x : UInt,
  group_y : UInt,
  group_z : UInt,
) = "rlComputeShaderDispatch"

// ============================================================================
// rlgl: Shader storage buffer object (SSBO)
// ============================================================================

///|
/// Load shader storage buffer object (SSBO).
#borrow(data)
pub extern "c" fn rl_load_shader_buffer(
  size : UInt,
  data : Bytes,
  usage_hint : Int,
) -> UInt = "moonbit_raylib_rl_load_shader_buffer"

///|
/// Load shader storage buffer object (SSBO) with no initial data.
pub extern "c" fn rl_load_shader_buffer_empty(
  size : UInt,
  usage_hint : Int,
) -> UInt = "moonbit_raylib_rl_load_shader_buffer_empty"

///|
/// Unload shader storage buffer object (SSBO).
pub extern "c" fn rl_unload_shader_buffer(ssbo_id : UInt) = "rlUnloadShaderBuffer"

///|
/// Update SSBO buffer data.
#borrow(data)
pub extern "c" fn rl_update_shader_buffer(
  id : UInt,
  data : Bytes,
  data_size : UInt,
  offset : UInt,
) = "moonbit_raylib_rl_update_shader_buffer"

///|
/// Read SSBO buffer data (GPU->CPU).
pub extern "c" fn rl_read_shader_buffer(
  id : UInt,
  count : UInt,
  offset : UInt,
) -> Bytes = "moonbit_raylib_rl_read_shader_buffer"

///|
/// Bind SSBO buffer.
pub extern "c" fn rl_bind_shader_buffer(id : UInt, index : UInt) = "rlBindShaderBuffer"

///|
/// Copy SSBO data between buffers.
pub extern "c" fn rl_copy_shader_buffer(
  dest_id : UInt,
  src_id : UInt,
  dest_offset : UInt,
  src_offset : UInt,
  count : UInt,
) = "rlCopyShaderBuffer"

///|
/// Get SSBO buffer size.
pub extern "c" fn rl_get_shader_buffer_size(id : UInt) -> UInt = "rlGetShaderBufferSize"

// ============================================================================
// rlgl: Bind image texture
// ============================================================================

///|
/// Bind image texture.
pub extern "c" fn rl_bind_image_texture(
  id : UInt,
  index : UInt,
  format : Int,
  read_only : Bool,
) = "moonbit_raylib_rl_bind_image_texture"

// ============================================================================
// rlgl: Matrix setters
// ============================================================================

///|
/// Set a custom projection matrix (replaces internal projection matrix).
#borrow(proj)
pub extern "c" fn rl_set_matrix_projection(proj : Bytes) = "moonbit_raylib_rl_set_matrix_projection"

///|
/// Set a custom modelview matrix (replaces internal modelview matrix).
#borrow(view)
pub extern "c" fn rl_set_matrix_modelview(view : Bytes) = "moonbit_raylib_rl_set_matrix_modelview"

// ============================================================================
// rlgl: Matrix getters (additional)
// ============================================================================

///|
/// Get internal accumulated transform matrix.
pub extern "c" fn rl_get_matrix_transform() -> Bytes = "moonbit_raylib_rl_get_matrix_transform"

///|
/// Get internal projection matrix for stereo render (selected eye).
pub extern "c" fn rl_get_matrix_projection_stereo(eye : Int) -> Bytes = "moonbit_raylib_rl_get_matrix_projection_stereo"

///|
/// Get internal view offset matrix for stereo render (selected eye).
pub extern "c" fn rl_get_matrix_view_offset_stereo(eye : Int) -> Bytes = "moonbit_raylib_rl_get_matrix_view_offset_stereo"

// ============================================================================
// rlgl: Stereo matrix setters
// ============================================================================

///|
/// Set eyes projection matrices for stereo rendering.
#borrow(right, left)
pub extern "c" fn rl_set_matrix_projection_stereo(right : Bytes, left : Bytes) = "moonbit_raylib_rl_set_matrix_projection_stereo"

///|
/// Set eyes view offsets matrices for stereo rendering.
#borrow(right, left)
pub extern "c" fn rl_set_matrix_view_offset_stereo(right : Bytes, left : Bytes) = "moonbit_raylib_rl_set_matrix_view_offset_stereo"
