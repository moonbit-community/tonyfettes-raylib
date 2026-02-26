///|
let screen_w : Int = 1280

///|
let screen_h : Int = 720

///|
let target_fps : Int = 120

///|
let hud_h : Int = 110

///|
let play_top : Float = Float::from_int(hud_h) + 14.0

///|
let play_bottom : Float = Float::from_int(screen_h) - 26.0

///|
let play_left : Float = 42.0

///|
let play_right : Float = Float::from_int(screen_w) - 42.0

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_stage_clear : Int = 2

///|
let state_game_over : Int = 3

///|
let obj_lantern : Int = 0

///|
let obj_bird : Int = 1

///|
let obj_storm : Int = 2

///|
let obj_orb : Int = 3

///|
let obj_koi : Int = 4

///|
let max_objs : Int = 360

///|
let max_sparks : Int = 900

///|
let max_halos : Int = 90

///|
let max_trails : Int = 320

///|
let kite_w : Float = 54.0

///|
let kite_h : Float = 64.0

///|
let kite_accel : Float = 1040.0

///|
let kite_drag : Float = 2.8

///|
let kite_max_speed : Float = 540.0

///|
let kite_rope_len_min : Float = 150.0

///|
let kite_rope_len_max : Float = 360.0

///|
let kite_rope_spring : Float = 9.0

///|
let kite_rope_damp : Float = 0.94

///|
let burst_cd_time : Float = 1.8

///|
let burst_radius : Float = 150.0

///|
let burst_cost : Float = 24.0

///|
let reel_energy_cost : Float = 22.0

///|
let reel_rate : Float = 120.0

///|
let rope_recover_rate : Float = 52.0

///|
let stage_time_base : Float = 62.0

///|
let stage_time_bonus : Float = 12.0

///|
let stage_goal_base : Int = 1300

///|
let stage_goal_bonus : Int = 720

///|
let calm_max : Float = 100.0

///|
let energy_max : Float = 100.0

///|
let calm_decay : Float = 3.2

///|
let energy_regen : Float = 16.0

///|
let wind_base : Float = 48.0

///|
let wind_stage_bonus : Float = 22.0

///|
let stage_clear_wait : Float = 2.0

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
fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
fn ease_out_cubic(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  Float::from_int(1) -
  (Float::from_int(1) - x) * (Float::from_int(1) - x) * (Float::from_int(1) - x)
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
fn point_in_rect(
  x : Float,
  y : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  x >= rx && x <= rx + rw && y >= ry && y <= ry + rh
}

///|
fn pointer_on_rect(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  if hold && point_in_rect(mx, my, rx, ry, rw, rh) {
    return true
  }

  for i = 0; i < touch_count; i = i + 1 {
    let p = @raylib.get_touch_position(i)
    if point_in_rect(p.x, p.y, rx, ry, rw, rh) {
      return true
    }
  }

  false
}

///|
fn sky_top() -> @raylib.Color {
  @raylib.Color::new(14, 28, 62, 255)
}

///|
fn sky_bottom() -> @raylib.Color {
  @raylib.Color::new(42, 82, 124, 255)
}

///|
fn cyan() -> @raylib.Color {
  @raylib.Color::new(96, 242, 255, 255)
}

///|
fn pink() -> @raylib.Color {
  @raylib.Color::new(255, 126, 198, 255)
}

///|
fn amber() -> @raylib.Color {
  @raylib.Color::new(255, 214, 126, 255)
}

///|
fn calm_col() -> @raylib.Color {
  @raylib.Color::new(255, 124, 162, 255)
}

///|
fn energy_col() -> @raylib.Color {
  @raylib.Color::new(122, 242, 196, 255)
}

///|
fn wind_col() -> @raylib.Color {
  @raylib.Color::new(148, 204, 255, 255)
}

///|
fn touch_btn_size() -> Float {
  98.0
}

///|
fn btn_left_rect() -> (Float, Float, Float, Float) {
  let s = touch_btn_size()
  (20.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
fn btn_right_rect() -> (Float, Float, Float, Float) {
  let s = touch_btn_size()
  (126.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
fn btn_up_rect() -> (Float, Float, Float, Float) {
  let s = touch_btn_size()
  (73.0, Float::from_int(screen_h) - s * 2.0 - 34.0, s, s)
}

///|
fn btn_down_rect() -> (Float, Float, Float, Float) {
  let s = touch_btn_size()
  (73.0, Float::from_int(screen_h) - 20.0, s, s)
}

///|
fn btn_burst_rect() -> (Float, Float, Float, Float) {
  let s = touch_btn_size()
  (
    Float::from_int(screen_w) - s - 20.0,
    Float::from_int(screen_h) - s - 20.0,
    s,
    s,
  )
}

///|
fn btn_reel_rect() -> (Float, Float, Float, Float) {
  let s = touch_btn_size()
  (
    Float::from_int(screen_w) - s * 2.0 - 34.0,
    Float::from_int(screen_h) - s - 20.0,
    s,
    s,
  )
}

///|
fn title_start_rect() -> (Float, Float, Float, Float) {
  let w : Float = 420.0
  let h : Float = 86.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.67,
    w,
    h,
  )
}

///|
fn retry_rect() -> (Float, Float, Float, Float) {
  let w : Float = 220.0
  let h : Float = 66.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.75,
    w,
    h,
  )
}
