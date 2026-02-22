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
let obj_scout : Int = 0

///|
let obj_spinner : Int = 1

///|
let obj_tank : Int = 2

///|
let obj_gear_wall : Int = 3

///|
let obj_coin : Int = 4

///|
let obj_coolant : Int = 5

///|
let obj_emp_cell : Int = 6

///|
let max_objs : Int = 420

///|
let max_shots : Int = 480

///|
let max_sparks : Int = 760

///|
let max_shock_rings : Int = 84

///|
let max_ghosts : Int = 240

///|
let lane_count : Int = 5

///|
let lane_gap : Float = Float::from_int(90)

///|
let car_w : Float = Float::from_int(44)

///|
let car_h : Float = Float::from_int(76)

///|
let accel_x : Float = Float::from_int(1620)

///|
let accel_y : Float = Float::from_int(1180)

///|
let car_drag : Float = Float::from_int(3)

///|
let max_speed_x : Float = Float::from_int(500)

///|
let max_speed_y : Float = Float::from_int(340)

///|
let base_scroll : Float = Float::from_int(270)

///|
let stage_scroll_bonus : Float = Float::from_int(36)

///|
let stage_goal_base : Float = Float::from_int(2500)

///|
let stage_goal_bonus : Float = Float::from_int(780)

///|
let spawn_start_y : Float = -120.0

///|
let spawn_gap_min : Float = 64.0

///|
let spawn_gap_max : Float = 164.0

///|
let armor_max : Float = Float::from_int(100)

///|
let heat_max : Float = Float::from_int(100)

///|
let heat_drain_base : Float = Float::from_int(3)

///|
let heat_drain_dash : Float = Float::from_int(6)

///|
let heat_pickup : Float = Float::from_int(23)

///|
let armor_drain_passive : Float = 0.45

///|
let shot_cd_base : Float = 0.148

///|
let shot_speed : Float = Float::from_int(760)

///|
let enemy_shot_speed : Float = Float::from_int(380)

///|
let shot_life : Float = 1.24

///|
let dash_cd_time : Float = 1.62

///|
let dash_time : Float = 0.25

///|
let dash_boost : Float = Float::from_int(540)

///|
let emp_cd_time : Float = 2.46

///|
let emp_time : Float = 0.82

///|
let emp_radius : Float = Float::from_int(220)

///|
let emp_kill_radius : Float = Float::from_int(108)

///|
let stage_clear_wait : Float = 1.9

///|
let invuln_time : Float = 0.64

///|
let hud_h : Int = 112

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
fn track_center(depth : Float, time_s : Float) -> Float {
  let c = Float::from_int(screen_w / 2)
  let sway0 = sinf(depth * 0.0025 + time_s * 0.68) * 150.0
  let sway1 = sinf(depth * 0.004 + time_s * 1.18 + 1.2) * 86.0
  c + sway0 + sway1
}

///|
fn track_half_width(stage : Int, depth : Float, time_s : Float) -> Float {
  let wobble = sinf(depth * 0.0035 + time_s * 0.92 + 0.8) * 58.0
  let shrink = Float::from_int(stage - 1) * 10.0
  clampf(
    Float::from_int(305) + wobble - shrink,
    Float::from_int(160),
    Float::from_int(334),
  )
}

///|
fn lane_offset(lane : Int) -> Float {
  (Float::from_int(lane) - Float::from_int(lane_count - 1) * 0.5) * lane_gap
}

///|
fn lane_pos(lane : Int, center : Float) -> Float {
  center + lane_offset(clampi(lane, 0, lane_count - 1))
}

///|
fn track_edges(stage : Int, depth : Float, time_s : Float) -> (Float, Float) {
  let c = track_center(depth, time_s)
  let hw = track_half_width(stage, depth, time_s)
  (c - hw, c + hw)
}

///|
fn spawn_x(distance : Float, time_s : Float, stage : Int, y : Float) -> Float {
  let depth = distance + (Float::from_int(screen_h) - y)
  let c = track_center(depth, time_s)
  let hw = track_half_width(stage, depth, time_s)
  randf(c - hw + 56.0, c + hw - 56.0)
}

///|
fn bg_top() -> @raylib.Color {
  @raylib.Color::new(10, 10, 24, 255)
}

///|
fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(12, 26, 44, 255)
}

///|
fn track_dark() -> @raylib.Color {
  @raylib.Color::new(16, 20, 34, 255)
}

///|
fn track_mid() -> @raylib.Color {
  @raylib.Color::new(22, 30, 50, 255)
}

///|
fn amber() -> @raylib.Color {
  @raylib.Color::new(255, 214, 124, 255)
}

///|
fn armor_col() -> @raylib.Color {
  @raylib.Color::new(255, 122, 154, 255)
}

///|
fn heat_col() -> @raylib.Color {
  @raylib.Color::new(116, 244, 196, 255)
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
fn btn_dash_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s * Float::from_int(2) - Float::from_int(34),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
fn btn_emp_rect() -> (Float, Float, Float, Float) {
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
  let h = Float::from_int(88)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.64,
    w,
    h,
  )
}

///|
fn retry_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(220)
  let h = Float::from_int(64)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.74,
    w,
    h,
  )
}
