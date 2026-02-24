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
let ent_guard : Int = 0

///|
let ent_drone : Int = 1

///|
let ent_turret : Int = 2

///|
let ent_crate : Int = 3

///|
let ent_medkit : Int = 4

///|
let ent_battery : Int = 5

///|
let ent_signal : Int = 6

///|
let max_ents : Int = 380

///|
let max_shots : Int = 460

///|
let max_fx : Int = 800

///|
let max_rings : Int = 76

///|
let max_shadows : Int = 220

///|
let player_w : Float = Float::from_int(42)

///|
let player_h : Float = Float::from_int(76)

///|
let player_accel_x : Float = Float::from_int(1380)

///|
let player_drag_x : Float = Float::from_int(4)

///|
let player_max_vx : Float = Float::from_int(380)

///|
let gravity : Float = Float::from_int(1550)

///|
let fall_max : Float = Float::from_int(760)

///|
let jump_speed : Float = Float::from_int(680)

///|
let dash_cd_time : Float = 1.4

///|
let dash_time : Float = 0.2

///|
let dash_speed : Float = Float::from_int(600)

///|
let hook_cd_time : Float = 2.3

///|
let hook_time : Float = 0.72

///|
let hook_radius : Float = Float::from_int(240)

///|
let hook_kill_radius : Float = Float::from_int(100)

///|
let invuln_time : Float = 0.62

///|
let fire_cd_base : Float = 0.15

///|
let shot_speed : Float = Float::from_int(780)

///|
let enemy_shot_speed : Float = Float::from_int(320)

///|
let shot_life : Float = 1.4

///|
let base_scroll : Float = Float::from_int(250)

///|
let stage_scroll_bonus : Float = Float::from_int(28)

///|
let stage_goal_base : Float = Float::from_int(2200)

///|
let stage_goal_bonus : Float = Float::from_int(700)

///|
let spawn_start_x : Float = Float::from_int(screen_w) + 100.0

///|
let spawn_gap_min : Float = 120.0

///|
let spawn_gap_max : Float = 220.0

///|
let lane_count : Int = 3

///|
let lane_gap : Float = Float::from_int(120)

///|
let lane_top : Float = Float::from_int(282)

///|
let armor_max : Float = Float::from_int(100)

///|
let heat_max : Float = Float::from_int(100)

///|
let heat_drain_base : Float = Float::from_int(3)

///|
let heat_drain_dash : Float = Float::from_int(6)

///|
let heat_pickup : Float = Float::from_int(24)

///|
let armor_passive : Float = 0.38

///|
let stage_clear_wait : Float = 1.86

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
fn lane_y(lane : Int) -> Float {
  lane_top + Float::from_int(clampi(lane, 0, lane_count - 1)) * lane_gap
}

///|
fn bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 16, 30, 255)
}

///|
fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(14, 34, 56, 255)
}

///|
fn snow_col() -> @raylib.Color {
  @raylib.Color::new(230, 244, 255, 255)
}

///|
fn cyan() -> @raylib.Color {
  @raylib.Color::new(94, 238, 255, 255)
}

///|
fn pink() -> @raylib.Color {
  @raylib.Color::new(255, 114, 214, 255)
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
fn btn_jump_rect() -> (Float, Float, Float, Float) {
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
fn btn_hook_rect() -> (Float, Float, Float, Float) {
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
