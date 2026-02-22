///|
let screen_w : Int = 1366

///|
let screen_h : Int = 768

///|
let target_fps : Int = 120

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_stage_clear : Int = 2

///|
let state_game_over : Int = 3

///|
let state_victory : Int = 4

///|
let tile_solid : Int = 0

///|
let tile_hazard : Int = 1

///|
let lose_none : Int = 0

///|
let lose_time : Int = 1

///|
let lose_fall : Int = 2

///|
let lose_hazard : Int = 3

///|
let stage_count : Int = 3

///|
let max_tiles : Int = 128

///|
let max_checkpoints : Int = 12

///|
let player_w : Float = 34.0

///|
let player_h : Float = 54.0

///|
let gravity : Float = 2140.0

///|
let max_fall_speed : Float = 980.0

///|
let run_accel_ground : Float = 2700.0

///|
let run_accel_air : Float = 1650.0

///|
let run_max_speed : Float = 420.0

///|
let run_drag_ground : Float = 2300.0

///|
let run_drag_air : Float = 820.0

///|
let jump_speed : Float = 780.0

///|
let jump_cut_gravity : Float = 2400.0

///|
let jump_buffer_time : Float = 0.13

///|
let coyote_time : Float = 0.11

///|
let wall_jump_window : Float = 0.17

///|
let wall_jump_push : Float = 470.0

///|
let wall_jump_speed : Float = 820.0

///|
let wall_slide_speed : Float = 210.0

///|
let wall_climb_time_max : Float = 0.62

///|
let wall_climb_up_accel : Float = 1650.0

///|
let wall_climb_up_speed : Float = 220.0

///|
let timer_cap : Float = 99.9

///|
let stage_fail_y_pad : Float = 210.0

///|
fn stage_initial_time(stage : Int) -> Float {
  if stage <= 1 {
    42.0
  } else if stage == 2 {
    36.0
  } else {
    32.0
  }
}

///|
fn stage_clear_bonus(stage : Int) -> Int {
  if stage == 1 {
    9
  } else if stage == 2 {
    8
  } else {
    0
  }
}

///|
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn approachf(v : Float, target : Float, step : Float) -> Float {
  if v < target {
    minf(v + step, target)
  } else {
    maxf(v - step, target)
  }
}

///|
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
}

///|
fn touch_left_rect() -> (Float, Float, Float, Float) {
  let s : Float = 94.0
  let y = Float::from_int(screen_h) - s - 22.0
  (20.0, y, s, s)
}

///|
fn touch_right_rect() -> (Float, Float, Float, Float) {
  let s : Float = 94.0
  let y = Float::from_int(screen_h) - s - 22.0
  (126.0, y, s, s)
}

///|
fn touch_jump_rect() -> (Float, Float, Float, Float) {
  let s : Float = 94.0
  let y = Float::from_int(screen_h) - s - 22.0
  (Float::from_int(screen_w) - s - 22.0, y, s, s)
}

///|
fn touch_climb_rect() -> (Float, Float, Float, Float) {
  let s : Float = 94.0
  let y = Float::from_int(screen_h) - s - 22.0
  (Float::from_int(screen_w) - s * 2.0 - 36.0, y, s, s)
}

///|
fn touch_play_restart_rect() -> (Float, Float, Float, Float) {
  (Float::from_int(screen_w) - 146.0, 16.0, 130.0, 44.0)
}

///|
fn title_start_rect() -> (Float, Float, Float, Float) {
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
fn panel_next_rect() -> (Float, Float, Float, Float) {
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
fn panel_restart_rect() -> (Float, Float, Float, Float) {
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
fn col_bg_top() -> @raylib.Color {
  @raylib.Color::new(18, 24, 44, 255)
}

///|
fn col_bg_bottom() -> @raylib.Color {
  @raylib.Color::new(8, 10, 20, 255)
}

///|
fn col_sky_glow() -> @raylib.Color {
  @raylib.Color::new(80, 132, 220, 90)
}

///|
fn col_roof() -> @raylib.Color {
  @raylib.Color::new(54, 66, 96, 255)
}

///|
fn col_roof_edge() -> @raylib.Color {
  @raylib.Color::new(98, 130, 196, 230)
}

///|
fn col_checkpoint() -> @raylib.Color {
  @raylib.Color::new(84, 220, 255, 255)
}

///|
fn col_goal() -> @raylib.Color {
  @raylib.Color::new(146, 255, 150, 255)
}

///|
fn col_text_main() -> @raylib.Color {
  @raylib.Color::new(234, 244, 255, 255)
}

///|
fn col_text_dim() -> @raylib.Color {
  @raylib.Color::new(178, 198, 228, 255)
}

///|
fn col_player_run() -> @raylib.Color {
  @raylib.Color::new(255, 214, 106, 255)
}

///|
fn col_player_wall() -> @raylib.Color {
  @raylib.Color::new(255, 148, 104, 255)
}
