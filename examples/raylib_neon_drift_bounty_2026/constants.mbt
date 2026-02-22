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
let state_stage_clear : Int = 2

///|
let state_game_over : Int = 3

///|
let foe_bike : Int = 0

///|
let foe_drone : Int = 1

///|
let foe_truck : Int = 2

///|
let foe_laser : Int = 3

///|
let item_credit : Int = 4

///|
let item_battery : Int = 5

///|
let item_hackcell : Int = 6

///|
let max_entities : Int = 380

///|
let max_bullets : Int = 440

///|
let max_sparks : Int = 760

///|
let max_glow_rings : Int = 80

///|
let max_afterimages : Int = 220

///|
let lanes_count : Int = 5

///|
let lane_gap : Float = Float::from_int(92)

///|
let player_w : Float = Float::from_int(42)

///|
let player_h : Float = Float::from_int(74)

///|
let player_accel_x : Float = Float::from_int(1700)

///|
let player_accel_y : Float = Float::from_int(1260)

///|
let player_drag : Float = Float::from_int(3)

///|
let player_max_speed_x : Float = Float::from_int(520)

///|
let player_max_speed_y : Float = Float::from_int(360)

///|
let base_scroll_speed : Float = Float::from_int(280)

///|
let stage_scroll_gain : Float = Float::from_int(34)

///|
let stage_distance_base : Float = Float::from_int(2600)

///|
let stage_distance_gain : Float = Float::from_int(760)

///|
let spawn_start_y : Float = -110.0

///|
let spawn_spacing_min : Float = 68.0

///|
let spawn_spacing_max : Float = 164.0

///|
let energy_drain_base : Float = Float::from_int(3)

///|
let energy_drain_boost : Float = Float::from_int(6)

///|
let energy_pickup : Float = Float::from_int(22)

///|
let shield_damage_decay : Float = Float::from_int(14)

///|
let player_shield_max : Float = Float::from_int(100)

///|
let player_energy_max : Float = Float::from_int(100)

///|
let fire_cooldown_base : Float = 0.145

///|
let bullet_speed : Float = Float::from_int(780)

///|
let enemy_bullet_speed : Float = Float::from_int(390)

///|
let bullet_life : Float = 1.2

///|
let boost_cd_time : Float = 1.55

///|
let boost_time : Float = 0.26

///|
let boost_speed_bonus : Float = Float::from_int(560)

///|
let hack_cd_time : Float = 2.4

///|
let hack_time : Float = 0.82

///|
let hack_radius : Float = Float::from_int(220)

///|
let hack_pulse_kill : Float = Float::from_int(110)

///|
let stage_clear_delay : Float = 1.85

///|
let invuln_after_hit : Float = 0.62

///|
let ui_panel_h : Int = 112

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
fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
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
fn sqrtf(v : Float) -> Float {
  v.sqrt()
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let n = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * n
}

///|
fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
fn chance(pct : Int) -> Bool {
  randi(0, 99) < pct
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
fn ease_out_cubic(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  Float::from_int(1) -
  (Float::from_int(1) - x) * (Float::from_int(1) - x) * (Float::from_int(1) - x)
}

///|
fn road_center_at(depth : Float, time_s : Float) -> Float {
  let cx = Float::from_int(screen_w / 2)
  let sway0 = sinf(depth * 0.0024 + time_s * 0.72) * 146.0
  let sway1 = sinf(depth * 0.0041 + time_s * 1.2 + 1.4) * 84.0
  cx + sway0 + sway1
}

///|
fn road_half_width(stage : Int, depth : Float, time_s : Float) -> Float {
  let pulse = sinf(depth * 0.0037 + time_s * 0.95 + 0.7) * 62.0
  let shrink = Float::from_int(stage - 1) * 10.0
  clampf(
    Float::from_int(310) + pulse - shrink,
    Float::from_int(164),
    Float::from_int(332),
  )
}

///|
fn lane_to_offset(lane : Int) -> Float {
  (Float::from_int(lane) - Float::from_int(lanes_count - 1) * 0.5) * lane_gap
}

///|
fn lane_x(lane : Int, center : Float) -> Float {
  center + lane_to_offset(clampi(lane, 0, lanes_count - 1))
}

///|
fn road_edges(stage : Int, depth : Float, time_s : Float) -> (Float, Float) {
  let c = road_center_at(depth, time_s)
  let hw = road_half_width(stage, depth, time_s)
  (c - hw, c + hw)
}

///|
fn road_spawn_x(
  game_depth : Float,
  game_time : Float,
  stage : Int,
  y : Float,
) -> Float {
  let d = game_depth + (Float::from_int(screen_h) - y)
  let c = road_center_at(d, game_time)
  let hw = road_half_width(stage, d, game_time)
  let lo = c - hw + 58.0
  let hi = c + hw - 58.0
  randf(lo, hi)
}

///|
fn bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 8, 24, 255)
}

///|
fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(10, 24, 46, 255)
}

///|
fn road_dark() -> @raylib.Color {
  @raylib.Color::new(14, 20, 34, 255)
}

///|
fn road_mid() -> @raylib.Color {
  @raylib.Color::new(20, 30, 52, 255)
}

///|
fn neon_yellow() -> @raylib.Color {
  @raylib.Color::new(255, 222, 118, 255)
}

///|
fn shield_col() -> @raylib.Color {
  @raylib.Color::new(255, 116, 152, 255)
}

///|
fn energy_col() -> @raylib.Color {
  @raylib.Color::new(112, 244, 196, 255)
}

///|
fn btn_size() -> Float {
  Float::from_int(104)
}

///|
fn btn_left_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
fn btn_right_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(134),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
fn btn_up_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(248),
    Float::from_int(screen_h) - s * Float::from_int(2) - Float::from_int(34),
    s,
    s,
  )
}

///|
fn btn_down_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(248),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
fn btn_fire_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
fn btn_boost_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s * Float::from_int(2) - Float::from_int(34),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
fn btn_hack_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s * Float::from_int(2) - Float::from_int(34),
    s,
    s,
  )
}

///|
fn title_start_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(420)
  let h = Float::from_int(90)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.64,
    w,
    h,
  )
}

///|
fn result_retry_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(220)
  let h = Float::from_int(64)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.74,
    w,
    h,
  )
}
