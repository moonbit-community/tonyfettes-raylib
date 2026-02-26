///|
let screen_w : Int = 1280

///|
let screen_h : Int = 720

///|
let target_fps : Int = 120

///|
let hud_h : Int = 110

///|
let play_left : Float = 46.0

///|
let play_right : Float = Float::from_int(screen_w) - 46.0

///|
let play_top : Float = Float::from_int(hud_h) + 18.0

///|
let play_bottom : Float = Float::from_int(screen_h) - 26.0

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_stage_clear : Int = 2

///|
let state_game_over : Int = 3

///|
let tea_jasmine : Int = 0

///|
let tea_oolong : Int = 1

///|
let tea_puer : Int = 2

///|
let tea_matcha : Int = 3

///|
let tea_berry : Int = 4

///|
let tea_count : Int = 5

///|
let max_customers : Int = 24

///|
let max_sparks : Int = 860

///|
let max_rings : Int = 86

///|
let max_shadows : Int = 320

///|
let customer_slots : Int = 6

///|
let player_w : Float = 46.0

///|
let player_h : Float = 58.0

///|
let player_accel : Float = 1260.0

///|
let player_drag : Float = 3.4

///|
let player_max_speed : Float = 360.0

///|
let dash_cd_time : Float = 1.5

///|
let dash_time : Float = 0.2

///|
let dash_speed : Float = 620.0

///|
let interact_reach : Float = 84.0

///|
let serve_reach : Float = 104.0

///|
let brew_time_base : Float = 1.9

///|
let brew_time_min : Float = 1.1

///|
let stage_goal_base : Int = 1300

///|
let stage_goal_bonus : Int = 760

///|
let stage_time_base : Float = 72.0

///|
let stage_time_bonus : Float = 10.0

///|
let stage_clear_wait : Float = 1.9

///|
let spawn_cd_min : Float = 0.6

///|
let spawn_cd_max : Float = 2.2

///|
let reputation_max : Float = 100.0

///|
let focus_max : Float = 100.0

///|
let focus_drain : Float = 28.0

///|
let focus_regen : Float = 20.0

///|
let dash_focus_cost : Float = 14.0

///|
let wrong_serve_penalty : Float = 8.0

///|
let miss_penalty : Float = 12.0

///|
let stage_clear_bonus : Int = 340

///|
let kettle_x : Float = 164.0

///|
let kettle_y : Float = 248.0

///|
let brew_x : Float = 480.0

///|
let brew_y : Float = 258.0

///|
let counter_x : Float = 958.0

///|
let counter_y : Float = 250.0

///|
fn leaf_x() -> Float {
  270.0
}

///|
fn leaf_y(tea : Int) -> Float {
  182.0 + Float::from_int(clampi(tea, 0, tea_count - 1)) * 86.0
}

///|
fn customer_slot_pos(slot : Int) -> (Float, Float) {
  let s = clampi(slot, 0, customer_slots - 1)
  let row = s / 3
  let col = s % 3
  let x : Float = 822.0 + Float::from_int(col) * 140.0
  let y : Float = 424.0 + Float::from_int(row) * 134.0
  (x, y)
}

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
fn bg_top() -> @raylib.Color {
  @raylib.Color::new(14, 28, 52, 255)
}

///|
fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(40, 74, 112, 255)
}

///|
fn amber() -> @raylib.Color {
  @raylib.Color::new(255, 214, 126, 255)
}

///|
fn pink() -> @raylib.Color {
  @raylib.Color::new(255, 126, 198, 255)
}

///|
fn cyan() -> @raylib.Color {
  @raylib.Color::new(108, 236, 255, 255)
}

///|
fn jade() -> @raylib.Color {
  @raylib.Color::new(126, 244, 196, 255)
}

///|
fn reputation_col() -> @raylib.Color {
  @raylib.Color::new(255, 128, 166, 255)
}

///|
fn focus_col() -> @raylib.Color {
  @raylib.Color::new(124, 244, 204, 255)
}

///|
fn tea_name(t : Int) -> String {
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
fn tea_color(t : Int) -> @raylib.Color {
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
fn btn_size() -> Float {
  98.0
}

///|
fn btn_left_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (20.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
fn btn_right_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (130.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
fn btn_up_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (75.0, Float::from_int(screen_h) - s * 2.0 - 34.0, s, s)
}

///|
fn btn_down_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (75.0, Float::from_int(screen_h) - 20.0, s, s)
}

///|
fn btn_interact_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - 20.0,
    Float::from_int(screen_h) - s - 20.0,
    s,
    s,
  )
}

///|
fn btn_focus_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - 20.0,
    Float::from_int(screen_h) - s * 2.0 - 34.0,
    s,
    s,
  )
}

///|
fn btn_dash_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
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
  let h : Float = 88.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.65,
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
