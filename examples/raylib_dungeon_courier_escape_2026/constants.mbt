///|
let screen_w : Int = 1440

///|
let screen_h : Int = 900

///|
let target_fps : Int = 120

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_retry : Int = 2

///|
let max_parcels : Int = 12

///|
let max_exits : Int = 3

///|
let max_guards : Int = 16

///|
let max_traps : Int = 28

///|
let max_smokes : Int = 8

///|
let hud_h : Float = 92.0

///|
let world_left : Float = 46.0

///|
let world_top : Float = 108.0

///|
let world_right : Float = Float::from_int(screen_w) - 46.0

///|
let world_bottom : Float = Float::from_int(screen_h) - 46.0

///|
let player_radius : Float = 14.0

///|
let player_base_speed : Float = 210.0

///|
let player_sprint_mult : Float = 1.62

///|
let player_carry_speed_mult : Float = 0.83

///|
let player_health_max : Float = 100.0

///|
let player_stealth_max : Float = 100.0

///|
let stealth_recovery_per_sec : Float = 16.0

///|
let stealth_break_damage_per_sec : Float = 19.0

///|
let sprint_noise_pressure : Float = 10.0

///|
let sprint_stealth_burn : Float = 8.0

///|
let interaction_range : Float = 36.0

///|
let parcel_spawn_margin : Float = 84.0

///|
let exit_radius : Float = 34.0

///|
let guard_speed_base : Float = 96.0

///|
let guard_speed_wave_gain : Float = 8.0

///|
let guard_alert_speed_mult : Float = 1.35

///|
let guard_cone_range_base : Float = 214.0

///|
let guard_cone_range_wave_gain : Float = 8.0

///|
let guard_cone_half_angle_base : Float = 27.0

///|
let guard_detection_base : Float = 14.0

///|
let guard_detection_peak : Float = 52.0

///|
let guard_alert_hold : Float = 1.5

///|
let guard_smoke_lure_range : Float = 250.0

///|
let guard_investigate_hold : Float = 1.4

///|
let guard_spawn_margin : Float = 90.0

///|
let trap_radius_base : Float = 18.0

///|
let trap_damage_base : Float = 16.0

///|
let trap_damage_wave_gain : Float = 2.5

///|
let trap_trigger_cooldown : Float = 1.15

///|
let trap_pressure : Float = 12.0

///|
let trap_spawn_margin : Float = 72.0

///|
let smoke_radius_base : Float = 154.0

///|
let smoke_life_secs : Float = 4.8

///|
let smoke_cover_factor : Float = 0.38

///|
let smoke_stock_base : Int = 2

///|
let wave_target_base : Int = 2

///|
let max_delivery_target : Int = 7

///|
let wave_time_base : Float = 74.0

///|
let wave_time_decay : Float = 4.2

///|
let wave_min_time : Float = 35.0

///|
let wave_clear_health_recover : Float = 12.0

///|
let wave_clear_score_base : Int = 160

///|
let wave_clear_score_wave_bonus : Int = 38

///|
let wave_clear_time_score_mult : Float = 4.0

///|
let pi : Float = 3.141592653589793

///|
let deg_to_rad : Float = pi / 180.0

///|
let rad_to_deg : Float = 180.0 / pi

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
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
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
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
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
fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
fn normalize_deg(a : Float) -> Float {
  let mut v = a
  while v > 180.0 {
    v = v - 360.0
  }
  while v < -180.0 {
    v = v + 360.0
  }
  v
}

///|
fn angle_delta_deg(a : Float, b : Float) -> Float {
  absf(normalize_deg(a - b))
}

///|
fn heading_deg(dx : Float, dy : Float) -> Float {
  @math.atan2f(dy, dx) * rad_to_deg
}

///|
fn world_w() -> Float {
  world_right - world_left
}

///|
fn world_h() -> Float {
  world_bottom - world_top
}

///|
fn world_center_x() -> Float {
  (world_left + world_right) * 0.5
}

///|
fn world_center_y() -> Float {
  (world_top + world_bottom) * 0.5
}

///|
fn player_spawn_x() -> Float {
  world_center_x()
}

///|
fn player_spawn_y() -> Float {
  world_bottom - 86.0
}

///|
fn default_exit_pos(i : Int) -> (Float, Float) {
  if i % max_exits == 0 {
    (world_left + 104.0, world_top + 84.0)
  } else if i % max_exits == 1 {
    (world_center_x(), world_top + 76.0)
  } else {
    (world_right - 104.0, world_bottom - 94.0)
  }
}

///|
fn alpha_color(c : @raylib.Color, a : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(a, 0, 255),
  )
}

///|
fn col_bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 14, 23, 255)
}

///|
fn col_bg_bottom() -> @raylib.Color {
  @raylib.Color::new(12, 21, 32, 255)
}

///|
fn col_floor() -> @raylib.Color {
  @raylib.Color::new(24, 34, 46, 255)
}

///|
fn col_floor_grid() -> @raylib.Color {
  @raylib.Color::new(44, 58, 74, 150)
}

///|
fn col_wall() -> @raylib.Color {
  @raylib.Color::new(56, 66, 84, 255)
}

///|
fn col_player() -> @raylib.Color {
  @raylib.Color::new(114, 232, 190, 255)
}

///|
fn col_guard() -> @raylib.Color {
  @raylib.Color::new(255, 122, 122, 255)
}

///|
fn col_parcel() -> @raylib.Color {
  @raylib.Color::new(250, 222, 120, 255)
}

///|
fn col_exit() -> @raylib.Color {
  @raylib.Color::new(126, 172, 255, 255)
}

///|
fn col_trap() -> @raylib.Color {
  @raylib.Color::new(242, 88, 142, 255)
}

///|
fn col_smoke() -> @raylib.Color {
  @raylib.Color::new(164, 168, 180, 210)
}

///|
fn col_health() -> @raylib.Color {
  @raylib.Color::new(238, 98, 114, 255)
}

///|
fn col_stealth() -> @raylib.Color {
  @raylib.Color::new(118, 216, 196, 255)
}
