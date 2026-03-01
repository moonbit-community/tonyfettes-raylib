///|
pub let screen_w : Int = 1280

///|
pub let screen_h : Int = 720

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
pub let ent_guard : Int = 0

///|
pub let ent_drone : Int = 1

///|
pub let ent_turret : Int = 2

///|
pub let ent_crate : Int = 3

///|
pub let ent_medkit : Int = 4

///|
pub let ent_battery : Int = 5

///|
pub let ent_signal : Int = 6

///|
pub let max_ents : Int = 380

///|
pub let max_shots : Int = 460

///|
pub let max_fx : Int = 800

///|
pub let max_rings : Int = 76

///|
pub let max_shadows : Int = 220

///|
pub let player_w : Float = Float::from_int(42)

///|
pub let player_h : Float = Float::from_int(76)

///|
pub let player_accel_x : Float = Float::from_int(1380)

///|
pub let player_drag_x : Float = Float::from_int(4)

///|
pub let player_max_vx : Float = Float::from_int(380)

///|
pub let gravity : Float = Float::from_int(1550)

///|
pub let fall_max : Float = Float::from_int(760)

///|
pub let jump_speed : Float = Float::from_int(680)

///|
pub let dash_cd_time : Float = 1.4

///|
pub let dash_time : Float = 0.2

///|
pub let dash_speed : Float = Float::from_int(600)

///|
pub let hook_cd_time : Float = 2.3

///|
pub let hook_time : Float = 0.72

///|
pub let hook_radius : Float = Float::from_int(240)

///|
pub let hook_kill_radius : Float = Float::from_int(100)

///|
pub let invuln_time : Float = 0.62

///|
pub let fire_cd_base : Float = 0.15

///|
pub let shot_speed : Float = Float::from_int(780)

///|
pub let enemy_shot_speed : Float = Float::from_int(320)

///|
pub let shot_life : Float = 1.4

///|
pub let base_scroll : Float = Float::from_int(250)

///|
pub let stage_scroll_bonus : Float = Float::from_int(28)

///|
pub let stage_goal_base : Float = Float::from_int(2200)

///|
pub let stage_goal_bonus : Float = Float::from_int(700)

///|
pub let spawn_start_x : Float = Float::from_int(screen_w) + 100.0

///|
pub let spawn_gap_min : Float = 120.0

///|
pub let spawn_gap_max : Float = 220.0

///|
pub let lane_count : Int = 3

///|
pub let lane_gap : Float = Float::from_int(120)

///|
pub let lane_top : Float = Float::from_int(282)

///|
pub let armor_max : Float = Float::from_int(100)

///|
pub let heat_max : Float = Float::from_int(100)

///|
pub let heat_drain_base : Float = Float::from_int(3)

///|
pub let heat_drain_dash : Float = Float::from_int(6)

///|
pub let heat_pickup : Float = Float::from_int(24)

///|
pub let armor_passive : Float = 0.38

///|
pub let stage_clear_wait : Float = 1.86

///|
pub let hud_h : Int = 112

///|
pub fn btn_size() -> Float {
  Float::from_int(104)
}

///|
pub fn btn_left_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
pub fn btn_right_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(134),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
pub fn btn_jump_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(248),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
pub fn btn_fire_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
pub fn btn_dash_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s * Float::from_int(2) - Float::from_int(34),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
pub fn btn_hook_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s * Float::from_int(2) - Float::from_int(34),
    s,
    s,
  )
}

///|
pub fn title_start_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(420)
  let h = Float::from_int(88)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.64,
    w,
    h,
  )
}

///|
pub fn retry_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(220)
  let h = Float::from_int(64)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.74,
    w,
    h,
  )
}

///|
pub fn bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 16, 30, 255)
}

///|
pub fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(14, 34, 56, 255)
}

///|
pub fn snow_col() -> @raylib.Color {
  @raylib.Color::new(230, 244, 255, 255)
}

///|
pub fn cyan() -> @raylib.Color {
  @raylib.Color::new(94, 238, 255, 255)
}

///|
pub fn pink() -> @raylib.Color {
  @raylib.Color::new(255, 114, 214, 255)
}

///|
pub fn amber() -> @raylib.Color {
  @raylib.Color::new(255, 214, 124, 255)
}

///|
pub fn armor_col() -> @raylib.Color {
  @raylib.Color::new(255, 122, 154, 255)
}

///|
pub fn heat_col() -> @raylib.Color {
  @raylib.Color::new(116, 244, 196, 255)
}
