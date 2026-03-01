///|
pub let screen_w : Int = 1366

///|
pub let screen_h : Int = 768

///|
pub let target_fps : Int = 120

///|
pub let state_title : Int = 0

///|
pub let state_play : Int = 1

///|
pub let state_stage_clear : Int = 2

///|
pub let state_game_over : Int = 3

///|
pub let state_victory : Int = 4

///|
pub let tile_solid : Int = 0

///|
pub let tile_hazard : Int = 1

///|
pub let lose_none : Int = 0

///|
pub let lose_time : Int = 1

///|
pub let lose_fall : Int = 2

///|
pub let lose_hazard : Int = 3

///|
pub let stage_count : Int = 3

///|
pub let max_tiles : Int = 128

///|
pub let max_checkpoints : Int = 12

///|
pub let player_w : Float = 34.0

///|
pub let player_h : Float = 54.0

///|
pub let gravity : Float = 2140.0

///|
pub let max_fall_speed : Float = 980.0

///|
pub let run_accel_ground : Float = 2700.0

///|
pub let run_accel_air : Float = 1650.0

///|
pub let run_max_speed : Float = 420.0

///|
pub let run_drag_ground : Float = 2300.0

///|
pub let run_drag_air : Float = 820.0

///|
pub let jump_speed : Float = 780.0

///|
pub let jump_cut_gravity : Float = 2400.0

///|
pub let jump_buffer_time : Float = 0.13

///|
pub let coyote_time : Float = 0.11

///|
pub let wall_jump_window : Float = 0.17

///|
pub let wall_jump_push : Float = 470.0

///|
pub let wall_jump_speed : Float = 820.0

///|
pub let wall_slide_speed : Float = 210.0

///|
pub let wall_climb_time_max : Float = 0.62

///|
pub let wall_climb_up_accel : Float = 1650.0

///|
pub let wall_climb_up_speed : Float = 220.0

///|
pub let timer_cap : Float = 99.9

///|
pub let stage_fail_y_pad : Float = 210.0

///|
pub fn stage_initial_time(stage : Int) -> Float {
  if stage <= 1 {
    42.0
  } else if stage == 2 {
    36.0
  } else {
    32.0
  }
}

///|
pub fn stage_clear_bonus(stage : Int) -> Int {
  if stage == 1 {
    9
  } else if stage == 2 {
    8
  } else {
    0
  }
}

///|
pub fn touch_left_rect() -> (Float, Float, Float, Float) {
  let s : Float = 94.0
  let y = Float::from_int(screen_h) - s - 22.0
  (20.0, y, s, s)
}

///|
pub fn touch_right_rect() -> (Float, Float, Float, Float) {
  let s : Float = 94.0
  let y = Float::from_int(screen_h) - s - 22.0
  (126.0, y, s, s)
}

///|
pub fn touch_jump_rect() -> (Float, Float, Float, Float) {
  let s : Float = 94.0
  let y = Float::from_int(screen_h) - s - 22.0
  (Float::from_int(screen_w) - s - 22.0, y, s, s)
}

///|
pub fn touch_climb_rect() -> (Float, Float, Float, Float) {
  let s : Float = 94.0
  let y = Float::from_int(screen_h) - s - 22.0
  (Float::from_int(screen_w) - s * 2.0 - 36.0, y, s, s)
}

///|
pub fn touch_play_restart_rect() -> (Float, Float, Float, Float) {
  (Float::from_int(screen_w) - 146.0, 16.0, 130.0, 44.0)
}

///|
pub fn title_start_rect() -> (Float, Float, Float, Float) {
  let w : Float = 320.0
  let h : Float = 82.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.62,
    w,
    h,
  )
}

///|
pub fn panel_next_rect() -> (Float, Float, Float, Float) {
  let w : Float = 230.0
  let h : Float = 72.0
  (
    Float::from_int(screen_w) * 0.5 - w - 14.0,
    Float::from_int(screen_h) * 0.66,
    w,
    h,
  )
}

///|
pub fn panel_restart_rect() -> (Float, Float, Float, Float) {
  let w : Float = 230.0
  let h : Float = 72.0
  (
    Float::from_int(screen_w) * 0.5 + 14.0,
    Float::from_int(screen_h) * 0.66,
    w,
    h,
  )
}

///|
pub fn col_bg_top() -> @raylib.Color {
  @raylib.Color::new(18, 24, 44, 255)
}

///|
pub fn col_bg_bottom() -> @raylib.Color {
  @raylib.Color::new(8, 10, 20, 255)
}

///|
pub fn col_sky_glow() -> @raylib.Color {
  @raylib.Color::new(80, 132, 220, 90)
}

///|
pub fn col_roof() -> @raylib.Color {
  @raylib.Color::new(54, 66, 96, 255)
}

///|
pub fn col_roof_edge() -> @raylib.Color {
  @raylib.Color::new(98, 130, 196, 230)
}

///|
pub fn col_checkpoint() -> @raylib.Color {
  @raylib.Color::new(84, 220, 255, 255)
}

///|
pub fn col_goal() -> @raylib.Color {
  @raylib.Color::new(146, 255, 150, 255)
}

///|
pub fn col_text_main() -> @raylib.Color {
  @raylib.Color::new(234, 244, 255, 255)
}

///|
pub fn col_text_dim() -> @raylib.Color {
  @raylib.Color::new(178, 198, 228, 255)
}

///|
pub fn col_player_run() -> @raylib.Color {
  @raylib.Color::new(255, 214, 106, 255)
}

///|
pub fn col_player_wall() -> @raylib.Color {
  @raylib.Color::new(255, 148, 104, 255)
}
