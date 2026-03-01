///|
pub let screen_w : Int = 1280

///|
pub let screen_h : Int = 720

///|
pub let target_fps : Int = 120

///|
pub let hud_h : Int = 110

///|
pub let play_left : Float = 46.0

///|
pub let play_right : Float = Float::from_int(screen_w) - 46.0

///|
pub let play_top : Float = Float::from_int(hud_h) + 18.0

///|
pub let play_bottom : Float = Float::from_int(screen_h) - 26.0

///|
pub let state_title : Int = 0

///|
pub let state_play : Int = 1

///|
pub let state_stage_clear : Int = 2

///|
pub let state_game_over : Int = 3

///|
pub let tea_jasmine : Int = 0

///|
pub let tea_oolong : Int = 1

///|
pub let tea_puer : Int = 2

///|
pub let tea_matcha : Int = 3

///|
pub let tea_berry : Int = 4

///|
pub let tea_count : Int = 5

///|
pub let max_customers : Int = 24

///|
pub let max_sparks : Int = 860

///|
pub let max_rings : Int = 86

///|
pub let max_shadows : Int = 320

///|
pub let customer_slots : Int = 6

///|
pub let player_w : Float = 46.0

///|
pub let player_h : Float = 58.0

///|
pub let player_accel : Float = 1260.0

///|
pub let player_drag : Float = 3.4

///|
pub let player_max_speed : Float = 360.0

///|
pub let dash_cd_time : Float = 1.5

///|
pub let dash_time : Float = 0.2

///|
pub let dash_speed : Float = 620.0

///|
pub let interact_reach : Float = 84.0

///|
pub let serve_reach : Float = 104.0

///|
pub let brew_time_base : Float = 1.9

///|
pub let brew_time_min : Float = 1.1

///|
pub let stage_goal_base : Int = 1300

///|
pub let stage_goal_bonus : Int = 760

///|
pub let stage_time_base : Float = 72.0

///|
pub let stage_time_bonus : Float = 10.0

///|
pub let stage_clear_wait : Float = 1.9

///|
pub let spawn_cd_min : Float = 0.6

///|
pub let spawn_cd_max : Float = 2.2

///|
pub let reputation_max : Float = 100.0

///|
pub let focus_max : Float = 100.0

///|
pub let focus_drain : Float = 28.0

///|
pub let focus_regen : Float = 20.0

///|
pub let dash_focus_cost : Float = 14.0

///|
pub let wrong_serve_penalty : Float = 8.0

///|
pub let miss_penalty : Float = 12.0

///|
pub let stage_clear_bonus : Int = 340

///|
pub let kettle_x : Float = 164.0

///|
pub let kettle_y : Float = 248.0

///|
pub let brew_x : Float = 480.0

///|
pub let brew_y : Float = 258.0

///|
pub let counter_x : Float = 958.0

///|
pub let counter_y : Float = 250.0

///|
pub fn leaf_x() -> Float {
  270.0
}

///|
pub fn leaf_y(tea : Int) -> Float {
  182.0 + Float::from_int(clampi(tea, 0, tea_count - 1)) * 86.0
}

///|
pub fn customer_slot_pos(slot : Int) -> (Float, Float) {
  let s = clampi(slot, 0, customer_slots - 1)
  let row = s / 3
  let col = s % 3
  let x : Float = 822.0 + Float::from_int(col) * 140.0
  let y : Float = 424.0 + Float::from_int(row) * 134.0
  (x, y)
}

///|
pub fn bg_top() -> @raylib.Color {
  @raylib.Color::new(14, 28, 52, 255)
}

///|
pub fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(40, 74, 112, 255)
}

///|
pub fn amber() -> @raylib.Color {
  @raylib.Color::new(255, 214, 126, 255)
}

///|
pub fn pink() -> @raylib.Color {
  @raylib.Color::new(255, 126, 198, 255)
}

///|
pub fn cyan() -> @raylib.Color {
  @raylib.Color::new(108, 236, 255, 255)
}

///|
pub fn jade() -> @raylib.Color {
  @raylib.Color::new(126, 244, 196, 255)
}

///|
pub fn reputation_col() -> @raylib.Color {
  @raylib.Color::new(255, 128, 166, 255)
}

///|
pub fn focus_col() -> @raylib.Color {
  @raylib.Color::new(124, 244, 204, 255)
}

///|
pub fn tea_name(t : Int) -> String {
  if t == tea_jasmine {
    "JASMINE"
  } else if t == tea_oolong {
    "OOLONG"
  } else if t == tea_puer {
    "PU-ERH"
  } else if t == tea_matcha {
    "MATCHA"
  } else {
    "BERRY"
  }
}

///|
pub fn tea_color(t : Int) -> @raylib.Color {
  if t == tea_jasmine {
    @raylib.Color::new(246, 238, 178, 255)
  } else if t == tea_oolong {
    @raylib.Color::new(220, 154, 110, 255)
  } else if t == tea_puer {
    @raylib.Color::new(164, 94, 74, 255)
  } else if t == tea_matcha {
    @raylib.Color::new(124, 208, 126, 255)
  } else {
    @raylib.Color::new(236, 112, 152, 255)
  }
}

///|
pub fn btn_size() -> Float {
  98.0
}

///|
pub fn btn_left_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (20.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
pub fn btn_right_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (130.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
pub fn btn_up_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (75.0, Float::from_int(screen_h) - s * 2.0 - 34.0, s, s)
}

///|
pub fn btn_down_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (75.0, Float::from_int(screen_h) - 20.0, s, s)
}

///|
pub fn btn_interact_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - 20.0,
    Float::from_int(screen_h) - s - 20.0,
    s,
    s,
  )
}

///|
pub fn btn_focus_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - 20.0,
    Float::from_int(screen_h) - s * 2.0 - 34.0,
    s,
    s,
  )
}

///|
pub fn btn_dash_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s * 2.0 - 34.0,
    Float::from_int(screen_h) - s - 20.0,
    s,
    s,
  )
}

///|
pub fn title_start_rect() -> (Float, Float, Float, Float) {
  let w : Float = 420.0
  let h : Float = 88.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.65,
    w,
    h,
  )
}

///|
pub fn retry_rect() -> (Float, Float, Float, Float) {
  let w : Float = 220.0
  let h : Float = 66.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.75,
    w,
    h,
  )
}
