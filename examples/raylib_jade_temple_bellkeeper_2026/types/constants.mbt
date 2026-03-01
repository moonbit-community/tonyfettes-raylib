///|
pub let screen_w : Int = 1280

///|
pub let screen_h : Int = 720

///|
pub let target_fps : Int = 120

///|
pub let hud_h : Int = 112

///|
pub let play_left : Float = 42.0

///|
pub let play_right : Float = Float::from_int(screen_w) - 42.0

///|
pub let play_top : Float = Float::from_int(hud_h) + 18.0

///|
pub let play_bottom : Float = Float::from_int(screen_h) - 24.0

///|
pub fn shrine_x() -> Float {
  Float::from_int(screen_w) * 0.5
}

///|
pub fn shrine_y() -> Float {
  Float::from_int(screen_h) * 0.55
}

///|
pub fn bell_orbit_r() -> Float {
  220.0
}

///|
pub fn bell_pos(i : Int) -> (Float, Float) {
  let cx = shrine_x()
  let cy = shrine_y()
  let r = bell_orbit_r()
  let k = i % bell_count

  if k == 0 {
    (cx, cy - r)
  } else if k == 1 {
    (cx + r, cy)
  } else if k == 2 {
    (cx, cy + r)
  } else {
    (cx - r, cy)
  }
}

///|
pub let state_title : Int = 0

///|
pub let state_play : Int = 1

///|
pub let state_stage_clear : Int = 2

///|
pub let state_game_over : Int = 3

///|
pub let foe_wisp : Int = 0

///|
pub let foe_brute : Int = 1

///|
pub let foe_shaman : Int = 2

///|
pub let foe_relic : Int = 3

///|
pub let max_foes : Int = 380

///|
pub let max_bolts : Int = 420

///|
pub let max_sparks : Int = 900

///|
pub let max_rings : Int = 96

///|
pub let max_echoes : Int = 320

///|
pub let hero_w : Float = 46.0

///|
pub let hero_h : Float = 52.0

///|
pub let hero_accel : Float = 1400.0

///|
pub let hero_drag : Float = 3.6

///|
pub let hero_max_speed : Float = 390.0

///|
pub let hero_invuln_time : Float = 0.62

///|
pub let hero_hurt_time : Float = 0.56

///|
pub let dash_cd_time : Float = 1.2

///|
pub let dash_time : Float = 0.2

///|
pub let dash_speed : Float = 700.0

///|
pub let bell_count : Int = 4

///|
pub let bell_ring_reach : Float = 138.0

///|
pub let bell_cd_time : Float = 1.38

///|
pub let bell_cost : Float = 18.0

///|
pub let bell_shock_radius : Float = 180.0

///|
pub let bell_shock_damage : Float = 26.0

///|
pub let bolt_speed : Float = 360.0

///|
pub let bolt_life : Float = 3.0

///|
pub let shrine_radius : Float = 64.0

///|
pub let shrine_max_hp : Float = 100.0

///|
pub let spirit_max : Float = 100.0

///|
pub let spirit_regen : Float = 16.0

///|
pub let spirit_dash_cost : Float = 12.0

///|
pub let stage_goal_base : Int = 1200

///|
pub let stage_goal_bonus : Int = 760

///|
pub let stage_time_base : Float = 60.0

///|
pub let stage_time_bonus : Float = 10.0

///|
pub let stage_clear_wait : Float = 1.9

///|
pub let spawn_cd_min : Float = 0.26

///|
pub let spawn_cd_max : Float = 1.08

///|
pub let shrine_drain_wisp : Float = 9.0

///|
pub let shrine_drain_brute : Float = 16.0

///|
pub let shrine_drain_shaman : Float = 11.0

///|
pub fn bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 18, 38, 255)
}

///|
pub fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(18, 42, 76, 255)
}

///|
pub fn cyan() -> @raylib.Color {
  @raylib.Color::new(96, 238, 255, 255)
}

///|
pub fn pink() -> @raylib.Color {
  @raylib.Color::new(255, 124, 188, 255)
}

///|
pub fn amber() -> @raylib.Color {
  @raylib.Color::new(255, 212, 122, 255)
}

///|
pub fn jade() -> @raylib.Color {
  @raylib.Color::new(126, 244, 198, 255)
}

///|
pub fn shrine_col() -> @raylib.Color {
  @raylib.Color::new(255, 136, 168, 255)
}

///|
pub fn spirit_col() -> @raylib.Color {
  @raylib.Color::new(120, 244, 204, 255)
}

///|
pub fn btn_size() -> Float {
  102.0
}

///|
pub fn btn_left_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (20.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
pub fn btn_right_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (132.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
pub fn btn_up_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (76.0, Float::from_int(screen_h) - s * 2.0 - 34.0, s, s)
}

///|
pub fn btn_down_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (76.0, Float::from_int(screen_h) - 20.0, s, s)
}

///|
pub fn btn_ring_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - 20.0,
    Float::from_int(screen_h) - s - 20.0,
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
  let h : Float = 86.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.66,
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
