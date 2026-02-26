///|
let screen_w : Int = 1280

///|
let screen_h : Int = 720

///|
let target_fps : Int = 120

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_win : Int = 2

///|
let state_lose : Int = 3

///|
let lose_none : Int = 0

///|
let lose_oxygen : Int = 1

///|
let lose_fuel : Int = 2

///|
let lose_hull : Int = 3

///|
let arena_x0 : Int = 78

///|
let arena_y0 : Int = 84

///|
let arena_w : Int = 1124

///|
let arena_h : Int = 574

///|
let arena_x1 : Int = arena_x0 + arena_w

///|
let arena_y1 : Int = arena_y0 + arena_h

///|
let surface_band_h : Int = 86

///|
let surface_band_y : Float = Float::from_int(arena_y0 + surface_band_h)

///|
let hot_zone_x : Float = Float::from_int(arena_x0) +
  Float::from_int(arena_w) * 0.72

///|
let hot_zone_y : Float = Float::from_int(arena_y0) +
  Float::from_int(arena_h) * 0.46

///|
let hot_zone_r : Float = 148.0

///|
let mission_min : Int = 1

///|
let mission_max : Int = 9

///|
let max_mines : Int = 54

///|
let max_targets : Int = 16

///|
let base_target_goal : Int = 4

///|
let target_goal_cap : Int = 12

///|
let base_mine_count : Int = 16

///|
let sub_start_x : Float = Float::from_int(arena_x0) + 126.0

///|
let sub_start_y : Float = Float::from_int(arena_y0) +
  Float::from_int(arena_h) * 0.62

///|
let sub_r : Float = 18.0

///|
let sub_accel : Float = 420.0

///|
let sub_boost_accel : Float = 760.0

///|
let sub_drag : Float = 4.8

///|
let sub_max_speed : Float = 220.0

///|
let sub_boost_max_speed : Float = 340.0

///|
let oxygen_max : Float = 100.0

///|
let fuel_max : Float = 100.0

///|
let hull_max : Float = 100.0

///|
let oxygen_base_drain : Float = 3.2

///|
let oxygen_hot_drain : Float = 4.4

///|
let oxygen_boost_drain : Float = 1.8

///|
let oxygen_surface_recover : Float = 10.2

///|
let fuel_idle_drain : Float = 0.5

///|
let fuel_move_drain : Float = 3.1

///|
let fuel_boost_drain : Float = 7.6

///|
let sonar_cd_time : Float = 1.28

///|
let sonar_pulse_time : Float = 0.82

///|
let sonar_base_range : Float = 192.0

///|
let sonar_hot_bonus : Float = 110.0

///|
let sonar_fuel_cost : Float = 5.6

///|
let sonar_oxygen_cost : Float = 4.8

///|
let mine_reveal_time : Float = 3.0

///|
let mine_damage_hull : Float = 36.0

///|
let mine_damage_oxygen : Float = 18.0

///|
let mine_damage_fuel : Float = 11.0

///|
let detect_oxygen_reward : Float = 4.8

///|
let detect_fuel_reward : Float = 3.2

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
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
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
fn sqrtf(v : Float) -> Float {
  v.sqrt()
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
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn arena_left() -> Float {
  Float::from_int(arena_x0)
}

///|
fn arena_right() -> Float {
  Float::from_int(arena_x1)
}

///|
fn arena_top() -> Float {
  Float::from_int(arena_y0)
}

///|
fn arena_bottom() -> Float {
  Float::from_int(arena_y1)
}

///|
fn title_start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 180, screen_h / 2 + 112, 360, 72)
}

///|
fn result_restart_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 190, screen_h / 2 + 84, 180, 64)
}

///|
fn result_next_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 + 10, screen_h / 2 + 84, 180, 64)
}

///|
fn result_title_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 110, screen_h / 2 + 160, 220, 52)
}

///|
fn mobile_left_btn() -> (Int, Int, Int, Int) {
  (34, screen_h - 146, 66, 66)
}

///|
fn mobile_right_btn() -> (Int, Int, Int, Int) {
  (182, screen_h - 146, 66, 66)
}

///|
fn mobile_up_btn() -> (Int, Int, Int, Int) {
  (108, screen_h - 220, 66, 66)
}

///|
fn mobile_down_btn() -> (Int, Int, Int, Int) {
  (108, screen_h - 72, 66, 66)
}

///|
fn mobile_sonar_btn() -> (Int, Int, Int, Int) {
  (screen_w - 184, screen_h - 152, 148, 66)
}

///|
fn mobile_boost_btn() -> (Int, Int, Int, Int) {
  (screen_w - 184, screen_h - 76, 148, 58)
}

///|
fn mobile_restart_btn() -> (Int, Int, Int, Int) {
  (screen_w - 148, 20, 128, 46)
}
