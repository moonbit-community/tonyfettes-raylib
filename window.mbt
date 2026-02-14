// Window management re-exports

///|
pub using @raylib {
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
  // Timing
  set_target_fps,
  get_frame_time,
  get_time,
  get_fps,
  // Misc
  set_trace_log_level,
  get_random_value,
  set_random_seed,
}

// Window management wrappers

///|
pub fn init_window(width : Int, height : Int, title : String) -> Unit {
  @raylib.init_window(width, height, @utf8.encode(title))
}

///|
pub fn set_window_title(title : String) -> Unit {
  @raylib.set_window_title(@utf8.encode(title))
}

///|
pub fn take_screenshot(file_name : String) -> Unit {
  @raylib.take_screenshot(@utf8.encode(file_name))
}

///|
pub fn open_url(url : String) -> Unit {
  @raylib.open_url(@utf8.encode(url))
}

// ConfigFlags constants

///|
pub const FlagVsyncHint : Int = 0x00000040

///|
pub const FlagFullscreenMode : Int = 0x00000002

///|
pub const FlagWindowResizable : Int = 0x00000004

///|
pub const FlagWindowUndecorated : Int = 0x00000008

///|
pub const FlagWindowHidden : Int = 0x00000080

///|
pub const FlagWindowMinimized : Int = 0x00000200

///|
pub const FlagWindowMaximized : Int = 0x00000400

///|
pub const FlagWindowUnfocused : Int = 0x00000800

///|
pub const FlagWindowTopmost : Int = 0x00001000

///|
pub const FlagWindowAlwaysRun : Int = 0x00000100

///|
pub const FlagWindowTransparent : Int = 0x00000010

///|
pub const FlagWindowHighdpi : Int = 0x00002000

///|
pub const FlagWindowMousePassthrough : Int = 0x00004000

///|
pub const FlagBorderlessWindowedMode : Int = 0x00008000

///|
pub const FlagMsaa4xHint : Int = 0x00000020

///|
pub const FlagInterlacedHint : Int = 0x00010000

// Log level constants

///|
pub const LogAll : Int = 0

///|
pub const LogTrace : Int = 1

///|
pub const LogDebug : Int = 2

///|
pub const LogInfo : Int = 3

///|
pub const LogWarning : Int = 4

///|
pub const LogError : Int = 5

///|
pub const LogFatal : Int = 6

///|
pub const LogNone : Int = 7
