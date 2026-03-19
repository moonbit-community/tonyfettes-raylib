// Window management re-exports

///|
/// Re-exported window management, monitor, timing, and utility functions from the FFI layer.
pub using @ffi {
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
  is_window_state,
  // Monitor
  get_monitor_count,
  get_current_monitor,
  get_monitor_width,
  get_monitor_height,
  get_monitor_physical_width,
  get_monitor_physical_height,
  get_monitor_refresh_rate,
  set_window_monitor,
  // Timing
  set_target_fps,
  get_frame_time,
  get_time,
  get_fps,
  // Event waiting
  enable_event_waiting,
  disable_event_waiting,
  // Custom frame control
  swap_screen_buffer,
  poll_input_events,
  wait_time,
  // Misc
  set_trace_log_level,
  get_random_value,
  set_random_seed,
}

///|
/// Set icon for window (single image, RGBA 32bit).
pub fn set_window_icon(image : Image) -> Unit {
  @ffi.set_window_icon(image.0)
}

///|
/// Get clipboard image content.
pub fn get_clipboard_image() -> Image {
  @ffi.get_clipboard_image()
}

// Window management wrappers

///|
/// Initialize window and OpenGL context.
pub fn init_window(width : Int, height : Int, title : String) -> Unit {
  @ffi.init_window(width, height, @utf8.encode(title))
}

///|
/// Set title for window.
pub fn set_window_title(title : String) -> Unit {
  @ffi.set_window_title(@utf8.encode(title))
}

///|
/// Take a screenshot of current screen (filename extension defines format).
pub fn take_screenshot(file_name : String) -> Unit {
  @ffi.take_screenshot(@utf8.encode(file_name))
}

///|
/// Open URL with default system browser (if available).
pub fn open_url(url : String) -> Unit {
  @ffi.open_url(@utf8.encode(url))
}

///|
/// Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...).
pub fn trace_log(log_level : Int, text : String) -> Unit {
  @ffi.trace_log(log_level, @utf8.encode(text))
}

// Window state wrappers (Vector2 returns)

///|
/// Get window position XY on monitor.
pub fn get_window_position() -> Vector2 {
  Vector2::from_bytes(@ffi.get_window_position())
}

///|
/// Get window scale DPI factor.
pub fn get_window_scale_dpi() -> Vector2 {
  Vector2::from_bytes(@ffi.get_window_scale_dpi())
}

// Monitor management wrappers (Vector2/String returns)

///|
/// Get specified monitor position.
pub fn get_monitor_position(monitor : Int) -> Vector2 {
  Vector2::from_bytes(@ffi.get_monitor_position(monitor))
}

///|
/// Get the human-readable, UTF-8 encoded name of the specified monitor.
pub fn get_monitor_name(monitor : Int) -> String {
  @utf8.decode_lossy(@ffi.get_monitor_name(monitor))
}

// Clipboard wrappers

///|
/// Set clipboard text content.
pub fn set_clipboard_text(text : String) -> Unit {
  @ffi.set_clipboard_text(@utf8.encode(text))
}

///|
/// Get clipboard text content.
pub fn get_clipboard_text() -> String {
  @utf8.decode_lossy(@ffi.get_clipboard_text())
}

// ConfigFlags constants

///|
/// Config flag: set to try enabling V-Sync on GPU.
pub const FlagVsyncHint : Int = 0x00000040

///|
/// Config flag: set to run program in fullscreen.
pub const FlagFullscreenMode : Int = 0x00000002

///|
/// Config flag: set to allow resizable window.
pub const FlagWindowResizable : Int = 0x00000004

///|
/// Config flag: set to disable window decoration (frame and buttons).
pub const FlagWindowUndecorated : Int = 0x00000008

///|
/// Config flag: set to hide window.
pub const FlagWindowHidden : Int = 0x00000080

///|
/// Config flag: set to minimize window (iconify).
pub const FlagWindowMinimized : Int = 0x00000200

///|
/// Config flag: set to maximize window (expanded to monitor).
pub const FlagWindowMaximized : Int = 0x00000400

///|
/// Config flag: set to window non focused.
pub const FlagWindowUnfocused : Int = 0x00000800

///|
/// Config flag: set to window always on top.
pub const FlagWindowTopmost : Int = 0x00001000

///|
/// Config flag: set to allow windows running while minimized.
pub const FlagWindowAlwaysRun : Int = 0x00000100

///|
/// Config flag: set to allow transparent framebuffer.
pub const FlagWindowTransparent : Int = 0x00000010

///|
/// Config flag: set to support HighDPI.
pub const FlagWindowHighdpi : Int = 0x00002000

///|
/// Config flag: set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED.
pub const FlagWindowMousePassthrough : Int = 0x00004000

///|
/// Config flag: set to run program in borderless windowed mode.
pub const FlagBorderlessWindowedMode : Int = 0x00008000

///|
/// Config flag: set to try enabling MSAA 4X.
pub const FlagMsaa4xHint : Int = 0x00000020

///|
/// Config flag: set to try enabling interlaced video format (for V3D).
pub const FlagInterlacedHint : Int = 0x00010000

// Log level constants

///|
/// Trace log level: display all logs.
pub const LogAll : Int = 0

///|
/// Trace log level: trace logging, intended for internal use only.
pub const LogTrace : Int = 1

///|
/// Trace log level: debug logging, used for internal debugging.
pub const LogDebug : Int = 2

///|
/// Trace log level: info logging, used for program execution info.
pub const LogInfo : Int = 3

///|
/// Trace log level: warning logging, used on recoverable failures.
pub const LogWarning : Int = 4

///|
/// Trace log level: error logging, used on unrecoverable failures.
pub const LogError : Int = 5

///|
/// Trace log level: fatal logging, used to abort program.
pub const LogFatal : Int = 6

///|
/// Trace log level: disable logging.
pub const LogNone : Int = 7
