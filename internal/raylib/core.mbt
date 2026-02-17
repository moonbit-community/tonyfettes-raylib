// ============================================================================
// Window management
// ============================================================================

///|
#borrow(title)
pub extern "c" fn init_window(width : Int, height : Int, title : Bytes) = "moonbit_raylib_init_window"

///|
pub extern "c" fn close_window() = "CloseWindow"

///|
pub extern "c" fn window_should_close() -> Bool = "WindowShouldClose"

///|
pub extern "c" fn is_window_ready() -> Bool = "IsWindowReady"

///|
pub extern "c" fn is_window_fullscreen() -> Bool = "IsWindowFullscreen"

///|
pub extern "c" fn is_window_hidden() -> Bool = "IsWindowHidden"

///|
pub extern "c" fn is_window_minimized() -> Bool = "IsWindowMinimized"

///|
pub extern "c" fn is_window_maximized() -> Bool = "IsWindowMaximized"

///|
pub extern "c" fn is_window_focused() -> Bool = "IsWindowFocused"

///|
pub extern "c" fn is_window_resized() -> Bool = "IsWindowResized"

///|
#borrow(title)
pub extern "c" fn set_window_title(title : Bytes) = "moonbit_raylib_set_window_title"

///|
pub extern "c" fn set_window_size(width : Int, height : Int) = "SetWindowSize"

///|
pub extern "c" fn set_window_position(x : Int, y : Int) = "SetWindowPosition"

///|
pub extern "c" fn set_window_min_size(width : Int, height : Int) = "SetWindowMinSize"

///|
pub extern "c" fn set_window_max_size(width : Int, height : Int) = "SetWindowMaxSize"

///|
pub extern "c" fn set_window_opacity(opacity : Float) = "SetWindowOpacity"

///|
pub extern "c" fn set_window_focused() = "SetWindowFocused"

///|
pub extern "c" fn get_screen_width() -> Int = "GetScreenWidth"

///|
pub extern "c" fn get_screen_height() -> Int = "GetScreenHeight"

///|
pub extern "c" fn get_render_width() -> Int = "GetRenderWidth"

///|
pub extern "c" fn get_render_height() -> Int = "GetRenderHeight"

///|
pub extern "c" fn toggle_fullscreen() = "ToggleFullscreen"

///|
pub extern "c" fn toggle_borderless_windowed() = "ToggleBorderlessWindowed"

///|
pub extern "c" fn maximize_window() = "MaximizeWindow"

///|
pub extern "c" fn minimize_window() = "MinimizeWindow"

///|
pub extern "c" fn restore_window() = "RestoreWindow"

///|
pub extern "c" fn set_config_flags(flags : Int) = "SetConfigFlags"

///|
pub extern "c" fn set_window_state(flags : Int) = "SetWindowState"

///|
pub extern "c" fn clear_window_state(flags : Int) = "ClearWindowState"

///|
pub extern "c" fn is_window_state(flag : Int) -> Bool = "IsWindowState"

///|
pub extern "c" fn get_window_position() -> Bytes = "moonbit_raylib_get_window_position"

///|
pub extern "c" fn get_window_scale_dpi() -> Bytes = "moonbit_raylib_get_window_scale_dpi"

// ============================================================================
// Monitor management
// ============================================================================

///|
pub extern "c" fn get_monitor_count() -> Int = "GetMonitorCount"

///|
pub extern "c" fn get_current_monitor() -> Int = "GetCurrentMonitor"

///|
pub extern "c" fn get_monitor_width(monitor : Int) -> Int = "GetMonitorWidth"

///|
pub extern "c" fn get_monitor_height(monitor : Int) -> Int = "GetMonitorHeight"

///|
pub extern "c" fn get_monitor_physical_width(monitor : Int) -> Int = "GetMonitorPhysicalWidth"

///|
pub extern "c" fn get_monitor_physical_height(monitor : Int) -> Int = "GetMonitorPhysicalHeight"

///|
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
pub extern "c" fn show_cursor() = "ShowCursor"

///|
pub extern "c" fn hide_cursor() = "HideCursor"

///|
pub extern "c" fn is_cursor_hidden() -> Bool = "IsCursorHidden"

///|
pub extern "c" fn enable_cursor() = "EnableCursor"

///|
pub extern "c" fn disable_cursor() = "DisableCursor"

///|
pub extern "c" fn is_cursor_on_screen() -> Bool = "IsCursorOnScreen"

// ============================================================================
// Drawing
// ============================================================================

///|
#borrow(color)
pub extern "c" fn clear_background(color : Bytes) = "moonbit_raylib_clear_background"

///|
pub extern "c" fn begin_drawing() = "BeginDrawing"

///|
pub extern "c" fn end_drawing() = "EndDrawing"

///|
#borrow(camera)
pub extern "c" fn begin_mode_2d(camera : Bytes) = "moonbit_raylib_begin_mode_2d"

///|
pub extern "c" fn end_mode_2d() = "EndMode2D"

///|
#borrow(camera)
pub extern "c" fn begin_mode_3d(camera : Bytes) = "moonbit_raylib_begin_mode_3d"

///|
pub extern "c" fn end_mode_3d() = "EndMode3D"

///|
pub extern "c" fn begin_scissor_mode(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) = "BeginScissorMode"

///|
pub extern "c" fn end_scissor_mode() = "EndScissorMode"

///|
pub extern "c" fn begin_blend_mode(mode : Int) = "BeginBlendMode"

///|
pub extern "c" fn end_blend_mode() = "EndBlendMode"

///|
#borrow(target)
pub extern "c" fn begin_texture_mode(target : RenderTexture) = "moonbit_raylib_begin_texture_mode"

///|
pub extern "c" fn end_texture_mode() = "EndTextureMode"

// ============================================================================
// Timing
// ============================================================================

///|
pub extern "c" fn set_target_fps(fps : Int) = "SetTargetFPS"

///|
pub extern "c" fn get_frame_time() -> Float = "GetFrameTime"

///|
pub extern "c" fn get_time() -> Double = "GetTime"

///|
pub extern "c" fn get_fps() -> Int = "GetFPS"

// ============================================================================
// Keyboard input
// ============================================================================

///|
pub extern "c" fn is_key_pressed(key : Int) -> Bool = "IsKeyPressed"

///|
pub extern "c" fn is_key_pressed_repeat(key : Int) -> Bool = "IsKeyPressedRepeat"

///|
pub extern "c" fn is_key_down(key : Int) -> Bool = "IsKeyDown"

///|
pub extern "c" fn is_key_released(key : Int) -> Bool = "IsKeyReleased"

///|
pub extern "c" fn is_key_up(key : Int) -> Bool = "IsKeyUp"

///|
pub extern "c" fn get_key_pressed() -> Int = "GetKeyPressed"

///|
pub extern "c" fn get_char_pressed() -> Int = "GetCharPressed"

///|
pub extern "c" fn set_exit_key(key : Int) = "SetExitKey"

// ============================================================================
// Mouse input
// ============================================================================

///|
pub extern "c" fn is_mouse_button_pressed(button : Int) -> Bool = "IsMouseButtonPressed"

///|
pub extern "c" fn is_mouse_button_down(button : Int) -> Bool = "IsMouseButtonDown"

///|
pub extern "c" fn is_mouse_button_released(button : Int) -> Bool = "IsMouseButtonReleased"

///|
pub extern "c" fn is_mouse_button_up(button : Int) -> Bool = "IsMouseButtonUp"

///|
pub extern "c" fn get_mouse_x() -> Int = "GetMouseX"

///|
pub extern "c" fn get_mouse_y() -> Int = "GetMouseY"

///|
pub extern "c" fn get_mouse_position() -> Bytes = "moonbit_raylib_get_mouse_position"

///|
pub extern "c" fn get_mouse_delta() -> Bytes = "moonbit_raylib_get_mouse_delta"

///|
pub extern "c" fn set_mouse_position(x : Int, y : Int) = "SetMousePosition"

///|
pub extern "c" fn set_mouse_offset(offset_x : Int, offset_y : Int) = "SetMouseOffset"

///|
pub extern "c" fn set_mouse_scale(scale_x : Float, scale_y : Float) = "SetMouseScale"

///|
pub extern "c" fn get_mouse_wheel_move() -> Float = "GetMouseWheelMove"

///|
pub extern "c" fn get_mouse_wheel_move_v() -> Bytes = "moonbit_raylib_get_mouse_wheel_move_v"

///|
pub extern "c" fn set_mouse_cursor(cursor : Int) = "SetMouseCursor"

// ============================================================================
// Gamepad input
// ============================================================================

///|
pub extern "c" fn is_gamepad_available(gamepad : Int) -> Bool = "IsGamepadAvailable"

///|
pub extern "c" fn get_gamepad_name(gamepad : Int) -> Bytes = "moonbit_raylib_get_gamepad_name"

///|
pub extern "c" fn is_gamepad_button_pressed(
  gamepad : Int,
  button : Int,
) -> Bool = "IsGamepadButtonPressed"

///|
pub extern "c" fn is_gamepad_button_down(gamepad : Int, button : Int) -> Bool = "IsGamepadButtonDown"

///|
pub extern "c" fn is_gamepad_button_released(
  gamepad : Int,
  button : Int,
) -> Bool = "IsGamepadButtonReleased"

///|
pub extern "c" fn is_gamepad_button_up(gamepad : Int, button : Int) -> Bool = "IsGamepadButtonUp"

///|
pub extern "c" fn get_gamepad_button_pressed() -> Int = "GetGamepadButtonPressed"

///|
pub extern "c" fn get_gamepad_axis_count(gamepad : Int) -> Int = "GetGamepadAxisCount"

///|
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
pub extern "c" fn get_touch_x() -> Int = "GetTouchX"

///|
pub extern "c" fn get_touch_y() -> Int = "GetTouchY"

///|
pub extern "c" fn get_touch_position(index : Int) -> Bytes = "moonbit_raylib_get_touch_position"

///|
pub extern "c" fn get_touch_point_id(index : Int) -> Int = "GetTouchPointId"

///|
pub extern "c" fn get_touch_point_count() -> Int = "GetTouchPointCount"

// ============================================================================
// Gesture input
// ============================================================================

///|
pub extern "c" fn set_gestures_enabled(flags : Int) = "SetGesturesEnabled"

///|
pub extern "c" fn is_gesture_detected(gesture : Int) -> Bool = "IsGestureDetected"

///|
pub extern "c" fn get_gesture_detected() -> Int = "GetGestureDetected"

///|
pub extern "c" fn get_gesture_hold_duration() -> Float = "GetGestureHoldDuration"

///|
pub extern "c" fn get_gesture_drag_vector() -> Bytes = "moonbit_raylib_get_gesture_drag_vector"

///|
pub extern "c" fn get_gesture_drag_angle() -> Float = "GetGestureDragAngle"

///|
pub extern "c" fn get_gesture_pinch_vector() -> Bytes = "moonbit_raylib_get_gesture_pinch_vector"

///|
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
pub extern "c" fn set_shader_location(
  shader : Shader,
  loc_index : Int,
  value : Int,
) = "moonbit_raylib_set_shader_location"

///|
#borrow(shader)
pub extern "c" fn get_shader_id(shader : Shader) -> Int = "moonbit_raylib_get_shader_id"

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
pub extern "c" fn get_random_value(min : Int, max : Int) -> Int = "GetRandomValue"

///|
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
#borrow(config)
pub extern "c" fn begin_vr_stereo_mode(config : VrStereoConfig) = "moonbit_raylib_begin_vr_stereo_mode"

///|
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
pub extern "c" fn rl_mult_matrixf(matf : Bytes) = "rlMultMatrixf"

// rlgl: State control

///|
pub extern "c" fn rl_enable_backface_culling() = "rlEnableBackfaceCulling"

///|
pub extern "c" fn rl_disable_backface_culling() = "rlDisableBackfaceCulling"

///|
pub extern "c" fn rl_check_render_batch_limit(v_count : Int) -> Bool = "rlCheckRenderBatchLimit"

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
pub extern "c" fn rl_framebuffer_complete(id : UInt) -> Bool = "rlFramebufferComplete"

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
pub extern "c" fn rl_load_texture_depth(width : Int, height : Int, use_render_buffer : Bool) -> UInt = "rlLoadTextureDepth"

///|
pub extern "c" fn rl_unload_texture(id : UInt) = "rlUnloadTexture"

// rlgl: Shader management (low-level)

///|
pub extern "c" fn rl_get_location_uniform(shader_id : UInt, uniform_name : Bytes) -> Int = "rlGetLocationUniform"

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
