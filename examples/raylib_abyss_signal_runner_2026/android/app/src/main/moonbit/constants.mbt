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
let obj_rock : Int = 0

///|
let obj_mine : Int = 1

///|
let obj_data : Int = 2

///|
let obj_oxygen : Int = 3

///|
let obj_current : Int = 4

///|
let obj_scrap : Int = 5

///|
let max_objs : Int = 420

///|
let max_particles : Int = 560

///|
let max_ripples : Int = 64

///|
let max_trails : Int = 180

///|
let player_r : Float = Float::from_int(22)

///|
let base_scroll : Float = Float::from_int(210)

///|
let stage_scroll_gain : Float = Float::from_int(24)

///|
let player_accel : Float = Float::from_int(920)

///|
let player_drag : Float = Float::from_int(2)

///|
let player_max_speed : Float = Float::from_int(360)

///|
let oxygen_drain : Float = Float::from_int(3)

///|
let oxygen_data_bonus : Float = Float::from_int(2)

///|
let oxygen_pickup : Float = Float::from_int(24)

///|
let sonar_cd_time : Float = 2.1

///|
let sonar_time : Float = 0.76

///|
let sonar_reveal_r : Float = Float::from_int(220)

///|
let sonar_destroy_r : Float = Float::from_int(70)

///|
let dash_cd_time : Float = 1.3

///|
let dash_time : Float = 0.19

///|
let dash_speed : Float = Float::from_int(560)

///|
let invuln_time : Float = 0.62

///|
let stage_base_goal : Float = Float::from_int(1900)

///|
let stage_goal_gain : Float = Float::from_int(620)

///|
let stage_clear_delay : Float = 1.8

///|
let spawn_start_y : Float = -120.0

///|
let spawn_spacing_min : Float = 70.0

///|
let spawn_spacing_max : Float = 170.0

///|
let cave_min_half : Float = Float::from_int(150)

///|
let cave_max_half : Float = Float::from_int(290)

///|
let cave_x_margin : Float = Float::from_int(84)

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
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
fn chance(p : Int) -> Bool {
  randi(0, 99) < p
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
fn ease_out_quad(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  1.0 - (1.0 - x) * (1.0 - x)
}

///|
fn cave_center(y : Float, t : Float) -> Float {
  let base = Float::from_int(screen_w / 2)
  let s0 = sinf(y * 0.004 + t * 0.6) * 170.0
  let s1 = sinf(y * 0.0022 + t * 1.1 + 1.4) * 80.0
  base + s0 + s1
}

///|
fn cave_half_width(y : Float, t : Float, stage : Int) -> Float {
  let wobble = sinf(y * 0.0033 + t * 0.7 + 0.9) * 62.0
  let shrink = Float::from_int(stage - 1) * 8.0
  clampf(cave_max_half + wobble - shrink, cave_min_half, cave_max_half)
}

///|
fn bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 14, 28, 255)
}

///|
fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(7, 28, 44, 255)
}

///|
fn cave_glow() -> @raylib.Color {
  @raylib.Color::new(82, 222, 255, 255)
}

///|
fn hazard_col() -> @raylib.Color {
  @raylib.Color::new(255, 98, 158, 255)
}

///|
fn data_col() -> @raylib.Color {
  @raylib.Color::new(146, 255, 190, 255)
}

///|
fn oxygen_col() -> @raylib.Color {
  @raylib.Color::new(146, 218, 255, 255)
}

///|
fn phase_col() -> @raylib.Color {
  @raylib.Color::new(186, 146, 255, 255)
}

///|
fn hp_col() -> @raylib.Color {
  @raylib.Color::new(255, 116, 156, 255)
}

///|
fn btn_size() -> Float {
  Float::from_int(102)
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
fn btn_sonar_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}
